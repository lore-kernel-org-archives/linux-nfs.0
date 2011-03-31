Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41881 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755464Ab1CaBhM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Mar 2011 21:37:12 -0400
Date: Wed, 30 Mar 2011 21:37:48 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Mark Moseley <moseleymark@gmail.com>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: BUG() in shrink_dcache_for_umount_subtree on nfs4 mount
Message-ID: <20110330213748.513d0774@corrin.poochiereds.net>
In-Reply-To: <AANLkTi=XA0dd7WJpX8DU-T_QSxnXmMfK-vLg+SpMR-cA@mail.gmail.com>
References: <20110325161156.007b2a10@tlielax.poochiereds.net>
	<AANLkTikq+y4hEaeyc=D5HRU2Jna4MZ41C+A3=0vF4JMZ@mail.gmail.com>
	<AANLkTinSq5Zg-Webeb-XE5MGJaohG67cBMbii6gjtWkZ@mail.gmail.com>
	<AANLkTi=XA0dd7WJpX8DU-T_QSxnXmMfK-vLg+SpMR-cA@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 30 Mar 2011 14:55:00 -0700
Mark Moseley <moseleymark@gmail.com> wrote:

> > I'm not 100% sure it's related (but I'm going to guess it is) but on
> > these same boxes, they're not actually able to reboot at the end of a
> > graceful shutdown. After yielding that bug and continuing with the
> > shutdown process, it gets all the way to exec'ing:
> >
> > reboot -d -f -i
> >
> > and then just hangs forever. I'm guessing a thread is hung still
> > trying to unmount things. On another box, I triggered that bug with a
> > umount of one top-level mount that had subtrees. When I umount'd
> > another top-level mount with subtrees on that same box, it's blocked
> > and unkillable. That second umount also logged another bug to the
> > kernel logs.
> >
> > In both umounts described above, the entries in /proc/mounts go away
> > after the umount.
> >
> > Jeff, are you at liberty to do a graceful shutdown of the box you saw
> > that bug on? If so, does it actually reboot?
> 
> 
> A bit more info: On the same boxes, freshly booted but with all the
> same mounts (even the subtrees) mounted, I don't get that bug, so it
> seems to happen just when there's been significant usage within those
> mounts. These are all read-only mounts, if it makes a difference.
> 
> I was however able to trigger the bug on a box that had been running
> (web serving) for about 15 minutes. Here's a snippet from slabinfo
> right before umount'ing (let me know if more of it would help):
> 

No, it hung. Unfortunately, I didn't collect any info that told me
where it was hung though.

I believe that's fairly typical though in situations like this. The
problem is that we likely have a dentry refcount leak somewhere. The
vfsmount refcount was low enough to allow an unmount though. Often
these sorts of problems lurk in error handling code...

> # grep nfs /proc/slabinfo
> nfsd4_delegations      0      0    360   22    2 : tunables    0    0
>   0 : slabdata      0      0      0
> nfsd4_stateids         0      0    120   34    1 : tunables    0    0
>   0 : slabdata      0      0      0
> nfsd4_files            0      0    136   30    1 : tunables    0    0
>   0 : slabdata      0      0      0
> nfsd4_stateowners      0      0    424   38    4 : tunables    0    0
>   0 : slabdata      0      0      0
> nfs_direct_cache       0      0    136   30    1 : tunables    0    0
>   0 : slabdata      0      0      0
> nfs_write_data        46     46    704   23    4 : tunables    0    0
>   0 : slabdata      2      2      0
> nfs_read_data        207    207    704   23    4 : tunables    0    0
>   0 : slabdata      9      9      0
> nfs_inode_cache    23901  23901   1056   31    8 : tunables    0    0
>   0 : slabdata    771    771      0
> nfs_page             256    256    128   32    1 : tunables    0    0
>   0 : slabdata      8      8      0

slabinfo probably won't tell us much here. If we can narrow down the
reproducer for this though then that would definitely help.
Actually, /proc/self/mountstats might give us something to go on...

-- 
Jeff Layton <jlayton@redhat.com>
