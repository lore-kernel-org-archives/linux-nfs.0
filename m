Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:60167 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760537Ab0JGNLA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Oct 2010 09:11:00 -0400
Received: from localhost.localdomain (laino1-lxp.hq.netapp.com [10.58.48.170])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o97DAgWC017616
	for <linux-nfs@vger.kernel.org>; Thu, 7 Oct 2010 06:10:46 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/4] pnfs_submit: Fix clp refcounting in layout recalls
Date: Wed,  6 Oct 2010 16:35:17 -0400
Message-Id: <1286397317-17881-5-git-send-email-iisaman@netapp.com>
In-Reply-To: <1286397317-17881-1-git-send-email-iisaman@netapp.com>
References: <1286397317-17881-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

We were issing a put, and doing pointless zero checking on clp for
which we hold a reference.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/callback_proc.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 5a996b5..6b560ce 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -304,8 +304,7 @@ static int pnfs_async_return_layout(struct nfs_client *clp, struct inode *inode,
 
 	init_completion(&data.started);
 	__module_get(THIS_MODULE);
-	if (!atomic_inc_not_zero(&clp->cl_count))
-		goto out_put_no_client;
+	atomic_inc(&clp->cl_count);
 
 	t = kthread_run(pnfs_recall_layout, &data, "%s", "pnfs_recall_layout");
 	if (IS_ERR(t)) {
@@ -320,7 +319,6 @@ static int pnfs_async_return_layout(struct nfs_client *clp, struct inode *inode,
 	return data.result;
 out_module_put:
 	nfs_put_client(clp);
-out_put_no_client:
 	clear_bit(NFS4CLNT_LAYOUT_RECALL, &clp->cl_state);
 	module_put(THIS_MODULE);
 	return status;
@@ -643,7 +641,7 @@ __be32 nfs4_callback_recallany(struct cb_recallanyargs *args, void *dummy)
 	status = cpu_to_be32(NFS4ERR_INVAL);
 	if (!validate_bitmap_values((const unsigned long *)
 				    &args->craa_type_mask))
-		return status;
+		goto out_put;
 
 	status = cpu_to_be32(NFS4_OK);
 	if (test_bit(RCA4_TYPE_MASK_RDATA_DLG, (const unsigned long *)
@@ -659,6 +657,8 @@ __be32 nfs4_callback_recallany(struct cb_recallanyargs *args, void *dummy)
 
 	if (flags)
 		nfs_expire_all_delegation_types(clp, flags);
+out_put:
+	nfs_put_client(clp);
 out:
 	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
 	return status;
-- 
1.7.2.1

