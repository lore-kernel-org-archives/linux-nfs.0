Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34729 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932444AbbG1LN2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jul 2015 07:13:28 -0400
Received: by pacan13 with SMTP id an13so69768784pac.1
        for <linux-nfs@vger.kernel.org>; Tue, 28 Jul 2015 04:13:27 -0700 (PDT)
Message-ID: <55B763CE.2040408@gmail.com>
Date: Tue, 28 Jul 2015 19:13:18 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: kinglongmee@gmail.com
Subject: [PATCH 5/5] NFS: Let opened is optional in _nfs4_do_open
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/nfs4file.c | 3 +--
 fs/nfs/nfs4proc.c | 5 ++---
 2 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index dcd39d4..43f1590 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -27,7 +27,6 @@ nfs4_file_open(struct inode *inode, struct file *filp)
 	struct inode *dir;
 	unsigned openflags = filp->f_flags;
 	struct iattr attr;
-	int opened = 0;
 	int err;
 
 	/*
@@ -66,7 +65,7 @@ nfs4_file_open(struct inode *inode, struct file *filp)
 		nfs_sync_inode(inode);
 	}
 
-	inode = NFS_PROTO(dir)->open_context(dir, ctx, openflags, &attr, &opened);
+	inode = NFS_PROTO(dir)->open_context(dir, ctx, openflags, &attr, NULL);
 	if (IS_ERR(inode)) {
 		err = PTR_ERR(inode);
 		switch (err) {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 801f5f4..26fc817 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2426,7 +2426,7 @@ static int _nfs4_do_open(struct inode *dir,
 			nfs_setsecurity(state->inode, opendata->o_res.f_attr, olabel);
 		}
 	}
-	if (opendata->file_created)
+	if (opened && opendata->file_created)
 		*opened |= FILE_CREATED;
 
 	if (pnfs_use_threshold(ctx_th, opendata->f_attr.mdsthreshold, server)) {
@@ -3539,7 +3539,6 @@ nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 	struct nfs4_label l, *ilabel = NULL;
 	struct nfs_open_context *ctx;
 	struct nfs4_state *state;
-	int opened = 0;
 	int status = 0;
 
 	ctx = alloc_nfs_open_context(dentry, FMODE_READ);
@@ -3549,7 +3548,7 @@ nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 	ilabel = nfs4_label_init_security(dir, dentry, sattr, &l);
 
 	sattr->ia_mode &= ~current_umask();
-	state = nfs4_do_open(dir, ctx, flags, sattr, ilabel, &opened);
+	state = nfs4_do_open(dir, ctx, flags, sattr, ilabel, NULL);
 	if (IS_ERR(state)) {
 		status = PTR_ERR(state);
 		goto out;
-- 
2.4.3

