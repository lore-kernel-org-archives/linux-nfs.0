From: Fred Isaman <iisaman@umich.edu>
Subject: Re: BUG: no open context for layout_get for the commit on close path
Date: Fri, 11 Jun 2010 11:12:06 -0400
Message-ID: <AANLkTiniZS_OH8XT6nHZYo3R4PQRSuBgfEFb4xKOfZEM@mail.gmail.com>
References: <4C1250B7.3020808@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:44722 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752089Ab0FKPMJ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Jun 2010 11:12:09 -0400
Received: by bwz7 with SMTP id 7so391980bwz.19
        for <linux-nfs@vger.kernel.org>; Fri, 11 Jun 2010 08:12:07 -0700 (PDT)
In-Reply-To: <4C1250B7.3020808@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Note that with my recently submitted patchset, pnfs_update_layout is
always called with an opencontext.

=46red


On Fri, Jun 11, 2010 at 11:05 AM, Benny Halevy <bhalevy@panasas.com> wr=
ote:
> That's a tricky one.
> With pnfs-all-2.6.34-2010-06-10 we hit the BUG in get_layout(), here:
>
> =A0 =A0 =A0 =A0if (!memcmp(lo->stateid.data, &zero_stateid, NFS4_STAT=
EID_SIZE)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct nfs_open_context *oldctx =3D ct=
x;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!oldctx) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ctx =3D nfs_find_open_=
context(ino, NULL,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0(range->iomode =3D=3D IOMODE_READ) ?
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0FMODE_READ: FMODE_WRITE);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0BUG_ON(!ctx);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0^^^^^^
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pnfs_layout_from_open_stateid(&lgp->ar=
gs.stateid, ctx->state);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!oldctx)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0put_nfs_open_context(c=
tx);
> =A0 =A0 =A0 =A0} else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pnfs_get_layout_stateid(&lgp->args.sta=
teid, lo);
>
> Jun 11 17:40:23 tl1 kernel: kernel BUG at /usr0/export/dev/bhalevy/gi=
t/linux-pnfs-bh-nfs41/fs/nfs/pnfs.c:576!
> Jun 11 17:40:23 tl1 kernel: invalid opcode: 0000 [#1] SMP DEBUG_PAGEA=
LLOC
> Jun 11 17:40:23 tl1 kernel: last sysfs file: /sys/devices/platform/ho=
st4/session1/target4:0:0/4:0:0:0/scsi_generic/sg2/dev
> Jun 11 17:40:23 tl1 kernel: CPU 0
> Jun 11 17:40:23 tl1 kernel: Modules linked in: panfs(P) panlayoutdriv=
er objlayoutdriver nfslayoutdriver exofs nfsd exportfs nfs lockd n
> fs_acl auth_rpcgss osd libosd crc32c sunrpc ip6_tables ipv6 iscsi_tcp=
 libiscsi_tcp libiscsi scsi_transport_iscsi cpufreq_ondemand acpi_
> cpufreq freq_table ext2 dm_mirror dm_region_hash dm_log dm_multipath =
dm_mod snd_hda_codec_via snd_hda_intel snd_hda_codec snd_hwdep i91
> 5 snd_seq_dummy snd_seq_oss drm_kms_helper snd_seq_midi_event snd_seq=
 snd_seq_device snd_pcm_oss drm snd_mixer_oss snd_pcm snd_timer sn
> d soundcore i2c_algo_bit video i2c_i801 output sg atl1c i2c_core snd_=
page_alloc rng_core button ata_generic ata_piix libata sd_mod scsi
> _mod ext3 jbd mbcache uhci_hcd ohci_hcd ehci_hcd [last unloaded: objl=
ayoutdriver]
> Jun 11 17:40:23 tl1 kernel:
> Jun 11 17:40:23 tl1 kernel: Pid: 5275, comm: ld Tainted: P =A0 =A0 =A0=
 =A0 =A0 2.6.34-pnfs #3 G41TM-P33 (MS-7592)/MS-7592
> Jun 11 17:40:23 tl1 kernel: RIP: 0010:[<ffffffffa04c7eab>] =A0[<fffff=
fffa04c7eab>] pnfs_update_layout+0x5b4/0x6e9 [nfs]
> Jun 11 17:40:23 tl1 kernel: RSP: 0018:ffff88002407dc38 =A0EFLAGS: 000=
10246
> Jun 11 17:40:23 tl1 kernel: RAX: 0000000000000000 RBX: ffff880046aa06=
f0 RCX: ffff880071a49c48
> Jun 11 17:40:23 tl1 kernel: RDX: ffff880046aa0588 RSI: 00000000000000=
00 RDI: ffff880046aa079c
> Jun 11 17:40:23 tl1 kernel: RBP: ffff88002407dd08 R08: 00000000000080=
d0 R09: ffff88002407dd20
> Jun 11 17:40:23 tl1 kernel: R10: 0000000000000000 R11: ffff880076b0ad=
80 R12: ffff88007cabb000
> Jun 11 17:40:23 tl1 kernel: R13: 0000000000000000 R14: ffff88007c0790=
00 R15: ffff880076ab1300
> Jun 11 17:40:23 tl1 kernel: FS: =A000007fe5e86396f0(0000) GS:ffff8800=
01a00000(0000) knlGS:0000000000000000
> Jun 11 17:40:23 tl1 kernel: CS: =A00010 DS: 0000 ES: 0000 CR0: 000000=
008005003b
> Jun 11 17:40:23 tl1 kernel: CR2: 0000000000472280 CR3: 000000002328b0=
00 CR4: 00000000000406f0
> Jun 11 17:40:23 tl1 kernel: DR0: 0000000000000000 DR1: 00000000000000=
00 DR2: 0000000000000000
> Jun 11 17:40:23 tl1 kernel: DR3: 0000000000000000 DR6: 00000000ffff0f=
f0 DR7: 0000000000000400
> Jun 11 17:40:23 tl1 kernel: Process ld (pid: 5275, threadinfo ffff880=
02407c000, task ffff88002acd16c0)
> Jun 11 17:40:23 tl1 kernel: Stack:
> Jun 11 17:40:23 tl1 kernel: ffff88002407dc88 ffffffff8117b243 fffffff=
f00000002 0000000200000000
> Jun 11 17:40:23 tl1 kernel: <0> 0000000100000000 0000000000000003 fff=
f88002407dd20 0000000000000000
> Jun 11 17:40:23 tl1 kernel: <0> 01ff88002407ddc8 ffff880046aa0660 000=
0000000000000 ffff88002acd16c0
> Jun 11 17:40:23 tl1 kernel: Call Trace:
> Jun 11 17:40:23 tl1 kernel: [<ffffffff8117b243>] ? radix_tree_tag_set=
+0x6a/0xcd
> Jun 11 17:40:23 tl1 kernel: [<ffffffff8105750f>] ? autoremove_wake_fu=
nction+0x0/0x39
> Jun 11 17:40:23 tl1 kernel: [<ffffffffa04c8129>] _pnfs_try_to_commit+=
0x149/0x229 [nfs]
> Jun 11 17:40:23 tl1 kernel: [<ffffffffa04a7248>] pnfs_initiate_commit=
+0x5a/0xa0 [nfs]
> Jun 11 17:40:23 tl1 kernel: [<ffffffffa04a8c0e>] nfs_write_inode+0x23=
a/0x394 [nfs]
> Jun 11 17:40:23 tl1 kernel: [<ffffffffa04a7d0c>] ? nfs_flush_one+0x0/=
0xf4 [nfs]
> Jun 11 17:40:23 tl1 kernel: [<ffffffff81104625>] writeback_single_ino=
de+0x10e/0x1de
> Jun 11 17:40:23 tl1 kernel: [<ffffffff81104722>] sync_inode+0x2d/0x3a
> Jun 11 17:40:23 tl1 kernel: [<ffffffff8105750f>] ? autoremove_wake_fu=
nction+0x0/0x39
> Jun 11 17:40:23 tl1 kernel: [<ffffffffa04a6bb8>] nfs_wb_all+0x42/0x44=
 [nfs]
> Jun 11 17:40:23 tl1 kernel: [<ffffffffa049a656>] nfs_do_fsync+0x20/0x=
3d [nfs]
> Jun 11 17:40:23 tl1 kernel: [<ffffffffa049a83b>] nfs_file_flush+0x75/=
0x7d [nfs]
> Jun 11 17:40:23 tl1 kernel: [<ffffffff810e7e88>] filp_close+0x43/0x72
> Jun 11 17:40:23 tl1 kernel: [<ffffffff810e7f53>] sys_close+0x9c/0xd0
> Jun 11 17:40:23 tl1 kernel: [<ffffffff81002c32>] system_call_fastpath=
+0x16/0x1b
> Jun 11 17:40:23 tl1 kernel: Code: 00 00 4c 8b ad 68 ff ff ff 4d 85 ed=
 75 21 31 d2 83 7d b0 01 48 89 df 0f 95 c2 31 f6 ff c2 e8 2e 4f fd
> =A0ff 48 85 c0 49 89 c5 75 04 <0f> 0b eb fe f6 05 f7 30 f6 ff 10 4d 8=
b 75 20 74 15 48 c7 c6 90
> Jun 11 17:40:23 tl1 kernel: RIP =A0[<ffffffffa04c7eab>] pnfs_update_l=
ayout+0x5b4/0x6e9 [nfs]
> Jun 11 17:40:23 tl1 kernel: RSP <ffff88002407dc38>
> Jun 11 17:40:23 tl1 kernel: ---[ end trace 128a6a97ff1e98ed ]---
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
