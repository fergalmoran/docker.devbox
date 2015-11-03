FROM ubuntu:latest

RUN apt-get update -y
RUN apt-get install -y mercurial \
    git \
    python \
    curl \
    vim \
    vim-nox \
    vim-scripts \
    strace \
    diffstat \
    pkg-config \
    cmake \
    build-essential \
    tcpdump \
    screen \
    python-setuptools \
    exuberant-ctags \
    build-essential \
    cmake \
    python-dev

# Setup home environment
RUN useradd dev
RUN gpasswd -a dev sudo
RUN mkdir /home/dev && chown -R dev: /home/dev
ENV PATH /home/dev/bin:$PATH
ENV HOME /home/dev
ENV HOMESRC ${HOME}/src/
ENV HOMEBIN ${HOME}/bin/

RUN mkdir -p ${HOMESRC} && \
    mkdir -p ${HOMEBIN}

#Setup pip
RUN easy_install pip \
    && pip install virtualenv virtualenvwrapper

#Setup node
ENV NODE_VERSION v5.0.0
ENV NODE_FILENAME node-${NODE_VERSION}-linux-x64
ENV NODE_TARNAME ${NODE_FILENAME}.tar.gz
ENV NODE_URL https://nodejs.org/dist/${NODE_VERSION}/${NODE_TARNAME}
RUN echo ${NODE_URL}
RUN curl -L ${NODE_URL} | tar -C ${HOMESRC} -xzf - \
    && ln -s ${HOMESRC}/${NODE_FILENAME} ${HOMESRC}/nodejs \
    && ln -s ${HOMESRC}/nodejs/bin/* ${HOMEBIN}/


#Set up git
RUN git clone https://github.com/fergalmoran/vimfiles.git ${HOME}/.vim \
    && ln -s ${HOME}/.vim/.vimrc ${HOME}/.vimrc \
    && cd ${HOME}/.vim \
    && git submodule update --init --recursive

RUN printf 'y' | vim +BundleInstall +qall \
    && echo "install YouCompleteMe" \
    && cd ${HOME}/.vim/bundle/YouCompleteMe \
    && ./install.py 

#Set up bash
RUN git clone https://github.com/fergalmoran/dotfiles.git ${HOME}/dotfiles\
    && cd ${HOME}/dotfiles \
    && ./install.sh

# Create a shared data volume
# We need to create an empty file, otherwise the volume will
# belong to root.
# This is probably a Docker bug.
RUN mkdir /var/shared/
RUN touch /var/shared/placeholder
RUN chown -R dev:dev /var/shared
VOLUME /var/shared

WORKDIR /home/dev
ENV HOME /home/dev

# Link in shared parts of the home directory
RUN ln -s /var/shared/.ssh
RUN ln -s /var/shared/.bash_history
RUN ln -s /var/shared/.maintainercfg

RUN chown -R dev: /home/dev
USER dev
ENV TERM xterm-256color

