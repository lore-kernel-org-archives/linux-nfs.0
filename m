Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38230 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754237AbaKRUKu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Nov 2014 15:10:50 -0500
Date: Tue, 18 Nov 2014 15:10:49 -0500
From: Bruce Fields <bfields@fieldses.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: Fix locking around callback channel reply receive
Message-ID: <20141118201049.GH7419@fieldses.org>
References: <1415833444-48129-1-git-send-email-trond.myklebust@primarydata.com>
 <20141112214128.4fc43a49@synchrony.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141112214128.4fc43a49@synchrony.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 12, 2014 at 09:41:28PM -0500, Jeff Layton wrote:
> On Wed, 12 Nov 2014 18:04:04 -0500
> Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
> > Both xprt_lookup_rqst() and xprt_complete_rqst() require that you
> > take the transport lock in order to avoid races with xprt_transmit().

Thanks, looks right.

Have you seen this in practice?  (I'm just wondering whether it's worth
a stable cc:.)

--b.

> > Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> > Cc: Bruce Fields <bfields@fieldses.org>
> > ---
> >  net/sunrpc/svcsock.c | 27 ++++++++++++++++-----------
> >  1 file changed, 16 insertions(+), 11 deletions(-)
> > 
> > diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> > index 3f959c681885..f9c052d508f0 100644
> > --- a/net/sunrpc/svcsock.c
> > +++ b/net/sunrpc/svcsock.c
> > @@ -1019,17 +1019,12 @@ static int receive_cb_reply(struct svc_sock *svsk, struct svc_rqst *rqstp)
> >  	xid = *p++;
> >  	calldir = *p;
> >  
> > -	if (bc_xprt)
> > -		req = xprt_lookup_rqst(bc_xprt, xid);
> > -
> > -	if (!req) {
> > -		printk(KERN_NOTICE
> > -			"%s: Got unrecognized reply: "
> > -			"calldir 0x%x xpt_bc_xprt %p xid %08x\n",
> > -			__func__, ntohl(calldir),
> > -			bc_xprt, ntohl(xid));
> > +	if (!bc_xprt)
> >  		return -EAGAIN;
> > -	}
> > +	spin_lock_bh(&bc_xprt->transport_lock);
> > +	req = xprt_lookup_rqst(bc_xprt, xid);
> > +	if (!req)
> > +		goto unlock_notfound;
> >  
> >  	memcpy(&req->rq_private_buf, &req->rq_rcv_buf, sizeof(struct xdr_buf));
> >  	/*
> > @@ -1040,11 +1035,21 @@ static int receive_cb_reply(struct svc_sock *svsk, struct svc_rqst *rqstp)
> >  	dst = &req->rq_private_buf.head[0];
> >  	src = &rqstp->rq_arg.head[0];
> >  	if (dst->iov_len < src->iov_len)
> > -		return -EAGAIN; /* whatever; just giving up. */
> > +		goto unlock_eagain; /* whatever; just giving up. */
> >  	memcpy(dst->iov_base, src->iov_base, src->iov_len);
> >  	xprt_complete_rqst(req->rq_task, rqstp->rq_arg.len);
> >  	rqstp->rq_arg.len = 0;
> > +	spin_unlock_bh(&bc_xprt->transport_lock);
> >  	return 0;
> > +unlock_notfound:
> > +	printk(KERN_NOTICE
> > +		"%s: Got unrecognized reply: "
> > +		"calldir 0x%x xpt_bc_xprt %p xid %08x\n",
> > +		__func__, ntohl(calldir),
> > +		bc_xprt, ntohl(xid));
> > +unlock_eagain:
> > +	spin_unlock_bh(&bc_xprt->transport_lock);
> > +	return -EAGAIN;
> >  }
> >  
> >  static int copy_pages_to_kvecs(struct kvec *vec, struct page **pages, int len)
> 
> Nice catch. It would also be good to pair this with a
> lockdep_assert_held() call in xprt_lookup_rqst, but that could be added
> in a separate patch.
> 
> Reviewed-by: Jeff Layton <jlayton@primarydata.com>
