
FROM alpine:latest



# マルチバイト文字をまともに扱うための設定
ENV LANG="en_US.UTF-8" LANGUAGE="en_US:ja" LC_ALL="en_US.UTF-8"

# 最低限必要なパッケージ
RUN apk update && \
    apk upgrade && \
    apk add --no-cache \
    build-base \
    curl \
    gcc \
    git \
    libxml2-dev \
    libxslt-dev \
    linux-headers \
    musl-dev\
    neovim \
    nodejs \
    npm \
    # python-dev \
    py-pip \
    python3-dev \
    py3-pip \
    # ruby \
    # ruby-dev \
    && \
    rm -rf /var/cache/apk/*

RUN pip3 install --upgrade pip pynvim
# RUN gem install -N \
#     etc \
#     json \
#     rubocop \
#     rubocop-performance \
#     rubocop-rails \
#     rubocop-rspec \
#     solargraph

# install dein.vim
# dein.vimインストール時/root/.comfig/nvim/init.vimの書き込みを行うため権限操作
COPY nvim /root/.config/nvim
RUN chmod 777 /root/.config
RUN chmod -R 777 /root/.config/nvim
# --overwrite-config -> init.vimの上書きを許可
# echo "1" -> インストーラーのselect入力に対して1を選択。（dein.vimの向き先の選択。/root/.cacheを指定）
RUN echo -e "1\n2" | sh -c "$(curl -fsSL https://raw.githubusercontent.com/Shougo/dein-installer.vim/master/installer.sh) --overwrite-config"
RUN cat /root/.config/nvim/init.vim.pre-dein-vim >> /root/.config/nvim/init.vim
RUN nvim +:UpdateRemotePlugins +qa

# Linuxでのroot:root問題対策
RUN chmod 777 /root

RUN chmod 777 /root/.cache
RUN chmod -R 777 /root/.cache/dein

RUN chmod 777 /root/.local/
RUN chmod 777 /root/.local/share
RUN chmod -R 777 /root/.local/share/nvim
RUN chmod 777 /root/.local/state
RUN chmod -R 777 /root/.local/state/nvim

ENTRYPOINT ["nvim"]
