From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH  3/17] svcrdma: Fix return value in svc_rdma_send
Date: Mon, 5 May 2008 18:08:17 -0400
Message-ID: <20080505220817.GH12814@fieldses.org>
References: <1209745721248-git-send-email-tom@opengridcomputing.com> <12097457213375-git-send-email-tom@opengridcomputing.com> <12097457212336-git-send-email-tom@opengridcomputing.com> <12097457212951-git-send-email-tom@opengridcomputing.com> <12097457211122-git-send-email-tom@opengridcomputing.com> <12097457223433-git-send-email-tom@opengridcomputing.com> <12097457223971-git-send-email-tom@opengridcomputing.com> <12097457223635-git-send-email-tom@opengridcomputing.com> <12097457223351-git-send-email-tom@opengridcomputing.com> <12097457221640-git-send-email-tom@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:58450 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762190AbYEEWIS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 May 2008 18:08:18 -0400
In-Reply-To: <12097457221640-git-send-email-tom@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 02, 2008 at 11:28:35AM -0500, Tom Tucker wrote:
> Fix the return value on close to -ENOTCONN so caller knows to free context.
> Also if a thread is waiting for free SQ space, check for close when waking
> to avoid posting WR to a closing transport.

A random related question: svc_rdma_send_error() seems to have only one
caller, which ignores its return value.  Should its return value be
made void?

--b.

> 
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> 
> ---
>  net/sunrpc/xprtrdma/svc_rdma_transport.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> index 14f83a1..8adb2f0 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> @@ -999,7 +999,7 @@ int svc_rdma_send(struct svcxprt_rdma *xprt, struct ib_send_wr *wr)
>  	int ret;
>  
>  	if (test_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags))
> -		return 0;
> +		return -ENOTCONN;
>  
>  	BUG_ON(wr->send_flags != IB_SEND_SIGNALED);
>  	BUG_ON(((struct svc_rdma_op_ctxt *)(unsigned long)wr->wr_id)->wr_op !=
