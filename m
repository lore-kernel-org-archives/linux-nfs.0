Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:34277 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750980Ab1ADTXw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jan 2011 14:23:52 -0500
Date: Tue, 4 Jan 2011 14:23:51 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] svcrpc: modifying positive sunrpc cache entries is racy
Message-ID: <20110104192350.GE2308@fieldses.org>
References: <20101229204752.GC12218@fieldses.org>
 <20101229205942.GD12218@fieldses.org>
 <20101230121940.3f48223a@notabene.brown>
 <20101230015719.GA27614@fieldses.org>
 <20110103205514.GB18056@fieldses.org>
 <20110104160152.602a3c44@notabene.brown>
 <20110104152231.GA27889@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110104152231.GA27889@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Jan 04, 2011 at 10:22:31AM -0500, J. Bruce Fields wrote:
> On Tue, Jan 04, 2011 at 04:01:52PM +1100, NeilBrown wrote:
> > On Mon, 3 Jan 2011 15:55:14 -0500 "J. Bruce Fields" <bfields@fieldses.org>
> > wrote:
> > > @@ -213,6 +214,33 @@ static inline int cache_is_valid(struct cache_detail *detail, struct cache_head
> > >  	}
> > >  }
> > >  
> > > +static int cache_is_valid(struct cache_detail *detail, struct cache_head *h)
> > > +{
> > > +	int rv;
> > > +
> > > +	read_lock(&detail->hash_lock);
> > > +	rv = __cache_is_valid(detail, h);
> > > +	read_unlock(&detail->hash_lock);
> > > +	return rv;
> > > +}
> > 
> > I don't think there is anything in __cache_is_valid that needs to be
> > protected.
> > The compiler will almost certainly produce code which loads f->flags once and
> > then performs 1 or 2 bit tests against the value in the register and produces
> > one of 3 possible return values based on the result.
> > There is absolutely no value in putting locking around that, especially as
> > CACHE_VALID is never cleared.
> > 
> > Maybe you imagine a re-ordering of setting CACHE_NEGATIVE and CACHE_VALID,
> > but as they are in the same cache line (and in fact in the same byte) they
> > cannot be re-ordered.  We always set CACHE_NEGATIVE before CACHE_VALID and
> > there is no way those two could get to memory in the wrong order.
> 
> The risk would be a reordering of CACHE_VALID with setting of the actual
> contents in the !NEGATIVE case, so:
> 
> 	task doing lookup		task doing update
> 	^^^^^^^^^^^^^^^^^		^^^^^^^^^^^^^^^^^
> 
> 	1. test for CACHE_VALID		3. set item->contents
> 	   & !CACHE_NEGATIVE
> 
> 	2. dereference			4. set CACHE_VALID, clear
> 	   item->contents->...		   CACHE_NEGATIVE.
> 
> As I understand it, if we want to gaurantee that item->contents is good
> at step 2, then we need a write barrier between 3 and 4, together with a
> read barrier between 1 and 2.  Taking the spinlock is overkill, but
> should accomplish the same thing, as it forces 1 to occur before 3 or
> after 4, and adds any necessary memory barriers.

So, that being the real problem, perhaps it's clearer to use explicit
memory barriers instead of more locking, and add some comments.  Also
split this into a separate patch, as in the following.

--b.
