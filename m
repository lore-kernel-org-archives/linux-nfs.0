Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4145 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752040Ab0LWXyz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Dec 2010 18:54:55 -0500
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 14/15] pnfs: update nfs4_callback_recallany to handle layouts
Date: Thu, 23 Dec 2010 18:54:40 -0500
Message-Id: <1293148481-28420-15-git-send-email-iisaman@netapp.com>
In-Reply-To: <1293148481-28420-1-git-send-email-iisaman@netapp.com>
References: <1293148481-28420-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Alexandros Batsakis <batsakis@netapp.com>

While here, update the code a bit.

Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/callback.h      |    8 ++++++++
 fs/nfs/callback_proc.c |   29 ++++++++++++++++++++++++++---
 2 files changed, 34 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index f6768ac..d3b44f9 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -119,6 +119,14 @@ extern int nfs41_validate_delegation_stateid(struct nfs_delegation *delegation,
 
 #define RCA4_TYPE_MASK_RDATA_DLG	0
 #define RCA4_TYPE_MASK_WDATA_DLG	1
+#define RCA4_TYPE_MASK_DIR_DLG         2
+#define RCA4_TYPE_MASK_FILE_LAYOUT     3
+#define RCA4_TYPE_MASK_BLK_LAYOUT      4
+#define RCA4_TYPE_MASK_OBJ_LAYOUT_MIN  8
+#define RCA4_TYPE_MASK_OBJ_LAYOUT_MAX  9
+#define RCA4_TYPE_MASK_OTHER_LAYOUT_MIN 12
+#define RCA4_TYPE_MASK_OTHER_LAYOUT_MAX 15
+#define RCA4_TYPE_MASK_ALL 0xf31f
 
 struct cb_recallanyargs {
 	struct sockaddr	*craa_addr;
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 6619c05..4bb91cb 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -230,6 +230,17 @@ __be32 nfs4_callback_layoutrecall(struct cb_layoutrecallargs *args,
 	return cpu_to_be32(res);
 }
 
+static void pnfs_recall_all_layouts(struct nfs_client *clp)
+{
+	struct cb_layoutrecallargs args;
+
+	/* Pretend we got a CB_LAYOUTRECALL(ALL) */
+	memset(&args, 0, sizeof(args));
+	args.cbl_recall_type = RETURN_ALL;
+	/* FIXME we ignore errors, what should we do? */
+	do_callback_layoutrecall(clp, &args);
+}
+
 int nfs41_validate_delegation_stateid(struct nfs_delegation *delegation, const nfs4_stateid *stateid)
 {
 	if (delegation == NULL)
@@ -421,29 +432,41 @@ out:
 	return status;
 }
 
+static bool
+validate_bitmap_values(unsigned long mask)
+{
+	return (mask & ~RCA4_TYPE_MASK_ALL) == 0;
+}
+
 __be32 nfs4_callback_recallany(struct cb_recallanyargs *args, void *dummy,
 			       struct cb_process_state *cps)
 {
 	__be32 status;
 	fmode_t flags = 0;
 
-	status = htonl(NFS4ERR_OP_NOT_IN_SESSION);
+	status = cpu_to_be32(NFS4ERR_OP_NOT_IN_SESSION);
 	if (!cps->clp) /* set in cb_sequence */
 		goto out;
 
 	dprintk("NFS: RECALL_ANY callback request from %s\n",
 		rpc_peeraddr2str(cps->clp->cl_rpcclient, RPC_DISPLAY_ADDR));
 
+	status = cpu_to_be32(NFS4ERR_INVAL);
+	if (!validate_bitmap_values(args->craa_type_mask))
+		goto out;
+
+	status = cpu_to_be32(NFS4_OK);
 	if (test_bit(RCA4_TYPE_MASK_RDATA_DLG, (const unsigned long *)
 		     &args->craa_type_mask))
 		flags = FMODE_READ;
 	if (test_bit(RCA4_TYPE_MASK_WDATA_DLG, (const unsigned long *)
 		     &args->craa_type_mask))
 		flags |= FMODE_WRITE;
-
+	if (test_bit(RCA4_TYPE_MASK_FILE_LAYOUT, (const unsigned long *)
+		     &args->craa_type_mask))
+		pnfs_recall_all_layouts(cps->clp);
 	if (flags)
 		nfs_expire_all_delegation_types(cps->clp, flags);
-	status = htonl(NFS4_OK);
 out:
 	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
 	return status;
-- 
1.7.2.1

