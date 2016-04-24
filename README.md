# Ralitobu.Plug

A [Plug](https://github.com/elixir-lang/plug) for [Ralitobu](https://github.com/asaaki/ralitobu)

## Usage

```elixir
# bucketize on remote IP, allow 10 req/s
plug Ralitobu.Plug, on_ip: true, limit: 10, lifetime: 1_000
```

## Example

```
$ curl -i http://localhost:4000/

HTTP/1.1 200 OK
server: Cowboy
date: Sun, 24 Apr 2016 12:44:37 GMT
content-length: 12
cache-control: max-age=0, private, must-revalidate
ratelimit-limit: 3
ratelimit-remaining: 0
ratelimit-reset: 2

hello world
```

```
$ curl -i http://localhost:4000/

HTTP/1.1 429 Too Many Requests
server: Cowboy
date: Sun, 24 Apr 2016 12:44:38 GMT
content-length: 64
cache-control: max-age=0, private, must-revalidate
ratelimit-limit: 3
ratelimit-remaining: 0
ratelimit-reset: 1
retry-after: 1
content-type: application/json; charset=utf-8

{"status": 429, "error": "Too Many Requests", "retry_after": 1}
```
