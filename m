From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 22/69] NFSv4: Remove redundant RENEW calls if we know the
 lease has expired
Date: Tue, 23 Dec 2008 18:02:12 -0500
Message-ID: <20081223230211.13743.71270.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:44861 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752622AbYLWXXt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:23:49 -0500
Received: from sacrsexc2-prd.hq.netapp.com ([10.99.115.28])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNNaFr006177
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:23:43 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4_fs.h   |    1 +
 fs/nfs/nfs4proc.c  |    3 ++-
 fs/nfs/nfs4state.c |   47 +++++++++++++++++++++++++++++------------------
 3 files changed, 32 insertions(+), 19 deletions(-)


diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 1c6fbd1..76eda46 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -39,6 +39,7 @@ struct idmap;
 
 enum nfs4_client_state {
 	NFS4CLNT_STATE_RECOVER  = 0,
+	NFS4CLNT_CHECK_LEASE,
 	NFS4CLNT_LEASE_EXPIRED,
 	NFS4CLNT_RECLAIM_REBOOT,
 	NFS4CLNT_RECLAIM_NOGRACE,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 279ab36..780ba00 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -984,7 +984,8 @@ static int nfs4_recover_expired_lease(struct nfs_server *server)
 		ret = nfs4_wait_clnt_recover(server->client, clp);
 		if (ret != 0)
 			return ret;
-		if (!test_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state))
+		if (!test_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state) &&
+		    !test_bit(NFS4CLNT_CHECK_LEASE,&clp->cl_state))
 			break;
 		nfs4_schedule_state_recovery(clp);
 	}
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index e5cd8ca..3cc88a5 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -817,6 +817,8 @@ void nfs4_schedule_state_recovery(struct nfs_client *clp)
 {
 	if (!clp)
 		return;
+	if (!test_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state))
+		set_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state);
 	if (test_and_set_bit(NFS4CLNT_STATE_RECOVER, &clp->cl_state) == 0)
 		nfs4_recover_state(clp);
 }
@@ -1019,6 +1021,23 @@ static void nfs4_state_end_reclaim_nograce(struct nfs_client *clp)
 	clear_bit(NFS4CLNT_RECLAIM_NOGRACE, &clp->cl_state);
 }
 
+static void nfs4_recovery_handle_error(struct nfs_client *clp, int error)
+{
+	switch (error) {
+		case -NFS4ERR_CB_PATH_DOWN:
+			set_bit(NFS4CLNT_CB_PATH_DOWN, &clp->cl_state);
+			break;
+		case -NFS4ERR_STALE_CLIENTID:
+		case -NFS4ERR_LEASE_MOVED:
+			set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
+			nfs4_state_start_reclaim_reboot(clp);
+			break;
+		case -NFS4ERR_EXPIRED:
+			set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
+			nfs4_state_start_reclaim_nograce(clp);
+	}
+}
+
 static int nfs4_do_reclaim(struct nfs_client *clp, const struct nfs4_state_recovery_ops *ops)
 {
 	struct rb_node *pos;
@@ -1031,6 +1050,7 @@ static int nfs4_do_reclaim(struct nfs_client *clp, const struct nfs4_state_recov
 		if (status < 0)
 			break;
 	}
+	nfs4_recovery_handle_error(clp, status);
 	return status;
 }
 
@@ -1045,19 +1065,7 @@ static int nfs4_check_lease(struct nfs_client *clp)
 		/* Yes there are: try to renew the old lease */
 		status = nfs4_proc_renew(clp, cred);
 		put_rpccred(cred);
-		switch (status) {
-			case -NFS4ERR_CB_PATH_DOWN:
-				set_bit(NFS4CLNT_CB_PATH_DOWN, &clp->cl_state);
-				break;
-			case -NFS4ERR_STALE_CLIENTID:
-			case -NFS4ERR_LEASE_MOVED:
-				set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
-				nfs4_state_start_reclaim_reboot(clp);
-				break;
-			case -NFS4ERR_EXPIRED:
-				set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
-				nfs4_state_start_reclaim_nograce(clp);
-		}
+		nfs4_recovery_handle_error(clp, status);
 		return status;
 	}
 
@@ -1095,8 +1103,6 @@ static int reclaimer(void *ptr)
 	/* Ensure exclusive access to NFSv4 state */
 	down_write(&clp->cl_sem);
 	while (!list_empty(&clp->cl_superblocks)) {
-		status = nfs4_check_lease(clp);
-
 		if (test_and_clear_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state)) {
 			/* We're going to have to re-establish a clientid */
 			status = nfs4_reclaim_lease(clp);
@@ -1106,16 +1112,21 @@ static int reclaimer(void *ptr)
 					continue;
 				goto out_error;
 			}
+			clear_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state);
+		}
+
+		if (test_and_clear_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state)) {
+			status = nfs4_check_lease(clp);
+			if (status != 0)
+				continue;
 		}
 
 		/* First recover reboot state... */
 		if (test_and_clear_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state)) {
 			/* Note: list is protected by exclusive lock on cl->cl_sem */
 			status = nfs4_do_reclaim(clp, &nfs4_reboot_recovery_ops);
-			if (status == -NFS4ERR_STALE_CLIENTID) {
-				set_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state);
+			if (status == -NFS4ERR_STALE_CLIENTID)
 				continue;
-			}
 			nfs4_state_end_reclaim_reboot(clp);
 			continue;
 		}

