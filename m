Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:38824 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341AbcAFQtZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jan 2016 11:49:25 -0500
Received: by mail-wm0-f53.google.com with SMTP id b14so84126179wmb.1
        for <linux-nfs@vger.kernel.org>; Wed, 06 Jan 2016 08:49:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1452098339-3161-1-git-send-email-trond.myklebust@primarydata.com>
References: <1452098339-3161-1-git-send-email-trond.myklebust@primarydata.com>
Date: Wed, 6 Jan 2016 11:49:24 -0500
Message-ID: <CANn89iJOo+L5GO87Qrt2imWNFr-A0Q4QnPksBaC0x58=sfZUqg@mail.gmail.com>
Subject: Re: [PATCH] SUNRPC: Fixup socket wait for memory
From: Eric Dumazet <edumazet@google.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond, sorry for the mess :(

On Wed, Jan 6, 2016 at 11:38 AM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> We're seeing hangs in the NFS client code, with loops of the form:
>
>
...

>  static void xs_write_space(struct sock *sk)
>  {
>         struct socket *sock;

It seems you no longer need this @sock variable

> +       struct socket_wq *wq;
>         struct rpc_xprt *xprt;
>
>         if (unlikely(!(sock = sk->sk_socket)))

if (!sk->sk_socket)
        return;

Maybe you don't even need to test sk_socket, but probably better not
leave it for this fix.

> @@ -1618,10 +1608,14 @@ static void xs_write_space(struct sock *sk)
>
>         if (unlikely(!(xprt = xprt_from_sock(sk))))
>                 return;
> -       if (test_and_clear_bit(SOCKWQ_ASYNC_NOSPACE, &sock->flags) == 0)
> -               return;
> +       rcu_read_lock();
> +       wq = rcu_dereference(sk->sk_wq);
> +       if (!wq || test_and_clear_bit(SOCKWQ_ASYNC_NOSPACE, &wq->flags) == 0)
> +               goto out;
>
>         xprt_write_space(xprt);
> +out:
> +       rcu_read_unlock();
>
