Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37347 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754906AbaGRTgE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Jul 2014 15:36:04 -0400
Date: Fri, 18 Jul 2014 15:35:59 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: hch@infradead.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 01/10] nfsd: Protect the nfs4_file delegation fields
 using the fi_lock
Message-ID: <20140718193559.GD12801@fieldses.org>
References: <1405696416-32585-1-git-send-email-jlayton@primarydata.com>
 <1405696416-32585-2-git-send-email-jlayton@primarydata.com>
 <20140718162825.GA8811@fieldses.org>
 <20140718133140.6a26ea4d@f20.localdomain>
 <20140718174957.GA12801@fieldses.org>
 <20140718150404.3d1e094c@tlielax.poochiereds.net>
 <20140718192149.GC12801@fieldses.org>
 <20140718153224.1ca7815c@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140718153224.1ca7815c@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 18, 2014 at 03:32:24PM -0400, Jeff Layton wrote:
> On Fri, 18 Jul 2014 15:21:49 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Fri, Jul 18, 2014 at 03:04:04PM -0400, Jeff Layton wrote:
> > > On Fri, 18 Jul 2014 13:49:57 -0400
> > > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > > 
> > > > On Fri, Jul 18, 2014 at 01:31:40PM -0400, Jeff Layton wrote:
> > > > > On Fri, 18 Jul 2014 12:28:25 -0400
> > > > > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > > > > 
> > > > > > On Fri, Jul 18, 2014 at 11:13:27AM -0400, Jeff Layton wrote:
> > > > > > > Move more of the delegation fields to be protected by the fi_lock. It's
> > > > > > > more granular than the state_lock and in later patches we'll want to
> > > > > > > be able to rely on it in addition to the state_lock.
> > > > > > > 
> > > > > > > Also, the current code in nfs4_setlease calls vfs_setlease and uses the
> > > > > > > client_mutex to ensure that it doesn't disappear before we can hash the
> > > > > > > delegation. With the client_mutex gone, we'll have a potential race
> > > > > > > condition.
> > > > > > > 
> > > > > > > It's possible that the delegation could be recalled after we acquire the
> > > > > > > lease but before we ever get around to hashing it. If that happens, then
> > > > > > > we'd have a nfs4_file that *thinks* it has a delegation, when it
> > > > > > > actually has none.
> > > > > > 
> > > > > > I understand now, thanks: so the lease break code walks the list of
> > > > > > delegations associated with the file, finds none, and issues no recall,
> > > > > > but the open code continues merrily on and returns a delegation, with
> > > > > > the result that we return the client a delegation that will never be
> > > > > > recalled.
> > > > > > 
> > > > > > That could be worded more carefully, and would be worth a separate patch
> > > > > > (since the bug predates the new locking).
> > > > > > 
> > > > > 
> > > > > Yes, that's basically correct. I'd have to think about how to fix that
> > > > > with the current code. It's probably doable if you think it's
> > > > > worthwhile, but I'll need to rebase this set on top of it.
> > > > 
> > > > Well, I was wondering if this patch could just be split in two, no need
> > > > to backport further than that.
> > > > 
> > > 
> > > Erm, now that I've looked, I don't think it'll be that easy. The key
> > > here is to ensure that fi_had_conflict is set while holding the
> > > fi_lock. The trick here is that we need to take it in nfs4_setlease as
> > > well, and check the flag before hashing the delegation without dropping
> > > the fi_lock.
> > 
> > OK, I'll live.  For the sake of anyone that actually runs across that
> > bug I'll update the summary and changelog to emphasize the bugfix over
> > the locking change.
> > 
> 
> Ok, thanks.
> 
> > > > > > > Attempt to acquire a delegation. If that succeeds, take the spinlocks
> > > > > > > and then check to see if the file has had a conflict show up since then.
> > > > > > > If it has, then we assume that the lease is no longer valid and that
> > > > > > > we shouldn't hand out a delegation.
> > > > > > > 
> > > > > > > There's also one more potential (but very unlikely) problem. If the
> > > > > > > lease is broken before the delegation is hashed, then it could leak.
> > > > > > > In the event that the fi_delegations list is empty, reset the
> > > > > > > fl_break_time to jiffies so that it's cleaned up ASAP by
> > > > > > > the normal lease handling code.
> > > > > > 
> > > > > > Is there actually any guarantee time_out_leases() will get called on
> > > > > > this inode again?
> > > > > > 
> > > > > > --b.
> > > > > > 
> > > > > 
> > > > > Yes. Lease breaks are handled in two phases. We walk the i_flock list
> > > > > and issue a ->lm_break on each lease, and then later we walk the list
> > > > > again after putting the task to sleep, and try to time out the leases.
> > > > > So by doing this, we should ensure that the task will wake up after
> > > > > sleeping and delete it.
> > > > 
> > > > In the case of an interrupt or a nonblocking break (which is what nfsd
> > > > will do), then time_out_leases isn't called again from what I could
> > > > tell.
> > > > 
> > > > --b.
> > > > 
> > > 
> > > In both cases, time_out_leases is still called at the beginning of
> > > __break_lease. So the next time that function is called it'll
> > > get cleaned up, or when the filp is closed (in locks_remove_file).
> > 
> > Right, but there's no guarantee another break_lease comes.  E.g. the
> > process waiting on the lease break could get killed.
> > 
> > --b.
> 
> In that case, there's no harm in leaving the lease on the list until
> the filp closes.

Doh, of course.

> FWIW, I looked at trying to just remove the lease from the list, but
> that's not safe from the lm_break callback. So, I think this is the
> best we can reasonably do here.

Makes sense, thanks!

--b.
