Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:19671 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752314AbdGMRxe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Jul 2017 13:53:34 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH][net-next] svcrdma: fix an incorrect check on -E2BIG and -EINVAL
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170713175115.9044-1-colin.king@canonical.com>
Date: Thu, 13 Jul 2017 13:53:10 -0400
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        "David S . Miller" <davem@davemloft.net>,
        Sagi Grimberg <sagi@grimberg.me>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
        linux-kernel@vger.kernel.org
Message-Id: <1D2A804A-9BEC-4D34-AF01-960F35E297E7@oracle.com>
References: <20170713175115.9044-1-colin.king@canonical.com>
To: Colin King <colin.king@canonical.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jul 13, 2017, at 1:51 PM, Colin King <colin.king@canonical.com> wrote:
> 
> From: Colin Ian King <colin.king@canonical.com>
> 
> The current check will always be true and will always jump to
> err1, this looks dubious to me. I believe && should be used
> instead of ||.
> 
> Detected by CoverityScan, CID#1450120 ("Logically Dead Code")
> 
> Fixes: 107c1d0a991a ("svcrdma: Avoid Send Queue overflow")
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>

Dan reported this today, and I have a similar patch in my
"pending for-rc" series. This one works too.


> ---
> net/sunrpc/xprtrdma/svc_rdma_sendto.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> index 19fd01e4b690..7c3a211e0e9a 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> @@ -684,7 +684,7 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
> 	return 0;
> 
>  err2:
> -	if (ret != -E2BIG || ret != -EINVAL)
> +	if (ret != -E2BIG && ret != -EINVAL)
> 		goto err1;
> 
> 	ret = svc_rdma_post_recv(rdma, GFP_KERNEL);
> -- 
> 2.11.0
> 

--
Chuck Lever



