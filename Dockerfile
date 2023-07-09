FROM debian:stable-slim

# 最低限必要なパッケージ
RUN apt update && \
    apt install -y  \
    curl \
    unzip \
    gcc \
    git \
    musl-dev \
    nodejs \
    locales \
    python3

# マルチバイト文字をまともに扱うための設定
RUN sed -i -E 's/# (en_US.UTF-8)/\1/' /etc/locale.gen && \
    locale-gen
ENV LANG="en_US.UTF-8" LANGUAGE="en_US:ja" LC_ALL="en_US.UTF-8"
# RUN dpkg --audit

# install dein.vim
# dein.vimインストール時/root/.comfig/nvim/init.vimの書き込みを行うため権限操作
COPY nvim /root/.config/nvim
RUN chmod 777 /root/.config
RUN chmod -R 777 /root/.config/nvim

# Linuxでのroot:root問題対策
RUN chmod 777 /root
RUN mkdir /root/.local/
RUN chmod 777 /root/.local/
# ENV APPIMAGE_EXTRACT_AND_RUN 1
RUN curl -L --create-dirs https://github.com/neovim/neovim/releases/latest/download/nvim.appimage -o /root/.appimage/nvim.appimage && \
    chmod u+x /root/.appimage/nvim.appimage
    # /root/.appimage/nvim.appimage && \
    # ln -s /root/.appimage/nvim.appimage /root/.local/bin/nvim

# deno_install
RUN curl -fsSL https://deno.land/x/install/install.sh | bash
ENV DENO_INSTALL /root/.deno
ENV PATH $DENO_INSTALL/bin:$PATH

RUN chmod 777 /root/.appimage
RUN /root/.appimage/nvim.appimage --appimage-extract
# RUN /root/.appimage/nvim.appimage +:UpdateRemotePlugins +qa
COPY nvim.sh /root
RUN echo $PATH
RUN ln -s "/squashfs-root/usr/bin/nvim" /usr/bin/nvim && \
    chmod u+x /root/nvim.sh && \
    /root/nvim.sh +qa
RUN chmod 777 /root/nvim.sh
RUN chmod 777 /root/.local/
RUN chmod 777 /root/.local/share
RUN chmod -R 777 /root/.local/share/nvim
RUN chmod 777 /root/.local/state
RUN chmod -R 777 /root/.local/state/nvim
RUN chmod 777 /root/.cache
RUN chmod -R 777 /root/.cache/dein

ENTRYPOINT ["/root/nvim.sh"]
