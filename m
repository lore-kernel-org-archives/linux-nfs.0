Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:39457 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755309AbdEVUbd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 22 May 2017 16:31:33 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH] xprtrdma: Delete an error message for a failed memory allocation in xprt_rdma_bc_setup()
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <3c3f0067-1438-129c-d921-e2c056d5776b@users.sourceforge.net>
Date: Mon, 22 May 2017 16:31:08 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        netdev@vger.kernel.org, Anna Schumaker <anna.schumaker@netapp.com>,
        "David S. Miller" <davem@davemloft.net>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
Message-Id: <DC0EF67A-4AF8-415A-8EC0-F86F8E6F08FE@oracle.com>
References: <3c3f0067-1438-129c-d921-e2c056d5776b@users.sourceforge.net>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On May 22, 2017, at 4:24 PM, SF Markus Elfring <elfring@users.sourceforge.net> wrote:
> 
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Mon, 22 May 2017 22:18:28 +0200
> 
> Omit an extra message for a memory allocation failure in this function.
> 
> This issue was detected by using the Coccinelle software.
> 
> Link: http://events.linuxfoundation.org/sites/events/files/slides/LCJ16-Refactor_Strings-WSang_0.pdf
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>


> ---
> net/sunrpc/xprtrdma/backchannel.c | 6 ++----
> 1 file changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
> index 24fedd4b117e..03f6b5840764 100644
> --- a/net/sunrpc/xprtrdma/backchannel.c
> +++ b/net/sunrpc/xprtrdma/backchannel.c
> @@ -119,11 +119,9 @@ int xprt_rdma_bc_setup(struct rpc_xprt *xprt, unsigned int reqs)
> 
> 	for (i = 0; i < (reqs << 1); i++) {
> 		rqst = kzalloc(sizeof(*rqst), GFP_KERNEL);
> -		if (!rqst) {
> -			pr_err("RPC:       %s: Failed to create bc rpc_rqst\n",
> -			       __func__);
> +		if (!rqst)
> 			goto out_free;
> -		}
> +
> 		dprintk("RPC:       %s: new rqst %p\n", __func__, rqst);
> 
> 		rqst->rq_xprt = &r_xprt->rx_xprt;
> -- 
> 2.13.0

--
Chuck Lever



