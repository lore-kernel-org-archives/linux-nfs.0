From: Neil Brown <neilb@suse.de>
Subject: Re: Thoughts about cache consistency and directories in particular.
Date: Sat, 21 Feb 2009 08:04:38 +1100
Message-ID: <18847.6886.50844.260910@notabene.brown>
References: <18846.4842.625445.980681@notabene.brown>
	<20090220182350.GB1104@fieldses.org>
	<18847.2286.101191.989726@notabene.brown>
	<20090220201424.GG1104@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:47115 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752490AbZBTVEq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Feb 2009 16:04:46 -0500
In-Reply-To: message from J. Bruce Fields on Friday February 20
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Friday February 20, bfields@fieldses.org wrote:
> On Sat, Feb 21, 2009 at 06:47:58AM +1100, Neil Brown wrote:
> > 
> > I cannot see how there is a regression here.  Subsequent getattrs will
> > show all modifications (if you wait at least one second).
> > The first gettattr returns '-0.000000001', which is different from any
> > previously returned mtime.
> > Any subsequent getattr will return 0.999999999 or 1, depending on when
> > it arrives.
> 
> Sorry, I guess I misread "smallest difference that can be reported by
> the protocol" as "smallest difference supported by the filesystem"!
> 
> The former is currently *always* smaller than the latter, so you're
> reporting an mtime that will never arise in any other way.  So you're
> right, this results in strictly more cache revalidations in every case.
> 
> It may turn out that this mtime-1 case ends up being the typical case,
> since a single logical file modification may appear as multiple writes
> on the server, and those are likely to come in rapid succession.

When you look at a file that is changing, yes.  When you look at a
file that hasn't changed for a while, you just get normal mtime.

> 
> A "make" that takes less than one second, on an ext3 export, may result
> in targets with earlier mtimes than sources.

No.  If they were both changed in the last second, they will both have
1 nanosecond subtracted from the mtime, so they will still look like
they have the same mtime.

> 
> (Why not mtime+1?  And why not ctime?)

Not "mtime + 1" because mtime should normally be monotonically
increasing.
If you touch a file into the future, then when that moment comes, its
mtime will jump backwards 1 nanosecond, then jump forwards again.  But
I don't think that is a problem.

Why not what ctime?
I agree with Trond that we need to apply this adjustment to ctime too.
But we cannot set mtime == ctime.  That would just be wrong.


> 
> > The only possible regression is that sometimes we will flush the cache
> > when previously we didn't.  In each case where that changes, the
> > client can not possible know whether it needs to or not, so flushing
> > rather than not flushing is the safest option.
> > 
> > > 
> > > By the way, I have one sadly neglected todo here: ext4 has a real nfsv4
> > > changeattribute, which needs to be hooked up to the nfsd code.
> > 
> > Does it?
> > I just had a quick look, found that it stores a 64 bit number on disk
> > which is stored in inode->i_version.
> > And this is incremented for directory operations.  But it doesn't seem
> > to be changed for file operations.
> > 
> > But maybe I missed something.
> 
> After some mucking around with git and git grep... looks like the
> inode_inc_iversion() calls do the job.  Note there's an i_version mount
> option that's required.

Ahh.... Now if only they had called that function
"inode_inc_i_version", then my grep would have found it...

So in nfsd we can simply do:

 if (IS_I_VERSION(fhp->fh_dentry->d_inode)) {
	change_attribute = fhp->fh_dentry->d_inode->i_version;
 } else {
        change_attribute = kstat.ctime;
 }

??

NeilBrown
