Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:53152 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1031972AbdDTWTH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 20 Apr 2017 18:19:07 -0400
Date: Thu, 20 Apr 2017 18:19:06 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: check for oversized NFSv2/v3 arguments
Message-ID: <20170420221906.GB6993@fieldses.org>
References: <20170414150440.GA5362@fieldses.org>
 <20170414150940.GB5362@fieldses.org>
 <87h91mtvdb.fsf@notabene.neil.brown.name>
 <20170418171351.GF6208@fieldses.org>
 <20170420161935.GB4782@fieldses.org>
 <20170420213014.GA6993@fieldses.org>
 <87efwmsp8w.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87efwmsp8w.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 21, 2017 at 08:11:59AM +1000, NeilBrown wrote:
> On Thu, Apr 20 2017, J. Bruce Fields wrote:
> 
> > On Thu, Apr 20, 2017 at 12:19:35PM -0400, J. Bruce Fields wrote:
> >> On Tue, Apr 18, 2017 at 01:13:51PM -0400, J. Bruce Fields wrote:
> >> > On Tue, Apr 18, 2017 at 10:25:20AM +1000, NeilBrown wrote:
> >> > >  I can't say that I like this patch at all.
> >> > > 
> >> > > The problem is that:
> >> > > 
> >> > > 	pages = size / PAGE_SIZE + 1; /* extra page as we hold both request and reply.
> >> > > 				       * We assume one is at most one page
> >> > > 				       */
> >> > > 
> >> > > this assumption is never verified.
> >> > > To my mind, the "obvious" way to verify this assumption is that an
> >> > > attempt to generate a multi-page reply should fail if there was a
> >> > > multi-page request.
> >> > 
> >> > A third option, by the way, which Ari Kauppi argued for, is adding a
> >> > null check each time we increment rq_next_page, since we seem to arrange
> >> > for the page array to always be NULL-terminated.
> >> > 
> >> > > Failing if there was a little bit of extra noise at the end of the
> >> > > request seems harsher than necessary, and could result in a regression.
> >> > 
> >> > You're worrying there might be a weird old client out there somewhere?
> >> > I guess it seems like a small enough risk to me.  I'm more worried the
> >> > extra garbage might violate assumptions elsewhere in the code.
> >> > 
> >> > But, this looks good too:
> >> 
> >> But, I'm not too happy about putting that NFSv2/v3-specific check in
> >> common rpc code.  Also, I think this check comes too late for some of
> >> the damage.
> 
> Too late?  It is earlier than anything else.

D'oh, yes, I had some idea the check happened after encoding.

> >> I may go with some variation on Ari's idea, let me give it a try....
> >
> > In the read case, I think Ari's approach wouldn't catch the error until
> > nfsd_direct_splice_actor(), which doesn't actually look capable of
> > handling errors.  Maybe that should be fixed.  Or maybe read just needs
> > some more checks.  Ugh.
> 
> By the time you get to nfsd_read(), the 'struct kvec' should be set up
> and valid.

That's ignored in the splice case, isn't it?

OK, maybe I need to sleep on it and look again in the morning....

--b.

> So we need checks is e.g. nfs3svc_decode_readargs(), but not
> deeper.


