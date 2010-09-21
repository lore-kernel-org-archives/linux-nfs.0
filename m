Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:50191 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752257Ab0IUXhc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Sep 2010 19:37:32 -0400
Date: Wed, 22 Sep 2010 09:37:25 +1000
From: Neil Brown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/6] sunrpc: close connection when a request is
 irretrievably lost.
Message-ID: <20100922093725.48a1a5fe@notabene>
In-Reply-To: <20100921205343.GB10570@fieldses.org>
References: <20100812065722.11459.18978.stgit@localhost.localdomain>
	<20100812070406.11459.61914.stgit@localhost.localdomain>
	<20100921205343.GB10570@fieldses.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 21 Sep 2010 16:53:43 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> Apologies for the delay getting to the rest of these.
> 
> On Thu, Aug 12, 2010 at 05:04:07PM +1000, NeilBrown wrote:
> > If we drop a request in the sunrpc layer, either due kmalloc failure,
> > or due to a cache miss when we could not queue the request for later
> > replay, then close the connection to encourage the client to retry sooner.
> > 
> > Note that if the drop happens in the NFS layer, NFSERR_JUKEBOX
> > (aka NFS4ERR_DELAY) is returned to guide the client concerning
> > replay.
> 
> Looks fine, but:
> 
> > diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> > index d9017d6..6359c42 100644
> > --- a/net/sunrpc/svc.c
> > +++ b/net/sunrpc/svc.c
> > @@ -1055,6 +1055,9 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
> >  		goto err_bad;
> >  	case SVC_DENIED:
> >  		goto err_bad_auth;
> > +	case SVC_CLOSE:
> > +		if (test_bit(XPT_TEMP, &rqstp->rq_xprt->xpt_flags))
> > +			svc_close_xprt(rqstp->rq_xprt);
> 
> There are also dropit's later in svc_process_common when xdr encoding
> fails.  I wonder if we should close there?
> 
> Well, it's an odd case.  Seems like it should almost be declared a
> programming error and made a WARN().
> 
> Applying as is.--b.

Thanks, I was wondering what had happened to these...

I cannot find them in your git though - not pushed yet, or am I looking in
the wrong branch (for-2.6.37 and nfsd-next seem the obvious choices).

For the other 'dropit' cases I think the svc_authorise failure is most likely
to be interesting.  That can only fail if svcauth_gss_wrap_resp_* fails.  I
don't really know what that means that ... maybe we should close the
connection in that case.

NeilBrown

