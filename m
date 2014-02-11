Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50003 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752716AbaBKRMj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Feb 2014 12:12:39 -0500
Date: Tue, 11 Feb 2014 12:12:37 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Rashika Kheria <rashika.kheria@gmail.com>
Cc: linux-kernel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, josh@joshtriplett.org
Subject: Re: [PATCH 13/13] net: Mark functions as static in
 net/sunrpc/svc_xprt.c
Message-ID: <20140211171237.GF19599@fieldses.org>
References: <6f029c895035908595957fb16ab445c82793c77d.1391888654.git.rashika.kheria@gmail.com>
 <259f3dc38d7115eccf3aaa2aa7de2414a47f90a2.1391888654.git.rashika.kheria@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <259f3dc38d7115eccf3aaa2aa7de2414a47f90a2.1391888654.git.rashika.kheria@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Feb 09, 2014 at 01:40:54AM +0530, Rashika Kheria wrote:
> Mark functions as static in net/sunrpc/svc_xprt.c because they are not
> used outside this file.
> 
> This eliminates the following warning in net/sunrpc/svc_xprt.c:
> net/sunrpc/svc_xprt.c:574:5: warning: no previous prototype for ‘svc_alloc_arg’ [-Wmissing-prototypes]
> net/sunrpc/svc_xprt.c:615:18: warning: no previous prototype for ‘svc_get_next_xprt’ [-Wmissing-prototypes]
> net/sunrpc/svc_xprt.c:694:6: warning: no previous prototype for ‘svc_add_new_temp_xprt’ [-Wmissing-prototypes]

Thanks, applying.--b.

> 
> Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
> ---
>  net/sunrpc/svc_xprt.c |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index 80a6640..06c6ff0 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -571,7 +571,7 @@ static void svc_check_conn_limits(struct svc_serv *serv)
>  	}
>  }
>  
> -int svc_alloc_arg(struct svc_rqst *rqstp)
> +static int svc_alloc_arg(struct svc_rqst *rqstp)
>  {
>  	struct svc_serv *serv = rqstp->rq_server;
>  	struct xdr_buf *arg;
> @@ -612,7 +612,7 @@ int svc_alloc_arg(struct svc_rqst *rqstp)
>  	return 0;
>  }
>  
> -struct svc_xprt *svc_get_next_xprt(struct svc_rqst *rqstp, long timeout)
> +static struct svc_xprt *svc_get_next_xprt(struct svc_rqst *rqstp, long timeout)
>  {
>  	struct svc_xprt *xprt;
>  	struct svc_pool		*pool = rqstp->rq_pool;
> @@ -691,7 +691,7 @@ struct svc_xprt *svc_get_next_xprt(struct svc_rqst *rqstp, long timeout)
>  	return xprt;
>  }
>  
> -void svc_add_new_temp_xprt(struct svc_serv *serv, struct svc_xprt *newxpt)
> +static void svc_add_new_temp_xprt(struct svc_serv *serv, struct svc_xprt *newxpt)
>  {
>  	spin_lock_bh(&serv->sv_lock);
>  	set_bit(XPT_TEMP, &newxpt->xpt_flags);
> -- 
> 1.7.9.5
> 
