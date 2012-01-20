Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:13978 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751344Ab2ATVk2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Jan 2012 16:40:28 -0500
Message-ID: <1327095610.9266.1.camel@lade.trondhjem.org>
Subject: Re: [PATCH RFC] SUNPRC: remove marking service temporary sockets
 with XPT_CHNGBUF
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Fri, 20 Jan 2012 16:40:10 -0500
In-Reply-To: <20120120125243.7733.81374.stgit@localhost6.localdomain6>
References: <20120120125243.7733.81374.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2012-01-20 at 16:55 +0400, Stanislav Kinsbursky wrote: 
> This is a cleanup patch.
> Service temporary sockets can be TCP or RDMA only. But XPT_CHNGBUF service
> socket flag is checked only for UDP sockets on receive.
> Thus (if I don't miss something non-obvious) this bit raising for temporary
> sockets can be removed.
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

I'm assuming that Bruce will prefer to carry this, since it is
completely orthogonal to the net namespace patchsets.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

