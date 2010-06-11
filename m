Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:60967 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756202Ab0FKHuH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Jun 2010 03:50:07 -0400
Received: by wyb40 with SMTP id 40so529923wyb.19
        for <linux-nfs@vger.kernel.org>; Fri, 11 Jun 2010 00:50:05 -0700 (PDT)
In-Reply-To: <4C11E50D.9060506@panasas.com>
References: <4C111B9C.3080603@panasas.com>
	<4C11E50D.9060506@panasas.com>
Date: Fri, 11 Jun 2010 03:50:04 -0400
Message-ID: <AANLkTinTPbEi1NSSLb5Yo_XGodh7b_c9oYQ7UdursRP_@mail.gmail.com>
Subject: Re: pnfs git tree status pnfs-all-2.6.35-rc2-2010-06-10
From: Fred Isaman <iisaman@umich.edu>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Benny Halevy <bhalevy@panasas.com>, NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Jun 11, 2010 at 3:26 AM, Boaz Harrosh <bharrosh@panasas.com> wrote:
> On 06/10/2010 08:06 PM, Benny Halevy wrote:
>> I've release the tree with Alexandros and Andy's latest pnfs-submit patches
>> as well as some fixes for pnfs-obj from Boaz.  The latter, and Andy's
>> patches went also for the pnfs-all-2.6.34 branch, tagged as
>> pnfs-all-2.6.34-2010-06-10
>>
>
> I will not be testing osd/exofs on the pnfs-all-2.6.35-rc branch from Benny.
> I will be sticking with pnfs-all-2.6.34. This is because of Alexandros Patches.
>
> I have gone half way through Fred's patches and I like them a lot so far, though
> they are still 50% raw. But it is all in the right direction. I would not
> mind working on a tree with these in and fix any issues that come up.
>
> Alexandro's, patches I have not had the time to review yet. And am reluctant to
> do so since they are still broken by definition. The server is still not
> converted, and it takes two to tango. Unlike some of us, I'm still dependent
> on the Linux server and that one is broken for me, if using Alexandro's client.
>
> I have been running some tests on the Latest pnfs-all-2.6.34 branch and seeing
> problems with Files-layout. Obj-layout is fine.
>
> I have a simple setup of export on localhost in a single physical machine.
> * The first is using the LOCAL-EXP of an ext3, rather empty partition.
>  I'm running my infamous test of "git clone linux" At the files checkout stage
>  i get like 10 of:
>        kernel: pnfs_destroy_inode: layout.refcount 1
>  and a BUG_ON at nfs/inode.c:1365
>  The machine becomes un stable after that. I suspect because of the BUG_ON killing
>  the kswapd thread (see below the stack trace). I told Benny that making these a
>  WAR_ON would be better since it is a leak not a CRASH going to happen so it will
>  be easier to fix.
>  But there is some layout ref-count problem hiding somewhere in files-layout.
>

I know of at least one problem...the server responding with a shortIO
will completely mess up the files-layout client. (It ends up trying to
resend the RPC twice.) I have some pnfs-submit patches queued up to
fix that, but have been holding them until some of the backlog of
patches clears.

Fred

