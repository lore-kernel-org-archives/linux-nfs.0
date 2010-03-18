Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5526 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753423Ab0CRNdI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Mar 2010 09:33:08 -0400
From: David Howells <dhowells@redhat.com>
Subject: [PATCH] NFS: Fix RCU warnings in
	nfs_inode_return_delegation_noreclaim() [ver #2]
To: Trond.Myklebust@netapp.com, paulmck@linux.vnet.ibm.com
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        David Howells <dhowells@redhat.com>
Date: Thu, 18 Mar 2010 13:33:02 +0000
Message-ID: <20100318133302.29754.1584.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Fix a number of RCU warnings in nfs_inode_return_delegation_noreclaim().
nfs_inode_return_delegation_noreclaim() and nfs_inode_return_delegation() don't
need to use rcu_dereference() outside the spinlocked region as they merely
examin the pointer and don't follow it, thus rendering unnecessary the need to
impose a partial ordering over the one item of interest.

nfs_detach_delegation_locked() doesn't need rcu_derefence() because it can only
be called if nfs_client::cl_lock is held, and that guards against anyone
changing nfsi->delegation under it.  Furthermore, the barrier in
rcu_derefence() is superfluous, given that the spin_lock() is also a barrier.

nfs_free_delegation() should be using rcu_dereference_check() to validate the
state that the data is in (the delegation inode must have been cleared).  By
this point, the delegation is being released, so no one else should be
attempting to use the saved credentials, and they can be cleared.  However,
rcu_assign_pointer() should be used to clear them, and the delegation itself
must still use call_rcu() as the list of delegations could be being traversed.


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

 fs/nfs/delegation.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 2563beb..fa9b7c5 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -37,7 +37,8 @@ static void nfs_free_delegation(struct nfs_delegation *delegation)
 {
 	struct rpc_cred *cred;
 
-	cred = rcu_dereference(delegation->cred);
+	cred = rcu_dereference_check(delegation->cred,
+				     delegation->inode == NULL);
 	rcu_assign_pointer(delegation->cred, NULL);
 	call_rcu(&delegation->rcu, nfs_free_delegation_callback);
 	if (cred)
@@ -167,7 +168,7 @@ static struct inode *nfs_delegation_grab_inode(struct nfs_delegation *delegation
 
 static struct nfs_delegation *nfs_detach_delegation_locked(struct nfs_inode *nfsi, const nfs4_stateid *stateid)
 {
-	struct nfs_delegation *delegation = rcu_dereference(nfsi->delegation);
+	struct nfs_delegation *delegation = nfsi->delegation;
 
 	if (delegation == NULL)
 		goto nomatch;
@@ -212,7 +213,7 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
 	spin_lock_init(&delegation->lock);
 
 	spin_lock(&clp->cl_lock);
-	if (rcu_dereference(nfsi->delegation) != NULL) {
+	if (nfsi->delegation != NULL) {
 		if (memcmp(&delegation->stateid, &nfsi->delegation->stateid,
 					sizeof(delegation->stateid)) == 0 &&
 				delegation->type == nfsi->delegation->type) {
@@ -329,7 +330,7 @@ void nfs_inode_return_delegation_noreclaim(struct inode *inode)
 	struct nfs_inode *nfsi = NFS_I(inode);
 	struct nfs_delegation *delegation;
 
-	if (rcu_dereference(nfsi->delegation) != NULL) {
+	if (nfsi->delegation != NULL) {
 		spin_lock(&clp->cl_lock);
 		delegation = nfs_detach_delegation_locked(nfsi, NULL);
 		spin_unlock(&clp->cl_lock);
@@ -345,7 +346,7 @@ int nfs_inode_return_delegation(struct inode *inode)
 	struct nfs_delegation *delegation;
 	int err = 0;
 
-	if (rcu_dereference(nfsi->delegation) != NULL) {
+	if (nfsi->delegation != NULL) {
 		spin_lock(&clp->cl_lock);
 		delegation = nfs_detach_delegation_locked(nfsi, NULL);
 		spin_unlock(&clp->cl_lock);

