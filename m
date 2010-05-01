From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH 2/2] NFS: Fix RCU issues in the NFSv4 delegation code
Date: Fri, 30 Apr 2010 17:32:48 -0700
Message-ID: <1272673968-28066-2-git-send-email-paulmck@linux.vnet.ibm.com>
References: <20100501003153.GA27982@linux.vnet.ibm.com>
Cc: mingo@elte.hu, peterz@infradead.org, Trond.Myklebust@netapp.com,
	David Howells <dhowells@redhat.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100501003153.GA27982@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: David Howells <dhowells@redhat.com>

Fix a number of RCU issues in the NFSv4 delegation code.

 (1) delegation->cred doesn't need to be RCU protected as it's essentially an
     invariant refcounted structure.

     By the time we get to nfs_free_delegation(), the delegation is being
     released, so no one else should be attempting to use the saved
     credentials, and they can be cleared.

     However, since the list of delegations could still be under traversal at
     this point by such as nfs_client_return_marked_delegations(), the cred
     should be released in nfs_do_free_delegation() rather than in
     nfs_free_delegation().  Simply using rcu_assign_pointer() to clear it is
     insufficient as that doesn't stop the cred from being destroyed, and nor
     does calling put_rpccred() after call_rcu(), given that the latter is
     asynchronous.

 (2) nfs_detach_delegation_locked() and nfs_inode_set_delegation() should use
     rcu_derefence_protected() because they can only be called if
     nfs_client::cl_lock is held, and that guards against anyone changing
     nfsi->delegation under it.  Furthermore, the barrier imposed by
     rcu_dereference() is superfluous, given that the spin_lock() is also a
     barrier.

 (3) nfs_detach_delegation_locked() is now passed a pointer to the nfs_client
     struct so that it can issue lockdep advice based on clp->cl_lock for (2).

 (4) nfs_inode_return_delegation_noreclaim() and nfs_inode_return_delegation()
     should use rcu_access_pointer() outside the spinlocked region as they
     merely examine the pointer and don't follow it, thus rendering unnecessary
     the need to impose a partial ordering over the one item of interest.

     These result in an RCU warning like the following:

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
Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
---
 fs/nfs/delegation.c |   44 +++++++++++++++++++++++---------------------
 1 files changed, 23 insertions(+), 21 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 8d9ec49..ea61d26 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -24,6 +24,8 @@
 
 static void nfs_do_free_delegation(struct nfs_delegation *delegation)
 {
+	if (delegation->cred)
+		put_rpccred(delegation->cred);
 	kfree(delegation);
 }
 
@@ -36,13 +38,7 @@ static void nfs_free_delegation_callback(struct rcu_head *head)
 
 static void nfs_free_delegation(struct nfs_delegation *delegation)
 {
-	struct rpc_cred *cred;
-
-	cred = rcu_dereference(delegation->cred);
-	rcu_assign_pointer(delegation->cred, NULL);
 	call_rcu(&delegation->rcu, nfs_free_delegation_callback);
-	if (cred)
-		put_rpccred(cred);
 }
 
 void nfs_mark_delegation_referenced(struct nfs_delegation *delegation)
@@ -180,9 +176,13 @@ static struct inode *nfs_delegation_grab_inode(struct nfs_delegation *delegation
 	return inode;
 }
 