> * Same exact test over an exofs export with obj-layout gives me clean responsive
>  machine with clean dmesg file.
>
> See you all in Bakeathon
> Boaz
>
> ---
> Jun 10 18:35:34 tl1 kernel: ------------[ cut here ]------------
> Jun 10 18:35:34 tl1 kernel: kernel BUG at /usr0/export/dev/bhalevy/git/linux-pnfs-bh-nfs41/fs/nfs/inode.c:1365!
> Jun 10 18:35:34 tl1 kernel: invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
> Jun 10 18:35:34 tl1 kernel: last sysfs file: /sys/devices/platform/host5/iscsi_host/host5/initiatorname
> Jun 10 18:35:34 tl1 kernel: CPU 1
> Jun 10 18:35:34 tl1 kernel: Modules linked in: nfslayoutdriver objlayoutdriver exofs nfsd exportfs nfs lockd nfs_acl auth_rpcgss osd libosd
>  crc32c sunrpc ip6_tables ipv6 iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi cpufreq_ondemand acpi_cpufreq freq_table ext2 dm_mirror
>  dm_region_hash dm_log dm_multipath dm_mod i915 snd_hda_codec_via snd_hda_intel drm_kms_helper snd_hda_codec snd_hwdep snd_seq_dummy snd_se
> q_oss drm snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss snd_pcm snd_timer snd soundcore snd_page_alloc i2c_algo_bit v
> ideo atl1c output i2c_i801 i2c_core rng_core sg button ata_generic ata_piix libata sd_mod scsi_mod ext3 jbd mbcache uhci_hcd ohci_hcd ehci_
> hcd [last unloaded: microcode]
> Jun 10 18:35:34 tl1 kernel:
> Jun 10 18:35:34 tl1 kernel: Pid: 291, comm: kswapd0 Not tainted 2.6.34-pnfs #3 G41TM-P33 (MS-7592)/MS-7592
> Jun 10 18:35:34 tl1 kernel: RIP: 0010:[<ffffffffa049b9a6>]  [<ffffffffa049b9a6>] nfs_destroy_inode+0x5e/0x99 [nfs]
> Jun 10 18:35:34 tl1 kernel: RSP: 0000:ffff88007d0d5c20  EFLAGS: 00010202
> Jun 10 18:35:34 tl1 kernel: RAX: 0000000000000029 RBX: ffff88004516abf0 RCX: 00000000000084c1
> Jun 10 18:35:34 tl1 kernel: RDX: 0000000000000000 RSI: 0000000000000046 RDI: 0000000000000246
> Jun 10 18:35:34 tl1 kernel: RBP: ffff88007d0d5c40 R08: ffffffffa04c5362 R09: 000000000000000a
> Jun 10 18:35:34 tl1 kernel: R10: 0000000000000000 R11: 0000000000000000 R12: ffff88004516a9a0
> Jun 10 18:35:34 tl1 kernel: R13: ffff88004516aba8 R14: ffff88007d0d5ca0 R15: 0000000000000080
> Jun 10 18:35:34 tl1 kernel: FS:  0000000000000000(0000) GS:ffff880001a80000(0000) knlGS:0000000000000000
> Jun 10 18:35:34 tl1 kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> Jun 10 18:35:34 tl1 kernel: CR2: 00007fc6fe5b0ecf CR3: 0000000076aca000 CR4: 00000000000406e0
> Jun 10 18:35:34 tl1 kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> Jun 10 18:35:34 tl1 kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Jun 10 18:35:34 tl1 kernel: Process kswapd0 (pid: 291, threadinfo ffff88007d0d4000, task ffff88007d0aad80)
> Jun 10 18:35:34 tl1 kernel: Stack:
> Jun 10 18:35:34 tl1 kernel: ffff88007d0d5c40 ffff88004516abf0 ffff88004516ac00 000000000000004e
> Jun 10 18:35:34 tl1 kernel: <0> ffff88007d0d5c60 ffffffff810fbdbf ffff88007d0d5c60 ffff88004516abf0
> Jun 10 18:35:34 tl1 kernel: <0> ffff88007d0d5c90 ffffffff810fc23c ffff880077917680 00000000000000b4
> Jun 10 18:35:34 tl1 kernel: Call Trace:
> Jun 10 18:35:34 tl1 kernel: [<ffffffff810fbdbf>] destroy_inode+0x2f/0x45
> Jun 10 18:35:34 tl1 kernel: [<ffffffff810fc23c>] dispose_list+0xb6/0xe4
> Jun 10 18:35:34 tl1 kernel: [<ffffffff810fc412>] shrink_icache_memory+0x1a8/0x1d8
> Jun 10 18:35:34 tl1 kernel: [<ffffffff810bc3b9>] shrink_slab+0xd8/0x15c
> Jun 10 18:35:34 tl1 kernel: [<ffffffff810bca11>] balance_pgdat+0x358/0x5ae
> Jun 10 18:35:34 tl1 kernel: [<ffffffff810ba4c7>] ? isolate_pages_global+0x0/0x1df
> Jun 10 18:35:34 tl1 kernel: [<ffffffff81057589>] ? spin_unlock_irqrestore+0xe/0x10
> Jun 10 18:35:34 tl1 kernel: [<ffffffff810bce20>] kswapd+0x1b9/0x1cf
> Jun 10 18:35:34 tl1 kernel: [<ffffffff8105750f>] ? autoremove_wake_function+0x0/0x39
> Jun 10 18:35:34 tl1 kernel: [<ffffffff8102edea>] ? spin_unlock_irqrestore+0xe/0x10
> Jun 10 18:35:34 tl1 kernel: [<ffffffff810bcc67>] ? kswapd+0x0/0x1cf
> Jun 10 18:35:34 tl1 kernel: [<ffffffff810570b9>] kthread+0x7f/0x87
> Jun 10 18:35:34 tl1 kernel: [<ffffffff81003a24>] kernel_thread_helper+0x4/0x10
> Jun 10 18:35:34 tl1 kernel: [<ffffffff8105703a>] ? kthread+0x0/0x87
> Jun 10 18:35:34 tl1 kernel: [<ffffffff81003a20>] ? kernel_thread_helper+0x0/0x10
> Jun 10 18:35:34 tl1 kernel: Code: 39 6b b8 74 04 0f 0b eb fe 8b 53 a8 85 d2 74 15 48 c7 c6 a0 97 4c a0 48 c7 c7 27 dc 4c a0 31 c0 e8 86 e7
> e6 e0 83 7b a8 00 74 04 <0f> 0b eb fe 49 8d 84 24 b0 01 00 00 48 39 83 60 ff ff ff 74 04
> Jun 10 18:35:34 tl1 kernel: RIP  [<ffffffffa049b9a6>] nfs_destroy_inode+0x5e/0x99 [nfs]
> Jun 10 18:35:34 tl1 kernel: RSP <ffff88007d0d5c20>
> Jun 10 18:35:34 tl1 kernel: ---[ end trace 1ad113810041ecf1 ]---
> Jun 10 18:36:34 tl1 ntpd[2200]: synchronized to 192.168.0.140, stratum 3
> Jun 10 18:36:34 tl1 ntpd[2200]: time reset +0.338350 s
> Jun 10 18:36:34 tl1 ntpd[2200]: kernel time sync status change 0001
> Jun 10 18:36:41 tl1 kernel: pnfs_destroy_inode: layout.refcount 1
> Jun 10 18:41:40 tl1 kernel: pnfs_destroy_inode: layout.refcount 1
> Jun 10 18:42:48 tl1 kernel: pnfs_destroy_inode: layout.refcount 1
> Jun 10 18:42:59 tl1 kernel: pnfs_destroy_inode: layout.refcount 1
> Jun 10 18:43:47 tl1 kernel: pnfs_destroy_inode: layout.refcount 1
> Jun 10 18:44:21 tl1 kernel: pnfs_destroy_inode: layout.refcount 1
> Jun 10 18:44:39 tl1 kernel: pnfs_destroy_inode: layout.refcount 1
> Jun 10 18:45:25 tl1 kernel: pnfs_destroy_inode: layout.refcount 1
> Jun 10 18:46:47 tl1 ntpd[2200]: synchronized to 192.168.0.140, stratum 3
> Jun 10 19:01:52 tl1 kernel: pnfs_destroy_inode: layout.refcount 1
> Jun 10 19:01:52 tl1 kernel: pnfs_destroy_inode: layout.refcount 1
> Jun 10 19:01:53 tl1 kernel: pnfs_destroy_inode: layout.refcount 1
> Jun 10 19:01:53 tl1 kernel: pnfs_destroy_inode: layout.refcount 1
> Jun 10 19:01:54 tl1 kernel: pnfs_destroy_inode: layout.refcount 1
> Jun 10 19:01:54 tl1 kernel: pnfs_destroy_inode: layout.refcount 1
>
>
>> Cumulative patches can be generated from
>> git://linux-nfs.org/~bhalevy/linux-pnfs.git
>> using
>> git diff v2.6.35-rc2 pnfs-all-2.6.35-rc2-2010-06-10
>> git diff v2.6.34 pnfs-all-2.6.34-2010-06-10
>>
>> Or, they can be downloaded from the wiki at:
>> http://wiki.linux-nfs.org/wiki/index.php/PNFS_Development_Git_tree
>>
>> Latest patches (since 2010-05-17):
>>
>> pnfs-submit:
>> Alexandros Batsakis (7):
>>       pnfs-submit: clean struct nfs_inode
>>       pnfs-submit: remove lgetcount, lretcount
>>       pnfs-submit: change stateid to be a union
>>       pnfs-submit: request whole-file layouts only
>>       pnfs-submit: change layout list to be similar to other state lists
>>       pnfs-submit: forgetful client (layouts)
>>       pnfs-submit: support for CB_RECALL_ANY (layouts)
>>
>> Andy Adamson (5):
>>       SQUASHME: pnfs-submit: replace layoutcommit_ctx with rpc_cred
>>       SQUASHME pnfs-submit: cleanup layoutcommit call
>>       SQUASHME pnfs-submit: handle async layoutcommit errors
>>       SQUASHME pnfs remove ifdef around layoutcommit_needed
>>       SQUASHME pnfs-submit: move layoutcommit to nfs_write_inode
>>
>> Ricardo Labiaga (2):
>>       SQUASHME: pnfs-submit: Use LAYOUT_NFSV4_1_FILES instead of LAYOUT_NFSV4_FILES
>>       pnfs-submit: Dynamically load the nfslayoutdriver
>>
>> Tao Guo (2):
>>       SQUASHME: pnfs-submit: call layoutcommit after flushing inode's data to disk.
>>       SQUASHME: pnfs: unlock lo_lock before calling layoutdriver's setup_layoutcommit
>>
>> pnfs-block:
>> Zhang Jingwang (1):
>>       SQAUSHME: blocklayoutdriver: NULL pointer reference when committing too many extents
>>
>> pnfsd-files:
>> Benny Halevy (1):
>>       SQUASHME: pnfsd: dlm: fixup LAYOUT_NFSV4_1_FILES
>>
>> Eric Anderle (2):
>>       pnfsd: make /proc/fs/nfsd/pnfs_dlm_device report dlm device list.
>>       SQUASHME: pnfsd: fix test in nfsd4_find_pnfs_dlm_device
>>
>> Ricardo Labiaga (1):
>>       SQUASHME: pnfs-submit: Use LAYOUT_NFSV4_1_FILES instead of LAYOUT_NFSV4_FILES
>>
>> pnfsd:
>> Benny Halevy (2):
>>       SQUASHME: pnfsd: cb_{set,client} moved in 2.6.35
>>       SQUASHME: pnfsd: cl_count removed in 2.6.35
>>
>> J. Bruce Fields (1):
>>       SQUASHME: nfsd4: fix cb_recall encoding
>>
>> spnfs:
>> Benny Halevy (1):
>>       SQUASHME: spnfs: fixup LAYOUT_NFSV4_1_FILES
>>
>> spnfs-block:
>> pnfsd-lexp:
>> Benny Halevy (1):
>>       SQUASHME: pnfsd-lexp: fixup LAYOUT_NFSV4_1_FILES
>>
>> pnfs-obj-all:
>> Boaz Harrosh (2):
>>       SQUASHME: pnfs-obj: panlayout: Fix very old BUG_ONs on ol_state.status
>>       SQUASHME: panfs_shim: Prints on Errors
>>
>> pnfs-block-all:
>> Zhang Jingwang (1):
>>       SQAUSHME: blocklayoutdriver: NULL pointer reference when committing too many extents
>>
>> spnfs-all:
>> Benny Halevy (1):
>>       SQUASHME: spnfs: fixup LAYOUT_NFSV4_1_FILES
>>
>> pnfs-all-latest:
>> Benny Halevy (1):
>>       DEBUG: pnfs: turn BUG_ONs in pnfs_destroy_inode to WARN_ONs
>>
>> pnfs-all-2.6.34:
>> Andy Adamson (5):
>>       SQUASHME: pnfs-submit: replace layoutcommit_ctx with rpc_cred
>>       pnfs: cleanup layoutcommit call
>>       pnfs: handle async layoutcommit errors
>>       pnfs: remove ifdef around layoutcommit_needed
>>       pnfs: move layoutcommit to nfs_write_inode
>>
>> Benny Halevy (4):
>>       SQUASHME: pnfsd: dlm: fixup LAYOUT_NFSV4_1_FILES
>>       SQUASHME: pnfsd-lexp: fixup LAYOUT_NFSV4_1_FILES
>>       SQUASHME: spnfs: fixup LAYOUT_NFSV4_1_FILES
>>       DEBUG: pnfs: turn BUG_ONs in pnfs_destroy_inode to WARN_ONs
>>
>> Boaz Harrosh (2):
>>       SQUASHME: pnfs-obj: panlayout: Fix very old BUG_ONs on ol_state.status
>>       panfs_shim: Prints on Errors
>>
>> Eric Anderle (2):
>>       pnfsd: make /proc/fs/nfsd/pnfs_dlm_device report dlm device list.
>>       SQUASHME: pnfsd: fix test in nfsd4_find_pnfs_dlm_device
>>
>> J. Bruce Fields (1):
>>       SQUASHME: nfsd4: fix cb_recall encoding
>>
>> Ricardo Labiaga (3):
>>       SQUASHME: pnfs-submit: Use LAYOUT_NFSV4_1_FILES instead of LAYOUT_NFSV4_FILES
>>       SQUASHME: pnfs-submit: Use LAYOUT_NFSV4_1_FILES instead of LAYOUT_NFSV4_FILES
>>       pnfs-submit: Dynamically load the nfslayoutdriver
>>
>> Tao Guo (2):
>>       SQUASHME: pnfs-submit: call layoutcommit after flushing inode's data to disk.
>>       SQUASHME: pnfs: unlock lo_lock before calling layoutdriver's setup_layoutcommit
>>
>> Zhang Jingwang (1):
>>       SQAUSHME: blocklayoutdriver: NULL pointer reference when committing too many extents
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
