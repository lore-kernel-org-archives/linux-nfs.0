From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 20/69] NFSv4: Callers to nfs4_get_renew_cred() need to hold
 nfs_client->cl_lock
Date: Tue, 23 Dec 2008 18:02:11 -0500
Message-ID: <20081223230211.13743.11816.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:45954 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752348AbYLWXXn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:23:43 -0500
Received: from svlrsexc1-prd.hq.netapp.com ([10.57.115.30])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNNbsW006182
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:23:39 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ditto for nfs4_get_setclientid_cred().

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4_fs.h    |    2 +-
 fs/nfs/nfs4renewd.c |    2 +-
 fs/nfs/nfs4state.c  |   20 +++++++++++++++-----
 3 files changed, 17 insertions(+), 7 deletions(-)


diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index ea79064..0ac6bbb 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -202,7 +202,7 @@ extern void nfs4_kill_renewd(struct nfs_client *);
 extern void nfs4_renew_state(struct work_struct *);
 
 /* nfs4state.c */
-struct rpc_cred *nfs4_get_renew_cred(struct nfs_client *clp);
+struct rpc_cred *nfs4_get_renew_cred_locked(struct nfs_client *clp);
 
 extern struct nfs4_state_owner * nfs4_get_state_owner(struct nfs_server *, struct rpc_cred *);
 extern void nfs4_put_state_owner(struct nfs4_state_owner *);
diff --git a/fs/nfs/nfs4renewd.c b/fs/nfs/nfs4renewd.c
index 3305acb..9fe8640 100644
--- a/fs/nfs/nfs4renewd.c
+++ b/fs/nfs/nfs4renewd.c
@@ -77,7 +77,7 @@ nfs4_renew_state(struct work_struct *work)
 	timeout = (2 * lease) / 3 + (long)last - (long)now;
 	/* Are we close to a lease timeout? */
 	if (time_after(now, last + lease/3)) {
-		cred = nfs4_get_renew_cred(clp);
+		cred = nfs4_get_renew_cred_locked(clp);
 		if (cred == NULL) {
 			set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
 			spin_unlock(&clp->cl_lock);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 99182b3..300faba 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -71,14 +71,12 @@ static int nfs4_init_client(struct nfs_client *clp, struct rpc_cred *cred)
 	return status;
 }
 
-static struct rpc_cred *nfs4_get_machine_cred(struct nfs_client *clp)
+static struct rpc_cred *nfs4_get_machine_cred_locked(struct nfs_client *clp)
 {
 	struct rpc_cred *cred = NULL;
 
-	spin_lock(&clp->cl_lock);
 	if (clp->cl_machine_cred != NULL)
 		cred = get_rpccred(clp->cl_machine_cred);
-	spin_unlock(&clp->cl_lock);
 	return cred;
 }
 
@@ -94,7 +92,7 @@ static void nfs4_clear_machine_cred(struct nfs_client *clp)
 		put_rpccred(cred);
 }
 
-struct rpc_cred *nfs4_get_renew_cred(struct nfs_client *clp)
+struct rpc_cred *nfs4_get_renew_cred_locked(struct nfs_client *clp)
 {
 	struct nfs4_state_owner *sp;
 	struct rb_node *pos;
@@ -110,13 +108,24 @@ struct rpc_cred *nfs4_get_renew_cred(struct nfs_client *clp)
 	return cred;
 }
 
+static struct rpc_cred *nfs4_get_renew_cred(struct nfs_client *clp)
+{
+	struct rpc_cred *cred;
+
+	spin_lock(&clp->cl_lock);
+	cred = nfs4_get_renew_cred_locked(clp);
+	spin_unlock(&clp->cl_lock);
+	return cred;
+}
+
 static struct rpc_cred *nfs4_get_setclientid_cred(struct nfs_client *clp)
 {
 	struct nfs4_state_owner *sp;
 	struct rb_node *pos;
 	struct rpc_cred *cred;
 
-	cred = nfs4_get_machine_cred(clp);
+	spin_lock(&clp->cl_lock);
+	cred = nfs4_get_machine_cred_locked(clp);
 	if (cred != NULL)
 		goto out;
 	pos = rb_first(&clp->cl_state_owners);
@@ -125,6 +134,7 @@ static struct rpc_cred *nfs4_get_setclientid_cred(struct nfs_client *clp)
 		cred = get_rpccred(sp->so_cred);
 	}
 out:
+	spin_unlock(&clp->cl_lock);
 	return cred;
 }
 

