Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:57762 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1732212AbeHCD6o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 2 Aug 2018 23:58:44 -0400
Date: Fri, 3 Aug 2018 02:04:46 +0000
From: Mark Fasheh <mfasheh@suse.de>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org,
        Andrew Morton <akpm@linux-foundation.org>,
        Amir Goldstein <amir73il@gmail.com>,
        linux-unionfs@vger.kernel.org, Jeff Mahoney <jeffm@suse.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/4] nfs: check for NULL vfsmount in nfs_getattr
Message-ID: <20180803020446.GF20761@wotan.suse.de>
Reply-To: Mark Fasheh <mfasheh@suse.de>
References: <20180731211045.5671-1-mfasheh@suse.de>
 <20180731211045.5671-3-mfasheh@suse.de>
 <20180731221605.GK30522@ZenIV.linux.org.uk>
 <20180731225157.GA20761@wotan.suse.de>
 <20180802004347.GV30522@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180802004347.GV30522@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Al,

On Thu, Aug 02, 2018 at 01:43:48AM +0100, Al Viro wrote:
> On Tue, Jul 31, 2018 at 10:51:57PM +0000, Mark Fasheh wrote:
> > Hi Al,
> > 
> > On Tue, Jul 31, 2018 at 11:16:05PM +0100, Al Viro wrote:
> > > On Tue, Jul 31, 2018 at 02:10:43PM -0700, Mark Fasheh wrote:
> > > > ->getattr from inside the kernel won't always have a vfsmount, check for
> > > > this.
> > > 
> > > Really?  Where would that happen?
> > 
> > It happens in my first patch. FWIW, I'm not tied to that particular bit of
> > code, or even this (latest) approach. I would actually very much appreciate
> > your input into how we might fix the problem we have where we are sometimes
> > not exporting a correct ino/dev pair to user space.
> 
> Which callers would those be?  I don't see anything in your series that
> wouldn't have vfsmount at hand...

You are correct - there's no callers in my patch series that don't have a
vfsmount available. I can remove patch #2 and pass the vfsmount through.

At some point I was trying to plug this callback into audit_copy_inode()
which AFAICT doesn't have a vfsmount to pass in when we're coming from
vfs_rename (vfs_rename() -> fsnotify_move()). I will eventually have to go
back and handle this for audit though so it seems worth mentioning here.


> > I have a good break-down of the problem and possible solutions here:
> > 
> > https://www.spinics.net/lists/linux-fsdevel/msg128003.html
> 
> btrfs pulling odd crap with device numbers is a problem, but this is far from
> the most obvious unpleasantness caused by that - e.g. userland code expecting
> that unequal st_dev for directory and subdirectory means that we have
> a mountpoint there.  Or assuming it can compare that to st_dev of mountpoints
> (or, indeed, the values in /proc/self/mountinfo) to find which fs it's on...

Indeed, I agree that all of these are pretty gross and things I'd like to
see fixed - I have to deal with subvolume boundaries in some of my own
software. I know Jeff is working on some code to give subvolumes their own
vfsmount but that wouldn't help with our device reporting unless we did
something like move s_dev from the super_block to the vfsmount (also an idea
that's been thrown around).


> /proc/*/maps is unfortunate, but it does contain the pathnames, doesn't it?
> What _real_ problems are there - the ones where we don't have a saner solution?
> Note that /proc/locks is (a) FPOS interface and (b) unsuitable for your
> approach anyway.

Yeah I see now that /proc/locks isn't going to work with something calling
into ->getattr().

Primarily my concerns are /proc/*/maps and audit (which is recording ino/dev
pairs). Even though /proc/*/maps prints a path it is still a problem as
there is no way for userspace to verify that the inode it stats using that
path is the correct one.

I don't mean to overstate the case but the /proc/*/maps issue is real to us
(SUSE) in that it's produced bug reports. For example, lsof produces
confusing output when we run with a btrfs subvolume as root.

As far as problems that can't be solved by this approach - there are
tracepoints in events/lock.h and events/writeback.h which ought to be
reporting the correct ino/dev pairs. There's of course /proc/locks too. I
acknowledge that whether those are severe enough to warrant a different
approach might be up for debate.

Thanks,
	--Mark
