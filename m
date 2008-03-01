From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] SVC: Guard call to xpo_release_rqst in svc_send
Date: Sat, 1 Mar 2008 11:24:41 -0500
Message-ID: <20080301162441.GB19927@fieldses.org>
References: <20080229204030.GB6276@fieldses.org> <C3EE27A2.3776E%tom@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs <linux-nfs@vger.kernel.org>,
	jaschut <jaschut@sandia.gov>,
	Steve Wise <swise@opengridcomputing.com>
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:51567 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763281AbYCAQYx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 1 Mar 2008 11:24:53 -0500
In-Reply-To: <C3EE27A2.3776E%tom@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 29, 2008 at 09:20:34PM -0600, Tom Tucker wrote:
> Bruce:
> 
> Summary response: Mia culpa....please revert this patch.

OK!  I hadn't gotten around to applying it, so no need to revert.

> Although it made the test failure go away, this patch just moves the
> problem, it doesn't fix anything.  

Remind me what the test failure was?  (You saw that the problem Torsten
Kaiser reported turned out to be a bug in the memory allocator, right?:
http://bugzilla.kernel.org/show_bug.cgi?id=9973)

--b.

> 
> More below inline....
> 
> On 2/29/08 2:40 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> 
> > On Wed, Feb 27, 2008 at 01:58:59PM -0600, Tom Tucker wrote:
> >>     
> >> The svc_send path is calling xpo_release_rqst without checking
> >> the XPT_DEAD bit. It is illegal to call transport methods on a dead
> >> transport. In practice, if the transport gets an error and shuts down
> >> while there are still RPC in svc_process the resulting svc_send could
> >> crash calling into a transport that is being shut down.
> > 
> > As long as we have a pointer to an xprt (say in rqstp->rq_xprt), we
> > should have a reference on the corresponding xprt class, shouldn't we?
> > Anything else seems like a problem.
> > 
> 
> Generally yes. In particular, at entry to svc_recv, we should have a minimum
> of two references. svc_xprt_enqueue gets you one, and there is a one ref
> bias that comes from svc_xprt_init. The bias gets removed on close.
> 
> >>     
> >> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> >> ---
> >> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> >> index ea377e0..467c1c0 100644
> >> --- a/net/sunrpc/svc_xprt.c
> >> +++ b/net/sunrpc/svc_xprt.c
> >> @@ -729,9 +729,6 @@ int svc_send(struct svc_rqst *rqstp)
> >> if (!xprt)
> >> return -EFAULT;
> >>  
> >> - /* release the receive skb before sending the reply */
> >> - rqstp->rq_xprt->xpt_ops->xpo_release_rqst(rqstp);
> >> -
> >> /* calculate over-all length */
> >> xb = &rqstp->rq_res;
> >> xb->len = xb->head[0].iov_len +
> >> @@ -742,8 +739,11 @@ int svc_send(struct svc_rqst *rqstp)
> >> mutex_lock(&xprt->xpt_mutex);
> >> if (test_bit(XPT_DEAD, &xprt->xpt_flags))
> >> len = -ENOTCONN;
> >> - else
> >> + else {
> >> +  /* release the receive skb before sending the reply */
> >> +  rqstp->rq_xprt->xpt_ops->xpo_release_rqst(rqstp);
> >> len = xprt->xpt_ops->xpo_sendto(rqstp);
> >> + }
> > 
> > So in the case where XPT_DEAD is set, doesn't the receive skb also need
> > to be freed, or does somebody else do that?
> > 
> 
> Only reboot does that :-\. I need to think this through more carefully. On
> RDMA transports this function is used to return send credits to the user,
> and that involves talking to the transport. Sorry for this hasty
> patch...it's not right.
> 
> >> mutex_unlock(&xprt->xpt_mutex);
> >> svc_xprt_release(rqstp);
> > 
> > Also something else is odd here: svc_xprt_release(rqstp) already calls
> > rqstp->rq_xprt->xpt_ops->xpo_release_rqst(rqstp) itself, so we seem to
> > have two calls to that method.
> > 
> 
> Hmm. Busted. This patch is broken in three dimensions. Is that a record?
> 
> Tom
>  
> > --b.
> > 
> >>  
> >> 
> >> -
> >> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
