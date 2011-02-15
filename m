Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out1.smtp.messagingengine.com ([66.111.4.25]:47708 "EHLO
	out1.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752381Ab1BOOiQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Feb 2011 09:38:16 -0500
Subject: Re: [PATCH 0/3] Fixes for vfs-scale and vfs-automount
From: Ian Kent <raven@themaw.net>
To: Nick Piggin <npiggin@suse.de>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: David Howells <dhowells@redhat.com>, Al Viro <viro@ZenIV.linux.org.uk>,
        Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
In-Reply-To: <1295420817.3076.24.camel@perseus>
References: <20110118040449.23109.33071.stgit@localhost6.localdomain6>
	 <1295420817.3076.24.camel@perseus>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 15 Feb 2011 22:25:02 +0800
Message-ID: <1297779902.13007.86.camel@perseus>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-01-19 at 15:06 +0800, Ian Kent wrote:
> On Tue, 2011-01-18 at 12:05 +0800, Ian Kent wrote:
> > I noticed a couple of problems which needed to be fixed before I can
> > start testing.
> 
> Before I return to testing I thought I should let everyone know the
> results so far, following the addition of the merged patches from this
> thread.

Sorry for the large recipient list but I think there's a need.
I've made very little progress on this but my most recent development
deserves an update.

Most recent kernel used is 2.6.38-rc4.

> 
> I have two tests, the first is the autofs connectathon test suite.
> It consists of a wide range of automount map constructs, and contains
> both success and failure cases and results in about 260 mounts. I
> usually run the test 3 times, and wait for the mounts to expire between
> runs.
> 
> The connectathon test worked fine and I didn't observe any unexpected
> log messages over the three runs.
> 
> The second test I run has been adapted from one of the connectathon
> tests. This test uses autofs submounts which are the most problematic of
> the autofs map constructs. The modified test is meant to introduce a
> fairly high level of contention by using a number of processes accessing
> the mounts at the same time (currently configured as 10 processes). I
> also attempt to introduce expire to mount contention by adjusting the
> expire timeout. In addition the test runs twice, one the the default
> nobrowse option and one for the browse option (no need to worry about
> what that means). All in all the test seems to be fairly good at
> exposing problems and 150 iterations of each configuration seems to get
> most problems within three consecutive runs.
> 
> The first run of this test returned a pass although there were some
> unexpected log messages. I'm not sure yet what is causing these. Of
> interest was a bunch of reported lstat() failures against directories
> that corresponded to failure cases and should not have existed at all.
> 
> The second run went through to completion but triggered the BUG() at
> line 941 in shrink_dcache_for_umount_subtree() when shutting down autofs
> after the first (nobrowse) part of the test run.
> 
> So, there is still a ref count problem somewhere, at least.

I'm seeing a reference being gained, or perhaps not being released
quickly enough after a close(2) on a file handle open on a mount point
being umounted seen in the backtrace [1] below. I can't say if there is
more than one like this because the BUG() stops the umounting. I'm
thinking of modifying the code to try and continue to see what else I
can find out.

I get this quite reliably running the test described above.

I've looked long and hard at the vfs-scale path walking code (and the
vfs-automount code) and I can't yet see how this could be possible.

Here are some observations I've made so far.

In this segement of code in autofs4:

int autofs4_d_manage(struct dentry *dentry, bool mounting_here, bool rcu_walk)
{
        struct autofs_sb_info *sbi = autofs4_sbi(dentry->d_sb);

        DPRINTK("dentry=%p %.*s",
                dentry, dentry->d_name.len, dentry->d_name.name);

        /* The daemon never waits. */
        if (autofs4_oz_mode(sbi) || mounting_here) {
                if (!d_mountpoint(dentry))
                        return -EISDIR;
                return 0;
        }

        /* We need to sleep, so we need pathwalk to be in ref-mode */
        if (rcu_walk)
                return -ECHILD;

        /* Wait for pending expires */
        do_expire_wait(dentry);

        /*
         * This dentry may be under construction so wait on mount
         * completion.
         */
        return autofs4_mount_wait(dentry);
}

If I move the

        /* We need to sleep, so we need pathwalk to be in ref-mode */
        if (rcu_walk)
                return -ECHILD;

