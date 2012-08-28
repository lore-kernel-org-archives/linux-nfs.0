Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:36404 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752382Ab2H1Mmo convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Aug 2012 08:42:44 -0400
Received: by ialo24 with SMTP id o24so10541276ial.19
        for <linux-nfs@vger.kernel.org>; Tue, 28 Aug 2012 05:42:44 -0700 (PDT)
From: Frank Nicholas <frank@nicholasfamilycentral.com>
Content-Type: text/plain; charset=us-ascii
Subject: kernel BUG at fs/nfs/idmap.c:684!
Message-Id: <DE540E0D-0D1E-45CE-9968-DA9950497B07@nicholasfamilycentral.com>
Date: Tue, 28 Aug 2012 08:42:47 -0400
To: linux-nfs@vger.kernel.org
Mime-Version: 1.0 (Mac OS X Mail 6.0 \(1486\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The information included below is per the URL:
http://www.kernel.org/pub/linux/docs/lkml/reporting-bugs.html

If different or additional information is needed, please let me know.

Kernel version:
Linux martin 3.5.2-gentoo #1 SMP Fri Aug 24 09:35:54 EDT 2012 x86_64 Intel(R) Core(TM) i5-2400 CPU @ 3.10GHz GenuineIntel GNU/Linux
Linux version 3.5.2-gentoo (root@martin) (gcc version 4.6.3 (Gentoo 4.6.3 p1.3, pie-0.5.2) ) #1 SMP Fri Aug 24 09:35:54 EDT 2012
Problem also occurred in 3.5.1-gentoo.

Modules:
Module                  Size  Used by
vboxnetadp             17542  0 
vboxnetflt             14893  0 
vboxdrv              1775582  2 vboxnetadp,vboxnetflt

Bug trigger:
Solaris 11/11 (patched as of July, 2012) is serving NFS V4 to a Gentoo Linux system.  IDMAP is being used to manage users/groups.  "/etc/idmap.conf" is fairly generic except for the domain name.
The Gentoo "portage" tree is shared via NFS.  I initiate an 'emerge --sync'  and the condition occurs.  NFS no longer works.  The system will not restart or shut down due to the hang in NFS.  The system has to be hard powered off to clear the condition.  The bug does not trigger reliably.  The Solaris 11/11 NFS server & Gentoo Linux NFS client have been configured this way for more than a year.  

Kernel log:
[160372.303310] ------------[ cut here ]------------
[160372.303353] kernel BUG at fs/nfs/idmap.c:684!
[160372.303392] invalid opcode: 0000 [#1] SMP 
[160372.303431] CPU 2 
[160372.303437] Modules linked in: vboxnetadp(O) vboxnetflt(O) vboxdrv(O)
[160372.303541] 
[160372.303572] Pid: 12852, comm: mount.nfs Tainted: G           O 3.5.2-gentoo #1 Gigabyte Technology Co., Ltd. Z68A-D3H-B3/Z68A-D3H-B3
[160372.303655] RIP: 0010:[<ffffffff81187e03>]  [<ffffffff81187e03>] nfs_idmap_legacy_upcall+0x323/0x330
[160372.303736] RSP: 0018:ffff8802421af5f8  EFLAGS: 00010282
[160372.303777] RAX: 0000000000000015 RBX: ffff8802ed9e5000 RCX: 0000000000000000
[160372.303847] RDX: 0000000000000005 RSI: ffff88026af757b9 RDI: ffff8802ed9e5017
[160372.303917] RBP: ffff88040d524740 R08: 000000000000003a R09: ffffffff81187b35
[160372.303987] R10: 00000000139c5e77 R11: 000000006138df6f R12: ffff88040b568410
[160372.304056] R13: ffff88040c3e5700 R14: 0000000000000015 R15: 0000000000000000
[160372.304128] FS:  00007f35102ca700(0000) GS:ffff88041fb00000(0000) knlGS:0000000000000000
[160372.304200] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[160372.304240] CR2: 00007f37a2b09880 CR3: 0000000236eae000 CR4: 00000000000407e0
[160372.304311] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[160372.304382] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[160372.304453] Process mount.nfs (pid: 12852, threadinfo ffff8802421ae000, task ffff8803e789be90)
[160372.304525] Stack:
[160372.304558]  ffff88026af757a4 ffff88026af757b9 ffff88040b568410 ffff8802ed9e59c0
[160372.304632]  ffff8802ed9e5540 ffffffff81526c0e 0000000000000000 ffffffff811ad2de
[160372.304707]  0000000000000000 ffff88040d53ae40 ffff88040c3e5700 ffff88040d53ae40
[160372.304781] Call Trace:
[160372.304819]  [<ffffffff811ad2de>] ? request_key_and_link+0x31e/0x450
[160372.304864]  [<ffffffff811ad465>] ? request_key_with_auxdata+0x15/0x60
[160372.304908]  [<ffffffff81187eeb>] ? nfs_idmap_request_key+0xdb/0x1c0
[160372.304951]  [<ffffffff811881a0>] ? nfs_idmap_lookup_id+0xe0/0x100
[160372.304995]  [<ffffffff811883a9>] ? nfs_map_string_to_numeric+0x29/0x90
[160372.305039]  [<ffffffff81182fcc>] ? decode_getfattr_attrs+0xb2c/0xb50
[160372.305082]  [<ffffffff8118307d>] ? decode_getfattr_generic.constprop.96+0x8d/0xe0
[160372.305155]  [<ffffffff811834b0>] ? nfs4_xdr_dec_link+0xf0/0xf0
[160372.305197]  [<ffffffff81183529>] ? nfs4_xdr_dec_lookup_root+0x79/0x80
[160372.305240]  [<ffffffff811834b0>] ? nfs4_xdr_dec_link+0xf0/0xf0
[160372.305285]  [<ffffffff81414d68>] ? rpcauth_unwrap_resp+0x58/0x60
[160372.305328]  [<ffffffff8140bed3>] ? call_decode+0x333/0x430
[160372.305370]  [<ffffffff81413776>] ? __rpc_execute+0x46/0x1e0
[160372.305412]  [<ffffffff810571f8>] ? wake_up_bit+0x18/0x40
[160372.305454]  [<ffffffff8140d529>] ? rpc_run_task+0x69/0x90
[160372.305496]  [<ffffffff8140d65f>] ? rpc_call_sync+0x3f/0x70
[160372.306028]  [<ffffffff81174e5e>] ? _nfs4_lookup_root.isra.42+0xae/0xd0
[160372.306072]  [<ffffffff81174ec7>] ? nfs4_lookup_root+0x47/0x80
[160372.306115]  [<ffffffff81179c10>] ? nfs4_proc_get_rootfh+0x30/0xd0
[160372.306158]  [<ffffffff8115e148>] ? nfs4_get_rootfh+0x28/0xc0
[160372.306200]  [<ffffffff8140cd21>] ? rpc_register_client+0x41/0x70
[160372.306243]  [<ffffffff81413fdb>] ? rpciod_up+0xb/0x20
[160372.306283]  [<ffffffff8140ce97>] ? rpc_clone_client+0x147/0x1c0
[160372.306326]  [<ffffffff81158290>] ? nfs4_server_common_setup+0x90/0x170
[160372.306369]  [<ffffffff811594fe>] ? nfs4_create_server+0x14e/0x2b0
[160372.306413]  [<ffffffff811625df>] ? nfs4_remote_mount+0x3f/0x90
[160372.306457]  [<ffffffff810d17da>] ? mount_fs+0x1a/0xd0
[160372.306500]  [<ffffffff810e92a3>] ? vfs_kern_mount+0x73/0x120
[160372.306542]  [<ffffffff81162720>] ? nfs_do_root_mount+0x90/0xe0
[160372.306584]  [<ffffffff81163bdf>] ? nfs_fs_mount+0x75f/0x970
[160372.306626]  [<ffffffff81163240>] ? nfs_fill_super+0x1d0/0x1d0
[160372.306669]  [<ffffffff81160720>] ? nfs_destroy_inode+0x20/0x20
[160372.306712]  [<ffffffff810d17da>] ? mount_fs+0x1a/0xd0
[160372.306753]  [<ffffffff810e92a3>] ? vfs_kern_mount+0x73/0x120
[160372.306795]  [<ffffffff810e9a93>] ? do_kern_mount+0x53/0x120
[160372.306838]  [<ffffffff810eb662>] ? do_mount+0x532/0x8a0
[160372.306880]  [<ffffffff810eb05a>] ? copy_mount_options+0xca/0x160
[160372.306922]  [<ffffffff810ebb0a>] ? sys_mount+0x9a/0x100
[160372.306965]  [<ffffffff8143e922>] ? system_call_fastpath+0x16/0x1b
[160372.307006] Code: b2 2f e9 c5 fd ff ff 90 66 c7 07 00 00 83 ea 02 48 83 c7 02 e9 72 fd ff ff 0f 1f 80 00 00 00 00 41 be f4 ff ff ff e9 22 fe ff ff <0f> 0b 66 66 2e 0f 1f 84 00 00 00 00 00 48 83 ec 58 48 89 7c 24 
[160372.307191] RIP  [<ffffffff81187e03>] nfs_idmap_legacy_upcall+0x323/0x330
[160372.307236]  RSP <ffff8802421af5f8>
[160372.307672] ---[ end trace fefc21185a0edeb6 ]