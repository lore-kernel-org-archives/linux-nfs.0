Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:42571 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751869Ab3ARXNJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jan 2013 18:13:09 -0500
From: greearb@candelatech.com
To: linux-nfs@vger.kernel.org
Cc: Ben Greear <greearb@candelatech.com>
Subject: [PATCH] nfs:  Fix crash on error case in nfs40_discover_server_trunking
Date: Fri, 18 Jan 2013 15:12:56 -0800
Message-Id: <1358550776-22999-1-git-send-email-greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

The call to nfs40_walk_client_list will not set 'result' in
the failure case, so we must not dereference it.  Per
Chuck Lever's suggestion, just run the nfs4_schedule_state_renewal
on the 'clp' object instead.

In addition, initilize the 'old' pointer so that if a bug like
this is ever introduced again, it will be easier to diagnose.

This fixes the splat below:

NFS: nfs40_walk_client_list Error: no matching nfs_client found
BUG: spinlock bad magic on CPU#5, mount.nfs4/18612
general protection fault: 0000 [#1] PREEMPT SMP
Modules linked in: nf_nat_ipv4 nf_nat nfsv4 auth_rpcgss nfs fscache 8021q garp stp llc macvlan wanlink(O]
CPU 5
Pid: 18612, comm: mount.nfs4 Tainted: G         C O 3.7.2+ #32 Iron Systems Inc. EE2610R/X8ST3
RIP: 0010:[<ffffffff81287033>]  [<ffffffff81287033>] spin_dump+0x5e/0x8c
RSP: 0018:ffff88022e647808  EFLAGS: 00010286
RAX: 0000000000000032 RBX: ffff8803cee0f318 RCX: ffffffff817ea493
RDX: ffff88022e647fd8 RSI: 0000000000000001 RDI: 0000000000000246
RBP: ffff88022e647818 R08: 00000000ffffffff R09: 000000008161d300
R10: ffff88022e647708 R11: 0000000000000000 R12: dead4ead00000000
R13: ffff8803de5f0780 R14: ffff88031297f840 R15: ffff8803de5f0780
FS:  00007f530cc5a740(0000) GS:ffff88041fca0000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007f22eeae4088 CR3: 000000022f88a000 CR4: 00000000000007e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process mount.nfs4 (pid: 18612, threadinfo ffff88022e646000, task ffff8803422cc590)
Stack:
 ffff8803cee0f318 ffff8803cee0f318 ffff88022e647838 ffffffff81287087
 ffffffff817d6812 ffff8803cee0f318 ffff88022e647868 ffffffff81287137
 0000000000000000 ffff8803cee0f318 ffff8803cee0f318 ffff8803de5f0780
Call Trace:
 [<ffffffff81287087>] spin_bug+0x26/0x28
 [<ffffffff81287137>] do_raw_spin_lock+0x25/0x10a
 [<ffffffff815246c5>] _raw_spin_lock+0x1e/0x23
 [<ffffffffa044487f>] nfs4_schedule_state_renewal+0x19/0x77 [nfsv4]
 [<ffffffffa0443b03>] nfs40_discover_server_trunking+0xb2/0xc0 [nfsv4]
 [<ffffffffa044242b>] nfs4_discover_server_trunking+0xb3/0x1e7 [nfsv4]
 [<ffffffffa044a0f4>] nfs4_init_client+0x143/0x1ad [nfsv4]
 [<ffffffff81278dc7>] ? idr_get_new_above_int+0x1c/0x70
 [<ffffffffa00f5474>] ? __rpc_init_priority_wait_queue+0x8d/0xb9 [sunrpc]
 [<ffffffffa00f54ae>] ? rpc_init_wait_queue+0xe/0x10 [sunrpc]
 [<ffffffffa044a330>] ? nfs4_alloc_client+0x12e/0x182 [nfsv4]
 [<ffffffffa03bcfff>] nfs_get_client+0x235/0x287 [nfs]
 [<ffffffffa0449461>] nfs4_set_client+0x71/0x8e [nfsv4]
 [<ffffffffa03bd8ac>] ? nfs_alloc_server+0xfa/0x101 [nfs]
 [<ffffffffa0449836>] nfs4_create_server+0xe2/0x25c [nfsv4]
 [<ffffffffa0444e1c>] nfs4_remote_mount+0x2a/0x56 [nfsv4]
 [<ffffffff8114aa69>] mount_fs+0x6b/0x152
 [<ffffffff8111a849>] ? __alloc_percpu+0xb/0xd
 [<ffffffff8116173f>] vfs_kern_mount+0x66/0xe5
 [<ffffffffa0444bb6>] nfs_do_root_mount+0x96/0xb5 [nfsv4]
 [<ffffffffa0444ddb>] nfs4_try_mount+0x32/0x49 [nfsv4]
 [<ffffffffa03c63b2>] nfs_fs_mount+0x823/0x905 [nfs]
 [<ffffffffa03c485e>] ? nfs_clone_super+0x66/0x66 [nfs]
 [<ffffffffa03c4710>] ? nfs_clone_sb_security+0x49/0x49 [nfs]
 [<ffffffff8114aa69>] mount_fs+0x6b/0x152
 [<ffffffff8111a849>] ? __alloc_percpu+0xb/0xd
 [<ffffffff8116173f>] vfs_kern_mount+0x66/0xe5
 [<ffffffff8116182f>] do_kern_mount+0x48/0xd8
 [<ffffffff81161fda>] do_mount+0x71b/0x77e
 [<ffffffff811620c0>] sys_mount+0x83/0xbd
 [<ffffffff81529829>] system_call_fastpath+0x16/0x1b
Code: 00 48 8d 88 58 04 00 00 31 c0 65 8b 14 25 20 b0 00 00 e8 94 b1 29 00 41 83 c8 ff 4d 85 e4 44 8b 4b
RIP  [<ffffffff81287033>] spin_dump+0x5e/0x8c
 RSP <ffff88022e647808>
---[ end trace 2e56a2cc96df8e08 ]---

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
 fs/nfs/nfs4client.c |    2 +-
 fs/nfs/nfs4state.c  |    2 ++
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index d6b39a9..cdc99bd 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -185,7 +185,7 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
 				    rpc_authflavor_t authflavour)
 {
 	char buf[INET6_ADDRSTRLEN + 1];
-	struct nfs_client *old;
+	struct nfs_client *old = NULL;
 	int error;
 
 	if (clp->cl_cons_state == NFS_CS_READY) {
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index c351e6b..7103617 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -139,6 +139,8 @@ int nfs40_discover_server_trunking(struct nfs_client *clp,
 	switch (status) {
 	case -NFS4ERR_STALE_CLIENTID:
 		set_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
+		nfs4_schedule_state_renewal(clp);
+		break;
 	case 0:
 		/* Sustain the lease, even if it's empty.  If the clientid4
 		 * goes stale it's of no use for trunking discovery. */
-- 
1.7.3.4

