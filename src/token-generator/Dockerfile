FROM ubuntu AS base
RUN apt update && apt install curl -y && \
    latest_version=$(curl -s https://api.github.com/repos/mike-engel/jwt-cli/releases/latest | grep tag_name | cut -d '"' -f 4) && \
    curl -L -o jwt-cli https://github.com/mike-engel/jwt-cli/releases/download/$latest_version/jwt-linux.tar.gz && \
    tar -xvf jwt-cli && \
    mv jwt /usr/local/bin/jwt && \
    chmod +x /usr/local/bin/jwt
# we install latest release from https://github.com/mike-engel/jwt-cli/releases
# RUN latest_version=$(curl -s https://api.github.com/repos/mike-engel/jwt-cli/releases/latest | grep tag_name | cut -d '"' -f 4) && \
#     curl -L -o jwt-cli https://github.com/mike-engel/jwt-cli/releases/download/$latest_version/jwt-linux.tar.gz && \
#     tar -xvf jwt-cli && \
#     mv jwt /usr/local/bin/jwt && \
#     chmod +x /usr/local/bin/jwt

FROM debian:bookworm-slim AS runner
COPY --from=base /usr/local/bin/jwt /usr/local/bin/jwt