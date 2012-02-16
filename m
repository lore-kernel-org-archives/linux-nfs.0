Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36147 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751412Ab2BPLvl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Feb 2012 06:51:41 -0500
Date: Thu, 16 Feb 2012 06:51:33 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Nick Piggin <npiggin@gmail.com>,
        Nick Piggin <npiggin@kernel.dk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH] fs/dcache: allow __d_obtain_alias() to return unhashed
 dentries
Message-ID: <20120216115133.GA20279@fieldses.org>
References: <20101227234641.GA22248@fieldses.org>
 <20110118204509.GA10903@fieldses.org>
 <AANLkTikL2CDSWQJ1QH_Y4G-j70Vd=VesNMMnYTmMGHC9@mail.gmail.com>
 <20110118220817.GF10903@fieldses.org>
 <20110308181320.GA15566@fieldses.org>
 <20110310105821.GE22723@ZenIV.linux.org.uk>
 <20110311150749.2fa2be66@notabene.brown>
 <20120214170300.GA4309@fieldses.org>
 <20120215165633.GE12490@fieldses.org>
 <20120216140603.08cb4900@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120216140603.08cb4900@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 16, 2012 at 02:06:03PM +1100, NeilBrown wrote:
> On Wed, 15 Feb 2012 11:56:33 -0500 "J. Bruce Fields" <bfields@fieldses.org>
> wrote:
> 
> > On Tue, Feb 14, 2012 at 12:03:00PM -0500, J. Bruce Fields wrote:
> > > On Fri, Mar 11, 2011 at 03:07:49PM +1100, NeilBrown wrote:
> > > > On Thu, 10 Mar 2011 10:58:21 +0000 Al Viro <viro@ZenIV.linux.org.uk> wrote:
> > > > 
> > > > > On Tue, Mar 08, 2011 at 01:13:20PM -0500, J. Bruce Fields wrote:
> > > > > 
> > > > > > Al, do you have this in your queue to look at?  Need me to resend?  Or
> > > > > > should it take some other route?
> > > > > 
> > > > > It's in queue, but I'd be a lot happier if I understood what's going on
> > > > > with __d_find_alias() elsewhere.  Namely, in d_splice_alias().  The thing
> > > > > is, unless I'm missing something we ought to use __d_find_any_alias()
> > > > > there as well.  Directories really, _really_ should not have more than
> > > > > one alias.  And what we get is really weird:
> > > > > 	* find (the only) alias
> > > > > 	* if it doesn't exist, create one (OK, no problem)
> > > > > 	* if it does exist and happens to be IS_ROOT and DCACHE_DISCONNECTED,
> > > > > move it (also fine, modulo rather useless BUG_ON() in there)
> > > > > 	* if it does exist and either isn't IS_ROOT or not DCACHE_DISCONNECTED,
> > > > > add a new alias and say nothing.
> > > > > 
> > > > > The last part looks very strange.  I'd been staring at the history of this
> > > > > function and I _think_ it's a rudiment of period when we used that stuff for
> > > > > non-directories as well.  It used to be directory-only; then Neil had
> > > > > switched it to non-directories as well (in "Fix disconnected dentries on NFS
> > > > > exports" back in 2004), adding want_discon argument to __d_find_alias() in
> > > > > process and using it instead of open-coded equivalent of __d_find_any_alias().
> > > > > Then, two years later, in "knfsd: close a race-opportunity in d_splice_alias"
> > > > > he'd made that code directory-only again, at which point we arrived to the
> > > > > current situation.
> > > > > 
> > > > > Neil, is there some reason I'm missing that makes __d_find_alias() right in
> > > > > there?  And do we still need the second argument in __d_find_alias()?
> > > > > 
> > > > > Anyway, Bruce's patch goes in tonight's push, but I'd love to see that
> > > > > mess cleaned up as well or at least explained.
> > > 
> > > Nothing like seeing somebody actually run across a bug here to motivate
> > > getting back to this....
> > > 
> > > So, like Al I'm wondering whether the __d_find_alias in d_splice_alias
> > > should be a __d_find_any_alias.
> > > 
> > > Disclaimer: the bug manifested in rhel5, and I haven't looked closely at
> > > upstream yet, though it seems like it would have the same problem.
> > > 
> > > In the particular case I'm seeing, the directory already has an alias
> > > that is UNHASHED (but not DISCONNECTED).  So d_splice_alias adds a
> > > second alias.
> > 
> > The reproducer I was using against rhel5 isn't going to work against
> > upstream, because it depended on the dentry_unhash() call in vfs_rmdir()
> > to create that UNHASHED dentry.
> > 
> > Though I think there's still code that can leave UNHASHED dentries
> > around still on the alias list.  I'll look some more....
> 
> I was going ask how you managed to get an 'unhashed' dentry which was not
> DISCONNECTED, and belonged to a directory that could be the subject of
> d_splice_alias (that implies it has a name).
> 
> The bug sounds like a race between lookup and rmdir, which should be
> prevented by i_mutex.

The rhel5 race is a bit more complicated than that: a filehandle lookup
has to come in to grab the unhashed dentry before rmdir drops the parent
i_mutex, and then the lookup comes along later.

I suspect that this is actually expected, and that it's not safe for us
to assume that directories will lose any UNHASHED dentries before
relevant locks are dropped.

I'm seeing something similar happening on an upstream kernel, so I'll
try to figure out where that's coming from now....

> I think that using __d_find_any_alias would just be papering over the
> problem, and would trigger a BUG_ON when it returned a non-DISCONNECTED alias.

Right, I throw away that BUG_ON as well.  Tested on rhel5 only.

--b.
