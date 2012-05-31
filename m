Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:65292 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932967Ab2EaTRE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 May 2012 15:17:04 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/1] NFSv4.1 handle OPEN O_CREATE mdsthreshold
Date: Thu, 31 May 2012 15:16:03 -0400
Message-Id: <1338491763-2767-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c |    4 +++-
 fs/nfs/nfs4xdr.c  |    2 ++
 2 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 65e1df8..698abe6 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2802,6 +2802,7 @@ nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 	struct dentry *de = dentry;
 	struct nfs4_state *state;
 	struct rpc_cred *cred = NULL;
+	struct nfs4_threshold **thp = NULL;
 	fmode_t fmode = 0;
 	int status = 0;
 
@@ -2809,9 +2810,10 @@ nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 		cred = ctx->cred;
 		de = ctx->dentry;
 		fmode = ctx->mode;
+		thp = &ctx->mdsthreshold;
 	}
 	sattr->ia_mode &= ~current_umask();
-	state = nfs4_do_open(dir, de, fmode, flags, sattr, cred, NULL);
+	state = nfs4_do_open(dir, de, fmode, flags, sattr, cred, thp);
 	d_drop(dentry);
 	if (IS_ERR(state)) {
 		status = PTR_ERR(state);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index ee4a74d..30fa0a5 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4357,6 +4357,8 @@ static int decode_attr_mdsthreshold(struct xdr_stream *xdr,
 	int status = 0;
 	uint32_t num;
 
+	if (res == NULL)
+		return 0;
 	if (unlikely(bitmap[2] & (FATTR4_WORD2_MDSTHRESHOLD - 1U)))
 		return -EIO;
 	if (likely(bitmap[2] & FATTR4_WORD2_MDSTHRESHOLD)) {
-- 
1.7.6.4

