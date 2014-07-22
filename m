Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38651 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751090AbaGVPAH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Jul 2014 11:00:07 -0400
Date: Tue, 22 Jul 2014 11:00:00 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: Jeff Layton <jeff.layton@primarydata.com>, hch@infradead.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 10/10] nfsd: give block_delegation and
 delegation_blocked its own spinlock
Message-ID: <20140722150000.GO8438@fieldses.org>
References: <1405696416-32585-1-git-send-email-jlayton@primarydata.com>
 <1405696416-32585-11-git-send-email-jlayton@primarydata.com>
 <20140721170254.0289ab9f@notabene.brown>
 <20140721074412.4d9be086@tlielax.poochiereds.net>
 <20140722064049.6478e74d@notabene.brown>
 <20140721211757.GL8438@fieldses.org>
 <20140722085025.00ca48cb@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140722085025.00ca48cb@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 22, 2014 at 08:50:25AM +1000, NeilBrown wrote:
> On Mon, 21 Jul 2014 17:17:57 -0400 "J. Bruce Fields" <bfields@fieldses.org>
> wrote:
> 
> > On Tue, Jul 22, 2014 at 06:40:49AM +1000, NeilBrown wrote:
> > > On Mon, 21 Jul 2014 07:44:12 -0400 Jeff Layton <jeff.layton@primarydata.com>
> > > wrote:
> > > 
> > > > On Mon, 21 Jul 2014 17:02:54 +1000
> > > > NeilBrown <neilb@suse.de> wrote:
> > > 
> > > > > >  	hash = arch_fast_hash(&fh->fh_base, fh->fh_size, 0);
> > > > > >  
> > > > > >  	__set_bit(hash&255, bd->set[bd->new]);
> > > > > >  	__set_bit((hash>>8)&255, bd->set[bd->new]);
> > > > > >  	__set_bit((hash>>16)&255, bd->set[bd->new]);
> > > > > > +	spin_lock(&blocked_delegations_lock);
> > > > > 
> > > > > __set_bit isn't atomic.  The spin_lock should be taken *before* these
> > > > > __set_bit() calls.
> > > > > 
> > > > > Otherwise, looks fine.
> > > > > 
> > > > > Thanks,
> > > > > NeilBrown
> > > > > 
> > > > > 
> > > > 
> > > > Ok. I guess the worry is that we could end up setting bits in the
> > > > middle of swapping the two fields? Makes sense -- fixed in my repo.
> > > 
> > > It is more subtle than that.
> > > __set_bit() will:
> > >   read a value from memory to a register
> > >   set a bit in the register
> > >   write the register back out to memory
> > > 
> > > If two threads both run __set_bit on the same word of memory at the same
> > > time, one of the updates can get lost.
> > > set_bit() (no underscore) performs an atomic RMW to avoid this, but is more
> > > expensive.
> > > spin_lock() obviously ensures the required exclusion and as we are going to
> > > take the lock anyway we may as well take it before setting bits so we can use
> > > the non-atomic (cheaper) __set_bit function.
> > > 
> > > > I'll send out the updated set later today (it also includes a few nits
> > > > that HCH pointed out last week).
> > > > 
> > > > As a side note...I wonder how much we'll get in the way of false
> > > > positives with this scheme?
> > > 
> > > If a future version of NFSv4 could allow delegations to be granted while a
> > > file is open (oh, it seems you are the only client using this file at the
> > > moment, you can treat this "open" as a delegation if you like) a few false
> > > positives would be a complete non-issue.
> > 
> > For what it's worth, I think 4.1 provides what you're asking for here;
> > see
> > 
> > 	http://tools.ietf.org/html/rfc5661#section-20.7
> > 
> > and the discussion of the various WANT_ flags in
> > 
> > 	http://tools.ietf.org/html/rfc5661#section-18.16.3
> > 
> > As far as I know none of that is implemented yet.
> > 
> > --b.
> 
> I guess I should really read the 4.1 (and 4.2) spec some day....
> Though the 20.7 section seems to be about saying "resources in general are
> available" rather than "this  specific file that you wanted a delegation for
> but didn't get one is how up for delegation"....
> But I only had a quick read so I might have missed something.

It was me that missed something, looks like CB_PUSH_DELEG is what you
actually want, not CB_RECALL_OBJ_AVAIL:

	http://tools.ietf.org/html/rfc5661#section-20.5
 
NFS4.1: it's the whole bell-and-whistle orchestra.

--b.
