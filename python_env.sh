# https://jacobian.org/2019/nov/11/python-environment-2020/#atom-entries

sudo yum install \
  zlib-devel \
  bzip2 \
  bzip2-devel \
  readline-devel \
  sqlite \
  sqlite-devel \
  openssl-devel \
  xz \
  xz-devel \
  libffi-devel

# install pyenv
PROJ=pyenv-installer
SCRIPT_URL=https://github.com/pyenv/$PROJ/raw/master/bin/$PROJ
curl -L $SCRIPT_URL | bash# setup
export PATH="~/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

pyenv install 3.8.0
# make it global
pyenv global 3.8.0

# install pipx
python -m pip install pipx
pipx install visidata
pipx inject visidata pandas

pipx install poetry==1.0.0b4

## DEPLOYMENT
FROM python:3.7

WORKDIR /code

RUN pip install -U pip && \
    pip install poetry

COPY poetry.lock pyproject.toml ./
COPY src/ ./src/

# Install poetry globally - with the current version of
# poetry, there is a known issue where poetry config will
# not create config.toml: https://github.com/sdispater/poetry/issues/1179
# As such, we create it ourselves.
RUN mkdir -p ${HOME}/.config/pypoetry/ && \
    touch ${HOME}/.config/pypoetry/config.toml && \
    poetry config settings.virtualenvs.create false && \

# Set PRODUCTION to anything to invoke installation with --no-dev
ARG PRODUCTION
RUN poetry install ${PRODUCTION:+--no-dev}
