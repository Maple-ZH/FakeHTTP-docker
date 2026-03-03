# --- 阶段 1: 编译阶段 ---
FROM alpine:latest AS builder

# 安装编译所需的依赖
# FakeHTTP 依赖 libnetfilter_queue, libnfnetlink, libmnl
RUN apk add --no-cache \
    build-base \
    gcc \
    make \
    musl-dev \
    libnetfilter_queue-dev \
    libnfnetlink-dev \
    libmnl-dev \
    linux-headers

# 设置工作目录
WORKDIR /app

# 复制源码
COPY . .

# 编译项目 (使用静态链接或常规链接)
RUN make

# --- 阶段 2: 运行阶段 ---
FROM alpine:latest

# 安装运行所需的运行时库 (FakeHTTP 需要 netfilter 相关的库)
RUN apk add --no-cache \
    libnetfilter_queue \
    libnfnetlink \
    libmnl \
    iptables \
    ca-certificates

# 从编译阶段拷贝二进制文件
COPY --from=builder /app/build/fakehttp /usr/local/bin/fakehttp

# 赋予执行权限
RUN chmod +x /usr/local/bin/fakehttp

# FakeHTTP 通常需要修改 netfilter 规则，所以需要以 root 或具备相应能力运行
# 默认入口
ENTRYPOINT ["fakehttp"]
