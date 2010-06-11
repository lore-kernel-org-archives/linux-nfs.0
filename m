From: Benny Halevy <bhalevy@panasas.com>
Subject: BUG: no open context for layout_get for the commit on close path
Date: Fri, 11 Jun 2010 18:05:27 +0300
Message-ID: <4C1250B7.3020808@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: NFS list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:32318 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751424Ab0FKPFa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Jun 2010 11:05:30 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

That's a tricky one.
With pnfs-all-2.6.34-2010-06-10 we hit the BUG in get_layout(), here:

        if (!memcmp(lo->stateid.data, &zero_stateid, NFS4_STATEID_SIZE)) {
                struct nfs_open_context *oldctx = ctx;

                if (!oldctx) {
                        ctx = nfs_find_open_context(ino, NULL,
                                        (range->iomode == IOMODE_READ) ?
                                        FMODE_READ: FMODE_WRITE);
                        BUG_ON(!ctx);
			^^^^^^
                }
                pnfs_layout_from_open_stateid(&lgp->args.stateid, ctx->state);
                if (!oldctx)
                        put_nfs_open_context(ctx);
        } else
                pnfs_get_layout_stateid(&lgp->args.stateid, lo);

Jun 11 17:40:23 tl1 kernel: kernel BUG at /usr0/export/dev/bhalevy/git/linux-pnfs-bh-nfs41/fs/nfs/pnfs.c:576!
Jun 11 17:40:23 tl1 kernel: invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
Jun 11 17:40:23 tl1 kernel: last sysfs file: /sys/devices/platform/host4/session1/target4:0:0/4:0:0:0/scsi_generic/sg2/dev
Jun 11 17:40:23 tl1 kernel: CPU 0 
Jun 11 17:40:23 tl1 kernel: Modules linked in: panfs(P) panlayoutdriver objlayoutdriver nfslayoutdriver exofs nfsd exportfs nfs lockd n
fs_acl auth_rpcgss osd libosd crc32c sunrpc ip6_tables ipv6 iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi cpufreq_ondemand acpi_
cpufreq freq_table ext2 dm_mirror dm_region_hash dm_log dm_multipath dm_mod snd_hda_codec_via snd_hda_intel snd_hda_codec snd_hwdep i91
5 snd_seq_dummy snd_seq_oss drm_kms_helper snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss drm snd_mixer_oss snd_pcm snd_timer sn
d soundcore i2c_algo_bit video i2c_i801 output sg atl1c i2c_core snd_page_alloc rng_core button ata_generic ata_piix libata sd_mod scsi
_mod ext3 jbd mbcache uhci_hcd ohci_hcd ehci_hcd [last unloaded: objlayoutdriver]
Jun 11 17:40:23 tl1 kernel:
Jun 11 17:40:23 tl1 kernel: Pid: 5275, comm: ld Tainted: P           2.6.34-pnfs #3 G41TM-P33 (MS-7592)/MS-7592
Jun 11 17:40:23 tl1 kernel: RIP: 0010:[<ffffffffa04c7eab>]  [<ffffffffa04c7eab>] pnfs_update_layout+0x5b4/0x6e9 [nfs]
Jun 11 17:40:23 tl1 kernel: RSP: 0018:ffff88002407dc38  EFLAGS: 00010246
Jun 11 17:40:23 tl1 kernel: RAX: 0000000000000000 RBX: ffff880046aa06f0 RCX: ffff880071a49c48
Jun 11 17:40:23 tl1 kernel: RDX: ffff880046aa0588 RSI: 0000000000000000 RDI: ffff880046aa079c
Jun 11 17:40:23 tl1 kernel: RBP: ffff88002407dd08 R08: 00000000000080d0 R09: ffff88002407dd20
Jun 11 17:40:23 tl1 kernel: R10: 0000000000000000 R11: ffff880076b0ad80 R12: ffff88007cabb000
Jun 11 17:40:23 tl1 kernel: R13: 0000000000000000 R14: ffff88007c079000 R15: ffff880076ab1300
Jun 11 17:40:23 tl1 kernel: FS:  00007fe5e86396f0(0000) GS:ffff880001a00000(0000) knlGS:0000000000000000
Jun 11 17:40:23 tl1 kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Jun 11 17:40:23 tl1 kernel: CR2: 0000000000472280 CR3: 000000002328b000 CR4: 00000000000406f0
Jun 11 17:40:23 tl1 kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Jun 11 17:40:23 tl1 kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Jun 11 17:40:23 tl1 kernel: Process ld (pid: 5275, threadinfo ffff88002407c000, task ffff88002acd16c0)
Jun 11 17:40:23 tl1 kernel: Stack:
Jun 11 17:40:23 tl1 kernel: ffff88002407dc88 ffffffff8117b243 ffffffff00000002 0000000200000000
Jun 11 17:40:23 tl1 kernel: <0> 0000000100000000 0000000000000003 ffff88002407dd20 0000000000000000
Jun 11 17:40:23 tl1 kernel: <0> 01ff88002407ddc8 ffff880046aa0660 0000000000000000 ffff88002acd16c0
Jun 11 17:40:23 tl1 kernel: Call Trace:
Jun 11 17:40:23 tl1 kernel: [<ffffffff8117b243>] ? radix_tree_tag_set+0x6a/0xcd
Jun 11 17:40:23 tl1 kernel: [<ffffffff8105750f>] ? autoremove_wake_function+0x0/0x39
Jun 11 17:40:23 tl1 kernel: [<ffffffffa04c8129>] _pnfs_try_to_commit+0x149/0x229 [nfs]
Jun 11 17:40:23 tl1 kernel: [<ffffffffa04a7248>] pnfs_initiate_commit+0x5a/0xa0 [nfs]
Jun 11 17:40:23 tl1 kernel: [<ffffffffa04a8c0e>] nfs_write_inode+0x23a/0x394 [nfs]
Jun 11 17:40:23 tl1 kernel: [<ffffffffa04a7d0c>] ? nfs_flush_one+0x0/0xf4 [nfs]
Jun 11 17:40:23 tl1 kernel: [<ffffffff81104625>] writeback_single_inode+0x10e/0x1de
Jun 11 17:40:23 tl1 kernel: [<ffffffff81104722>] sync_inode+0x2d/0x3a
Jun 11 17:40:23 tl1 kernel: [<ffffffff8105750f>] ? autoremove_wake_function+0x0/0x39
Jun 11 17:40:23 tl1 kernel: [<ffffffffa04a6bb8>] nfs_wb_all+0x42/0x44 [nfs]
Jun 11 17:40:23 tl1 kernel: [<ffffffffa049a656>] nfs_do_fsync+0x20/0x3d [nfs]
Jun 11 17:40:23 tl1 kernel: [<ffffffffa049a83b>] nfs_file_flush+0x75/0x7d [nfs]
Jun 11 17:40:23 tl1 kernel: [<ffffffff810e7e88>] filp_close+0x43/0x72
Jun 11 17:40:23 tl1 kernel: [<ffffffff810e7f53>] sys_close+0x9c/0xd0
Jun 11 17:40:23 tl1 kernel: [<ffffffff81002c32>] system_call_fastpath+0x16/0x1b
Jun 11 17:40:23 tl1 kernel: Code: 00 00 4c 8b ad 68 ff ff ff 4d 85 ed 75 21 31 d2 83 7d b0 01 48 89 df 0f 95 c2 31 f6 ff c2 e8 2e 4f fd
 ff 48 85 c0 49 89 c5 75 04 <0f> 0b eb fe f6 05 f7 30 f6 ff 10 4d 8b 75 20 74 15 48 c7 c6 90 
Jun 11 17:40:23 tl1 kernel: RIP  [<ffffffffa04c7eab>] pnfs_update_layout+0x5b4/0x6e9 [nfs]
Jun 11 17:40:23 tl1 kernel: RSP <ffff88002407dc38>
Jun 11 17:40:23 tl1 kernel: ---[ end trace 128a6a97ff1e98ed ]---
