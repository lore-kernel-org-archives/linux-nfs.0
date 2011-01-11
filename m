Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56201 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932363Ab1AKQVt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Jan 2011 11:21:49 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 12/14] nfsd4: give out delegations more quickly in 4.1 case
Date: Tue, 11 Jan 2011 11:21:32 -0500
Message-Id: <1294762894-21371-13-git-send-email-bfields@redhat.com>
In-Reply-To: <1294762894-21371-1-git-send-email-bfields@redhat.com>
References: <1294762894-21371-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   17 +++++++++++++++--
 1 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 00a50b8..408957c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2627,6 +2627,19 @@ nfs4_set_claim_prev(struct nfsd4_open *open)
 	open->op_stateowner->so_client->cl_firststate = 1;
 }
 
+/* Should we give out recallable state?: */
+static bool nfsd4_cb_channel_good(struct nfs4_client *clp)
+{
+	if (clp->cl_cb_state == NFSD4_CB_UP)
+		return true;
+	/*
+	 * In the sessions case, since we don't have to establish a
+	 * separate connection for callbacks, we assume it's OK
+	 * until we hear otherwise:
+	 */
+	return clp->cl_minorversion && clp->cl_cb_state == NFSD4_CB_UNKNOWN;
+}
+
 /*
  * Attempt to hand out a delegation.
  */
@@ -2635,11 +2648,11 @@ nfs4_open_delegation(struct svc_fh *fh, struct nfsd4_open *open, struct nfs4_sta
 {
 	struct nfs4_delegation *dp;
 	struct nfs4_stateowner *sop = stp->st_stateowner;
-	/* XXX: or unknown and nfsv4.1: */
-	int cb_up = (sop->so_client->cl_cb_state == NFSD4_CB_UP);
+	int cb_up;
 	struct file_lock *fl;
 	int status, flag = 0;
 
+	cb_up = nfsd4_cb_channel_good(sop->so_client);
 	flag = NFS4_OPEN_DELEGATE_NONE;
 	open->op_recall = 0;
 	switch (open->op_claim_type) {
-- 
1.7.1

