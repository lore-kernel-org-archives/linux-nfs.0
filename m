From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH  2/17] svcrdma: Fix race with dto_tasklet in
	svc_rdma_send
Date: Mon, 5 May 2008 18:06:36 -0400
Message-ID: <20080505220636.GG12814@fieldses.org>
References: <12097457211326-git-send-email-tom@opengridcomputing.com> <1209745721248-git-send-email-tom@opengridcomputing.com> <12097457213375-git-send-email-tom@opengridcomputing.com> <12097457212336-git-send-email-tom@opengridcomputing.com> <12097457212951-git-send-email-tom@opengridcomputing.com> <12097457211122-git-send-email-tom@opengridcomputing.com> <12097457223433-git-send-email-tom@opengridcomputing.com> <12097457223971-git-send-email-tom@opengridcomputing.com> <12097457223635-git-send-email-tom@opengridcomputing.com> <12097457223351-git-send-email-tom@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:58445 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752123AbYEEWGh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 May 2008 18:06:37 -0400
In-Reply-To: <12097457223351-git-send-email-tom@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 02, 2008 at 11:28:34AM -0500, Tom Tucker wrote:
> The svc_rdma_send function will attempt to reap SQ WR to make room for
> a new request if it finds the SQ full. This function races with the
> dto_tasklet that also reaps SQ WR. To avoid calling the function
> unnecessarily use test_and_clear_bit with the RDMAXPRT_SQ_PENDING
> flag to serialize access to the sq_cq_reap function.

OK.  I won't pretend to understand much of this, but--would it be worth
pulling out the added code here into a helper function, since it now
exists in two different places?  (Especially if correctness depends on
the same thing happening in both the places this bit can be cleared.)

--b.

> 
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> 
> ---
>  net/sunrpc/xprtrdma/svc_rdma_transport.c |    8 ++++++--
>  1 files changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> index 1e0af2f..14f83a1 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> @@ -1010,8 +1010,12 @@ int svc_rdma_send(struct svcxprt_rdma *xprt, struct ib_send_wr *wr)
>  		if (xprt->sc_sq_depth == atomic_read(&xprt->sc_sq_count)) {
>  			spin_unlock_bh(&xprt->sc_lock);
>  			atomic_inc(&rdma_stat_sq_starve);
> -			/* See if we can reap some SQ WR */
> -			sq_cq_reap(xprt);
> +
> +			/* See if we can opportunistically reap SQ WR to make room */
> +			if (test_and_clear_bit(RDMAXPRT_SQ_PENDING, &xprt->sc_flags)) {
> +				ib_req_notify_cq(xprt->sc_sq_cq, IB_CQ_NEXT_COMP);
> +				sq_cq_reap(xprt);
> +			}
>  
>  			/* Wait until SQ WR available if SQ still full */
>  			wait_event(xprt->sc_send_wait,
