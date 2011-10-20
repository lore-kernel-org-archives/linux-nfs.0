Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gy0-f174.google.com ([209.85.160.174]:45069 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754088Ab1JTCNB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Oct 2011 22:13:01 -0400
Received: by mail-gy0-f174.google.com with SMTP id 13so2302451gyb.19
        for <linux-nfs@vger.kernel.org>; Wed, 19 Oct 2011 19:13:01 -0700 (PDT)
From: Benny Halevy <benny@tonian.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 2/7] nfsd41: use SEQ4_STATUS_BACKCHANNEL_FAULT when cb_sequence is invalid
Date: Wed, 19 Oct 2011 19:12:58 -0700
Message-Id: <1319076778-13352-1-git-send-email-benny@tonian.com>
In-Reply-To: <4E9F82FC.2000904@tonian.com>
References: <4E9F82FC.2000904@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@panasas.com>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4callback.c |   10 ++++++++++
 fs/nfsd/nfs4state.c    |    8 +++++++-
 fs/nfsd/state.h        |    1 +
 3 files changed, 18 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index de018ec..7748d6a 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -39,6 +39,8 @@
 
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
 
+static void nfsd4_mark_cb_fault(struct nfs4_client *, int reason);
+
 #define NFSPROC4_CB_NULL 0
 #define NFSPROC4_CB_COMPOUND 1
 
@@ -460,6 +462,8 @@ static int decode_cb_sequence4resok(struct xdr_stream *xdr,
 	 */
 	status = 0;
 out:
+	if (status)
+		nfsd4_mark_cb_fault(cb->cb_clp, status);
 	return status;
 out_overflow:
 	print_overflow_msg(__func__, xdr);
@@ -686,6 +690,12 @@ static void nfsd4_mark_cb_down(struct nfs4_client *clp, int reason)
 	warn_no_callback_path(clp, reason);
 }
 
+static void nfsd4_mark_cb_fault(struct nfs4_client *clp, int reason)
+{
+	clp->cl_cb_state = NFSD4_CB_FAULT;
+	warn_no_callback_path(clp, reason);
+}
+
 static void nfsd4_cb_probe_done(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_client *clp = container_of(calldata, struct nfs4_client, cl_cb_null);
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 7da0748..ccdb9b2 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1929,8 +1929,14 @@ static bool nfsd4_request_too_big(struct svc_rqst *rqstp,
 
 		nfsd4_get_session(cstate->session);
 		atomic_inc(&clp->cl_refcount);
-		if (clp->cl_cb_state == NFSD4_CB_DOWN)
+		switch (clp->cl_cb_state) {
+		case NFSD4_CB_DOWN:
 			seq->status_flags |= SEQ4_STATUS_CB_PATH_DOWN;
+			break;
+		case NFSD4_CB_FAULT:
+			seq->status_flags |= SEQ4_STATUS_BACKCHANNEL_FAULT;
+			break;
+		}
 	}
 	kfree(conn);
 	spin_unlock(&client_lock);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 87eecfd..c5b87a2 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -258,6 +258,7 @@ struct nfs4_client {
 #define NFSD4_CB_UP		0
 #define NFSD4_CB_UNKNOWN	1
 #define NFSD4_CB_DOWN		2
+#define NFSD4_CB_FAULT		3
 	int			cl_cb_state;
 	struct nfsd4_callback	cl_cb_null;
 	struct nfsd4_session	*cl_cb_session;
-- 
1.7.6

