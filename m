From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 24/33] NFSv4: Attempt to use machine credentials in
	SETCLIENTID calls
Date: Sat, 19 Apr 2008 16:40:53 -0400
Message-ID: <20080419204053.14124.3478.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080419204047.14124.49490.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:18330 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756398AbYDSUu2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 19 Apr 2008 16:50:28 -0400
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m3JKoRnt002626
	for <linux-nfs@vger.kernel.org>; Sat, 19 Apr 2008 13:50:27 -0700 (PDT)
In-Reply-To: <20080419204047.14124.49490.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4state.c |   41 +++++++++++++++++++++++++++++++++++++----
 1 files changed, 37 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 7775435..46eb624 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -71,6 +71,29 @@ static int nfs4_init_client(struct nfs_client *clp, struct rpc_cred *cred)
 	return status;
 }
 
+static struct rpc_cred *nfs4_get_machine_cred(struct nfs_client *clp)
+{
+	struct rpc_cred *cred = NULL;
+
+	spin_lock(&clp->cl_lock);
+	if (clp->cl_machine_cred != NULL)
+		cred = get_rpccred(clp->cl_machine_cred);
+	spin_unlock(&clp->cl_lock);
+	return cred;
+}
+
+static void nfs4_clear_machine_cred(struct nfs_client *clp)
+{
+	struct rpc_cred *cred;
+
+	spin_lock(&clp->cl_lock);
+	cred = clp->cl_machine_cred;
+	clp->cl_machine_cred = NULL;
+	spin_unlock(&clp->cl_lock);
+	if (cred != NULL)
+		put_rpccred(cred);
+}
+
 struct rpc_cred *nfs4_get_renew_cred(struct nfs_client *clp)
 {
 	struct nfs4_state_owner *sp;
@@ -91,13 +114,18 @@ static struct rpc_cred *nfs4_get_setclientid_cred(struct nfs_client *clp)
 {
 	struct nfs4_state_owner *sp;
 	struct rb_node *pos;
+	struct rpc_cred *cred;
 
+	cred = nfs4_get_machine_cred(clp);
+	if (cred != NULL)
+		goto out;
 	pos = rb_first(&clp->cl_state_owners);
 	if (pos != NULL) {
 		sp = rb_entry(pos, struct nfs4_state_owner, so_client_node);
-		return get_rpccred(sp->so_cred);
+		cred = get_rpccred(sp->so_cred);
 	}
-	return NULL;
+out:
+	return cred;
 }
 
 static void nfs_alloc_unique_id(struct rb_root *root, struct nfs_unique_id *new,
@@ -924,10 +952,10 @@ restart_loop:
 	if (cred != NULL) {
 		/* Yes there are: try to renew the old lease */
 		status = nfs4_proc_renew(clp, cred);
+		put_rpccred(cred);
 		switch (status) {
 			case 0:
 			case -NFS4ERR_CB_PATH_DOWN:
-				put_rpccred(cred);
 				goto out;
 			case -NFS4ERR_STALE_CLIENTID:
 			case -NFS4ERR_LEASE_MOVED:
@@ -936,14 +964,19 @@ restart_loop:
 	} else {
 		/* "reboot" to ensure we clear all state on the server */
 		clp->cl_boot_time = CURRENT_TIME;
-		cred = nfs4_get_setclientid_cred(clp);
 	}
 	/* We're going to have to re-establish a clientid */
 	nfs4_state_mark_reclaim(clp);
 	status = -ENOENT;
+	cred = nfs4_get_setclientid_cred(clp);
 	if (cred != NULL) {
 		status = nfs4_init_client(clp, cred);
 		put_rpccred(cred);
+		/* Handle case where the user hasn't set up machine creds */
+		if (status == -EACCES && cred == clp->cl_machine_cred) {
+			nfs4_clear_machine_cred(clp);
+			goto restart_loop;
+		}
 	}
 	if (status)
 		goto out_error;

