Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:30194 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341AbcAFPhK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jan 2016 10:37:10 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: [patch -next] svcrdma: fix a couple warning messages
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20160105095249.GB23619@mwanda>
Date: Wed, 6 Jan 2016 10:36:49 -0500
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>, Ray Jui <rjui@broadcom.com>,
        Scott Branden <sbranden@broadcom.com>,
        Jon Mason <jonmason@broadcom.com>, Doug Ledford <dledford@redhat.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Sagi Grimberg <sagig@mellanox.com>,
        Michael Wang <yun.wang@profitbricks.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
Message-Id: <80C8DCE5-5838-4045-A135-28A8960AA7A1@oracle.com>
References: <20160105095249.GB23619@mwanda>
To: Dan Carpenter <dan.carpenter@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jan 5, 2016, at 4:52 AM, Dan Carpenter <dan.carpenter@oracle.com> wrote:
> 
> The WARN_ON_ONCE() macro takes a condition, passing it this string
> literal sort of works as intended but it's better to use WARN_ONCE()
> instead.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Hi Dan, I have to rebase and resubmit this series anyway.
I've squashed both your fixes into the original patches that
introduced the issues.

Thanks for reporting!


> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> index abfbd02..4b397ad 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> @@ -221,7 +221,7 @@ out_empty:
> 	spin_lock_bh(&xprt->sc_ctxt_lock);
> 	xprt->sc_ctxt_used--;
> 	spin_unlock_bh(&xprt->sc_ctxt_lock);
> -	WARN_ON_ONCE("svcrdma: empty RDMA ctxt list?\n");
> +	WARN_ONCE(1, "svcrdma: empty RDMA ctxt list?\n");
> 	return NULL;
> }
> 
> @@ -328,7 +328,7 @@ out_empty:
> 	if (map)
> 		goto out;
> 
> -	WARN_ON_ONCE("svcrdma: empty request map list?\n");
> +	WARN_ONCE(1, "svcrdma: empty request map list?\n");
> 	return NULL;
> }
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever




