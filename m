Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:53110 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1033638AbdDTVaP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 20 Apr 2017 17:30:15 -0400
Date: Thu, 20 Apr 2017 17:30:14 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.com>
Cc: linux-nfs@vger.kernel.org, Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] nfsd: check for oversized NFSv2/v3 arguments
Message-ID: <20170420213014.GA6993@fieldses.org>
References: <20170414150440.GA5362@fieldses.org>
 <20170414150940.GB5362@fieldses.org>
 <87h91mtvdb.fsf@notabene.neil.brown.name>
 <20170418171351.GF6208@fieldses.org>
 <20170420161935.GB4782@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170420161935.GB4782@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 20, 2017 at 12:19:35PM -0400, J. Bruce Fields wrote:
> On Tue, Apr 18, 2017 at 01:13:51PM -0400, J. Bruce Fields wrote:
> > On Tue, Apr 18, 2017 at 10:25:20AM +1000, NeilBrown wrote:
> > >  I can't say that I like this patch at all.
> > > 
> > > The problem is that:
> > > 
> > > 	pages = size / PAGE_SIZE + 1; /* extra page as we hold both request and reply.
> > > 				       * We assume one is at most one page
> > > 				       */
> > > 
> > > this assumption is never verified.
> > > To my mind, the "obvious" way to verify this assumption is that an
> > > attempt to generate a multi-page reply should fail if there was a
> > > multi-page request.
> > 
> > A third option, by the way, which Ari Kauppi argued for, is adding a
> > null check each time we increment rq_next_page, since we seem to arrange
> > for the page array to always be NULL-terminated.
> > 
> > > Failing if there was a little bit of extra noise at the end of the
> > > request seems harsher than necessary, and could result in a regression.
> > 
> > You're worrying there might be a weird old client out there somewhere?
> > I guess it seems like a small enough risk to me.  I'm more worried the
> > extra garbage might violate assumptions elsewhere in the code.
> > 
> > But, this looks good too:
> 
> But, I'm not too happy about putting that NFSv2/v3-specific check in
> common rpc code.  Also, I think this check comes too late for some of
> the damage.
> 
> I may go with some variation on Ari's idea, let me give it a try....

In the read case, I think Ari's approach wouldn't catch the error until
nfsd_direct_splice_actor(), which doesn't actually look capable of
handling errors.  Maybe that should be fixed.  Or maybe read just needs
some more checks.  Ugh.

--b.

> 
> --b.
> 
> > 
> > > We already know how big replies can get, so we can perform a complete
> > > sanity check quite early:
> > > 
> > > diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> > > index a08aeb56b8e4..14f4d425cf8c 100644
> > > --- a/net/sunrpc/svc.c
> > > +++ b/net/sunrpc/svc.c
> > > @@ -1196,6 +1196,12 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
> > >  		goto err_bad_proc;
> > >  	rqstp->rq_procinfo = procp;
> > >  
> > > +	if ((procp->pc_xdrressize == 0 ||
> > > +	     procp->pc_xdrressize > XDR_QUADLEN(PAGE_SIZE)) &&
> > > +	    rqstp->rq_arg.len > PAGE_SIZE)
> > > +		/* The assumption about request/reply sizes in svc_init_buffer() is violated! */
> > > +		goto err_garbage;
> > > +
> > >  	/* Syntactic check complete */
> > >  	serv->sv_stats->rpccnt++;
> > >  
> > > 
> > > I haven't tested this at all and haven't even convinced myself that
> > > it covers every case (though I cannot immediately think of any likely
> > > corners).
> > > 
> > > Does it address your test case?
> > 
> > I'll check, it probably does.
> > 
> > We'd need to limit the test to v2/v3.
> > 
> > I'm also not opposed to doing both (or all three).
> > 
> > --b.
