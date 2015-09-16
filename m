Return-Path: <trond.myklebust@primarydata.com>
MIME-Version: 1.0
In-Reply-To: <d858d15746eeb224f4fb27554771e14b58f31306.1442411712.git.bcodding@redhat.com>
References: <d858d15746eeb224f4fb27554771e14b58f31306.1442411712.git.bcodding@redhat.com>
Date: Wed, 16 Sep 2015 10:05:03 -0400
Message-ID: <CAHQdGtRQ9RZNrJeYBykQLx1FsWenebQa35MBEHUiCY9EVedwXw@mail.gmail.com>
Subject: Re: [PATCH] SUNRPC: Fix transport reset race while TCP is connecting
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 16, 2015 at 9:58 AM, Benjamin Coddington
<bcodding@redhat.com> wrote:
> After a network segmentation that times out the socket, we can get stuck in
> a loop where the client repeatedly sends a SYN, then a RST, with the result
> that the client will never successfully reconnect to the server.
>
> When there's a need to re-establish a TCP connection, the scheduled
> connect_worker does xs_tcp_setup_socket(), which sends a SYN, then
> immediately wakes the waiting task to call_connect_status with a status of
> EAGAIN, which proceeds to xprt_connect() and kernel_sock_shutdown() which
> will send a RST.
>
> Fix this loop by deferring xprt_clear_connecting() until the TCP state
> change of ESTALISHED or CLOSED, thereby ensuring that we do not race into
> xs_connect() while waiting for SYN,ACK from the server.
>
> Fixes: 099392048c (SUNRPC: Prevent SYN+SYNACK+RST storms)
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> ---
>  net/sunrpc/xprtsock.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 7be90bc..6df51df 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -1450,6 +1450,7 @@ static void xs_tcp_state_change(struct sock *sk)
>         switch (sk->sk_state) {
>         case TCP_ESTABLISHED:
>                 spin_lock(&xprt->transport_lock);
> +               xprt_clear_connecting(xprt);
>                 if (!xprt_test_and_set_connected(xprt)) {
>                         struct sock_xprt *transport = container_of(xprt,
>                                         struct sock_xprt, xprt);
> @@ -1496,6 +1497,7 @@ static void xs_tcp_state_change(struct sock *sk)
>                 smp_mb__after_atomic();
>                 break;
>         case TCP_CLOSE:
> +               xprt_clear_connecting(xprt);
>                 xs_sock_mark_closed(xprt);
>         }
>   out:
> @@ -2237,10 +2239,10 @@ static void xs_tcp_setup_socket(struct work_struct *work)
>                 xs_tcp_force_close(xprt);
>                 break;
>         case 0:
> -       case -EINPROGRESS:
> +               xprt_clear_connecting(xprt);
>         case -EALREADY:
> +       case -EINPROGRESS:
>                 xprt_unlock_connect(xprt, transport);
> -               xprt_clear_connecting(xprt);
>                 return;
>         case -EINVAL:
>                 /* Happens, for instance, if the user specified a link
>

This introduces races. The call to xprt_clear_connecting in TCP_CLOSE
can trigger pretty much at any time, and so could interfere with a
subsequent connection attempt.

I have an alternative patch which addresses this problem and which is
undergoing testing.
