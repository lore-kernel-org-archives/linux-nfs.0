Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bk0-f49.google.com ([209.85.214.49]:42176 "EHLO
	mail-bk0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757460Ab3IBLCV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Sep 2013 07:02:21 -0400
Received: by mail-bk0-f49.google.com with SMTP id r7so1493350bkg.8
        for <linux-nfs@vger.kernel.org>; Mon, 02 Sep 2013 04:02:20 -0700 (PDT)
Message-ID: <52247034.6020305@primarydata.com>
Date: Mon, 02 Sep 2013 14:02:12 +0300
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@redhat.com>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: list debug fallout
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruce,

I see the following warnings when running over nfsv4.0 and nfsv4.1 with a 3.10 based kernel
in the close, delegreturn and laundromat paths.
The branch is pnfs-all-latest but since this happens regardless of pnfs I don't think it's related...

What I ran is simply mount and cat of a file in the root directory.

The corrupt value seems like uninitialized (and poisoned) memory, right?

Sep  2 13:07:58 localhost kernel: nfsv4 compound op #3/4: 4 (OP_CLOSE)
Sep  2 13:07:58 localhost kernel: nfsd4_check_resp_size length 116, xb->page_len 0 tlen 0 pad 24
Sep  2 13:07:58 localhost kernel: NFSD: nfsd4_close on file foo
Sep  2 13:07:58 localhost kernel: NFSD: nfs4_preprocess_seqid_op: seqid=0 stateid = (52244b55/00000004/0000000b/00000001)
Sep  2 13:07:58 localhost kernel: renewing client (clientid 52244b55/00000004)
Sep  2 13:07:58 localhost kernel: --> pnfsd_lexp_layout_return: inode=6671
Sep  2 13:07:58 localhost kernel: return_layout_to_fs: inode 6671 iomode=2 offset=0x0 length=0xffffffffffffffff flags=0x1 status=0
Sep  2 13:07:58 localhost kernel: pNFS put_layout_state: ls ffff8800360e2000 ls_ref 2
Sep  2 13:07:58 localhost kernel: pNFS destroy_layout: lp ffff88003b554000 ls ffff8800360e2000 ino 6671
Sep  2 13:07:58 localhost kernel: pNFS put_layout_state: ls ffff8800360e2000 ls_ref 1
Sep  2 13:07:58 localhost kernel: ------------[ cut here ]------------
Sep  2 13:07:58 localhost kernel: WARNING: at /usr0/home/bhalevy/dev/linux-pnfs/
lib/list_debug.c:59 __list_del_entry+0xa1/0xd0()
Sep  2 13:07:58 localhost kernel: list_del corruption. prev->next should be ffff880037af6020, but was 6b6b6b6b6b6b6b6b
Sep  2 13:07:58 localhost kernel: Modules linked in: nfs_layout_nfsv41_files rpcsec_gss_krb5 nfsv4 nfs nfsd auth_rpcgss oid_registry nfs_acl lockd sunrpc autofs4
Sep  2 13:07:58 localhost kernel: CPU: 1 PID: 832 Comm: nfsd Tainted: G        W    3.10.0-pnfs+ #5
Sep  2 13:07:58 localhost kernel: Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
Sep  2 13:07:58 localhost kernel: 0000000000000009 ffff88003b815bd8 ffffffff816cf76b ffff88003b815c10
Sep  2 13:07:58 localhost kernel: ffffffff8105a4b1 ffff880037af6020 ffff880037af6000 ffff880037af6040
Sep  2 13:07:58 localhost kernel: ffff88003c3c0000 ffff880037a5c8c4 ffff88003b815c70 ffffffff8105a51c
Sep  2 13:07:58 localhost kernel: Call Trace:
Sep  2 13:07:58 localhost kernel: [<ffffffff816cf76b>] dump_stack+0x19/0x1b
Sep  2 13:07:58 localhost kernel: [<ffffffff8105a4b1>] warn_slowpath_common+0x61/0x80
Sep  2 13:07:58 localhost kernel: [<ffffffff8105a51c>] warn_slowpath_fmt+0x4c/0x50
Sep  2 13:07:58 localhost kernel: [<ffffffff8135e741>] __list_del_entry+0xa1/0xd0
Sep  2 13:07:58 localhost kernel: [<ffffffff8135e77d>] list_del+0xd/0x30
Sep  2 13:07:58 localhost kernel: [<ffffffffa012b19f>] unhash_open_stateid+0x1f/0x80 [nfsd]
Sep  2 13:07:58 localhost kernel: [<ffffffffa013094e>] nfsd4_close+0x18e/0x5a0 [nfsd]
Sep  2 13:07:58 localhost kernel: [<ffffffffa01307c5>] ? nfsd4_close+0x5/0x5a0 [nfsd]
Sep  2 13:07:58 localhost kernel: [<ffffffffa011b061>] nfsd4_proc_compound+0x5c1/0x7d0 [nfsd]
Sep  2 13:07:58 localhost kernel: [<ffffffffa0103f1b>] nfsd_dispatch+0xbb/0x200 [nfsd]
Sep  2 13:07:58 localhost kernel: [<ffffffffa001e04d>] svc_process_common+0x46d/0x6e0 [sunrpc]
Sep  2 13:07:58 localhost kernel: [<ffffffffa001e3c7>] svc_process+0x107/0x170 [sunrpc]
Sep  2 13:07:58 localhost kernel: [<ffffffffa01032b3>] nfsd+0xd3/0x160 [nfsd]
Sep  2 13:07:58 localhost kernel: [<ffffffffa01031e0>] ? nfsd_destroy+0x220/0x220 [nfsd]
Sep  2 13:07:58 localhost kernel: [<ffffffff810889ad>] kthread+0xed/0x100
Sep  2 13:07:58 localhost kernel: [<ffffffff810c796d>] ? trace_hardirqs_off+0xd/0x10
Sep  2 13:07:58 localhost kernel: [<ffffffff810cb07d>] ? trace_hardirqs_on_caller+0xfd/0x1c0
Sep  2 13:07:58 localhost kernel: [<ffffffff810888c0>] ? insert_kthread_work+0x80/0x80
Sep  2 13:07:58 localhost kernel: [<ffffffff816e126c>] ret_from_fork+0x7c/0xb0
Sep  2 13:07:58 localhost kernel: [<ffffffff810888c0>] ? insert_kthread_work+0x80/0x80
Sep  2 13:07:58 localhost kernel: ---[ end trace 2b7eb5db0f72eb08 ]---

Sep  2 13:28:33 localhost kernel: nfsv4 compound op #4/4: 8 (OP_DELEGRETURN)
Sep  2 13:28:33 localhost kernel: nfsd4_check_resp_size length 164, xb->page_len 0 tlen 0 pad 8
Sep  2 13:28:33 localhost kernel: nfsd: fh_verify(16: 01010001 00000000 00001a0f dc6a31eb 00000000 00000000)
Sep  2 13:28:33 localhost kernel: renewing client (clientid 5224676e/00000001)
Sep  2 13:28:33 localhost kernel: ------------[ cut here ]------------
Sep  2 13:28:33 localhost kernel: WARNING: at /usr0/home/bhalevy/dev/linux-pnfs/lib/list_debug.c:59 __list_del_entry+0xa1/0xd0()
Sep  2 13:28:33 localhost kernel: list_del corruption. prev->next should be ffff88003b960020, but was 6b6b6b6b6b6b6b6b
Sep  2 13:28:33 localhost kernel: Modules linked in: nfs_layout_nfsv41_files rpc
sec_gss_krb5 nfsv4 nfs nfsd auth_rpcgss oid_registry nfs_acl lockd sunrpc autofs4
Sep  2 13:28:33 localhost kernel: CPU: 1 PID: 306 Comm: nfsd Tainted: G        W    3.10.0-pnfs+ #6
Sep  2 13:28:33 localhost kernel: Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
Sep  2 13:28:33 localhost kernel: 0000000000000009 ffff88003bce3be8 ffffffff816cf76b ffff88003bce3c20
Sep  2 13:28:33 localhost kernel: ffffffff8105a4b1 ffff88003b960000 ffff88003b960020 ffff88003b27a2d0
Sep  2 13:28:33 localhost kernel: ffff88003b27db88 ffff88003d7028e8 ffff88003bce3c80 ffffffff8105a51c
Sep  2 13:28:33 localhost kernel: Call Trace:
Sep  2 13:28:33 localhost kernel: [<ffffffff816cf76b>] dump_stack+0x19/0x1b
Sep  2 13:28:33 localhost kernel: [<ffffffff8105a4b1>] warn_slowpath_common+0x61/0x80
Sep  2 13:28:33 localhost kernel: [<ffffffff8105a51c>] warn_slowpath_fmt+0x4c/0x50
Sep  2 13:28:33 localhost kernel: [<ffffffff8135e741>] __list_del_entry+0xa1/0xd0
Sep  2 13:28:33 localhost kernel: [<ffffffffa012955b>] unhash_delegation+0x3b/0xc0 [nfsd]
Sep  2 13:28:33 localhost kernel: [<ffffffffa01298d2>] destroy_delegation+0x12/0x30 [nfsd]
Sep  2 13:28:33 localhost kernel: [<ffffffffa0130de5>] nfsd4_delegreturn+0x275/0x2b0 [nfsd]
Sep  2 13:28:33 localhost kernel: [<ffffffffa0130b75>] ? nfsd4_delegreturn+0x5/0x2b0 [nfsd]
Sep  2 13:28:33 localhost kernel: [<ffffffffa011b061>] nfsd4_proc_compound+0x5c1/0x7d0 [nfsd]
Sep  2 13:28:33 localhost kernel: [<ffffffffa0103f1b>] nfsd_dispatch+0xbb/0x200 [nfsd]
Sep  2 13:28:33 localhost kernel: [<ffffffffa001e04d>] svc_process_common+0x46d/0x6e0 [sunrpc]
Sep  2 13:28:33 localhost kernel: [<ffffffffa001e3c7>] svc_process+0x107/0x170 [sunrpc]
Sep  2 13:28:33 localhost kernel: [<ffffffffa01032b3>] nfsd+0xd3/0x160 [nfsd]
Sep  2 13:28:33 localhost kernel: [<ffffffffa01031e0>] ? nfsd_destroy+0x220/0x220 [nfsd]
Sep  2 13:28:33 localhost kernel: [<ffffffff810889ad>] kthread+0xed/0x100
Sep  2 13:28:33 localhost kernel: [<ffffffff810c796d>] ? trace_hardirqs_off+0xd/0x10
Sep  2 13:28:33 localhost kernel: [<ffffffff810cb07d>] ? trace_hardirqs_on_caller+0xfd/0x1c0
Sep  2 13:28:33 localhost kernel: [<ffffffff810888c0>] ? insert_kthread_work+0x80/0x80
Sep  2 13:28:33 localhost kernel: [<ffffffff816e126c>] ret_from_fork+0x7c/0xb0
Sep  2 13:28:33 localhost kernel: [<ffffffff810888c0>] ? insert_kthread_work+0x80/0x80
Sep  2 13:28:33 localhost kernel: ---[ end trace 343813d8d9f6371e ]---

Sep  2 13:47:36 localhost kernel: NFSD: laundromat service - starting
Sep  2 13:47:36 localhost kernel: NFSD: purging unused client (clientid 00000001)
Sep  2 13:47:36 localhost kernel: nfsd4_umh_cltrack_upcall: cmd: remove
Sep  2 13:47:36 localhost kernel: nfsd4_umh_cltrack_upcall: arg: 4c696e7578204e465376342e31206c6f63616c686f73742e6c6f63616c646f6d61696e
Sep  2 13:47:36 localhost kernel: nfsd4_umh_cltrack_upcall: legacy: (null)
Sep  2 13:47:36 localhost kernel: nfsd4_umh_cltrack_upcall: /sbin/nfsdcltrack return value: 0
Sep  2 13:47:36 localhost kernel: ------------[ cut here ]------------
Sep  2 13:47:36 localhost kernel: WARNING: at /usr0/home/bhalevy/dev/linux-pnfs/lib/list_debug.c:59 __list_del_entry+0xa1/0xd0()
Sep  2 13:47:36 localhost kernel: list_del corruption. prev->next should be ffff88003b2b0020, but was 6b6b6b6b6b6b6b6b
Sep  2 13:47:36 localhost kernel: Modules linked in: nfs_layout_nfsv41_files rpcsec_gss_krb5 nfsv4 nfs nfsd auth_rpcgss oid_registry nfs_acl lockd sunrpc autofs4
Sep  2 13:47:36 localhost kernel: CPU: 0 PID: 39 Comm: kworker/u4:1 Tainted: G        W    3.10.0-pnfs+ #6
Sep  2 13:47:36 localhost kernel: Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
Sep  2 13:47:36 localhost kernel: Workqueue: nfsd4 laundromat_main [nfsd]
Sep  2 13:47:36 localhost kernel: 0000000000000009 ffff8800390b5ba8 ffffffff816cf76b ffff8800390b5be0
Sep  2 13:47:36 localhost kernel: ffffffff8105a4b1 ffff88003b2b0000 ffff88003b2b0020 ffff8800390b5ca8
Sep  2 13:47:36 localhost kernel: ffff88003865ef88 ffff88003855f008 ffff8800390b5c40 ffffffff8105a51c
Sep  2 13:47:36 localhost kernel: Call Trace:
Sep  2 13:47:36 localhost kernel: [<ffffffff816cf76b>] dump_stack+0x19/0x1b
Sep  2 13:47:36 localhost kernel: [<ffffffff8105a4b1>] warn_slowpath_common+0x61/0x80
Sep  2 13:47:36 localhost kernel: [<ffffffff8105a51c>] warn_slowpath_fmt+0x4c/0x50
Sep  2 13:47:36 localhost kernel: [<ffffffff8135e741>] __list_del_entry+0xa1/0xd0
Sep  2 13:47:36 localhost kernel: [<ffffffffa012955b>] unhash_delegation+0x3b/0xc0 [nfsd]
Sep  2 13:47:36 localhost kernel: [<ffffffffa01298d2>] destroy_delegation+0x12/0x30 [nfsd]
Sep  2 13:47:36 localhost kernel: [<ffffffffa012b219>] destroy_client+0x179/0x660 [nfsd]
Sep  2 13:47:36 localhost kernel: [<ffffffffa012b0a5>] ? destroy_client+0x5/0x660 [nfsd]
Sep  2 13:47:36 localhost kernel: [<ffffffffa013907d>] ? nfsd4_umh_cltrack_remove+0x3d/0x60 [nfsd]
Sep  2 13:47:36 localhost kernel: [<ffffffffa012d74a>] laundromat_main+0x1ba/0x570 [nfsd]
Sep  2 13:47:36 localhost kernel: [<ffffffff81080255>] ? process_one_work+0x1a5/0x6c0
Sep  2 13:47:36 localhost kernel: [<ffffffff810802c1>] process_one_work+0x211/0x6c0
Sep  2 13:47:36 localhost kernel: [<ffffffff81080255>] ? process_one_work+0x1a5/0x6c0
Sep  2 13:47:36 localhost kernel: [<ffffffff8108088d>] worker_thread+0x11d/0x3a0
Sep  2 13:47:36 localhost kernel: [<ffffffff81080770>] ? process_one_work+0x6c0/0x6c0
Sep  2 13:47:36 localhost kernel: [<ffffffff810889ad>] kthread+0xed/0x100
Sep  2 13:47:36 localhost kernel: [<ffffffff810c796d>] ? trace_hardirqs_off+0xd/0x10
Sep  2 13:47:36 localhost kernel: [<ffffffff810cb07d>] ? trace_hardirqs_on_caller+0xfd/0x1c0
Sep  2 13:47:36 localhost kernel: [<ffffffff810888c0>] ? insert_kthread_work+0x80/0x80
Sep  2 13:47:36 localhost kernel: [<ffffffff816e126c>] ret_from_fork+0x7c/0xb0
Sep  2 13:47:36 localhost kernel: [<ffffffff810888c0>] ? insert_kthread_work+0x80/0x80
Sep  2 13:47:36 localhost kernel: ---[ end trace d023d316d3a6f48c ]---
