Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:58977 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756500Ab1INMMd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Sep 2011 08:12:33 -0400
Date: Wed, 14 Sep 2011 08:12:25 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mitsuo Hayasaka <mitsuo.hayasaka.hu@hitachi.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        yrl.pp-manager.tt@hitachi.com
Subject: Re: [PATCH net-next-2.6 ] Fix overflow of socket buffer in sunrpc
Message-ID: <20110914121225.GA3435@fieldses.org>
References: <20110902034138.22595.9759.stgit@ltc219.sdl.hitachi.co.jp>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110902034138.22595.9759.stgit@ltc219.sdl.hitachi.co.jp>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Sep 02, 2011 at 12:41:38PM +0900, Mitsuo Hayasaka wrote:
> The sk_sndbuf and sk_rcvbuf fields of struct sock are sizes of send and
> receive socket buffers respectively, and are defined as integer.
> The sunrpc which is used in NFSD and any other applications

I'd call those "kernel subsystems" or "in-kernel applications"--it needs
to be clear that you're not talking about userspace applications.

> can change them
> via svc_sock_setbufsize(). It, however, sets them as unsigned integer and
> may cause overflow of integer. This leads to a degradation of networking
> capability.

Tracing through the callers, actually I believe they all set this to a
constant, with the single exception of nfsd, which allows the size to be
configured; but write_maxlksize already limits it to NFSSVC_MAXBLKSIZE.

So this patch looks unnecessary to me, unless I'm missing something.

If you can argue that it would be safer to check here as well, I might
consider that, but please:

	- do make that argument in detail;
	- especially, convince me that *this* is the right place for the
	  check; and
	- also double-check my audit of the callers.

And include all that in the changelog.

Dropping for now.

--b.

> 
> This patch adds integer-overflow check into svc_sock_setbufsize() before
> both fields are set, and limits their maximum sizes to INT_MAX.
> 
> Signed-off-by: Mitsuo Hayasaka <mitsuo.hayasaka.hu@hitachi.com>
> Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: "J. Bruce Fields" <bfields@fieldses.org>
> Cc: Neil Brown <neilb@suse.de>
> Cc: "David S. Miller" <davem@davemloft.net>
> ---
> 
>  net/sunrpc/svcsock.c |    6 ++++++
>  1 files changed, 6 insertions(+), 0 deletions(-)
> 
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index 767d494..bd66775 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -54,6 +54,7 @@
>  #include "sunrpc.h"
>  
>  #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
> +#define MAX_SKBUFSIZ	INT_MAX
>  
>  
>  static struct svc_sock *svc_setup_socket(struct svc_serv *, struct socket *,
> @@ -435,6 +436,11 @@ static void svc_sock_setbufsize(struct socket *sock, unsigned int snd,
>  	 * on not having CAP_SYS_RESOURCE or similar, we go direct...
>  	 * DaveM said I could!
>  	 */
> +	if (snd > MAX_SKBUFSIZ/2)
> +		snd = MAX_SKBUFSIZ/2;
> +	if (rcv > MAX_SKBUFSIZ/2)
> +		rcv = MAX_SKBUFSIZ/2;
> +
>  	lock_sock(sock->sk);
>  	sock->sk->sk_sndbuf = snd * 2;
>  	sock->sk->sk_rcvbuf = rcv * 2;
> 
