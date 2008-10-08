From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 02/15] RPC/RDMA: add data types and new FRMR memory
	registration enum.
Date: Wed, 8 Oct 2008 13:55:19 -0400
Message-ID: <20081008175519.GA11295@fieldses.org>
References: <20081008154506.1336.59892.stgit@tmt3.nane.netapp.com> <20081008154713.1336.41538.stgit@tmt3.nane.netapp.com> <1223486623.7361.10.camel@localhost> <RTPCLUEXC1-PRDmcarc00000072@RTPMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Tom Talpey <talpey@netapp.com>, linux-nfs@vger.kernel.org
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:45747 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753982AbYJHRzX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Oct 2008 13:55:23 -0400
In-Reply-To: <RTPCLUEXC1-PRDmcarc00000072-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 08, 2008 at 01:30:56PM -0400, Talpey, Thomas wrote:
> At 01:23 PM 10/8/2008, Trond Myklebust wrote:
> >On Wed, 2008-10-08 at 11:47 -0400, Tom Talpey wrote:
> >> Internal RPC/RDMA structure updates in preparation for FRMR support.
> >> 
> >> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> >> Signed-off-by: Tom Talpey <talpey@netapp.com>
> >
> >Shouldn't there be a
> >
> >From: Tom Tucker <tom@opengridcomputing.com>
> >
> >at the top of this email in order to indicate that Tom Tucker is the
> >author?
> 
> Co-author. Should it have two From lines?

Gotta pick one.  I tend to leave whoever got there first as the author.
If it was a pretty involved collaboration I suppose you could even do
something cheesy like assinging half the series to one person and half
to the other.

--b.

> 
> Tom.
> 
> >
> >> ---
> >> 
> >>  net/sunrpc/xprtrdma/xprt_rdma.h |    8 +++++++-
> >>  1 files changed, 7 insertions(+), 1 deletions(-)
> >> 
> >> diff --git a/include/linux/sunrpc/xprtrdma.h 
> >b/include/linux/sunrpc/xprtrdma.h
> >> index 4de56b1..55a5d92 100644
> >> --- a/include/linux/sunrpc/xprtrdma.h
> >> +++ b/include/linux/sunrpc/xprtrdma.h
> >> @@ -78,6 +78,7 @@ enum rpcrdma_memreg {
> >>  	RPCRDMA_MEMWINDOWS,
> >>  	RPCRDMA_MEMWINDOWS_ASYNC,
> >>  	RPCRDMA_MTHCAFMR,
> >> +	RPCRDMA_FRMR,
> >>  	RPCRDMA_ALLPHYSICAL,
> >>  	RPCRDMA_LAST
> >>  };
> >> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h 
> >b/net/sunrpc/xprtrdma/xprt_rdma.h
> >> index 2427822..05b7898 100644
> >> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
> >> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
> >> @@ -58,6 +58,8 @@ struct rpcrdma_ia {
> >>  	struct rdma_cm_id 	*ri_id;
> >>  	struct ib_pd		*ri_pd;
> >>  	struct ib_mr		*ri_bind_mem;
> >> +	u32			ri_dma_lkey;
> >> +	int			ri_have_dma_lkey;
> >>  	struct completion	ri_done;
> >>  	int			ri_async_rc;
> >>  	enum rpcrdma_memreg	ri_memreg_strategy;
> >> @@ -156,6 +158,10 @@ struct rpcrdma_mr_seg {		/* chunk descriptors */
> >>  			union {
> >>  				struct ib_mw	*mw;
> >>  				struct ib_fmr	*fmr;
> >> +				struct {
> >> +					struct ib_fast_reg_page_list *fr_pgl;
> >> +					struct ib_mr *fr_mr;
> >> +				} frmr;
> >>  			} r;
> >>  			struct list_head mw_list;
> >>  		} *rl_mw;
> >> @@ -198,7 +204,7 @@ struct rpcrdma_buffer {
> >>  	atomic_t	rb_credits;	/* most recent server credits */
> >>  	unsigned long	rb_cwndscale;	/* cached framework rpc_cwndscale */
> >>  	int		rb_max_requests;/* client max requests */
> >> -	struct list_head rb_mws;	/* optional memory windows/fmrs */
> >> +	struct list_head rb_mws;	/* optional memory windows/fmrs/frmrs */
> >>  	int		rb_send_index;
> >>  	struct rpcrdma_req	**rb_send_bufs;
> >>  	int		rb_recv_index;
> >> 
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
