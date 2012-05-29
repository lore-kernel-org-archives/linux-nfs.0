Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:53308 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751996Ab2E2T6Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 May 2012 15:58:16 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH] NFS: add more context to state manager error mesgs
Date: Tue, 29 May 2012 15:57:59 -0400
Message-Id: <1338321479-3830-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
This has been useful for me in the past - time to share it!

Very simple, but should help narrow down the scope problems in the state manager
thread on systems without rpcdebug enabled.

 fs/nfs/nfs4state.c |   16 ++++++++++++++--
 1 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index c679b9e..b9963d8 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1855,10 +1855,12 @@ static int nfs4_bind_conn_to_session(struct nfs_client *clp)
 static void nfs4_state_manager(struct nfs_client *clp)
 {
 	int status = 0;
+	const char *section = "", *section_sep = "";
 
 	/* Ensure exclusive access to NFSv4 state */
 	do {
 		if (test_bit(NFS4CLNT_PURGE_STATE, &clp->cl_state)) {
+			section = "purge state";
 			status = nfs4_reclaim_lease(clp);
 			if (status < 0)
 				goto out_error;
@@ -1867,6 +1869,7 @@ static void nfs4_state_manager(struct nfs_client *clp)
 		}
 
 		if (test_and_clear_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state)) {
+			section = "lease expired";
 			/* We're going to have to re-establish a clientid */
 			status = nfs4_reclaim_lease(clp);
 			if (status < 0)
@@ -1886,6 +1889,7 @@ static void nfs4_state_manager(struct nfs_client *clp)
 		}
 
 		if (test_and_clear_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state)) {
+			section = "check lease";
 			status = nfs4_check_lease(clp);
 			if (status < 0)
 				goto out_error;
@@ -1896,6 +1900,7 @@ static void nfs4_state_manager(struct nfs_client *clp)
 		/* Initialize or reset the session */
 		if (test_and_clear_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state)
 		   && nfs4_has_session(clp)) {
+			section = "reset session";
 			status = nfs4_reset_session(clp);
 			if (test_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state))
 				continue;
@@ -1906,6 +1911,7 @@ static void nfs4_state_manager(struct nfs_client *clp)
 		/* Send BIND_CONN_TO_SESSION */
 		if (test_and_clear_bit(NFS4CLNT_BIND_CONN_TO_SESSION,
 				&clp->cl_state) && nfs4_has_session(clp)) {
+			section = "bind conn to session";
 			status = nfs4_bind_conn_to_session(clp);
 			if (status < 0)
 				goto out_error;
@@ -1914,6 +1920,7 @@ static void nfs4_state_manager(struct nfs_client *clp)
 
 		/* First recover reboot state... */
 		if (test_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state)) {
+			section = "reclaim reboot";
 			status = nfs4_do_reclaim(clp,
 				clp->cl_mvops->reboot_recovery_ops);
 			if (test_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state) ||
@@ -1928,6 +1935,7 @@ static void nfs4_state_manager(struct nfs_client *clp)
 
 		/* Now recover expired state... */
 		if (test_and_clear_bit(NFS4CLNT_RECLAIM_NOGRACE, &clp->cl_state)) {
+			section = "reclaim nograce";
 			status = nfs4_do_reclaim(clp,
 				clp->cl_mvops->nograce_recovery_ops);
 			if (test_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state) ||
@@ -1946,6 +1954,7 @@ static void nfs4_state_manager(struct nfs_client *clp)
 		/* Recall session slots */
 		if (test_and_clear_bit(NFS4CLNT_RECALL_SLOT, &clp->cl_state)
 		   && nfs4_has_session(clp)) {
+			section = "recall slot";
 			status = nfs4_recall_slot(clp);
 			if (status < 0)
 				goto out_error;
@@ -1962,8 +1971,11 @@ static void nfs4_state_manager(struct nfs_client *clp)
 	} while (atomic_read(&clp->cl_count) > 1);
 	return;
 out_error:
-	pr_warn_ratelimited("NFS: state manager failed on NFSv4 server %s"
-			" with error %d\n", clp->cl_hostname, -status);
+	if (strlen(section))
+		section_sep = ": ";
+	pr_warn_ratelimited("NFS: state manager%s%s failed on NFSv4 server %s"
+			" with error %d\n", section_sep, section,
+			clp->cl_hostname, -status);
 	nfs4_end_drain_session(clp);
 	nfs4_clear_state_manager_bit(clp);
 }
-- 
1.7.4.4

