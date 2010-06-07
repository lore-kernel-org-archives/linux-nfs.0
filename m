From: Alexandros Batsakis <batsakis@netapp.com>
Subject: [PATCH 8/8] pnfs-submit: support for CB_RECALL_ANY (layouts)
Date: Mon,  7 Jun 2010 14:11:53 -0700
Message-ID: <1275945113-3436-9-git-send-email-batsakis@netapp.com>
References: <1275945113-3436-1-git-send-email-batsakis@netapp.com>
 <1275945113-3436-2-git-send-email-batsakis@netapp.com>
 <1275945113-3436-3-git-send-email-batsakis@netapp.com>
 <1275945113-3436-4-git-send-email-batsakis@netapp.com>
 <1275945113-3436-5-git-send-email-batsakis@netapp.com>
 <1275945113-3436-6-git-send-email-batsakis@netapp.com>
 <1275945113-3436-7-git-send-email-batsakis@netapp.com>
 <1275945113-3436-8-git-send-email-batsakis@netapp.com>
Cc: bhalevy@panasas.com, Alexandros Batsakis <batsakis@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:54324 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753589Ab0FGVL2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Jun 2010 17:11:28 -0400
In-Reply-To: <1275945113-3436-8-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

CB_RECALL_ANY serves as a hint to the client to return some server state.
We reply immediately and we clean the layouts asycnhronously.

FIXME: currently we return _all_ layouts
FIXME: eventually we should treat layouts as delegations, marked them expired
and fire the state manager to clean them.

Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
---
 fs/nfs/callback.h      |    7 +++++
 fs/nfs/callback_proc.c |   58 ++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 63 insertions(+), 2 deletions(-)

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
index af7a01d..4bff9b0 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -339,6 +339,27 @@ out_put_no_client:
 	return status;
 }
 
+static int pnfs_recall_all_layouts(struct nfs_client *clp)
+{
+	struct cb_pnfs_layoutrecallargs rl;
+	struct inode *inode;
+	int status = 0;
+
+	rl.cbl_recall_type = RETURN_ALL;
+	rl.cbl_seg.iomode = IOMODE_ANY;
+	rl.cbl_seg.offset = 0;
+	rl.cbl_seg.length = NFS4_MAX_UINT64;
+
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
@@ -606,13 +627,37 @@ out:
 	return status;
 }
 
+static inline bool
+validate_bitmap_values(const unsigned long *mask)
+{
+	int i;
+
+	if (*mask == 0)
+		return true;
+	if (test_bit(RCA4_TYPE_MASK_RDATA_DLG, mask) ||
+	    test_bit(RCA4_TYPE_MASK_WDATA_DLG, mask) ||
+	    test_bit(RCA4_TYPE_MASK_DIR_DLG, mask) ||
+	    test_bit(RCA4_TYPE_MASK_FILE_LAYOUT, mask) ||
+	    test_bit(RCA4_TYPE_MASK_BLK_LAYOUT, mask))
+		return true;
+	for (i = RCA4_TYPE_MASK_OBJ_LAYOUT_MIN;
+	     i <= RCA4_TYPE_MASK_OBJ_LAYOUT_MAX; i++)
+		if (test_bit(i, mask))
+			return true;
+	for (i = RCA4_TYPE_MASK_OTHER_LAYOUT_MIN;
+	     i <= RCA4_TYPE_MASK_OTHER_LAYOUT_MAX; i++)
+		if (test_bit(i, mask))
+			return true;
+	return false;
+}
+
 __be32 nfs4_callback_recallany(struct cb_recallanyargs *args, void *dummy)
 {
 	struct nfs_client *clp;
 	__be32 status;
 	fmode_t flags = 0;
 
-	status = htonl(NFS4ERR_OP_NOT_IN_SESSION);
+	status = cpu_to_be32(NFS4ERR_OP_NOT_IN_SESSION);
 	clp = nfs_find_client(args->craa_addr, 4);
 	if (clp == NULL)
 		goto out;
@@ -620,16 +665,25 @@ __be32 nfs4_callback_recallany(struct cb_recallanyargs *args, void *dummy)
 	dprintk("NFS: RECALL_ANY callback request from %s\n",
 		rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_ADDR));
 
+	status = cpu_to_be32(NFS4ERR_INVAL);
+	if (!validate_bitmap_values((const unsigned long *)
+				    &args->craa_type_mask))
+		return status;
+
+	status = cpu_to_be32(NFS4_OK);
 	if (test_bit(RCA4_TYPE_MASK_RDATA_DLG, (const unsigned long *)
 		     &args->craa_type_mask))
 		flags = FMODE_READ;
 	if (test_bit(RCA4_TYPE_MASK_WDATA_DLG, (const unsigned long *)
 		     &args->craa_type_mask))
 		flags |= FMODE_WRITE;
+	if (test_bit(RCA4_TYPE_MASK_FILE_LAYOUT, (const unsigned long *)
+		     &args->craa_type_mask))
+		if (pnfs_recall_all_layouts(clp) == -EAGAIN)
+			status = cpu_to_be32(NFS4ERR_DELAY);
 
 	if (flags)
 		nfs_expire_all_delegation_types(clp, flags);
-	status = htonl(NFS4_OK);
 out:
 	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
 	return status;
-- 
1.6.2.5

