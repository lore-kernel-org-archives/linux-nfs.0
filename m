From: Alexandros Batsakis <batsakis@netapp.com>
Subject: [PATCH 8/8] pnfs-submit: support for cb_recall_any (layouts)
Date: Mon, 17 May 2010 10:56:44 -0700
Message-ID: <1274119004-30213-9-git-send-email-batsakis@netapp.com>
References: <1274119004-30213-1-git-send-email-batsakis@netapp.com>
 <1274119004-30213-2-git-send-email-batsakis@netapp.com>
 <1274119004-30213-3-git-send-email-batsakis@netapp.com>
 <1274119004-30213-4-git-send-email-batsakis@netapp.com>
 <1274119004-30213-5-git-send-email-batsakis@netapp.com>
 <1274119004-30213-6-git-send-email-batsakis@netapp.com>
 <1274119004-30213-7-git-send-email-batsakis@netapp.com>
 <1274119004-30213-8-git-send-email-batsakis@netapp.com>
Cc: linux-nfs@vger.kernel.org,
	Alexandros Batsakis <batsakis@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:3595 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755452Ab0EQR4z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 May 2010 13:56:55 -0400
In-Reply-To: <1274119004-30213-8-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

CB_RECALL_ANY serves as a hint to the client to return some server state.
We reply immediately and we clean the layouts asycnhronously.

FIXME: currently we return _all_ layouts
FIXME: eventually we should treat layouts as delegations, marked them expired
and fire the state manager to clean them.

Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
---
 fs/nfs/callback.h      |    7 ++++++
 fs/nfs/callback_proc.c |   52 +++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 58 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index 73f21bc..b39ac86 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -115,6 +115,13 @@ extern int nfs41_validate_delegation_stateid(struct nfs_delegation *delegation,
 
 #define RCA4_TYPE_MASK_RDATA_DLG	0
 #define RCA4_TYPE_MASK_WDATA_DLG	1
+#define RCA4_TYPE_MASK_DIR_DLG         2
+#define RCA4_TYPE_MASK_FILE_LAYOUT     3
+#define RCA4_TYPE_MASK_BLK_LAYOUT      4
+#define RCA4_TYPE_MASK_OBJ_LAYOUT_MIN  8
+#define RCA4_TYPE_MASK_OBJ_LAYOUT_MAX  9
+#define RCA4_TYPE_MASK_OTHER_LAYOUT_MIN 12
+#define RCA4_TYPE_MASK_OTHER_LAYOUT_MAX 15
 
 struct cb_recallanyargs {
 	struct sockaddr	*craa_addr;
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 419fee7..d09fb07 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -337,6 +337,26 @@ out_put_no_client:
 	return status;
 }
 
+static int pnfs_recall_all_layouts(struct nfs_client *clp)
+{
+	struct cb_pnfs_layoutrecallargs rl;
+	struct inode *inode;
+	int status = 0;
+
+	rl.cbl_recall_type = RETURN_ALL;
+	rl.cbl_seg.offset = 0;
+	rl.cbl_seg.length = NFS4_MAX_UINT64;
+	rl.cbl_seg.iomode = IOMODE_ANY;
+	/* we need the inode to get the nfs_server struct */
+	inode = nfs_layoutrecall_find_inode(clp, &rl);
+	if (!inode)
+		return status;
+	status = pnfs_async_return_layout(clp, inode, &rl);
+	iput(inode);
+
+	return status;
+}
+
 __be32 pnfs_cb_layoutrecall(struct cb_pnfs_layoutrecallargs *args,
 			    void *dummy)
 {
@@ -651,6 +671,27 @@ out:
 	return status;
 }
 
+static inline int
+validate_bitmap_values(const unsigned long* mask)
+{
+	int i;
+	if (test_bit(RCA4_TYPE_MASK_RDATA_DLG, mask) ||
+	    test_bit(RCA4_TYPE_MASK_WDATA_DLG, mask) ||
+	    test_bit(RCA4_TYPE_MASK_DIR_DLG, mask) ||
+	    test_bit(RCA4_TYPE_MASK_FILE_LAYOUT, mask) ||
+	    test_bit(RCA4_TYPE_MASK_BLK_LAYOUT, mask))
+		return 1;
+	for (i = RCA4_TYPE_MASK_OBJ_LAYOUT_MIN;
+             i <= RCA4_TYPE_MASK_OBJ_LAYOUT_MAX; i++)
+		if (test_bit(i, mask))
+			return 1;
+	for (i = RCA4_TYPE_MASK_OTHER_LAYOUT_MIN;
+	     i <= RCA4_TYPE_MASK_OTHER_LAYOUT_MAX; i++)
+		if (test_bit(i, mask))
+			return 1;
+	return 0;
+}
+
 __be32 nfs4_callback_recallany(struct cb_recallanyargs *args, void *dummy)
 {
 	struct nfs_client *clp;
@@ -665,16 +706,25 @@ __be32 nfs4_callback_recallany(struct cb_recallanyargs *args, void *dummy)
 	dprintk("NFS: RECALL_ANY callback request from %s\n",
 		rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_ADDR));
 
+	status = htonl(NFS4ERR_INVAL);
+	if (!validate_bitmap_values((const unsigned long *)
+				    &args->craa_type_mask))
+		return status;
+
 	if (test_bit(RCA4_TYPE_MASK_RDATA_DLG, (const unsigned long *)
 		     &args->craa_type_mask))
 		flags = FMODE_READ;
 	if (test_bit(RCA4_TYPE_MASK_WDATA_DLG, (const unsigned long *)
 		     &args->craa_type_mask))
 		flags |= FMODE_WRITE;
+	if (test_bit(RCA4_TYPE_MASK_FILE_LAYOUT, (const unsigned long *)
+		     &args->craa_type_mask))
+		status = pnfs_recall_all_layouts(clp);
 
 	if (flags)
 		nfs_expire_all_delegation_types(clp, flags);
-	status = htonl(NFS4_OK);
+	if (status != htonl(NFS4ERR_DELAY))
+		status = htonl(NFS4_OK);
 out:
 	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
 	return status;
-- 
1.6.2.5

