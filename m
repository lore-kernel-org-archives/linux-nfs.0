Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:32885 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935256AbeB1W7v (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Feb 2018 17:59:51 -0500
Received: by mail-wr0-f196.google.com with SMTP id v18so3514844wrv.0
        for <linux-nfs@vger.kernel.org>; Wed, 28 Feb 2018 14:59:51 -0800 (PST)
Date: Wed, 28 Feb 2018 15:59:46 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 7/8] xprtrdma: Chain Send to FastReg WRs
Message-ID: <20180228225946.GF19007@ziepe.ca>
References: <20180228202916.25968.21750.stgit@manet.1015granger.net>
 <20180228203059.25968.28807.stgit@manet.1015granger.net>
 <37357f5c-25c5-b862-4e4f-7f84a38a29b2@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <37357f5c-25c5-b862-4e4f-7f84a38a29b2@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 28, 2018 at 04:51:11PM -0500, Anna Schumaker wrote:
> 
> 
> On 02/28/2018 03:30 PM, Chuck Lever wrote:
> > With FRWR, the client transport can perform memory registration and
> > post a Send with just a single ib_post_send.
> > 
> > This reduces contention between the send_request path and the Send
> > Completion handlers, and reduces the overhead of registering a chunk
> > that has multiple segments.
> > 
> > Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> >  net/sunrpc/xprtrdma/fmr_ops.c   |   11 ++++++++
> >  net/sunrpc/xprtrdma/frwr_ops.c  |   51 +++++++++++++++++++++++++++------------
> >  net/sunrpc/xprtrdma/verbs.c     |    3 +-
> >  net/sunrpc/xprtrdma/xprt_rdma.h |    2 ++
> >  4 files changed, 49 insertions(+), 18 deletions(-)
> > 
> > diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
> > index 629e539..5cc68a8 100644
> > +++ b/net/sunrpc/xprtrdma/fmr_ops.c
> > @@ -251,6 +251,16 @@ enum {
> >  	return ERR_PTR(-EIO);
> >  }
> >  
> > +/* Post Send WR containing the RPC Call message.
> > + */
> > +static int
> > +fmr_op_send(struct rpcrdma_ia *ia, struct rpcrdma_req *req)
> > +{
> > +	struct ib_send_wr *bad_wr;
> > +
> > +	return ib_post_send(ia->ri_id->qp, &req->rl_sendctx->sc_wr, &bad_wr);
> 
> I wish there was a bad_wr null-check in ib_post_send() (or in the
> infiniband drivers) so you don't have to declare a variable that's
> never used again.  Coordinating that might be more work than it's
> worth, though.

It is a good point, I actually don't think we have any user in kernel
of bad_wr ..

Would prefer to just drop the parameter and add a new function call if
really, really needed.

Jason
