Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oi0-f44.google.com ([209.85.218.44]:45671 "EHLO
	mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752748AbbBZPgf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Feb 2015 10:36:35 -0500
Received: by mail-oi0-f44.google.com with SMTP id a3so9910047oib.3
        for <linux-nfs@vger.kernel.org>; Thu, 26 Feb 2015 07:36:34 -0800 (PST)
Message-ID: <1424964991.10136.8.camel@primarydata.com>
Subject: Re: NMI/soft lockup in nfs_delegation_need_return()
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: David Howells <dhowells@redhat.com>
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
Date: Thu, 26 Feb 2015 10:36:31 -0500
In-Reply-To: <6150.1424947519@warthog.procyon.org.uk>
References: <1411654543.3044.24.camel@leira.trondhjem.org>
	 <28059.1411650278@warthog.procyon.org.uk>
	 <6150.1424947519@warthog.procyon.org.uk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2015-02-26 at 10:45 +0000, David Howells wrote:
> Seems I can still reproduce this (see below).  I don't suppose you've had any
> further insights since September?
> 
> David
> ---
> NMI watchdog: BUG: soft lockup - CPU#1 stuck for 23s! [90.155.74.18-ma:2834]
> Modules linked in: cachefiles nfsv4 nfsv3 nfsv2 nfs fscache auth_rpcgss nfs_acl lockd grace sunrpc
> irq event stamp: 135774
> hardirqs last  enabled at (135773): [<ffffffff81091701>] __call_rcu+0x241/0x253
> hardirqs last disabled at (135774): [<ffffffff8155895a>] apic_timer_interrupt+0x6a/0x80
> softirqs last  enabled at (135762): [<ffffffff810439a8>] __do_softirq+0x25a/0x319
> softirqs last disabled at (135757): [<ffffffff81043c73>] irq_exit+0x5e/0xd6
> CPU: 1 PID: 2834 Comm: 90.155.74.18-ma Tainted: G        W       3.19.0-fsdevel+ #1143
> Hardware name:                  /DG965RY, BIOS MQ96510J.86A.0816.2006.0716.2308 07/16/2006
> task: ffff88000ab6a410 ti: ffff88001cab8000 task.ti: ffff88001cab8000
> RIP: 0010:[<ffffffffa010c418>]  [<ffffffffa010c418>] nfs_client_return_marked_delegations+0x9b/0x1a9 [nfsv4]
> RSP: 0018:ffff88001cabbdb8  EFLAGS: 00000292
> RAX: ffff880000e4b7c0 RBX: ffffffffa010c39c RCX: 0000000000000000
> RDX: ffff880000e4b808 RSI: ffff88000ab6a410 RDI: ffff88000ab6a410
> RBP: ffff88001cabbe08 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000296
> R13: ffff88001cabbd98 R14: 0000000000000002 R15: 0000000000000000
> FS:  0000000000000000(0000) GS:ffff88003db00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 00007f419ab7a000 CR3: 000000003a7fa000 CR4: 00000000000007e0
> Stack:
>  ffff880038dc9cc8 ffff880010e8d7f8 ffff88000ab6a410 ffff880000e4b7c0
>  ffff88001cabbe08 ffff880038dc9c00 ffff880038dc9c00 ffff880038dc9d30
>  0000000000000000 0000000000000000 ffff88001cabbe58 ffffffffa010a54f
> Call Trace:
>  [<ffffffffa010a54f>] nfs4_run_state_manager+0x5da/0x5df [nfsv4]
>  [<ffffffffa0109f75>] ? nfs4_do_reclaim+0x55d/0x55d [nfsv4]
>  [<ffffffffa0109f75>] ? nfs4_do_reclaim+0x55d/0x55d [nfsv4]
>  [<ffffffff81059b9d>] kthread+0x10e/0x116
>  [<ffffffff81059a8f>] ? kthread_create_on_node+0x1bb/0x1bb
>  [<ffffffff815579ac>] ret_from_fork+0x7c/0xb0
>  [<ffffffff81059a8f>] ? kthread_create_on_node+0x1bb/0x1bb
> Code: 00 48 89 45 c8 4c 8b 65 c8 48 8d 83 f8 07 00 00 48 89 45 b8 4c 3b 65 b8 0f 84 d6 00 00 00 49 8d 54 24 48 f0 41 0f ba 74 24 48 01 <72> 05 45 31 f6 eb 03 41 b6 01 f0 0f ba 32 02 72 02 eb 36 45 84 

Maybe. Does the following patch help?

Cheers
  Trond
8<--------------------------------------------------------
>From 3a6839513e9ef00a5bd519b9965a301d8d156a7d Mon Sep 17 00:00:00 2001
From: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Thu, 26 Feb 2015 09:57:34 -0500
Subject: [PATCH] NFSv4: Pin the superblock while we're returning the
 delegation

This patch ensures that the superblock doesn't go ahead and disappear
underneath us while the state manager thread is returning delegations.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/delegation.c | 20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index a1f0685b42ff..dcc5af078d48 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -471,14 +471,20 @@ restart:
 								super_list) {
 			if (!nfs_delegation_need_return(delegation))
 				continue;
-			inode = nfs_delegation_grab_inode(delegation);
-			if (inode == NULL)
+			if (!nfs_sb_active(server->super))
 				continue;
+			inode = nfs_delegation_grab_inode(delegation);
+			if (inode == NULL) {
+				rcu_read_unlock();
+				nfs_sb_deactive(server->super);
+				goto restart;
+			}
 			delegation = nfs_start_delegation_return_locked(NFS_I(inode));
 			rcu_read_unlock();
 
 			err = nfs_end_delegation_return(inode, delegation, 0);
 			iput(inode);
+			nfs_sb_deactive(server->super);
 			if (!err)
 				goto restart;
 			set_bit(NFS4CLNT_DELEGRETURN, &clp->cl_state);
@@ -812,9 +818,14 @@ restart:
 			if (test_bit(NFS_DELEGATION_NEED_RECLAIM,
 						&delegation->flags) == 0)
 				continue;
-			inode = nfs_delegation_grab_inode(delegation);
-			if (inode == NULL)
+			if (!nfs_sb_active(server->super))
 				continue;
+			inode = nfs_delegation_grab_inode(delegation);
+			if (inode == NULL) {
+				rcu_read_unlock();
+				nfs_sb_deactive(server->super);
+				goto restart;
+			}
 			delegation = nfs_detach_delegation(NFS_I(inode),
 					delegation, server);
 			rcu_read_unlock();
@@ -822,6 +833,7 @@ restart:
 			if (delegation != NULL)
 				nfs_free_delegation(delegation);
 			iput(inode);
+			nfs_sb_deactive(server->super);
 			goto restart;
 		}
 	}
-- 
2.1.0



-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com