above the

        /* The daemon never waits. */
        if (autofs4_oz_mode(sbi) || mounting_here) {
                if (!d_mountpoint(dentry))
                        return -EISDIR;
                return 0;
        }

I almost never see the problem in the first stage of the test, that
being the nobrowse configuration, but almost always see it in the second
stage, the so called browse configuration. Which amounts to saying that
the problem appears to happen more often when mount point directories in
the automount headachy exist before being mounted on and are not removed
when they are expired. Unfortunately it isn't as simple as that either
since the automount map itself is fairly complex. Still, I thought it
worth mentioning.

The most recent curious thing is that if I change the test a bit to use
bind mounts on local paths instead of NFS mounts I don't get this BUG()
at all. Don't get me wrong, I'm not saying this is necessarily an NFS
problem, it may be that the reduced latency of bind mounts changes the
test behavior and hides the bug. So I'd appreciate some help from NFS
folks in case it is something that needs to be changed in NFS, since I
can't see anything that might cause it in the NFS code myself.

If anyone would like to try and run the test themselves I'll work on
decoupling it from the RHTS infrastructure within which it is currently
implemented. 

[1] the BUG trace I see

Feb 14 20:20:20 perseus kernel: pid 15761: autofs4_kill_sb: s_root ffff88020d388f00 d_count 1 d_inode ffff88020ddf7840 d_flags 60010 sbi type 4 open_count 0 ino->flags 0
Feb 14 20:20:20 perseus kernel: pid 15761: autofs4_kill_sb: s_root ffff88020d3889c0 d_count 1 d_inode ffff88020ddf5440 d_flags 60010 sbi type 4 open_count 0 ino->flags 0
Feb 14 20:20:20 perseus kernel: pid 15743: autofs4_expire_indirect: returning ffff8801f96a0480 g3c
Feb 14 20:20:20 perseus kernel: pid 15762: autofs4_kill_sb: s_root ffff8800ccbe6000 d_count 2 d_inode ffff88020ddcc480 d_flags 60010 sbi type 4 open_count 0 ino->flags 0
Feb 14 20:20:20 perseus kernel: pid 15762: autofs4_kill_sb: s_root->d_subdirs empty
Feb 14 20:20:20 perseus kernel: BUG: Dentry ffff8800ccbe6000{i=26a028,n=/} still in use (1) [unmount of autofs autofs]
Feb 14 20:20:20 perseus kernel: ------------[ cut here ]------------
Feb 14 20:20:20 perseus kernel: kernel BUG at fs/dcache.c:943!
Feb 14 20:20:20 perseus kernel: invalid opcode: 0000 [#1] SMP
Feb 14 20:20:20 perseus kernel: last sysfs file: /sys/devices/system/cpu/cpu5/cache/index2/shared_cpu_map
Feb 14 20:20:20 perseus kernel: CPU 0
Feb 14 20:20:20 perseus kernel: Modules linked in: nls_utf8 udf crc_itu_t tcp_lp tun fuse ip6table_filter ip6_tables
	ebtable_nat ebtables ipt_MASQUERADE iptable_nat nf_nat bridge stp llc nfs lockd fscache nfs_acl auth_rpcgss
	autofs4 sunrpc ipv6 cpufreq_ondemand powernow_k8 freq_table mperf kvm_amd kvm uinput snd_hda_codec_hdmi
	snd_hda_codec_via snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device snd_pcm snd_timer snd
	edac_core edac_mce_amd asus_atk0110 r8169 mii i2c_piix4 ppdev parport_pc parport soundcore joydev wmi
	xhci_hcd serio_raw snd_page_alloc shpchp pcspkr microcode ata_generic pata_acpi usb_storage pata_atiixp
	radeon ttm drm_kms_helper drm i2c_algo_bit i2c_core [last unloaded: scsi_wait_scan]
Feb 14 20:20:20 perseus kernel:
Feb 14 20:20:20 perseus kernel: Pid: 15762, comm: automount Not tainted 2.6.38-rc4+ #2 M4A88T-M/USB3/System Product Name
Feb 14 20:20:20 perseus kernel: RIP: 0010:[<ffffffff811206e3>]  [<ffffffff811206e3>] shrink_dcache_for_umount_subtree+0x102/0x1d0
Feb 14 20:20:20 perseus kernel: RSP: 0018:ffff880209b23d58  EFLAGS: 00010296
Feb 14 20:20:20 perseus kernel: RAX: 000000000000005d RBX: ffff8800ccbe6000 RCX: 00000000000051e2
Feb 14 20:20:20 perseus kernel: RDX: 0000000000000000 RSI: 0000000000000092 RDI: 0000000000000246
Feb 14 20:20:20 perseus kernel: RBP: ffff880209b23d88 R08: 0000000000000002 R09: ffff8802ffffffff
Feb 14 20:20:20 perseus kernel: R10: ffff880209b23c48 R11: 0000000000000000 R12: ffff8800ccbe6000
Feb 14 20:20:20 perseus kernel: R13: ffff8800ccbe60a0 R14: ffff88020a68fc00 R15: ffff8800ccbe60a0
Feb 14 20:20:20 perseus kernel: FS:  00007fa9a2101700(0000) GS:ffff8800cfc00000(0000) knlGS:00000000f75e4710
Feb 14 20:20:20 perseus kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Feb 14 20:20:20 perseus kernel: CR2: 00007fa9940089c0 CR3: 000000017022a000 CR4: 00000000000006f0
Feb 14 20:20:20 perseus kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Feb 14 20:20:20 perseus kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Feb 14 20:20:20 perseus kernel: Process automount (pid: 15762, threadinfo ffff880209b22000, task ffff880059ee1710)
Feb 14 20:20:20 perseus kernel: Stack:
Feb 14 20:20:20 perseus kernel: ffff88020a68fe58 ffffffff8104771e 0000000000000004 ffff88020a68fc00
Feb 14 20:20:20 perseus kernel: ffff8800ccbe6000 ffff880209e680c0 ffff880209b23da8 ffffffff811210b8
Feb 14 20:20:20 perseus kernel: ffff88020a68fc00 ffffffffa027c990 ffff880209b23dd8 ffffffff81110721
Feb 14 20:20:20 perseus kernel: Call Trace:
Feb 14 20:20:20 perseus kernel: [<ffffffff8104771e>] ? try_to_wake_up+0x214/0x226
Feb 14 20:20:20 perseus kernel: [<ffffffff811210b8>] shrink_dcache_for_umount+0x4d/0x5f
Feb 14 20:20:20 perseus kernel: [<ffffffff81110721>] generic_shutdown_super+0x29/0xf6
Feb 14 20:20:20 perseus kernel: [<ffffffff8111086e>] kill_anon_super+0x16/0x50
Feb 14 20:20:20 perseus kernel: [<ffffffff811108cf>] kill_litter_super+0x27/0x2c
Feb 14 20:20:20 perseus kernel: [<ffffffffa0279390>] autofs4_kill_sb+0x1a7/0x1b6 [autofs4]
Feb 14 20:20:20 perseus kernel: [<ffffffff81110a9e>] deactivate_locked_super+0x26/0x46
Feb 14 20:20:20 perseus kernel: [<ffffffff811115ba>] deactivate_super+0x3a/0x3e
Feb 14 20:20:20 perseus kernel: [<ffffffff81126599>] mntput_no_expire+0xd0/0xd5
Feb 14 20:20:20 perseus kernel: [<ffffffff811270f1>] sys_umount+0x2e9/0x317
Feb 14 20:20:20 perseus kernel: [<ffffffff8100ac02>] system_call_fastpath+0x16/0x1b
Feb 14 20:20:20 perseus kernel: Code: 8b 40 28 4c 8b 08 48 8b 43 30 48 85 c0 74 07 48 8b 90 a8 00 00 00 48 89 34 24 48 c7 c7 af 68 7a 81 48 89 de 31 c0 e8 a1 60 33 00 <0f> 0b 4c 8b 63 18 4c 8d ab 90 00 00 00 4c 39 e3 75 0d 4c 89 ef
Feb 14 20:20:20 perseus kernel: RIP  [<ffffffff811206e3>] shrink_dcache_for_umount_subtree+0x102/0x1d0
Feb 14 20:20:20 perseus kernel: RSP <ffff880209b23d58>
Feb 14 20:20:20 perseus kernel: ---[ end trace 58b3a9ecb744fd7d ]---

