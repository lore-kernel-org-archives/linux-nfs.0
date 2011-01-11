Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56204 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932370Ab1AKQVy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Jan 2011 11:21:54 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 13/14] nfsd4: simplify nfsd4_cb_prepare
Date: Tue, 11 Jan 2011 11:21:33 -0500
Message-Id: <1294762894-21371-14-git-send-email-bfields@redhat.com>
In-Reply-To: <1294762894-21371-1-git-send-email-bfields@redhat.com>
References: <1294762894-21371-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Remove handling for a nonexistant case (status && !-EAGAIN).

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4callback.c |   26 ++++----------------------
 1 files changed, 4 insertions(+), 22 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index fff96dc..69955e9 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -613,24 +613,14 @@ void nfsd4_change_callback(struct nfs4_client *clp, struct nfs4_cb_conn *conn)
  * If the slot is available, then mark it busy.  Otherwise, set the
  * thread for sleeping on the callback RPC wait queue.
  */
-static int nfsd41_cb_setup_sequence(struct nfs4_client *clp,
-		struct rpc_task *task)
+static bool nfsd41_cb_get_slot(struct nfs4_client *clp, struct rpc_task *task)
 {
-	u32 *ptr = (u32 *)clp->cl_cb_session->se_sessionid.data;
-	int status = 0;
-
-	dprintk("%s: %u:%u:%u:%u\n", __func__,
-		ptr[0], ptr[1], ptr[2], ptr[3]);
-
 	if (test_and_set_bit(0, &clp->cl_cb_slot_busy) != 0) {
 		rpc_sleep_on(&clp->cl_cb_waitq, task, NULL);
 		dprintk("%s slot is busy\n", __func__);
-		status = -EAGAIN;
-		goto out;
+		return false;
 	}
-out:
-	dprintk("%s status=%d\n", __func__, status);
-	return status;
+	return true;
 }
 
 /*
@@ -643,19 +633,11 @@ static void nfsd4_cb_prepare(struct rpc_task *task, void *calldata)
 	struct nfs4_delegation *dp = container_of(cb, struct nfs4_delegation, dl_recall);
 	struct nfs4_client *clp = dp->dl_client;
 	u32 minorversion = clp->cl_minorversion;
-	int status = 0;
 
 	cb->cb_minorversion = minorversion;
 	if (minorversion) {
-		status = nfsd41_cb_setup_sequence(clp, task);
-		if (status) {
-			if (status != -EAGAIN) {
-				/* terminate rpc task */
-				task->tk_status = status;
-				task->tk_action = NULL;
-			}
+		if (!nfsd41_cb_get_slot(clp, task))
 			return;
-		}
 	}
 	rpc_call_start(task);
 }
-- 
1.7.1

