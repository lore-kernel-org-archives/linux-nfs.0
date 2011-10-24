Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:50457 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751189Ab1J0QJr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Oct 2011 12:09:47 -0400
Received: by iaby12 with SMTP id y12so3059012iab.19
        for <linux-nfs@vger.kernel.org>; Thu, 27 Oct 2011 09:09:47 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Trond.Myklebust@netapp.com, bhalevy@tonian.com,
        Peng Tao <peng_tao@emc.com>
Subject: [PATCH-RFC] nfs41: handle BLK_LAYOUT CB_RECALL_ANY
Date: Sun, 23 Oct 2011 20:25:47 -0700
Message-Id: <1319426747-2179-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi, Trond and Benny,

The patch depends on the pnfs private workqueue for now. So I want to consult
you about where to put the work. Is pnfs private workqueue dropped? If yes, where
should I put this kind of work?

Thanks,
Tao

For blocklayout, we want to issue layoutreturn to return layouts when
handling CB_RECALL_ANY.

Signed-off-by: Peng Tao <peng_tao@emc.com>
---
 fs/nfs/callback_proc.c |   55 +++++++++++++++++++++++++++++++++++++++++-------
 include/linux/nfs4.h   |    3 +-
 2 files changed, 49 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 43926ad..6bb005c 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -160,7 +160,8 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 }
 
 static u32 initiate_bulk_draining(struct nfs_client *clp,
-				  struct cb_layoutrecallargs *args)
+				  struct cb_layoutrecallargs *args,
+				  int sendreturn)
 {
 	struct nfs_server *server;
 	struct pnfs_layout_hdr *lo;
@@ -204,12 +205,47 @@ static u32 initiate_bulk_draining(struct nfs_client *clp,
 		list_del_init(&lo->plh_bulk_recall);
 		spin_unlock(&ino->i_lock);
 		pnfs_free_lseg_list(&free_me_list);
+		if (sendreturn && list_empty(&lo->plh_segs))
+			pnfs_return_layout(ino);
 		put_layout_hdr(lo);
 		iput(ino);
 	}
 	return rv;
 }
 
+struct recallany_data {
+	struct nfs_client *clp;
+	struct work_struct ra_work;
+};
+
+static void layout_recallany_draining(struct work_struct *work)
+{
+	struct recallany_data *ra;
+	struct cb_layoutrecallargs args;
+
+	memset(&args, 0, sizeof(args));
+	ra = container_of(work, struct recallany_data, ra_work);
+	/* Ignore draining error. Per RFC, if layoutreturns are not sent, it is up
+	 * to server to handle the situation (e.g., send specific layoutrecalls).
+	 */
+	initiate_bulk_draining(ra->clp, &args, 1);
+	kfree(ra);
+}
+
+static u32 init_recallany_draining(struct nfs_client *clp)
+{
+	struct recallany_data *ra;
+
+	ra = kmalloc(sizeof(*ra), GFP_NOFS);
+	if (ra) {
+		ra->clp = clp;
+		INIT_WORK(&ra->ra_work, layout_recallany_draining);
+		pnfsiod_queue_work(&ra->ra_work);
+		return NFS4_OK;
+	}
+	return NFS4ERR_DELAY;
+}
+
 static u32 do_callback_layoutrecall(struct nfs_client *clp,
 				    struct cb_layoutrecallargs *args)
 {
@@ -220,8 +256,10 @@ static u32 do_callback_layoutrecall(struct nfs_client *clp,
 		goto out;
 	if (args->cbl_recall_type == RETURN_FILE)
 		res = initiate_file_draining(clp, args);
+	if (args->cbl_recall_type == RETURN_ANY)
+		res = init_recallany_draining(clp);
 	else
-		res = initiate_bulk_draining(clp, args);
+		res = initiate_bulk_draining(clp, args, 0);
 	clear_bit(NFS4CLNT_LAYOUTRECALL, &clp->cl_state);
 out:
 	dprintk("%s returning %i\n", __func__, res);
@@ -245,15 +283,13 @@ __be32 nfs4_callback_layoutrecall(struct cb_layoutrecallargs *args,
 	return cpu_to_be32(res);
 }
 
-static void pnfs_recall_all_layouts(struct nfs_client *clp)
+static __be32 pnfs_recall_all_layouts(struct nfs_client *clp, uint32_t type)
 {
 	struct cb_layoutrecallargs args;
 
-	/* Pretend we got a CB_LAYOUTRECALL(ALL) */
 	memset(&args, 0, sizeof(args));
-	args.cbl_recall_type = RETURN_ALL;
-	/* FIXME we ignore errors, what should we do? */
-	do_callback_layoutrecall(clp, &args);
+	args.cbl_recall_type = type;
+	return cpu_to_be32(do_callback_layoutrecall(clp, &args));
 }
 
 __be32 nfs4_callback_devicenotify(struct cb_devicenotifyargs *args,
@@ -533,7 +569,10 @@ __be32 nfs4_callback_recallany(struct cb_recallanyargs *args, void *dummy,
 		flags |= FMODE_WRITE;
 	if (test_bit(RCA4_TYPE_MASK_FILE_LAYOUT, (const unsigned long *)
 		     &args->craa_type_mask))
-		pnfs_recall_all_layouts(cps->clp);
+		pnfs_recall_all_layouts(cps->clp, RETURN_ALL);
+	if (test_bit(RCA4_TYPE_MASK_BLK_LAYOUT, (const unsigned long *)
+		     &args->craa_type_mask))
+		status = pnfs_recall_all_layouts(cps->clp, RETURN_ANY);
 	if (flags)
 		nfs_expire_all_delegation_types(cps->clp, flags);
 out:
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 76f99e8..1f71a9e 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -597,7 +597,8 @@ enum pnfs_layouttype {
 enum pnfs_layoutreturn_type {
 	RETURN_FILE = 1,
 	RETURN_FSID = 2,
-	RETURN_ALL  = 3
+	RETURN_ALL  = 3,
+	RETURN_ANY  = 4
 };
 
 enum pnfs_iomode {
-- 
1.7.1.262.g5ef3d

