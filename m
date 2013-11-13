Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38794 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755687Ab3KMP5E (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Nov 2013 10:57:04 -0500
Date: Wed, 13 Nov 2013 10:56:58 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Weng Meiling <wengmeiling.weng@huawei.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com, davem@davemloft.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Li Zefan <lizefan@huawei.com>
Subject: Re: [PATCH] svcrpc: remove the unnecessary evaluation
Message-ID: <20131113155658.GH28033@fieldses.org>
References: <52786417.6090707@huawei.com>
 <527C9160.3070808@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <527C9160.3070808@huawei.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 08, 2013 at 03:23:12PM +0800, Weng Meiling wrote:
> 
> From: Weng Meiling <wengmeiling.weng@huawei.com>

Huh.  Looks like that was introduced with "[PATCH] knfsd: make sure
svc_process call the correct pg_authenticate for multi-service port" in
2005.  OK!  Applied.

--b.

> 
> Signed-off-by: Weng Meiling <wengmeiling.weng@huawei.com>
> ---
>  net/sunrpc/svc.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index b974571..e7fbe36 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -1104,8 +1104,6 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
>  	rqstp->rq_vers = vers = svc_getnl(argv);	/* version number */
>  	rqstp->rq_proc = proc = svc_getnl(argv);	/* procedure number */
> 
> -	progp = serv->sv_program;
> -
>  	for (progp = serv->sv_program; progp; progp = progp->pg_next)
>  		if (prog == progp->pg_prog)
>  			break;
> -- 
> 1.8.3.1
> 
> 
> 
> 
