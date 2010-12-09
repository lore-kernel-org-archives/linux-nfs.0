Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp07.in.ibm.com ([122.248.162.7]:35164 "EHLO
	e28smtp07.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753870Ab0LILfV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Dec 2010 06:35:21 -0500
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp07.in.ibm.com (8.14.4/8.13.1) with ESMTP id oB9BZGdx010907
	for <linux-nfs@vger.kernel.org>; Thu, 9 Dec 2010 17:05:16 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oB9BZGVf3743924
	for <linux-nfs@vger.kernel.org>; Thu, 9 Dec 2010 17:05:16 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oB9BZFJV021419
	for <linux-nfs@vger.kernel.org>; Thu, 9 Dec 2010 17:05:16 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: trond.myklebust@netapp.com, bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH] nfs: Set MS_POSIXACL always
Date: Thu,  9 Dec 2010 17:05:14 +0530
Message-Id: <1291894514-6524-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

We want to skip VFS applying mode for NFS. So set MS_POSIXACL always
and selectively use umask. Ideally we would want to use umask only
when we don't have inheritable ACEs set. But NFS currently don't
allow to send umask to the server. So this is best what we can do
and this is consistent with NFSv3

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/nfs/dir.c      |    3 +--
 fs/nfs/nfs4proc.c |    5 +++++
 fs/nfs/super.c    |   10 ++++++++++
 3 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 8ea4a41..070f368 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1361,8 +1361,7 @@ static struct dentry *nfs_atomic_lookup(struct inode *dir, struct dentry *dentry
 	if (nd->flags & LOOKUP_CREATE) {
 		attr.ia_mode = nd->intent.open.create_mode;
 		attr.ia_valid = ATTR_MODE;
-		if (!IS_POSIXACL(dir))
-			attr.ia_mode &= ~current_umask();
+		attr.ia_mode &= ~current_umask();
 	} else {
 		open_flags &= ~(O_EXCL | O_CREAT);
 		attr.ia_valid = 0;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6a653ff..c57b4e0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2486,6 +2486,7 @@ nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 		path = &ctx->path;
 		fmode = ctx->mode;
 	}
+	sattr->ia_mode &= ~current_umask();
 	state = nfs4_do_open(dir, path, fmode, flags, sattr, cred);
 	d_drop(dentry);
 	if (IS_ERR(state)) {
@@ -2816,6 +2817,8 @@ static int nfs4_proc_mkdir(struct inode *dir, struct dentry *dentry,
 {
 	struct nfs4_exception exception = { };
 	int err;
+
+	sattr->ia_mode &= ~current_umask();
 	do {
 		err = nfs4_handle_exception(NFS_SERVER(dir),
 				_nfs4_proc_mkdir(dir, dentry, sattr),
@@ -2916,6 +2919,8 @@ static int nfs4_proc_mknod(struct inode *dir, struct dentry *dentry,
 {
 	struct nfs4_exception exception = { };
 	int err;
+
+	sattr->ia_mode &= ~current_umask();
 	do {
 		err = nfs4_handle_exception(NFS_SERVER(dir),
 				_nfs4_proc_mknod(dir, dentry, sattr, rdev),
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 3c04504..e57e670 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2498,6 +2498,11 @@ static void nfs4_clone_super(struct super_block *sb,
 	sb->s_maxbytes = old_sb->s_maxbytes;
 	sb->s_time_gran = 1;
 	sb->s_op = old_sb->s_op;
+	/*
+	 * The VFS shouldn't apply the umask to mode bits. We will do
+	 * so ourselves when necessary.
+	 */
+	sb->s_flags  |= MS_POSIXACL;
  	nfs_initialise_sb(sb);
 }
 
@@ -2508,6 +2513,11 @@ static void nfs4_fill_super(struct super_block *sb)
 {
 	sb->s_time_gran = 1;
 	sb->s_op = &nfs4_sops;
+	/*
+	 * The VFS shouldn't apply the umask to mode bits. We will do
+	 * so ourselves when necessary.
+	 */
+	sb->s_flags  |= MS_POSIXACL;
 	nfs_initialise_sb(sb);
 }
 
-- 
1.7.1

