Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56191 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756186Ab1AKQVp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Jan 2011 11:21:45 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 08/14] nfsd4: set sequence flag when backchannel is down
Date: Tue, 11 Jan 2011 11:21:28 -0500
Message-Id: <1294762894-21371-9-git-send-email-bfields@redhat.com>
In-Reply-To: <1294762894-21371-1-git-send-email-bfields@redhat.com>
References: <1294762894-21371-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Implement the SEQ4_STATUS_CB_PATH_DOWN flag.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |    6 +++++-
 fs/nfsd/nfs4xdr.c   |    8 ++------
 fs/nfsd/xdr4.h      |    2 +-
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 919ad25..15bd1cc 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1800,8 +1800,12 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 out:
 	/* Hold a session reference until done processing the compound. */
 	if (cstate->session) {
+		struct nfs4_client *clp = session->se_client;
+
 		nfsd4_get_session(cstate->session);
-		atomic_inc(&session->se_client->cl_refcount);
+		atomic_inc(&clp->cl_refcount);
+		if (clp->cl_cb_state == NFSD4_CB_DOWN)
+			seq->status_flags |= SEQ4_STATUS_CB_PATH_DOWN;
 	}
 	kfree(conn);
 	spin_unlock(&client_lock);
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 4ff2c9e..956629b 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3137,13 +3137,9 @@ nfsd4_encode_sequence(struct nfsd4_compoundres *resp, int nfserr,
 	WRITE32(seq->seqid);
 	WRITE32(seq->slotid);
 	WRITE32(seq->maxslots);
-	/*
-	 * FIXME: for now:
-	 *   target_maxslots = maxslots
-	 *   status_flags = 0
-	 */
+	/* For now: target_maxslots = maxslots */
 	WRITE32(seq->maxslots);
-	WRITE32(0);
+	WRITE32(seq->status_flags);
 
 	ADJUST_ARGS();
 	resp->cstate.datap = p; /* DRC cache data pointer */
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 3a7aa4d..366401e 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -378,8 +378,8 @@ struct nfsd4_sequence {
 	u32			cachethis;		/* request */
 #if 0
 	u32			target_maxslots;	/* response */
-	u32			status_flags;		/* response */
 #endif /* not yet */
+	u32			status_flags;		/* response */
 };
 
 struct nfsd4_destroy_session {
-- 
1.7.1

