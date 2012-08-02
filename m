Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ob0-f174.google.com ([209.85.214.174]:36380 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751693Ab2HBQHl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Aug 2012 12:07:41 -0400
Received: by obbuo13 with SMTP id uo13so14020366obb.19
        for <linux-nfs@vger.kernel.org>; Thu, 02 Aug 2012 09:07:40 -0700 (PDT)
MIME-Version: 1.0
From: William Dauchy <wdauchy@gmail.com>
Date: Thu, 2 Aug 2012 18:07:20 +0200
Message-ID: <CAJ75kXa9PRJMHXfTHGLxnXUAMwnA9RD5G+cjHnOdk8SE_hbsZQ@mail.gmail.com>
Subject: nfs_idmap_legacy_upcall
To: David Howells <dhowells@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I'm getting a trace on nfs_idmap_legacy_upcall with a 3.4.7 amd64 kernel.
This nfs patch was also applied:
a427b9e (trond tree) NFS: Fix a number of bugs in the idmapper
Any thoughts?

CPU 0
Pid: 32093, comm: mount.nfs4 Not tainted 3.4.7
RIP: 0010:[<ffffffff81185451>]  [<ffffffff81185451>]
nfs_idmap_legacy_upcall+0x1e1/0x1f0
RSP: 0018:ffff88056eef9548  EFLAGS: 00010282
RAX: 000000000000000e RBX: ffff88061b8d1200 RCX: 0000000000000000
RDX: 0000000000000006 RSI: ffff8805804354d2 RDI: ffff88061b8d1210
RBP: ffff8805b8725140 R08: 000000000000003a R09: ffffffff811852ed
R10: 00000000f661ded1 R11: 00000000677e45e9 R12: ffff880c0512c5b0
R13: ffff8805b8725740 R14: ffff88061ccab140 R15: 000000000000000e
FS:  0000036dfcf5d700(0000) GS:ffff880627c00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000040001dc1000 CR3: 000000000148e000 CR4: 00000000000007f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process mount.nfs4 (pid: 32093, threadinfo ffff88056ec3f950, task
ffff88056ec3f500)
Stack:
 ffff8805804354c4 ffff8805804354d2 ffffffff81938600 ffff880c0512c5b0
 ffff88061ccaae40 ffff88061ccab140 ffffffff816b02b9 ffffffff81938618
 0000000000000000 ffffffff811a56b4 0000000000000000 0000000000000000
Call Trace:
 [<ffffffff811a56b4>] ? request_key_and_link+0x394/0x460
 [<ffffffff811a57d5>] ? request_key_with_auxdata+0x15/0x60
 [<ffffffff81185543>] ? nfs_idmap_request_key+0xe3/0x1c0
 [<ffffffff811856d0>] ? nfs_idmap_get_key+0xb0/0xd0
 [<ffffffff811859af>] ? nfs_idmap_lookup_id+0x2f/0x80
 [<ffffffff81185a39>] ? nfs_map_group_to_gid+0x39/0x90
 [<ffffffff8117e4f5>] ? decode_getfattr_attrs+0x915/0xa10
 [<ffffffff8117fdc6>] ? T.1607+0x96/0xe0
 [<ffffffff811802a9>] ? nfs4_xdr_dec_lookup_root+0x69/0x70
 [<ffffffff814481f0>] ? rpc_queue_empty+0x40/0x40
 [<ffffffff814481f0>] ? rpc_queue_empty+0x40/0x40
 [<ffffffff81180240>] ? nfs4_xdr_dec_remove+0x90/0x90
 [<ffffffff81449419>] ? rpcauth_unwrap_resp+0x79/0x80
 [<ffffffff81180240>] ? nfs4_xdr_dec_remove+0x90/0x90
 [<ffffffff81441313>] ? call_decode+0x2a3/0x400
 [<ffffffff81448806>] ? __rpc_execute+0x46/0x1b0
 [<ffffffff81055368>] ? wake_up_bit+0x18/0x40
 [<ffffffff81441cc9>] ? rpc_run_task+0x79/0xa0
 [<ffffffff81441deb>] ? rpc_call_sync+0x3b/0x70
 [<ffffffff8117624a>] ? _nfs4_lookup_root+0xaa/0xd0
 [<ffffffff81458052>] ? T.993+0x92/0xd0
 [<ffffffff811762be>] ? nfs4_lookup_root+0x4e/0x90
 [<ffffffff81176330>] ? nfs4_proc_get_root+0x30/0xd0
 [<ffffffff811616c3>] ? nfs4_get_rootfh+0x43/0xf0
 [<ffffffff81440ac9>] ? rpc_net_ns+0x19/0x20
 [<ffffffff814418a6>] ? rpc_register_client+0x56/0xa0
 [<ffffffff8115b553>] ? nfs4_server_common_setup+0x63/0xf0
 [<ffffffff8115c8ca>] ? nfs4_create_server+0x1ca/0x2c0
 [<ffffffff81166432>] ? nfs4_remote_mount+0x62/0x210
 [<ffffffff810f5045>] ? mount_fs+0x45/0x1c0
 [<ffffffff8111288d>] ? vfs_kern_mount+0x6d/0x100
 [<ffffffff81166840>] ? nfs_do_root_mount+0x90/0xf0
 [<ffffffff81166b08>] ? nfs4_try_mount+0x38/0x60
 [<ffffffff81166d15>] ? nfs4_mount+0x1e5/0x490
 [<ffffffff810df1a4>] ? __kmalloc_track_caller+0x34/0x120
 [<ffffffff810f5045>] ? mount_fs+0x45/0x1c0
 [<ffffffff8111288d>] ? vfs_kern_mount+0x6d/0x100
 [<ffffffff81112e33>] ? do_kern_mount+0x53/0x110
 [<ffffffff8111440e>] ? do_mount+0x22e/0x870
 [<ffffffff811f6cb5>] ? __get_user_1+0x25/0x30
 [<ffffffff81114aea>] ? sys_mount+0x9a/0x100
 [<ffffffff8147e2de>] ? system_call_fastpath+0x18/0x1d
Code: 01 48 8d 7b 02 ba 80 00 00 00 48 89 e6 e8 58 36 07 00 41 89 c7
eb 9c 0f 1f 00 c7 03 00 00 00 00 48 8d 7b 04 b2 88 e9 b9 fe ff ff <0f>
0b eb fe 66 66 2e 0f 1f 84 00 00 00 00 00 48 83 ec 58 31 c0
RIP  [<ffffffff81185451>] nfs_idmap_legacy_upcall+0x1e1/0x1f0
 RSP <ffff88056eef9548>
---[ end trace ab4ae3b499d533dc ]---

Regards,
-- 
William
