Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43860 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751795Ab2ATVqv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Jan 2012 16:46:51 -0500
Date: Fri, 20 Jan 2012 16:46:48 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org, xemul@parallels.com,
        neilb@suse.de, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, davem@davemloft.net, devel@openvz.org
Subject: Re: [PATCH RFC] SUNPRC: remove marking service temporary sockets
 with XPT_CHNGBUF
Message-ID: <20120120214648.GB17859@fieldses.org>
References: <20120120125243.7733.81374.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120120125243.7733.81374.stgit@localhost6.localdomain6>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 20, 2012 at 04:55:39PM +0400, Stanislav Kinsbursky wrote:
> This is a cleanup patch.
> Service temporary sockets can be TCP or RDMA only. But XPT_CHNGBUF service
> socket flag is checked only for UDP sockets on receive.
> Thus (if I don't miss something non-obvious) this bit raising for temporary
> sockets can be removed.

Yes, I believe that's correct, it's leftover cleanup from
9660439861aa8dbd5e2b8087f33e20760c2c9afc "svcrpc: take advantage of tcp
autotuning".

I'll ignore the "RFC" marking and apply unless you tell me otherwise....

--b.

> 
> Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
> 
> ---
>  net/sunrpc/svcsock.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index e8af0c9..2867249 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -1381,8 +1381,6 @@ void svc_sock_update_bufs(struct svc_serv *serv)
>  	spin_lock_bh(&serv->sv_lock);
>  	list_for_each_entry(svsk, &serv->sv_permsocks, sk_xprt.xpt_list)
>  		set_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags);
> -	list_for_each_entry(svsk, &serv->sv_tempsocks, sk_xprt.xpt_list)
> -		set_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags);
>  	spin_unlock_bh(&serv->sv_lock);
>  }
>  EXPORT_SYMBOL_GPL(svc_sock_update_bufs);
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