-static struct nfs_delegation *nfs_detach_delegation_locked(struct nfs_inode *nfsi, const nfs4_stateid *stateid)
+static struct nfs_delegation *nfs_detach_delegation_locked(struct nfs_inode *nfsi,
+							   const nfs4_stateid *stateid,
+							   struct nfs_client *clp)
 {
-	struct nfs_delegation *delegation = rcu_dereference(nfsi->delegation);
+	struct nfs_delegation *delegation =
+		rcu_dereference_protected(nfsi->delegation,
+					  lockdep_is_held(&clp->cl_lock));
 
 	if (delegation == NULL)
 		goto nomatch;
@@ -209,7 +209,7 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
 {
 	struct nfs_client *clp = NFS_SERVER(inode)->nfs_client;
 	struct nfs_inode *nfsi = NFS_I(inode);
-	struct nfs_delegation *delegation;
+	struct nfs_delegation *delegation, *old_delegation;
 	struct nfs_delegation *freeme = NULL;
 	int status = 0;
 
@@ -227,10 +227,12 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
 	spin_lock_init(&delegation->lock);
 
 	spin_lock(&clp->cl_lock);
-	if (rcu_dereference(nfsi->delegation) != NULL) {
-		if (memcmp(&delegation->stateid, &nfsi->delegation->stateid,
-					sizeof(delegation->stateid)) == 0 &&
-				delegation->type == nfsi->delegation->type) {
+	old_delegation = rcu_dereference_protected(nfsi->delegation,
+						   lockdep_is_held(&clp->cl_lock));
+	if (old_delegation != NULL) {
+		if (memcmp(&delegation->stateid, &old_delegation->stateid,
+					sizeof(old_delegation->stateid)) == 0 &&
+				delegation->type == old_delegation->type) {
 			goto out;
 		}
 		/*
@@ -240,12 +242,12 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
 		dfprintk(FILE, "%s: server %s handed out "
 				"a duplicate delegation!\n",
 				__func__, clp->cl_hostname);
-		if (delegation->type <= nfsi->delegation->type) {
+		if (delegation->type <= old_delegation->type) {
 			freeme = delegation;
 			delegation = NULL;
 			goto out;
 		}
-		freeme = nfs_detach_delegation_locked(nfsi, NULL);
+		freeme = nfs_detach_delegation_locked(nfsi, NULL, clp);
 	}
 	list_add_rcu(&delegation->super_list, &clp->cl_delegations);
 	nfsi->delegation_state = delegation->type;
@@ -315,7 +317,7 @@ restart:
 		if (inode == NULL)
 			continue;
 		spin_lock(&clp->cl_lock);
-		delegation = nfs_detach_delegation_locked(NFS_I(inode), NULL);
+		delegation = nfs_detach_delegation_locked(NFS_I(inode), NULL, clp);
 		spin_unlock(&clp->cl_lock);
 		rcu_read_unlock();
 		if (delegation != NULL) {
@@ -344,9 +346,9 @@ void nfs_inode_return_delegation_noreclaim(struct inode *inode)
 	struct nfs_inode *nfsi = NFS_I(inode);
 	struct nfs_delegation *delegation;
 
-	if (rcu_dereference(nfsi->delegation) != NULL) {
+	if (rcu_access_pointer(nfsi->delegation) != NULL) {
 		spin_lock(&clp->cl_lock);
-		delegation = nfs_detach_delegation_locked(nfsi, NULL);
+		delegation = nfs_detach_delegation_locked(nfsi, NULL, clp);
 		spin_unlock(&clp->cl_lock);
 		if (delegation != NULL)
 			nfs_do_return_delegation(inode, delegation, 0);
@@ -360,9 +362,9 @@ int nfs_inode_return_delegation(struct inode *inode)
 	struct nfs_delegation *delegation;
 	int err = 0;
 
-	if (rcu_dereference(nfsi->delegation) != NULL) {
+	if (rcu_access_pointer(nfsi->delegation) != NULL) {
 		spin_lock(&clp->cl_lock);
-		delegation = nfs_detach_delegation_locked(nfsi, NULL);
+		delegation = nfs_detach_delegation_locked(nfsi, NULL, clp);
 		spin_unlock(&clp->cl_lock);
 		if (delegation != NULL) {
 			nfs_msync_inode(inode);
@@ -540,7 +542,7 @@ restart:
 		if (inode == NULL)
 			continue;
 		spin_lock(&clp->cl_lock);
-		delegation = nfs_detach_delegation_locked(NFS_I(inode), NULL);
+		delegation = nfs_detach_delegation_locked(NFS_I(inode), NULL, clp);
 		spin_unlock(&clp->cl_lock);
 		rcu_read_unlock();
 		if (delegation != NULL)
-- 
1.7.0
