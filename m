Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out3.smtp.messagingengine.com ([66.111.4.27]:50453 "EHLO
	out3.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752539Ab1EZOsI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 May 2011 10:48:08 -0400
Subject: Re: BUG() in shrink_dcache_for_umount_subtree on nfs4 mount
From: Ian Kent <raven@themaw.net>
To: Mark Moseley <moseleymark@gmail.com>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
In-Reply-To: <AANLkTimS19xXqwTgjZ7b6=D5OoNAqeGzBJk6FEFBNVAe@mail.gmail.com>
References: <20110325161156.007b2a10@tlielax.poochiereds.net>
	 <AANLkTikq+y4hEaeyc=D5HRU2Jna4MZ41C+A3=0vF4JMZ@mail.gmail.com>
	 <AANLkTinSq5Zg-Webeb-XE5MGJaohG67cBMbii6gjtWkZ@mail.gmail.com>
	 <AANLkTi=XA0dd7WJpX8DU-T_QSxnXmMfK-vLg+SpMR-cA@mail.gmail.com>
	 <20110330213748.513d0774@corrin.poochiereds.net>
	 <AANLkTimS19xXqwTgjZ7b6=D5OoNAqeGzBJk6FEFBNVAe@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 26 May 2011 22:47:54 +0800
Message-ID: <1306421274.3540.9.camel@perseus.themaw.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-03-31 at 12:17 -0700, Mark Moseley wrote:
> On Wed, Mar 30, 2011 at 6:37 PM, Jeff Layton <jlayton@redhat.com> wrote:
> > On Wed, 30 Mar 2011 14:55:00 -0700
> > Mark Moseley <moseleymark@gmail.com> wrote:
> >
> >> > I'm not 100% sure it's related (but I'm going to guess it is) but on
> >> > these same boxes, they're not actually able to reboot at the end of a
> >> > graceful shutdown. After yielding that bug and continuing with the
> >> > shutdown process, it gets all the way to exec'ing:
> >> >
> >> > reboot -d -f -i
> >> >
> >> > and then just hangs forever. I'm guessing a thread is hung still
> >> > trying to unmount things. On another box, I triggered that bug with a
> >> > umount of one top-level mount that had subtrees. When I umount'd
> >> > another top-level mount with subtrees on that same box, it's blocked
> >> > and unkillable. That second umount also logged another bug to the
> >> > kernel logs.
> >> >
> >> > In both umounts described above, the entries in /proc/mounts go away
> >> > after the umount.
> >> >
> >> > Jeff, are you at liberty to do a graceful shutdown of the box you saw
> >> > that bug on? If so, does it actually reboot?
> >>
> >>
> >> A bit more info: On the same boxes, freshly booted but with all the
> >> same mounts (even the subtrees) mounted, I don't get that bug, so it
> >> seems to happen just when there's been significant usage within those
> >> mounts. These are all read-only mounts, if it makes a difference.
> >>
> >> I was however able to trigger the bug on a box that had been running
> >> (web serving) for about 15 minutes. Here's a snippet from slabinfo
> >> right before umount'ing (let me know if more of it would help):
> >>
> >
> > No, it hung. Unfortunately, I didn't collect any info that told me
> > where it was hung though.
> >
> > I believe that's fairly typical though in situations like this. The
> > problem is that we likely have a dentry refcount leak somewhere. The
> > vfsmount refcount was low enough to allow an unmount though. Often
> > these sorts of problems lurk in error handling code...
> >
> >> # grep nfs /proc/slabinfo
> >> nfsd4_delegations      0      0    360   22    2 : tunables    0    0
> >>   0 : slabdata      0      0      0
> >> nfsd4_stateids         0      0    120   34    1 : tunables    0    0
> >>   0 : slabdata      0      0      0
> >> nfsd4_files            0      0    136   30    1 : tunables    0    0
> >>   0 : slabdata      0      0      0
> >> nfsd4_stateowners      0      0    424   38    4 : tunables    0    0
> >>   0 : slabdata      0      0      0
> >> nfs_direct_cache       0      0    136   30    1 : tunables    0    0
> >>   0 : slabdata      0      0      0
> >> nfs_write_data        46     46    704   23    4 : tunables    0    0
> >>   0 : slabdata      2      2      0
> >> nfs_read_data        207    207    704   23    4 : tunables    0    0
> >>   0 : slabdata      9      9      0
> >> nfs_inode_cache    23901  23901   1056   31    8 : tunables    0    0
> >>   0 : slabdata    771    771      0
> >> nfs_page             256    256    128   32    1 : tunables    0    0
> >>   0 : slabdata      8      8      0
> >
> > slabinfo probably won't tell us much here. If we can narrow down the
> > reproducer for this though then that would definitely help.
> > Actually, /proc/self/mountstats might give us something to go on...
> 
> Would turning on kmemleak and letting it run for a bit (luckily 15
> mins of regular use seems to be enough to trigger this bug) tell us
> anything? I can do that easily enough but I don't know if it tracks
> dentry entries.
> 
> Also I'll grab mountstats as well before/after trying a umount.
> Anything in particular within mountstats I should pay close attention
> to?

Unfortunately, this type of problem defies attempts to work out what is
causing it.

I had a similar problem with a dentry ref count leak in autofs when the
rcu-walk and vfs-automount patches were merged concurrently in 2.6.38.
The only reason I eventually found it was thanks to the eagle eye of Al
Viro. It was actually an obvious problem but in this case (where the
problem actually occurs at some point before the BUG()) it's extremely
difficult to find a way to work out where to look and that's the kick!
All that can be done is to nail down a reproducer (which Jeff is working
on I believe) and hope we can work out a way to target the debugging
from there.

You did say you have clear evidence that autofs in 2.6.38 is not part of
the problem, yes? If you are using autofs then we need to add the 2.6.39
autofs patches to ensure we don't get more confused between the two
problems.

Ian

