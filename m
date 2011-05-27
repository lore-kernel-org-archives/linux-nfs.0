Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-px0-f179.google.com ([209.85.212.179]:50651 "EHLO
	mail-px0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932118Ab1E0TvN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 May 2011 15:51:13 -0400
In-Reply-To: <1306422152.3540.21.camel@perseus.themaw.net>
References: <20110325161156.007b2a10@tlielax.poochiereds.net>
	<AANLkTikq+y4hEaeyc=D5HRU2Jna4MZ41C+A3=0vF4JMZ@mail.gmail.com>
	<AANLkTinSq5Zg-Webeb-XE5MGJaohG67cBMbii6gjtWkZ@mail.gmail.com>
	<AANLkTi=XA0dd7WJpX8DU-T_QSxnXmMfK-vLg+SpMR-cA@mail.gmail.com>
	<20110330213748.513d0774@corrin.poochiereds.net>
	<AANLkTimS19xXqwTgjZ7b6=D5OoNAqeGzBJk6FEFBNVAe@mail.gmail.com>
	<AANLkTi=dinD0KeHDb1S8k6L0yfhGsAxVxiz7TwszVQ7E@mail.gmail.com>
	<BANLkTik_PML+cjge4e8ne-mq-BwSEjZMZg@mail.gmail.com>
	<20110525160815.666844ad@tlielax.poochiereds.net>
	<20110526094929.71c248ee@barsoom.rdu.redhat.com>
	<1306422152.3540.21.camel@perseus.themaw.net>
Date: Fri, 27 May 2011 12:51:12 -0700
Message-ID: <BANLkTimWEe+eGAEvp=mpLgUXUOTTy+t5=g@mail.gmail.com>
Subject: Re: BUG() in shrink_dcache_for_umount_subtree on nfs4 mount
From: Mark Moseley <moseleymark@gmail.com>
To: Ian Kent <raven@themaw.net>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, autofs@linux.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, May 26, 2011 at 8:02 AM, Ian Kent <raven@themaw.net> wrote:
> On Thu, 2011-05-26 at 09:49 -0400, Jeff Layton wrote:
>> On Wed, 25 May 2011 16:08:15 -0400
>> Jeff Layton <jlayton@redhat.com> wrote:
>>
>> > On Wed, 27 Apr 2011 16:23:07 -0700
>> > Mark Moseley <moseleymark@gmail.com> wrote:
>> >
>> > >
>> > > I posted this to bugzilla a while back but I figured I'd paste it here too:
>> > >
>> > > -----------------------------------------------------------------------------------------------------
>> > >
>> > > I've been getting bit by the exact same bug and been bisecting for the past
>> > > couple of weeks. It's slow going as it can sometimes take a day for the BUG()
>> > > to show up (though can also at time take 10 minutes). And I've also seen it
>> > > more than once where something was good after a day and then BUG()'d later on,
>> > > just to make things more complicated. So the upshot is that while I feel
>> > > confident enough about this latest batch of bisecting to post it here, I
>> > > wouldn't bet my life on it. I hope this isn't a case where bisecting just shows
>> > > where the bug gets exposed but not where it actually got planted :)
>> > >
>> > > Incidentally, I tried the patch from the top of this thread and it didn't seem
>> > > to make a difference. I still got bit.
>> > >
>> > > I've posted on the linux-fsdevel thread that Jeff Layton started about it,
>> > > http://www.spinics.net/lists/linux-nfs/msg20280.html if you need more details
>> > > on my setup (though I'll be happy to provide anything else you need). Though in
>> > > that thread you'll see that I'm not using autofs explicitly, the Netapp GX
>> > > cluster NFS appears to use autofs to do the implicit submounts (I'm not 100%
>> > > sure that's the correct terminology, so hopefully you know what I mean).
>> > >
>> > > Here's my bisect log, ending up at commit
>> > > e61da20a50d21725ff27571a6dff9468e4fb7146
>> > >
>> > > git bisect start 'fs'
>> > > # good: [3c0eee3fe6a3a1c745379547c7e7c904aa64f6d5] Linux 2.6.37
>> > > git bisect good 3c0eee3fe6a3a1c745379547c7e7c904aa64f6d5
>> > > # bad: [c56eb8fb6dccb83d9fe62fd4dc00c834de9bc470] Linux 2.6.38-rc1
>> > > git bisect bad c56eb8fb6dccb83d9fe62fd4dc00c834de9bc470
>> > > # good: [7c955fca3e1d8132982148267d9efcafae849bb6] Merge branch 'for_linus' of
>> > > git://git.kernel.org/pub/scm/linux/kernel/git/jack/linux-udf-2.6
>> > > git bisect good 7c955fca3e1d8132982148267d9efcafae849bb6
>> > > # good: [c32b0d4b3f19c2f5d29568f8b7b72b61693f1277] fs/mpage.c: consolidate code
>> > > git bisect good c32b0d4b3f19c2f5d29568f8b7b72b61693f1277
>> > > # bad: [f8206b925fb0eba3a11839419be118b09105d7b1] Merge branch 'for-linus' of
>> > > git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs-2.6
>> > > git bisect bad f8206b925fb0eba3a11839419be118b09105d7b1
>> > > # good: [a8f2800b4f7b76cecb7209cb6a7d2b14904fc711] nfsd4: fix callback
>> > > restarting
>> > > git bisect good a8f2800b4f7b76cecb7209cb6a7d2b14904fc711
>> > > # bad: [6651149371b842715906311b4631b8489cebf7e8] autofs4: Clean up
>> > > autofs4_free_ino()
>> > > git bisect bad 6651149371b842715906311b4631b8489cebf7e8
>> > > # good: [0ad53eeefcbb2620b6a71ffdaad4add20b450b8b] afs: add afs_wq and use it
>> > > instead of the system workqueue
>> > > git bisect good 0ad53eeefcbb2620b6a71ffdaad4add20b450b8b
>> > > # good: [01c64feac45cea1317263eabc4f7ee1b240f297f] CIFS: Use d_automount()
>> > > rather than abusing follow_link()
>> > > git bisect good 01c64feac45cea1317263eabc4f7ee1b240f297f
>> > > # good: [b5b801779d59165c4ecf1009009109545bd1f642] autofs4: Add d_manage()
>> > > dentry operation
>> > > git bisect good b5b801779d59165c4ecf1009009109545bd1f642
>> > > # bad: [e61da20a50d21725ff27571a6dff9468e4fb7146] autofs4: Clean up inode
>> > > operations
>> > > git bisect bad e61da20a50d21725ff27571a6dff9468e4fb7146
>> > > # good: [8c13a676d5a56495c350f3141824a5ef6c6b4606] autofs4: Remove unused code
>> > > git bisect good 8c13a676d5a56495c350f3141824a5ef6c6b4606
>> >
>> > I can more or less reproduce this at will now, I think even with very
>> > few NFS operations on an automounted nfsv4 mount. Here's an oops from a
>> > 2.6.39 kernel:
>> >
>> > [  119.419789] tun0: Features changed: 0x00004800 -> 0x00004000
>> > [  178.242917] FS-Cache: Netfs 'nfs' registered for caching
>> > [  178.269980] SELinux: initialized (dev 0:2c, type nfs4), uses genfs_contexts
>> > [  178.282296] SELinux: initialized (dev 0:2d, type nfs4), uses genfs_contexts
>> > [  523.953284] BUG: Dentry ffff8801f3084180{i=2,n=} still in use (1) [unmount of nfs4 0:2c]
>> > [  523.953306] ------------[ cut here ]------------
>> > [  523.954013] kernel BUG at fs/dcache.c:925!
>> > [  523.954013] invalid opcode: 0000 [#1] SMP
>> > [  523.954013] last sysfs file: /sys/devices/virtual/bdi/0:45/uevent
>> > [  523.954013] CPU 1
>> > [  523.954013] Modules linked in: nfs lockd auth_rpcgss nfs_acl tun fuse ip6table_filter ip6_tables ebtable_nat ebtables sunrpc cachefiles fscache cpufreq_ondemand powernow_k8 freq_table mperf it87 adt7475 hwmon_vid xfs snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_intel raid1 snd_hda_codec snd_usb_audio snd_usbmidi_lib snd_hwdep snd_seq snd_rawmidi snd_seq_device snd_pcm snd_timer snd uvcvideo ppdev videodev soundcore media sp5100_tco v4l2_compat_ioctl32 edac_core parport_pc snd_page_alloc i2c_piix4 edac_mce_amd k10temp parport wmi r8169 microcode mii virtio_net kvm_amd kvm ipv6 ata_generic pata_acpi pata_atiixp radeon ttm drm_kms_helper drm i2c_algo_bit i2c_core [last unloaded: scsi_wait_scan]
>> > [  523.954013]
>> > [  523.954013] Pid: 8387, comm: umount.nfs4 Not tainted 2.6.39-1.fc16.x86_64 #1 BIOSTAR Group TA790GX 128M/TA790GX 128M
>> > [  523.954013] RIP: 0010:[<ffffffff81131788>]  [<ffffffff81131788>] shrink_dcache_for_umount_subtree+0x104/0x1c9
>> > [  523.954013] RSP: 0018:ffff8801f2385d98  EFLAGS: 00010296
>> > [  523.954013] RAX: 0000000000000062 RBX: ffff8801f3084180 RCX: 00000000000027a7
>> > [  523.954013] RDX: 0000000000000000 RSI: 0000000000000046 RDI: 0000000000000246
>> > [  523.954013] RBP: ffff8801f2385dc8 R08: 0000000000000002 R09: 0000ffff00066c0a
>> > [  523.954013] R10: 0000ffff00066c0a R11: 0000000000000003 R12: ffff8801f3084180
>> > [  523.954013] R13: ffff8801f31305f0 R14: ffff8801f30ec5f0 R15: 0000000000000000
>> > [  523.954013] FS:  00007f08e468d720(0000) GS:ffff88022fc80000(0000) knlGS:00000000f770f870
>> > [  523.954013] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> > [  523.954013] CR2: 00007fff8fc29ff8 CR3: 00000001f7ac4000 CR4: 00000000000006e0
>> > [  523.954013] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>> > [  523.954013] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>> > [  523.954013] Process umount.nfs4 (pid: 8387, threadinfo ffff8801f2384000, task ffff8801f7a61710)
>> > [  523.954013] Stack:
>> > [  523.954013]  ffff8801fdd74a58 0000000000000000 ffff8801fdd74800 ffff8801f3084240
>> > [  523.954013]  ffff8801f2385f28 ffff8801f30ec540 ffff8801f2385de8 ffffffff81132063
>> > [  523.954013]  ffff8801fdd74800 ffffffffa0542300 ffff8801f2385e18 ffffffff81121f15
>> > [  523.954013] Call Trace:
>> > [  523.954013]  [<ffffffff81132063>] shrink_dcache_for_umount+0x4d/0x5f
>> > [  523.954013]  [<ffffffff81121f15>] generic_shutdown_super+0x23/0xde
>> > [  523.954013]  [<ffffffff8112204d>] kill_anon_super+0x13/0x4c
>> > [  523.954013]  [<ffffffffa051c436>] nfs4_kill_super+0x44/0x77 [nfs]
>> > [  523.954013]  [<ffffffff81122271>] deactivate_locked_super+0x26/0x4b
>> > [  523.954013]  [<ffffffff81122a83>] deactivate_super+0x37/0x3b
>> > [  523.954013]  [<ffffffff811375b3>] mntput_no_expire+0xcc/0xd1
>> > [  523.954013]  [<ffffffff811375de>] mntput+0x26/0x28
>> > [  523.954013]  [<ffffffff81137bef>] release_mounts+0x59/0x73
>> > [  523.954013]  [<ffffffff81138155>] sys_umount+0x28d/0x2da
>> > [  523.954013]  [<ffffffff814828c2>] system_call_fastpath+0x16/0x1b
>> > [  523.954013] Code: 8b 40 28 4c 8b 08 48 8b 43 30 48 85 c0 74 07 48 8b 90 a8 00 00 00 48 89 34 24 48 c7 c7 f9 ed 7a 81 48 89 de 31 c0 e8 4e 17 34 00 <0f> 0b 4c 8b 63 18 4c 39 e3 75 11 48 8d bb 90 00 00 00 45 31 e4
>> > [  523.954013] RIP  [<ffffffff81131788>] shrink_dcache_for_umount_subtree+0x104/0x1c9
>> > [  523.954013]  RSP <ffff8801f2385d98>
>> > [  523.954013] [drm] force priority to high
>> > [  523.954013] [drm] force priority to high
>> > [  524.042397] ---[ end trace ff21a3f70c461b5e ]---
>> > [  534.621786] [drm] force priority to high
>> > [  534.621866] [drm] force priority to high
>> >
>> > Client rpc stats:
>> > calls      retrans    authrefrsh
>> > 44         0          44
>> >
>> > Client nfs v4:
>> > null         read         write        commit       open         open_conf
>> > 0         0% 0         0% 1         2% 0         0% 1         2% 1         2%
>> > open_noat    open_dgrd    close        setattr      fsinfo       renew
>> > 0         0% 0         0% 1         2% 1         2% 4         9% 0         0%
>> > setclntid    confirm      lock         lockt        locku        access
>> > 1         2% 1         2% 0         0% 0         0% 0         0% 6        13%
>> > getattr      lookup       lookup_root  remove       rename       link
>> > 7        16% 5        11% 1         2% 0         0% 0         0% 0         0%
>> > symlink      create       pathconf     statfs       readlink     readdir
>> > 0         0% 0         0% 3         6% 0         0% 0         0% 3         6%
>> > server_caps  delegreturn  getacl       setacl       fs_locations rel_lkowner
>> > 7        16% 0         0% 0         0% 0         0% 0         0% 0         0%
>> > exchange_id  create_ses   destroy_ses  sequence     get_lease_t  reclaim_comp
>> > 0         0% 0         0% 0         0% 0         0% 0         0% 0         0%
>> > layoutget    layoutcommit layoutreturn getdevlist   getdevinfo   ds_write
>> > 0         0% 0         0% 0         0% 0         0% 0         0% 0         0%
>> > ds_commit
>> > 0         0%
>> >
>> > That's good because I think it may help narrow down the codepaths that
>> > lead to this...
>> >
>> > All I did was save a file to the mount using claws-mail and wait for
>> > autofs to unmount it. I'm going to see if I can narrow down the
>> > reproducer somewhat and whether I can take autofs out of the picture.
>> >
>>
>> (cc'ing autofs mailing list too)
>>
>> Taking autofs out of the picture seems to make the problem go away, so
>> this seems to be related to that. Why, exactly, I'm not sure yet. It's
>> always been my understanding that autofs basically gets out of the way
>> once the fs is mounted, but I suppose it needs some way to check for
>> expiration so maybe that mechanism is causing issues.
>
> Mmmm ... with 2.6.39 ... mmm ...
>
> With the vfs-automount in place autofs doesn't quite get out of the way
> anymore but only in so much as it gets a looking during the follow while
> path walking.
>
> Your thought about the autofs expire may be a good lead. There could be
> a problem between the expire check and the ref countless rcu-walk in
> that a umount (possibly a kernel dentry expire) could occur while there
> is an elevated ref-count (by the autofs expire) perhaps. I've thought
> about this possibility the couple of times I've seen reports like this
> but don't have anything concrete.
>
> But, I thought that Mark sees a problem when autofs is not involved at
> all which of course probably means autofs may be the reproducer not the
> cause or we have two bugs. Mark, can you confirm you see this without
> autofs in use please?
>
> Ian

Yup, we're not loading the autofs4 module:

# zgrep AUTOFS /proc/config.gz
CONFIG_AUTOFS4_FS=m
#

# lsmod | grep auto
#

I'm pretty that the Netapp GX cluster uses autofs routines to do its
implicit submounts though. Or at the very least, it's doing very
autofs-y things, i.e. the kernel takes care of mounting submounts on
its own. Depending on the job of the server, those submounts can
number from 30 up to 300, so there's always a decent amount of
submounts.

I'm more than happy to grab any debugging info that would be help,
and/or try out any patches/configs/etc.
