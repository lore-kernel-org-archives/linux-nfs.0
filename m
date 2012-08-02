Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bk0-f46.google.com ([209.85.214.46]:47855 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751735Ab2HBIrU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Aug 2012 04:47:20 -0400
Received: by bkwj10 with SMTP id j10so4129902bkw.19
        for <linux-nfs@vger.kernel.org>; Thu, 02 Aug 2012 01:47:19 -0700 (PDT)
From: Idan Kedar <idank@tonian.com>
To: coredev@tonian.com, Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@tonian.com>
Subject: [PATCH v2 0/2] pnfs: fix a crash when hitting Ctrl+C during LAYOUTGET
Date: Thu,  2 Aug 2012 11:47:09 +0300
Message-Id: <1343897231-30205-1-git-send-email-idank@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

While working on object layout, we have encountered a general protection fault
in xdr_shrink_bufhead when killing a process performing a lot of reads.

full trace:

[ 1353.258729] general protection fault: 0000 [#1] SMP DEBUG_PAGEALLOC
[ 1353.259109] CPU 0 
[ 1353.259109] Modules linked in:[ 1353.259109]  objlayoutdriver exofs libore osd libosd iscsi_tcp netconsole nfs nfsd lockd fscache auth_rpcgss nfs_acl sunrpc e1000 rtc_cmos serio_raw microcode [last unloaded: scsi_wait_scan]

[ 1353.259109] Pid: 4, comm: kworker/0:0 Not tainted 3.5.0-nfsobj #147 innotek GmbH VirtualBox
[ 1353.259109] RIP: 0010:[<ffffffff8132cf2d>]  [<ffffffff8132cf2d>] memcpy+0xd/0x110
[ 1353.259109] RSP: 0018:ffff88003d6cdab8  EFLAGS: 00010202
[ 1353.259109] RAX: ffff88003b51928c RBX: ffff88003b51928c RCX: 000000000000000d
[ 1353.259109] RDX: 0000000000000004 RSI: 0005080000000004 RDI: ffff88003b51928c
[ 1353.259109] RBP: ffff88003d6cdb00 R08: ffff88003a9d0748 R09: 0000000000000001
[ 1353.259109] R10: 0000000000000000 R11: 0000000000000001 R12: 000000000000006c
[ 1353.259109] R13: 0000000000000004 R14: 000000000000006c R15: ffff88003d6cc000
[ 1353.259109] FS:  0000000000000000(0000) GS:ffff88003e200000(0000) knlGS:0000000000000000
[ 1353.259109] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 1353.259109] CR2: 0000003ce4076770 CR3: 000000003772c000 CR4: 00000000000006f0
[ 1353.259109] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1353.259109] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 1353.259109] Process kworker/0:0 (pid: 4, threadinfo ffff88003d6cc000, task ffff88003d6d0000)
[ 1353.259109] Stack:
[ 1353.259109]  ffffffffa0056e17 ffff88003d6cdfd8 ffff88003bebf8c8 ffff88003d6cdae0
[ 1353.259109]  ffff88003bebc390 0000000000000ffc 0000000000021000 0000000000021000
[ 1353.259109]  ffff88003b518284 ffff88003d6cdb70 ffffffffa005779f ffff88003e3d4a80
[ 1353.259109] Call Trace:
[ 1353.259109]  [<ffffffffa0056e17>] ? _copy_from_pages+0xa7/0xe0 [sunrpc]
[ 1353.259109]  [<ffffffffa005779f>] xdr_shrink_bufhead+0x7f/0x270 [sunrpc]
[ 1353.259109]  [<ffffffffa00579e2>] xdr_read_pages+0x42/0x150 [sunrpc]
[ 1353.259109]  [<ffffffffa01668a4>] nfs4_xdr_dec_layoutget+0x174/0x180 [nfs]
[ 1353.259109]  [<ffffffffa0166730>] ? decode_getfh+0x120/0x120 [nfs]
[ 1353.259109]  [<ffffffffa0166730>] ? decode_getfh+0x120/0x120 [nfs]
[ 1353.259109]  [<ffffffffa004de05>] rpcauth_unwrap_resp+0x65/0x70 [sunrpc]
[ 1353.259109]  [<ffffffffa0043f47>] call_decode+0x377/0x470 [sunrpc]
[ 1353.259109]  [<ffffffff810c216d>] ? trace_hardirqs_off+0xd/0x10
[ 1353.259109]  [<ffffffffa0043bd0>] ? call_status+0x210/0x210 [sunrpc]
[ 1353.259109]  [<ffffffffa0043bd0>] ? call_status+0x210/0x210 [sunrpc]
[ 1353.259109]  [<ffffffffa004bb14>] __rpc_execute+0x64/0x2b0 [sunrpc]
[ 1353.259109]  [<ffffffffa004bd60>] ? __rpc_execute+0x2b0/0x2b0 [sunrpc]
[ 1353.259109]  [<ffffffffa004bd75>] rpc_async_schedule+0x15/0x20 [sunrpc]
[ 1353.259109]  [<ffffffff81084294>] process_one_work+0x1a4/0x4f0
[ 1353.259109]  [<ffffffff81084231>] ? process_one_work+0x141/0x4f0
[ 1353.259109]  [<ffffffff81085fc2>] worker_thread+0x162/0x350
[ 1353.259109]  [<ffffffff81085e60>] ? manage_workers.clone.19+0x240/0x240
[ 1353.259109]  [<ffffffff8108b5c6>] kthread+0xc6/0xd0
[ 1353.259109]  [<ffffffff81097426>] ? finish_task_switch+0x46/0xf0
[ 1353.259109]  [<ffffffff817a91b4>] kernel_thread_helper+0x4/0x10
[ 1353.259109]  [<ffffffff8179f9f0>] ? retint_restore_args+0x13/0x13
[ 1353.259109]  [<ffffffff8108b500>] ? __init_kthread_worker+0x70/0x70
[ 1353.259109]  [<ffffffff817a91b0>] ? gs_change+0x13/0x13
[ 1353.259109] Code: 43 50 88 43 4e 48 83 c4 08 5b c9 c3 66 90 e8 eb fb ff ff eb e6 90 90 90 90 90 90 90 90 90 48 89 f8 48 89 d1 48 c1 e9 03 83 e2 07 <f3> 48 a5 89 d1 f3 a4 c3 20 4c 8b 06 4c 8b 4e 08 4c 8b 56 10 4c 
[ 1353.259109] RIP  [<ffffffff8132cf2d>] memcpy+0xd/0x110
[ 1353.259109]  RSP <ffff88003d6cdab8>
[ 1353.328569] ---[ end trace a48bf911452c4212 ]---

to reproduce:
mount an object-based pNFS file system. we used exofs as the MDS. assume the
mount point is /mnt/pnfs, run:

cp -r /bin /mnt/pnfs
cd /mnt/pnfs
while true; do
        rm -rf bin2
        echo 3 > /proc/sys/vm/drop_caches
        cp -r bin bin2 &
        sleep 1
        kill -s int $!
done

on my setup it crashed after a couple of minutes, sometimes a couple of seconds.
your mileage may vary.

differences from v1:
* fold 3rd patch into first one.
* use kcalloc() instead of kzalloc().
* functions renamed to better fit the convention.

Idan Kedar (2):
  pnfs: defer release of pages in layoutget
  pnfs: nfs4_proc_layoutget returns void

 fs/nfs/nfs4proc.c |   61 ++++++++++++++++++++++++++++++++++++++++++++++++++--
 fs/nfs/pnfs.c     |   39 +---------------------------------
 fs/nfs/pnfs.h     |    2 +-
 3 files changed, 60 insertions(+), 42 deletions(-)

-- 
1.7.6.5

