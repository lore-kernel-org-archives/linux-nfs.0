Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:33673 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751871AbbG3Nmr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jul 2015 09:42:47 -0400
Received: by pdbnt7 with SMTP id nt7so24932846pdb.0
        for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2015 06:42:47 -0700 (PDT)
Message-ID: <55BA29C9.1090703@gmail.com>
Date: Thu, 30 Jul 2015 21:42:33 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: [PATCH 4/7 v2] NFS: Make opened as optional argument in _nfs4_do_open
References: <55BA290B.2020704@gmail.com> <55BA2936.4030404@gmail.com>
In-Reply-To: <55BA2936.4030404@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Check opened, only update it when non-NULL.
It's not needs define an unused value for the opened
when calling _nfs4_do_open.

v2, add change-log.

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
index 3acb1eb..1e5a2fb 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2439,7 +2439,7 @@ static int _nfs4_do_open(struct inode *dir,
 			nfs_setsecurity(state->inode, opendata->o_res.f_attr, olabel);
 		}
 	}
-	if (opendata->file_created)
+	if (opened && opendata->file_created)
 		*opened |= FILE_CREATED;
 
 	if (pnfs_use_threshold(ctx_th, opendata->f_attr.mdsthreshold, server)) {
@@ -3552,7 +3552,6 @@ nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 	struct nfs4_label l, *ilabel = NULL;
 	struct nfs_open_context *ctx;
 	struct nfs4_state *state;
-	int opened = 0;
 	int status = 0;
 
 	ctx = alloc_nfs_open_context(dentry, FMODE_READ);
@@ -3562,7 +3561,7 @@ nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 	ilabel = nfs4_label_init_security(dir, dentry, sattr, &l);
 
 	sattr->ia_mode &= ~current_umask();
-	state = nfs4_do_open(dir, ctx, flags, sattr, ilabel, &opened);
+	state = nfs4_do_open(dir, ctx, flags, sattr, ilabel, NULL);
 	if (IS_ERR(state)) {
 		status = PTR_ERR(state);
 		goto out;
-- 
2.4.3

