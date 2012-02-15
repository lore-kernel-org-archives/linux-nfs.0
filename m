Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58995 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751433Ab2BOQ4l (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Feb 2012 11:56:41 -0500
Date: Wed, 15 Feb 2012 11:56:33 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Nick Piggin <npiggin@gmail.com>,
        Nick Piggin <npiggin@kernel.dk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH] fs/dcache: allow __d_obtain_alias() to return unhashed
 dentries
Message-ID: <20120215165633.GE12490@fieldses.org>
References: <20101218161609.GA22150@fieldses.org>
 <AANLkTingRv_gtRSctGzMfYrKg02M_sKj97HSQPRm_mA_@mail.gmail.com>
 <20101227234641.GA22248@fieldses.org>
 <20110118204509.GA10903@fieldses.org>
 <AANLkTikL2CDSWQJ1QH_Y4G-j70Vd=VesNMMnYTmMGHC9@mail.gmail.com>
 <20110118220817.GF10903@fieldses.org>
 <20110308181320.GA15566@fieldses.org>
 <20110310105821.GE22723@ZenIV.linux.org.uk>
 <20110311150749.2fa2be66@notabene.brown>
 <20120214170300.GA4309@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120214170300.GA4309@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 14, 2012 at 12:03:00PM -0500, J. Bruce Fields wrote:
> On Fri, Mar 11, 2011 at 03:07:49PM +1100, NeilBrown wrote:
> > On Thu, 10 Mar 2011 10:58:21 +0000 Al Viro <viro@ZenIV.linux.org.uk> wrote:
> > 
> > > On Tue, Mar 08, 2011 at 01:13:20PM -0500, J. Bruce Fields wrote:
> > > 
> > > > Al, do you have this in your queue to look at?  Need me to resend?  Or
> > > > should it take some other route?
> > > 
> > > It's in queue, but I'd be a lot happier if I understood what's going on
> > > with __d_find_alias() elsewhere.  Namely, in d_splice_alias().  The thing
> > > is, unless I'm missing something we ought to use __d_find_any_alias()
> > > there as well.  Directories really, _really_ should not have more than
> > > one alias.  And what we get is really weird:
> > > 	* find (the only) alias
> > > 	* if it doesn't exist, create one (OK, no problem)
> > > 	* if it does exist and happens to be IS_ROOT and DCACHE_DISCONNECTED,
> > > move it (also fine, modulo rather useless BUG_ON() in there)
> > > 	* if it does exist and either isn't IS_ROOT or not DCACHE_DISCONNECTED,
> > > add a new alias and say nothing.
> > > 
> > > The last part looks very strange.  I'd been staring at the history of this
> > > function and I _think_ it's a rudiment of period when we used that stuff for
> > > non-directories as well.  It used to be directory-only; then Neil had
> > > switched it to non-directories as well (in "Fix disconnected dentries on NFS
> > > exports" back in 2004), adding want_discon argument to __d_find_alias() in
> > > process and using it instead of open-coded equivalent of __d_find_any_alias().
> > > Then, two years later, in "knfsd: close a race-opportunity in d_splice_alias"
> > > he'd made that code directory-only again, at which point we arrived to the
> > > current situation.
> > > 
> > > Neil, is there some reason I'm missing that makes __d_find_alias() right in
> > > there?  And do we still need the second argument in __d_find_alias()?
> > > 
> > > Anyway, Bruce's patch goes in tonight's push, but I'd love to see that
> > > mess cleaned up as well or at least explained.
> 
> Nothing like seeing somebody actually run across a bug here to motivate
> getting back to this....
> 
> So, like Al I'm wondering whether the __d_find_alias in d_splice_alias
> should be a __d_find_any_alias.
> 
> Disclaimer: the bug manifested in rhel5, and I haven't looked closely at
> upstream yet, though it seems like it would have the same problem.
> 
> In the particular case I'm seeing, the directory already has an alias
> that is UNHASHED (but not DISCONNECTED).  So d_splice_alias adds a
> second alias.

The reproducer I was using against rhel5 isn't going to work against
upstream, because it depended on the dentry_unhash() call in vfs_rmdir()
to create that UNHASHED dentry.

Though I think there's still code that can leave UNHASHED dentries
around still on the alias list.  I'll look some more....

--b.


> 
> (And we notice because a rename happens to pick up one of each, and the
> rename locking then tries to take the parent's i_mutex twice (since the
> rename code think it's dealing with a cross-directory rename)).
> 
> Using __d_find_any_alias seems to fix the problem.
> 
> Would rehashing an UNHASHED dentry here violate any important assumptions?
> 
> >    I'm a bit uncomfortable that d_splice_alias drops all locks before
> >    calling d_move.  Normally when d_move is called, both directories are
> >    locked in some way.  In the case the source is not a directory bit
> >    is the state of being anonymous.  Theoretically two calls to
> >    d_splice_alias on the same inode could try to d_move the same
> >    anonymous dentry to two different places, which would be bad.
> >    So I think some locking is needed there.
> 
> I think d_splice_alias is only ever called from lookup, under the
> parent's i_mutex?
> 
> So if we have two tasks in the d_move here, then the two callers must be
> doing lookups in two different directories, and holding the i_mutex on
> both of them.
> 
> The directory can't have been renamed while either caller was holding
> the i_mutex, so this is really a directory that's returned on lookup
> from two different parents.
> 
> That sounds like a bug already.  Could it happen on a corrupted
> filesystem maybe?
> 
> --b.
