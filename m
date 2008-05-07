From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH  1/3] svcrdma: Remove redunant call to xpo_release_rqst
	method.
Date: Wed, 07 May 2008 10:08:06 -0500
Message-ID: <1210172886.27493.30.camel@trinity.ogc.int>
References: <12097450861136-git-send-email-tom@opengridcomputing.com>
	 <12097450861293-git-send-email-tom@opengridcomputing.com>
	 <20080506215940.GQ13484@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:46446 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754627AbYEGPFh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 May 2008 11:05:37 -0400
In-Reply-To: <20080506215940.GQ13484@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Tue, 2008-05-06 at 17:59 -0400, J. Bruce Fields wrote:
> On Fri, May 02, 2008 at 11:18:04AM -0500, Tom Tucker wrote:
> > The xpo_release_rqst method is called from svc_xprt_release and therefore
> > this direct call of the provider method is redundant. There is no bug
> > here since the provider protects against multiple calls.
> > 
> > Originally, this code was here because the xpo_release_rqst function was
> > being used by the RDMA transport to return credits to the client, i.e.
> > posting a receive buffer. This had to be done before the send in order to
> > avoid a race wherein the client responds immediately with a new request
> > but the buffer has not yet been posted. This is a poor design point and
> > the recv buffer posting has been modified in the rdma transport.
> 
> The comment there refers to the socket code, not the rdma code, and

Yes, you are correct. 

> there was a svc_release_skb() there before the rdma code came along.
> I'd like to understand why.

I believe it's because the socket code has buffer quotas and the skb
you're holding consumes credits in the recv sock buf. So it's
conceivable that you could send a message, another client message
arrives prior to releasing the skb your holding, and this new message
gets dropped unnecessarily. I don't believe it affects the sending at
all because the message you're holding came from sock_recv_datagram and
only consumes recv side credits.

Since this patch is only for "clean up" purposes, I'm inclined to just
ditch this patch and let us noodle on it a little more. Agreed?

> 
> --b.
> 
> > 
> > Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> > 
> > ---
> >  net/sunrpc/svc_xprt.c |    3 ---
> >  1 files changed, 0 insertions(+), 3 deletions(-)
> > 
> > diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> > index d8e8d79..74e52d4 100644
> > --- a/net/sunrpc/svc_xprt.c
> > +++ b/net/sunrpc/svc_xprt.c
> > @@ -751,9 +751,6 @@ int svc_send(struct svc_rqst *rqstp)
> >  	if (!xprt)
> >  		return -EFAULT;
> >  
> > -	/* release the receive skb before sending the reply */
> > -	rqstp->rq_xprt->xpt_ops->xpo_release_rqst(rqstp);
> > -
> >  	/* calculate over-all length */
> >  	xb = &rqstp->rq_res;
> >  	xb->len = xb->head[0].iov_len +
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

