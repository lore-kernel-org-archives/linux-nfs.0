Return-Path: <SRS0=HWLc=ZN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF761C432C0
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Nov 2019 21:54:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A25492068E
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Nov 2019 21:54:31 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726539AbfKUVyb (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 21 Nov 2019 16:54:31 -0500
Received: from fieldses.org ([173.255.197.46]:36198 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726297AbfKUVyb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 21 Nov 2019 16:54:31 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id AB17F1C23; Thu, 21 Nov 2019 16:54:30 -0500 (EST)
Date:   Thu, 21 Nov 2019 16:54:30 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 1/2] SUNRPC: Fix backchannel latency metrics
Message-ID: <20191121215430.GA31527@fieldses.org>
References: <20191120212443.2140.88674.stgit@klimt.1015granger.net>
 <20191120212546.2140.2677.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20191120212546.2140.2677.stgit@klimt.1015granger.net>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Applying just this one to the nfsd tree for now.

--b.

On Wed, Nov 20, 2019 at 04:25:46PM -0500, Chuck Lever wrote:
> I noticed that for callback requests, the reported backlog latency
> is always zero, and the rtt value is crazy big. The problem was that
> rqst->rq_xtime is never set for backchannel requests.
> 
> Fixes: 78215759e20d ("SUNRPC: Make RTT measurement more ... ")
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  net/sunrpc/xprtrdma/svc_rdma_backchannel.c |    1 +
>  net/sunrpc/xprtsock.c                      |    3 ++-
>  2 files changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
> index d1fcc41d5eb5..908e78bb87c6 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
> @@ -195,6 +195,7 @@ static int svc_rdma_bc_sendto(struct svcxprt_rdma *rdma,
>  	pr_info("%s: %*ph\n", __func__, 64, rqst->rq_buffer);
>  #endif
>  
> +	rqst->rq_xtime = ktime_get();
>  	rc = svc_rdma_bc_sendto(rdma, rqst, ctxt);
>  	if (rc) {
>  		svc_rdma_send_ctxt_put(rdma, ctxt);
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 70e52f567b2a..5361b98f31ae 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -2659,6 +2659,8 @@ static int bc_sendto(struct rpc_rqst *req)
>  		.iov_len	= sizeof(marker),
>  	};
>  
> +	req->rq_xtime = ktime_get();
> +
>  	len = kernel_sendmsg(transport->sock, &msg, &iov, 1, iov.iov_len);
>  	if (len != iov.iov_len)
>  		return -EAGAIN;
> @@ -2684,7 +2686,6 @@ static int bc_send_request(struct rpc_rqst *req)
>  	struct svc_xprt	*xprt;
>  	int len;
>  
> -	dprintk("sending request with xid: %08x\n", ntohl(req->rq_xid));
>  	/*
>  	 * Get the server socket associated with this callback xprt
>  	 */
