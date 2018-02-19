Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38485 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751000AbeBSFEF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Feb 2018 00:04:05 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Mon, 19 Feb 2018 16:02:29 +1100
Subject: [PATCH 09/23] NFSv4: add cl_root_cred for use when machine cred is
 not available.
Cc: linux-nfs@vger.kernel.org
Message-ID: <151901654905.17421.13619498648448266985.stgit@noble>
In-Reply-To: <151901634940.17421.7637564368419392071.stgit@noble>
References: <151901634940.17421.7637564368419392071.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFSv4 state management tries a root credential when no machine
credential is available, as can happen with kerberos.
It does this by replacing the cl_machine_cred with a root credential.
This means that any user of the machine credential needs to take
a lock while getting a reference to the machine credential, which is
a little cumbersome.

So introduce an explicit cl_root_cred, and never free either
credential until client shutdown.  This means that no locking
is needed to reference these credentials.  Future patches
will make use of this.

This is only a temporary addition.  both cl_machine_cred and
cl_root_cred will disappear later in the series.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/nfs/client.c           |    2 ++
 fs/nfs/nfs4state.c        |   20 ++++++++++++--------
 include/linux/nfs_fs_sb.h |    1 +
 3 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index b9129e2befea..e101b67ca5ba 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -248,6 +248,8 @@ void nfs_free_client(struct nfs_client *clp)
 
 	if (clp->cl_machine_cred != NULL)
 		put_rpccred(clp->cl_machine_cred);
+	if (clp->cl_root_cred != NULL)
+		put_rpccred(clp->cl_root_cred);
 
 	put_net(clp->cl_net);
 	put_nfs_version(clp->cl_nfs_mod);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 91a4d4eeb235..bfbc9a87d09d 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -158,24 +158,28 @@ int nfs40_discover_server_trunking(struct nfs_client *clp,
 
 struct rpc_cred *nfs4_get_machine_cred_locked(struct nfs_client *clp)
 {
-	struct rpc_cred *cred = NULL;
+	struct rpc_cred *cred = clp->cl_root_cred;
 
-	if (clp->cl_machine_cred != NULL)
-		cred = get_rpccred(clp->cl_machine_cred);
+	if (!cred)
+		cred = clp->cl_machine_cred;
+	if (cred)
+		return get_rpccred(cred);
 	return cred;
 }
 
 static void nfs4_root_machine_cred(struct nfs_client *clp)
 {
-	struct rpc_cred *cred, *new;
+	struct rpc_cred *new;
 
 	new = rpc_lookup_machine_cred(NULL);
 	spin_lock(&clp->cl_lock);
-	cred = clp->cl_machine_cred;
-	clp->cl_machine_cred = new;
+	if (clp->cl_root_cred == NULL) {
+		clp->cl_root_cred = new;
+		new = NULL;
+	}
 	spin_unlock(&clp->cl_lock);
-	if (cred != NULL)
-		put_rpccred(cred);
+	if (new != NULL)
+		put_rpccred(new);
 }
 
 static struct rpc_cred *
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 4e735be53e70..ca3f14b0f738 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -59,6 +59,7 @@ struct nfs_client {
 
 	u32			cl_minorversion;/* NFSv4 minorversion */
 	struct rpc_cred		*cl_machine_cred;
+	struct rpc_cred		*cl_root_cred;	/* Use when machine_cred is ineffective */
 
 #if IS_ENABLED(CONFIG_NFS_V4)
 	struct list_head	cl_ds_clients; /* auth flavor data servers */


