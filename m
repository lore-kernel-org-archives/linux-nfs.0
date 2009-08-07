From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 00/12] Some improvements to request deferral and
	related code
Date: Fri, 7 Aug 2009 14:13:50 +1000
Message-ID: <19067.43518.105153.247173@notabene.brown>
References: <20090804051145.15929.11356.stgit@notabene.brown>
	<20090804140428.GE14249@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:52114 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750887AbZHGENk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Aug 2009 00:13:40 -0400
In-Reply-To: message from J. Bruce Fields on Tuesday August 4
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tuesday August 4, bfields@fieldses.org wrote:
> On Tue, Aug 04, 2009 at 03:22:38PM +1000, NeilBrown wrote:
> >  This series fixes a few little bugs and tidies up some code but does
> >  two main important things.
> > 
> >  1/ 'allow thread to block....' will wait a little while if there is a
> >  cache miss.  If an answer is available in that time, it continues on
> >  it's merry way.  If no answer arrives, the old deferral approach is
> >  used.  It waits 5 seconds if there are spare nfsd threads, and 1
> >  second if there all threads are busy.  I have almost nothing with
> >  which to justify these numbers.
> 
> I think the v4 server at least should return NFS4ERR_DELAY in this case
> instead of doing the internal replay.  That avoids possible problems
> with non-idempotent compound ops.

If the request has been handed to nfsd, then yes I agree.  We probably
want some way for nfsd to mark the request as "don't replay" so that
an error will propagate out.  Currently we map that error to EJUKEBOX
for v3 or v4, but you are right, we want ERR_DELAY for v4.

If the request is still in the RPC code (trying to identify the
origin or to decode the crypto) then we cannot return ERR_DELAY, but
as none of the request will have been processed yet, there is no room
for a problem with non-idempotent ops.

It has occurred to me that we could throw away the current request
deferral completely:  if we don't feel comfortable delaying the thread
for as long as it takes, we just return an error or drop the request
(closing any connection).
I'm not sure I'd be comfortable doing that if there were only a few
(8?) threads though.
Maybe if we got dynamic nfsd threads so that new ones could be created
on demand I would feel quite happy to discard the deferral stuff and
just use a delay.

> 
> >From the protocol point of view I don't know if there's any rule of
> thumb about when it'd be best to return DELAY.  Perhaps it's best to
> avoid it whenever possible, but when the delay is on the order of
> seconds it sounds reasonable to me.

Of course you don't know how long the delay will be until it happens:-)

But I agree.  Delay internally if possible, but as soon as that seems
to be awkward (e.g. run out of threads), return DELAY

Thanks,
NeilBrown
