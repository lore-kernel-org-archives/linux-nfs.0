Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:37899 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750877AbbJ0VQu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Oct 2015 17:16:50 -0400
Date: Tue, 27 Oct 2015 17:16:48 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stefan Hajnoczi <stefanha@redhat.com>
Cc: linux-nfs@vger.kernel.org, Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH] SUNRPC: drop stale comment in svc_setup_socket()
Message-ID: <20151027211648.GE14022@fieldses.org>
References: <1445941410-28270-1-git-send-email-stefanha@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1445941410-28270-1-git-send-email-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 27, 2015 at 10:23:30AM +0000, Stefan Hajnoczi wrote:
> Since 9660439861aa8dbd5e2b8087f33e20760c2c9afc ("svcrpc: take advantage
> of tcp autotuning") the svc_setup_socket() function does set the send
> and receive buffer sizes so the comment is out-of-date:

Hm, looks like it did it before too, just in svc_tcp_init instead.
Anyway, agreed that the comment doesn't look like much help, applying
your patch with a shorter changelog--thanks.

--b.

> 
>   /* initialise setting must have enough space to
>    * receive and respond to one request.
>    */
>   svc_sock_setbufsize(svsk->sk_sock, 4 * serv->sv_max_mesg,
>                                      4 * serv->sv_max_mesg);
> 
> Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
> ---
>  net/sunrpc/svcsock.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index 0c81202..c7157eb 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -1367,7 +1367,6 @@ EXPORT_SYMBOL_GPL(svc_sock_update_bufs);
>  
>  /*
>   * Initialize socket for RPC use and create svc_sock struct
> - * XXX: May want to setsockopt SO_SNDBUF and SO_RCVBUF.
>   */
>  static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
>  						struct socket *sock,
> -- 
> 2.4.3
