From: David Howells <dhowells@redhat.com>
Subject: [PATCH] NFS: Fix RCU warnings in
	nfs_inode_return_delegation_noreclaim()
Date: Tue, 16 Mar 2010 11:51:30 +0000
Message-ID: <20100316115130.25642.17789.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Howells <dhowells@redhat.com>
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21303 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753426Ab0CPLvg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Mar 2010 07:51:36 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix a number of RCU warnings in nfs_inode_return_delegation_noreclaim().  They
look like simple cases of missing rcu_read_lock/unlock() calls.

===================================================
[ INFO: suspicious rcu_dereference_check() usage. ]
---------------------------------------------------
fs/nfs/delegation.c:332 invoked rcu_dereference_check() without protection!

other info that might help us debug this:


rcu_scheduler_active = 1, debug_locks = 0
2 locks held by mount.nfs4/2281:
 #0:  (&type->s_umount_key#34){+.+...}, at: [<ffffffff810b25b4>] deactivate_super+0x60/0x80
 #1:  (iprune_sem){+.+...}, at: [<ffffffff810c332a>] invalidate_inodes+0x39/0x13a

stack backtrace:
Pid: 2281, comm: mount.nfs4 Not tainted 2.6.34-rc1-cachefs #110
Call Trace:
 [<ffffffff8105149f>] lockdep_rcu_dereference+0xaa/0xb2
 [<ffffffffa00b4591>] nfs_inode_return_delegation_noreclaim+0x5b/0xa0 [nfs]
 [<ffffffffa0095d63>] nfs4_clear_inode+0x11/0x1e [nfs]
 [<ffffffff810c2d92>] clear_inode+0x9e/0xf8
 [<ffffffff810c3028>] dispose_list+0x67/0x10e
 [<ffffffff810c340d>] invalidate_inodes+0x11c/0x13a
 [<ffffffff810b1dc1>] generic_shutdown_super+0x42/0xf4
 [<ffffffff810b1ebe>] kill_anon_super+0x11/0x4f
 [<ffffffffa009893c>] nfs4_kill_super+0x3f/0x72 [nfs]
 [<ffffffff810b25bc>] deactivate_super+0x68/0x80
 [<ffffffff810c6744>] mntput_no_expire+0xbb/0xf8
 [<ffffffff810c681b>] release_mounts+0x9a/0xb0
 [<ffffffff810c689b>] put_mnt_ns+0x6a/0x79
 [<ffffffffa00983a1>] nfs_follow_remote_path+0x5a/0x146 [nfs]
 [<ffffffffa0098334>] ? nfs_do_root_mount+0x82/0x95 [nfs]
 [<ffffffffa00985a9>] nfs4_try_mount+0x75/0xaf [nfs]
 [<ffffffffa0098874>] nfs4_get_sb+0x291/0x31a [nfs]
 [<ffffffff810b2059>] vfs_kern_mount+0xb8/0x177
 [<ffffffff810b2176>] do_kern_mount+0x48/0xe8
 [<ffffffff810c810b>] do_mount+0x782/0x7f9
 [<ffffffff810c8205>] sys_mount+0x83/0xbe
 [<ffffffff81001eeb>] system_call_fastpath+0x16/0x1b

Also on:

fs/nfs/delegation.c:215 invoked rcu_dereference_check() without protection!
 [<ffffffff8105149f>] lockdep_rcu_dereference+0xaa/0xb2
 [<ffffffffa00b4223>] nfs_inode_set_delegation+0xfe/0x219 [nfs]
 [<ffffffffa00a9c6f>] nfs4_opendata_to_nfs4_state+0x2c2/0x30d [nfs]
 [<ffffffffa00aa15d>] nfs4_do_open+0x2a6/0x3a6 [nfs]
 ...

And:

fs/nfs/delegation.c:40 invoked rcu_dereference_check() without protection!
 [<ffffffff8105149f>] lockdep_rcu_dereference+0xaa/0xb2
 [<ffffffffa00b3bef>] nfs_free_delegation+0x3d/0x6e [nfs]
 [<ffffffffa00b3e71>] nfs_do_return_delegation+0x26/0x30 [nfs]
 [<ffffffffa00b406a>] __nfs_inode_return_delegation+0x1ef/0x1fe [nfs]
 [<ffffffffa00b448a>] nfs_client_return_marked_delegations+0xc9/0x124 [nfs]
 ...

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/nfs/delegation.c |   15 ++++++++++++---
 1 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 2563beb..a77c735 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -37,8 +37,10 @@ static void nfs_free_delegation(struct nfs_delegation *delegation)
 {
 	struct rpc_cred *cred;
 
+	rcu_read_lock();
 	cred = rcu_dereference(delegation->cred);
 	rcu_assign_pointer(delegation->cred, NULL);
+	rcu_read_unlock();
 	call_rcu(&delegation->rcu, nfs_free_delegation_callback);
 	if (cred)
 		put_rpccred(cred);
@@ -212,10 +214,12 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
 	spin_lock_init(&delegation->lock);
 
 	spin_lock(&clp->cl_lock);
+	rcu_read_lock();
 	if (rcu_dereference(nfsi->delegation) != NULL) {
 		if (memcmp(&delegation->stateid, &nfsi->delegation->stateid,
 					sizeof(delegation->stateid)) == 0 &&
 				delegation->type == nfsi->delegation->type) {
+			rcu_read_unlock();
 			goto out;
 		}
 		/*
@@ -228,6 +232,7 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
 		if (delegation->type <= nfsi->delegation->type) {
 			freeme = delegation;
 			delegation = NULL;
+			rcu_read_lock();
 			goto out;
 		}
 		freeme = nfs_detach_delegation_locked(nfsi, NULL);
@@ -236,6 +241,7 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
 	nfsi->delegation_state = delegation->type;
 	rcu_assign_pointer(nfsi->delegation, delegation);
 	delegation = NULL;
+	rcu_read_unlock();
 
 	/* Ensure we revalidate the attributes and page cache! */
 	spin_lock(&inode->i_lock);
@@ -327,15 +333,18 @@ void nfs_inode_return_delegation_noreclaim(struct inode *inode)
 {
 	struct nfs_client *clp = NFS_SERVER(inode)->nfs_client;
 	struct nfs_inode *nfsi = NFS_I(inode);
-	struct nfs_delegation *delegation;
+	struct nfs_delegation *delegation = NULL;
 
+	rcu_read_lock();
 	if (rcu_dereference(nfsi->delegation) != NULL) {
 		spin_lock(&clp->cl_lock);
 		delegation = nfs_detach_delegation_locked(nfsi, NULL);
 		spin_unlock(&clp->cl_lock);
-		if (delegation != NULL)
-			nfs_do_return_delegation(inode, delegation, 0);
 	}
+	rcu_read_unlock();
+
+	if (delegation)
+		nfs_do_return_delegation(inode, delegation, 0);
 }
 
 int nfs_inode_return_delegation(struct inode *inode)

