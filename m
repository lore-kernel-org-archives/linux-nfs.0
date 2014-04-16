Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f49.google.com ([209.85.192.49]:60078 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161621AbaDPOx1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Apr 2014 10:53:27 -0400
Received: by mail-qg0-f49.google.com with SMTP id e89so3508113qgf.8
        for <linux-nfs@vger.kernel.org>; Wed, 16 Apr 2014 07:53:27 -0700 (PDT)
Date: Wed, 16 Apr 2014 10:47:02 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: NeilBrown <neilb@suse.de>
Cc: linux-mm@kvack.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, xfs@oss.sgi.com, netdev@vger.kernel.org
Subject: Re: [PATCH 05/19] SUNRPC: track whether a request is coming from a
 loop-back interface.
Message-ID: <20140416104702.264cde48@tlielax.poochiereds.net>
In-Reply-To: <20140416040336.10604.14822.stgit@notabene.brown>
References: <20140416033623.10604.69237.stgit@notabene.brown>
	<20140416040336.10604.14822.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 16 Apr 2014 14:03:36 +1000
NeilBrown <neilb@suse.de> wrote:

> If an incoming NFS request is coming from the local host, then
> nfsd will need to perform some special handling.  So detect that
> possibility and make the source visible in rq_local.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> ---
>  include/linux/sunrpc/svc.h      |    1 +
>  include/linux/sunrpc/svc_xprt.h |    1 +
>  net/sunrpc/svcsock.c            |   10 ++++++++++
>  3 files changed, 12 insertions(+)
> 
> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
> index 04e763221246..a0dbbd1e00e9 100644
> --- a/include/linux/sunrpc/svc.h
> +++ b/include/linux/sunrpc/svc.h
> @@ -254,6 +254,7 @@ struct svc_rqst {
>  	u32			rq_prot;	/* IP protocol */
>  	unsigned short
>  				rq_secure  : 1;	/* secure port */
> +	unsigned short		rq_local   : 1;	/* local request */
>  
>  	void *			rq_argp;	/* decoded arguments */
>  	void *			rq_resp;	/* xdr'd results */
> diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
> index b05963f09ebf..b99bdfb0fcf9 100644
> --- a/include/linux/sunrpc/svc_xprt.h
> +++ b/include/linux/sunrpc/svc_xprt.h
> @@ -63,6 +63,7 @@ struct svc_xprt {
>  #define	XPT_DETACHED	10		/* detached from tempsocks list */
>  #define XPT_LISTENER	11		/* listening endpoint */
>  #define XPT_CACHE_AUTH	12		/* cache auth info */
> +#define XPT_LOCAL	13		/* connection from loopback interface */
>  
>  	struct svc_serv		*xpt_server;	/* service for transport */
>  	atomic_t    	    	xpt_reserved;	/* space on outq that is rsvd */
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index b6e59f0a9475..193115fe968c 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -811,6 +811,7 @@ static struct svc_xprt *svc_tcp_accept(struct svc_xprt *xprt)
>  	struct socket	*newsock;
>  	struct svc_sock	*newsvsk;
>  	int		err, slen;
> +	struct dst_entry *dst;
>  	RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
>  
>  	dprintk("svc: tcp_accept %p sock %p\n", svsk, sock);
> @@ -867,6 +868,14 @@ static struct svc_xprt *svc_tcp_accept(struct svc_xprt *xprt)
>  	}
>  	svc_xprt_set_local(&newsvsk->sk_xprt, sin, slen);
>  
> +	clear_bit(XPT_LOCAL, &newsvsk->sk_xprt.xpt_flags);
> +	rcu_read_lock();
> +	dst = rcu_dereference(newsock->sk->sk_dst_cache);
> +	if (dst && dst->dev &&
> +	    (dst->dev->features & NETIF_F_LOOPBACK))
> +		set_bit(XPT_LOCAL, &newsvsk->sk_xprt.xpt_flags);
> +	rcu_read_unlock();
> +

In the use-case you describe, the client is unlikely to have mounted
"localhost", but is more likely to be mounting a floating address in
the cluster.

Will this flag end up being set in such a situation? It looks like
NETIF_F_LOOPBACK isn't set on all adapters -- mostly on "lo" and a few
others that support MAC-LOOPBACK.


>  	if (serv->sv_stats)
>  		serv->sv_stats->nettcpconn++;
>  
> @@ -1112,6 +1121,7 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
>  
>  	rqstp->rq_xprt_ctxt   = NULL;
>  	rqstp->rq_prot	      = IPPROTO_TCP;
> +	rqstp->rq_local	      = !!test_bit(XPT_LOCAL, &svsk->sk_xprt.xpt_flags);
>  
>  	p = (__be32 *)rqstp->rq_arg.head[0].iov_base;
>  	calldir = p[1];
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Jeff Layton <jlayton@poochiereds.net>
