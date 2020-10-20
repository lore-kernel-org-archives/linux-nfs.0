Return-Path: <SRS0=zkC/=D3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A68C2C388F2
	for <linux-nfs@archiver.kernel.org>; Tue, 20 Oct 2020 18:39:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 44AF522244
	for <linux-nfs@archiver.kernel.org>; Tue, 20 Oct 2020 18:39:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1603219180;
	bh=cgrozDlS18uUWHQbhKg4LtQ89oDU0R79IgAi9RatH3M=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=DaavFQkX5o8gGDsPYEpEJ7XQI/oau5PJ8/svltWtO0O9wFfU+jRpYp/1iRepk+wj3
	 nI8bzeSaM9b/XRe8lN4tV8LGQ4DRtnvZWQoYXLQTVCMy4e1xtIPX5r4rm5s2Yg7xeR
	 NuXxyl/6Uj3kZyQ0++ZowvXuxP9rjBTCgoORVr2s=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2389303AbgJTSjj (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 20 Oct 2020 14:39:39 -0400
Received: from mail.kernel.org ([198.145.29.99]:51830 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2389145AbgJTSjj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Oct 2020 14:39:39 -0400
Received: from localhost.localdomain (c-68-36-133-222.hsd1.mi.comcast.net [68.36.133.222])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 5E8C22222C;
        Tue, 20 Oct 2020 18:39:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1603219178;
        bh=cgrozDlS18uUWHQbhKg4LtQ89oDU0R79IgAi9RatH3M=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=eP902lcRnrLGdj3arWuBuUkCpeZgu13IJ6fMar+tntsMntiJR9HImn+kn/DORqJC6
         Pob/DJELD0NItdZlne3ibOxVYVhxWW2Zq2bfIsDFFG2typ5RkzDtQQouO7cwDLyukw
         6jG7Wd71qKBkx6wWmNWfkkzYCQSQupinm7rbVysg=
From:   trondmy@kernel.org
To:     Daire Byrne <daire@dneg.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 1/3] NFSv3: Refactor nfs3_proc_lookup() to split out the dentry
Date:   Tue, 20 Oct 2020 14:37:16 -0400
Message-Id: <20201020183718.14618-2-trondmy@kernel.org>
X-Mailer: git-send-email 2.26.2
In-Reply-To: <20201020183718.14618-1-trondmy@kernel.org>
References: <279389889.68934777.1603124383614.JavaMail.zimbra@dneg.com>
 <20201020183718.14618-1-trondmy@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

We want to reuse the lookup code in NFSv3 in order to emulate the
NFSv4 lookupp operation.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs3proc.c | 33 ++++++++++++++++++++++-----------
 1 file changed, 22 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 2397ceedba8a..acbdf7496d31 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -154,14 +154,14 @@ nfs3_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 }
 
 static int
-nfs3_proc_lookup(struct inode *dir, struct dentry *dentry,
-		 struct nfs_fh *fhandle, struct nfs_fattr *fattr,
-		 struct nfs4_label *label)
+__nfs3_proc_lookup(struct inode *dir, const char *name, size_t len,
+		   struct nfs_fh *fhandle, struct nfs_fattr *fattr,
+		   unsigned short task_flags)
 {
 	struct nfs3_diropargs	arg = {
 		.fh		= NFS_FH(dir),
-		.name		= dentry->d_name.name,
-		.len		= dentry->d_name.len
+		.name		= name,
+		.len		= len
 	};
 	struct nfs3_diropres	res = {
 		.fh		= fhandle,
@@ -173,17 +173,11 @@ nfs3_proc_lookup(struct inode *dir, struct dentry *dentry,
 		.rpc_resp	= &res,
 	};
 	int			status;
-	unsigned short task_flags = 0;
-
-	/* Is this is an attribute revalidation, subject to softreval? */
-	if (nfs_lookup_is_soft_revalidate(dentry))
-		task_flags |= RPC_TASK_TIMEOUT;
 
 	res.dir_attr = nfs_alloc_fattr();
 	if (res.dir_attr == NULL)
 		return -ENOMEM;
 
-	dprintk("NFS call  lookup %pd2\n", dentry);
 	nfs_fattr_init(fattr);
 	status = rpc_call_sync(NFS_CLIENT(dir), &msg, task_flags);
 	nfs_refresh_inode(dir, res.dir_attr);
@@ -198,6 +192,23 @@ nfs3_proc_lookup(struct inode *dir, struct dentry *dentry,
 	return status;
 }
 
+static int
+nfs3_proc_lookup(struct inode *dir, struct dentry *dentry,
+		 struct nfs_fh *fhandle, struct nfs_fattr *fattr,
+		 struct nfs4_label *label)
+{
+	unsigned short task_flags = 0;
+
+	/* Is this is an attribute revalidation, subject to softreval? */
+	if (nfs_lookup_is_soft_revalidate(dentry))
+		task_flags |= RPC_TASK_TIMEOUT;
+
+	dprintk("NFS call  lookup %pd2\n", dentry);
+	return __nfs3_proc_lookup(dir, dentry->d_name.name,
+				  dentry->d_name.len, fhandle, fattr,
+				  task_flags);
+}
+
 static int nfs3_proc_access(struct inode *inode, struct nfs_access_entry *entry)
 {
 	struct nfs3_accessargs	arg = {
-- 
2.26.2

