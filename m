From: Alexandros Batsakis <batsakis@netapp.com>
Subject: [PATCH 1/1] nfs41: ensure negotiated session values are reasonable
Date: Tue,  5 Jan 2010 04:46:45 -0800
Message-ID: <1262695605-2335-1-git-send-email-batsakis@netapp.com>
Cc: Alexandros Batsakis <batsakis@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:27495 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754570Ab0AEQnT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Jan 2010 11:43:19 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
---
 fs/nfs/nfs4proc.c |   19 +++++++++++++++++--
 1 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 198d51d..a4b7d69 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4832,6 +4832,21 @@ static int nfs4_verify_channel_attrs(struct nfs41_create_session_args *args,
 	return ret;
 }
 
+static int nfs4_check_sane_channel_attrs(struct nfs4_session *session)
+{
+	int ret = 0;
+
+        ret |= session->fc_attrs.max_rqst_sz < NFS_MIN_FILE_IO_SIZE + nfs41_maxwrite_overhead;
+	ret |= session->fc_attrs.max_resp_sz < NFS_MIN_FILE_IO_SIZE + nfs41_maxread_overhead;
+	ret |= session->fc_attrs.max_ops < NFS4_MAX_OPS;
+
+	if (ret) {
+		printk(KERN_WARNING "Session INVALID: negotiated channel values too small");
+		ret = -EINVAL;
+	}
+	return ret;
+}
+
 static int _nfs4_proc_create_session(struct nfs_client *clp)
 {
 	struct nfs4_session *session = clp->cl_session;
@@ -4855,8 +4870,8 @@ static int _nfs4_proc_create_session(struct nfs_client *clp)
 	status = rpc_call_sync(session->clp->cl_rpcclient, &msg, 0);
 
 	if (!status)
-		/* Verify the session's negotiated channel_attrs values */
-		status = nfs4_verify_channel_attrs(&args, session);
+		status = nfs4_verify_channel_attrs(&args, session) |
+			nfs4_check_sane_channel_attrs(session);
 	if (!status) {
 		/* Increment the clientid slot sequence id */
 		clp->cl_seqid++;
-- 
1.6.2.5

