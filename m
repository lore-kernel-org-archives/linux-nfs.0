Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gy0-f174.google.com ([209.85.160.174]:64666 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753666Ab2BTXAw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Feb 2012 18:00:52 -0500
Received: by ghrr11 with SMTP id r11so2758651ghr.19
        for <linux-nfs@vger.kernel.org>; Mon, 20 Feb 2012 15:00:51 -0800 (PST)
Message-ID: <4F42D05F.802@tonian.com>
Date: Mon, 20 Feb 2012 14:59:43 -0800
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: NFS list <linux-nfs@vger.kernel.org>
Subject: 3.3-rc1 pnfs client oops
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

After running a Connectathon test that reported the following:
rmdir: failed to remove `/mnt/10.41.40.52': Device or resource busy

I umounted /mnt/10.41.40.52 and ran the test again.
The client immediately oopsed with the report below.
The problem seems to have occurred in _deviceid_purge_client:

	while (!hlist_empty(&tmp)) {
		d = hlist_entry(tmp.first, struct nfs4_deviceid_node, tmpnode);
		hlist_del(&d->tmpnode);
		if (atomic_dec_and_test(&d->ref))
			d->ld->free_deviceid_node(d);
                               ^^^^^^^^^^^^^^^^^^^^^
	}

The machine code is:
			d->ld->free_deviceid_node(d);
ffffffff8103c0fa:	48 8b 43 10          	mov    0x10(%rbx),%rax
ffffffff8103c0fe:	4c 89 ff             	mov    %r15,%rdi
ffffffff8103c101:	ff 90 98 00 00 00    	callq  *0x98(%rax)
                                                ^^^^^^^^^^^^^^^^^^

Feb 20 18:50:51 vmf2-bh kernel: nfs4filelayout_init: NFSv4 File Layout Driver Registering...
Feb 20 19:02:42 vmf2-bh kernel: hrtimer: interrupt took 2549538 ns
Feb 20 19:02:43 vmf2-bh kernel: nfs4filelayout_exit: NFSv4 File Layout Driver Unregistering...
Feb 20 19:02:43 vmf2-bh kernel: nfs4filelayout_init: NFSv4 File Layout Driver Registering...
Feb 20 19:02:43 vmf2-bh kernel: Got error -10052 from the server on DESTROY_SESSION. Session has been destroyed regardless...
Feb 20 19:02:43 vmf2-bh kernel: BUG: unable to handle kernel paging request at ffffffffa0060628
Feb 20 19:02:43 vmf2-bh kernel: IP: [<ffffffffa01f7e0f>] nfs4_deviceid_purge_client+0x117/0x142 [nfs]
Feb 20 19:02:43 vmf2-bh kernel: PGD 1a07067 PUD 1a0b063 PMD 2adfb067 PTE 0
Feb 20 19:02:43 vmf2-bh kernel: Oops: 0000 [#1] SMP
Feb 20 19:02:43 vmf2-bh kernel: CPU 0
Feb 20 19:02:43 vmf2-bh kernel: Modules linked in: nfs_layout_nfsv41_files nfs nfsd lockd exportfs nfs_acl auth_rpcgss sunrpc iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi e1000 ipv6 autofs4 [last unloaded: nfs_layout_nfsv41_files]
Feb 20 19:02:43 vmf2-bh kernel:
Feb 20 19:02:43 vmf2-bh kernel: Pid: 2758, comm: 10.41.40.52-man Not tainted 3.3.0-rc1-pnfs-00144-g2cb2f65 #82 innotek GmbH VirtualBox
Feb 20 19:02:43 vmf2-bh kernel: RIP: 0010:[<ffffffffa01f7e0f>]  [<ffffffffa01f7e0f>] nfs4_deviceid_purge_client+0x117/0x142 [nfs]
Feb 20 19:02:43 vmf2-bh kernel: RSP: 0018:ffff88002482bd90  EFLAGS: 00010202
Feb 20 19:02:43 vmf2-bh kernel: RAX: ffffffffa0060590 RBX: ffff88002e39bac8 RCX: 0000000000000040
Feb 20 19:02:43 vmf2-bh kernel: RDX: ffff88002482bd98 RSI: 0000000000000008 RDI: ffff88002e39bab8
Feb 20 19:02:43 vmf2-bh kernel: RBP: ffff88002482bdd0 R08: ffff88002482bd30 R09: dead000000100100
Feb 20 19:02:43 vmf2-bh kernel: R10: dead000000200200 R11: ffff880024f47a18 R12: 0000000000000014
Feb 20 19:02:43 vmf2-bh kernel: R13: ffff880024f47a18 R14: ffff88002482bd98 R15: ffff88002e39bab8
Feb 20 19:02:43 vmf2-bh kernel: FS:  0000000000000000(0000) GS:ffff880030800000(0000) knlGS:0000000000000000
Feb 20 19:02:43 vmf2-bh kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Feb 20 19:02:43 vmf2-bh kernel: CR2: ffffffffa0060628 CR3: 000000002ad5d000 CR4: 00000000000006f0
Feb 20 19:02:43 vmf2-bh kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Feb 20 19:02:43 vmf2-bh kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Feb 20 19:02:43 vmf2-bh kernel: Process 10.41.40.52-man (pid: 2758, threadinfo ffff88002482a000, task ffff88002d090000)
Feb 20 19:02:43 vmf2-bh kernel: Stack:
Feb 20 19:02:43 vmf2-bh kernel: ffff88002482bda0 0000000000000000 ffff88002482bdd0 ffff880024f47a18
Feb 20 19:02:43 vmf2-bh kernel: ffff880024f47b10 ffff880024f47b10 0000000000000004 0000000000000000
Feb 20 19:02:43 vmf2-bh kernel: ffff88002482be30 ffffffffa01f6a8c ffff880024f47a18 0000000000000000
Feb 20 19:02:43 vmf2-bh kernel: Call Trace:
Feb 20 19:02:43 vmf2-bh kernel: [<ffffffffa01f6a8c>] pnfs_destroy_all_layouts+0x37/0x1e8 [nfs]
Feb 20 19:02:43 vmf2-bh kernel: [<ffffffffa00a574f>] ? put_rpccred+0x3d/0x103 [sunrpc]
Feb 20 19:02:43 vmf2-bh kernel: [<ffffffffa01eff58>] nfs4_run_state_manager+0x1a2/0x531 [nfs]
Feb 20 19:02:43 vmf2-bh kernel: [<ffffffffa01efdb6>] ? nfs4_do_reclaim+0x47a/0x47a [nfs]
Feb 20 19:02:43 vmf2-bh kernel: [<ffffffff8105ce1f>] kthread+0xaf/0xb7
Feb 20 19:02:43 vmf2-bh kernel: [<ffffffff8108c99e>] ? trace_hardirqs_on+0xd/0xf
Feb 20 19:02:43 vmf2-bh kernel: [<ffffffff814d4c74>] kernel_thread_helper+0x4/0x10
Feb 20 19:02:43 vmf2-bh kernel: [<ffffffff814ccdb4>] ? retint_restore_args+0x13/0x13
Feb 20 19:02:43 vmf2-bh kernel: [<ffffffff8105cd70>] ? __init_kthread_worker+0x5a/0x5a
Feb 20 19:02:43 vmf2-bh kernel: [<ffffffff814d4c70>] ? gs_change+0x13/0x13
Feb 20 19:02:43 vmf2-bh kernel: Code: 10 00 00 00 ad de 49 ba 00 02 20 00 00 00 ad de 48 8d 7b 38 4c 89 0b 4c 89 53 08 e8 c8 fa ff ff 85 c0 74 0d 48 8b 43 10 4c 89 ff <ff> 90 98 00 00 00 48 8b 5d c8 48 85 db 75 ab 49 ff c4 49 83 fc
Feb 20 19:02:43 vmf2-bh kernel: RIP  [<ffffffffa01f7e0f>] nfs4_deviceid_purge_client+0x117/0x142 [nfs]
Feb 20 19:02:43 vmf2-bh kernel: RSP <ffff88002482bd90>
Feb 20 19:02:43 vmf2-bh kernel: CR2: ffffffffa0060628
Feb 20 19:02:43 vmf2-bh kernel: ---[ end trace 810fae7fe0f28793 ]---
