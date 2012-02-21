Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47977 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752022Ab2BUVXZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Feb 2012 16:23:25 -0500
Date: Tue, 21 Feb 2012 16:23:23 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tom Tucker <tom@opengridcomputing.com>
Cc: Dan Carpenter <dan.carpenter@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: Re: [patch] svcrdma: silence a Sparse warning
Message-ID: <20120221212323.GA4426@fieldses.org>
References: <20120221072804.GA6896@elgon.mountain>
 <20120221210603.GA4326@fieldses.org>
 <4F4407E1.7030400@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F4407E1.7030400@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 21, 2012 at 03:08:49PM -0600, Tom Tucker wrote:
> 
> This is my bad. I don't know why my sparse didn't catch it, it seems
> like it should have. Thanks for
> fixing it Dan.

Thanks, applying.--b.

> 
> Tom
> 
> 
> On 2/21/12 3:06 PM, J. Bruce Fields wrote:
> >(Cc'ing Tom).
> >
> >On Tue, Feb 21, 2012 at 10:28:04AM +0300, Dan Carpenter wrote:
> >>Sparse complains that the definition function definition and the
> >>implementation aren't anotated the same way.
> >>
> >>Signed-off-by: Dan Carpenter<dan.carpenter@oracle.com>
> >>
> >>diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
> >>index d205e9f..0b8e3e6 100644
> >>--- a/include/linux/sunrpc/svc_rdma.h
> >>+++ b/include/linux/sunrpc/svc_rdma.h
> >>@@ -190,7 +190,7 @@ extern int svc_rdma_xdr_encode_error(struct svcxprt_rdma *,
> >>  extern void svc_rdma_xdr_encode_write_list(struct rpcrdma_msg *, int);
> >>  extern void svc_rdma_xdr_encode_reply_array(struct rpcrdma_write_array *, int);
> >>  extern void svc_rdma_xdr_encode_array_chunk(struct rpcrdma_write_array *, int,
> >>-					    u32, u64, u32);
> >>+					    __be32, __be64, u32);
> >>  extern void svc_rdma_xdr_encode_reply_header(struct svcxprt_rdma *,
> >>  					     struct rpcrdma_msg *,
> >>  					     struct rpcrdma_msg *,
> >--
> >To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >the body of a message to majordomo@vger.kernel.org
> >More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
