Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:53277 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757155Ab1D0XXI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Apr 2011 19:23:08 -0400
Received: by pvg12 with SMTP id 12so1460400pvg.19
        for <linux-nfs@vger.kernel.org>; Wed, 27 Apr 2011 16:23:07 -0700 (PDT)
In-Reply-To: <AANLkTi=dinD0KeHDb1S8k6L0yfhGsAxVxiz7TwszVQ7E@mail.gmail.com>
References: <20110325161156.007b2a10@tlielax.poochiereds.net>
	<AANLkTikq+y4hEaeyc=D5HRU2Jna4MZ41C+A3=0vF4JMZ@mail.gmail.com>
	<AANLkTinSq5Zg-Webeb-XE5MGJaohG67cBMbii6gjtWkZ@mail.gmail.com>
	<AANLkTi=XA0dd7WJpX8DU-T_QSxnXmMfK-vLg+SpMR-cA@mail.gmail.com>
	<20110330213748.513d0774@corrin.poochiereds.net>
	<AANLkTimS19xXqwTgjZ7b6=D5OoNAqeGzBJk6FEFBNVAe@mail.gmail.com>
	<AANLkTi=dinD0KeHDb1S8k6L0yfhGsAxVxiz7TwszVQ7E@mail.gmail.com>
Date: Wed, 27 Apr 2011 16:23:07 -0700
Message-ID: <BANLkTik_PML+cjge4e8ne-mq-BwSEjZMZg@mail.gmail.com>
Subject: Re: BUG() in shrink_dcache_for_umount_subtree on nfs4 mount
From: Mark Moseley <moseleymark@gmail.com>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
To: unlisted-recipients:; (no To-header on input)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Mar 31, 2011 at 4:21 PM, Mark Moseley <moseleymark@gmail.com> wrote:
> On Thu, Mar 31, 2011 at 12:17 PM, Mark Moseley <moseleymark@gmail.com> wrote:
>> On Wed, Mar 30, 2011 at 6:37 PM, Jeff Layton <jlayton@redhat.com> wrote:
>>> On Wed, 30 Mar 2011 14:55:00 -0700
>>> Mark Moseley <moseleymark@gmail.com> wrote:
>>>
>>>> > I'm not 100% sure it's related (but I'm going to guess it is) but on
>>>> > these same boxes, they're not actually able to reboot at the end of a
>>>> > graceful shutdown. After yielding that bug and continuing with the
>>>> > shutdown process, it gets all the way to exec'ing:
>>>> >
>>>> > reboot -d -f -i
>>>> >
>>>> > and then just hangs forever. I'm guessing a thread is hung still
>>>> > trying to unmount things. On another box, I triggered that bug with a
>>>> > umount of one top-level mount that had subtrees. When I umount'd
>>>> > another top-level mount with subtrees on that same box, it's blocked
>>>> > and unkillable. That second umount also logged another bug to the
>>>> > kernel logs.
>>>> >
>>>> > In both umounts described above, the entries in /proc/mounts go away
>>>> > after the umount.
>>>> >
>>>> > Jeff, are you at liberty to do a graceful shutdown of the box you saw
>>>> > that bug on? If so, does it actually reboot?
>>>>
>>>>
>>>> A bit more info: On the same boxes, freshly booted but with all the
>>>> same mounts (even the subtrees) mounted, I don't get that bug, so it
>>>> seems to happen just when there's been significant usage within those
>>>> mounts. These are all read-only mounts, if it makes a difference.
>>>>
>>>> I was however able to trigger the bug on a box that had been running
>>>> (web serving) for about 15 minutes. Here's a snippet from slabinfo
>>>> right before umount'ing (let me know if more of it would help):
>>>>
>>>
>>> No, it hung. Unfortunately, I didn't collect any info that told me
>>> where it was hung though.
>>>
>>> I believe that's fairly typical though in situations like this. The
>>> problem is that we likely have a dentry refcount leak somewhere. The
>>> vfsmount refcount was low enough to allow an unmount though. Often
>>> these sorts of problems lurk in error handling code...
>>>
>>>> # grep nfs /proc/slabinfo
>>>> nfsd4_delegations      0      0    360   22    2 : tunables    0    0
>>>>   0 : slabdata      0      0      0
>>>> nfsd4_stateids         0      0    120   34    1 : tunables    0    0
>>>>   0 : slabdata      0      0      0
>>>> nfsd4_files            0      0    136   30    1 : tunables    0    0
>>>>   0 : slabdata      0      0      0
>>>> nfsd4_stateowners      0      0    424   38    4 : tunables    0    0
>>>>   0 : slabdata      0      0      0
>>>> nfs_direct_cache       0      0    136   30    1 : tunables    0    0
>>>>   0 : slabdata      0      0      0
>>>> nfs_write_data        46     46    704   23    4 : tunables    0    0
>>>>   0 : slabdata      2      2      0
>>>> nfs_read_data        207    207    704   23    4 : tunables    0    0
>>>>   0 : slabdata      9      9      0
>>>> nfs_inode_cache    23901  23901   1056   31    8 : tunables    0    0
>>>>   0 : slabdata    771    771      0
>>>> nfs_page             256    256    128   32    1 : tunables    0    0
>>>>   0 : slabdata      8      8      0
>>>
>>> slabinfo probably won't tell us much here. If we can narrow down the
>>> reproducer for this though then that would definitely help.
>>> Actually, /proc/self/mountstats might give us something to go on...
>>
>> Would turning on kmemleak and letting it run for a bit (luckily 15
>> mins of regular use seems to be enough to trigger this bug) tell us
>> anything? I can do that easily enough but I don't know if it tracks
>> dentry entries.
>>
>> Also I'll grab mountstats as well before/after trying a umount.
>> Anything in particular within mountstats I should pay close attention
>> to?
>>
>
> I've been trying random things too, just to see if anything shakes out:
>
> * I tried mounting the top-level mount with the subtree mounts via TCP
> (was UDP), but I still get that error.
>
> * Mounting normally (UDP), if I iterate through the subtrees and
> unmount them *first* (so that there's zero subtrees left over) and
> then unmount the top-level mount, I *don't* get that error. And a
> umount at shutdown proceeds without error and the final call to reboot
> works just fine (instead of hanging indefinitely). So unmounting all
> the subtrees first cleans things up sufficiently.
>
> One random/irrelevant but slightly interesting thing is that when I
> trigger that error, it also bumps kernel.printk from "1 7 1 4" to "15
> 7 1 4". I've not seen that before.
>

I posted this to bugzilla a while back but I figured I'd paste it here too:

-----------------------------------------------------------------------------------------------------

I've been getting bit by the exact same bug and been bisecting for the past
couple of weeks. It's slow going as it can sometimes take a day for the BUG()
to show up (though can also at time take 10 minutes). And I've also seen it
more than once where something was good after a day and then BUG()'d later on,
just to make things more complicated. So the upshot is that while I feel
confident enough about this latest batch of bisecting to post it here, I
wouldn't bet my life on it. I hope this isn't a case where bisecting just shows
where the bug gets exposed but not where it actually got planted :)

Incidentally, I tried the patch from the top of this thread and it didn't seem
to make a difference. I still got bit.

I've posted on the linux-fsdevel thread that Jeff Layton started about it,
http://www.spinics.net/lists/linux-nfs/msg20280.html if you need more details
on my setup (though I'll be happy to provide anything else you need). Though in
that thread you'll see that I'm not using autofs explicitly, the Netapp GX
cluster NFS appears to use autofs to do the implicit submounts (I'm not 100%
sure that's the correct terminology, so hopefully you know what I mean).

Here's my bisect log, ending up at commit
e61da20a50d21725ff27571a6dff9468e4fb7146

git bisect start 'fs'
# good: [3c0eee3fe6a3a1c745379547c7e7c904aa64f6d5] Linux 2.6.37
git bisect good 3c0eee3fe6a3a1c745379547c7e7c904aa64f6d5
# bad: [c56eb8fb6dccb83d9fe62fd4dc00c834de9bc470] Linux 2.6.38-rc1
git bisect bad c56eb8fb6dccb83d9fe62fd4dc00c834de9bc470
# good: [7c955fca3e1d8132982148267d9efcafae849bb6] Merge branch 'for_linus' of
git://git.kernel.org/pub/scm/linux/kernel/git/jack/linux-udf-2.6
git bisect good 7c955fca3e1d8132982148267d9efcafae849bb6
# good: [c32b0d4b3f19c2f5d29568f8b7b72b61693f1277] fs/mpage.c: consolidate code
git bisect good c32b0d4b3f19c2f5d29568f8b7b72b61693f1277
# bad: [f8206b925fb0eba3a11839419be118b09105d7b1] Merge branch 'for-linus' of
git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs-2.6
git bisect bad f8206b925fb0eba3a11839419be118b09105d7b1
# good: [a8f2800b4f7b76cecb7209cb6a7d2b14904fc711] nfsd4: fix callback
restarting
git bisect good a8f2800b4f7b76cecb7209cb6a7d2b14904fc711
# bad: [6651149371b842715906311b4631b8489cebf7e8] autofs4: Clean up
autofs4_free_ino()
git bisect bad 6651149371b842715906311b4631b8489cebf7e8
# good: [0ad53eeefcbb2620b6a71ffdaad4add20b450b8b] afs: add afs_wq and use it
instead of the system workqueue
git bisect good 0ad53eeefcbb2620b6a71ffdaad4add20b450b8b
# good: [01c64feac45cea1317263eabc4f7ee1b240f297f] CIFS: Use d_automount()
rather than abusing follow_link()
git bisect good 01c64feac45cea1317263eabc4f7ee1b240f297f
# good: [b5b801779d59165c4ecf1009009109545bd1f642] autofs4: Add d_manage()
dentry operation
git bisect good b5b801779d59165c4ecf1009009109545bd1f642
# bad: [e61da20a50d21725ff27571a6dff9468e4fb7146] autofs4: Clean up inode
operations
git bisect bad e61da20a50d21725ff27571a6dff9468e4fb7146
# good: [8c13a676d5a56495c350f3141824a5ef6c6b4606] autofs4: Remove unused code
git bisect good 8c13a676d5a56495c350f3141824a5ef6c6b4606
