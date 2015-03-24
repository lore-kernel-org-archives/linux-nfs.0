Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.gtisc.gatech.edu ([143.215.130.81]:34387 "EHLO
	mx1.gtisc.gatech.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752205AbbCXDGl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Mar 2015 23:06:41 -0400
From: Chengyu Song <csong84@gatech.edu>
To: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Cc: taesoo@gatech.edu, changwoo@gatech.edu, sanidhya@gatech.edu,
        blee@gatech.edu, csong84@gatech.edu
Subject: [PATCH 1/1] nfsd: incorrect check for debugfs returns
Date: Mon, 23 Mar 2015 22:58:05 -0400
Message-Id: <1427165885-20823-1-git-send-email-csong84@gatech.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

debugfs_create_dir and debugfs_create_file may return -ENODEV when debugfs
is not configured, so the return value should be checked against ERROR_VALUE
as well, otherwise the later dereference of the dentry pointer would crash
the kernel.

Signed-off-by: Chengyu Song <csong84@gatech.edu>
---
 fs/nfsd/fault_inject.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
index c16bf5a..621d065 100644
--- a/fs/nfsd/fault_inject.c
+++ b/fs/nfsd/fault_inject.c
@@ -132,19 +132,23 @@ int nfsd_fault_inject_init(void)
 	unsigned int i;
 	struct nfsd_fault_inject_op *op;
 	umode_t mode = S_IFREG | S_IRUSR | S_IWUSR;
+	struct dentry *dent;
 
-	debug_dir = debugfs_create_dir("nfsd", NULL);
-	if (!debug_dir)
+	dent = debugfs_create_dir("nfsd", NULL);
+	if (IS_ERR_OR_NULL(dent))
 		goto fail;
+	debug_dir = dent;
 
 	for (i = 0; i < NUM_INJECT_OPS; i++) {
 		op = &inject_ops[i];
-		if (!debugfs_create_file(op->file, mode, debug_dir, op, &fops_nfsd))
+		dent = debugfs_create_file(op->file, mode, debug_dir, op, &fops_nfsd);
+		if (IS_ERR_OR_NULL(dent))
 			goto fail;
+
 	}
 	return 0;
 
 fail:
 	nfsd_fault_inject_cleanup();
-	return -ENOMEM;
+	return dent ? PTR_ERR(dent) : -ENOMEM;
 }
-- 
2.1.0

