Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:52893 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751490AbeFDWbx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jun 2018 18:31:53 -0400
Received: by mail-it0-f68.google.com with SMTP id m194-v6so1012566itg.2
        for <linux-nfs@vger.kernel.org>; Mon, 04 Jun 2018 15:31:53 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-49-162-121.hsd1.mi.comcast.net. [68.49.162.121])
        by smtp.gmail.com with ESMTPSA id s5-v6sm4309480ioj.13.2018.06.04.15.31.50
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 04 Jun 2018 15:31:51 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 01/11] NFSv4: Don't request size+change attribute if they are delegated to us
Date: Mon,  4 Jun 2018 18:31:19 -0400
Message-Id: <20180604223129.121477-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

When we hold a delegation, we should not need to request attributes such
as the file size or the change attribute. For some servers, avoiding
asking for these unneeded attributes can improve the overall system
performance.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4proc.c | 40 +++++++++++++++++++++++++++++++++++-----
 1 file changed, 35 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index bb1141c48281..c44cfa6be8ff 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -71,6 +71,8 @@
 
 #define NFSDBG_FACILITY		NFSDBG_PROC
 
+#define NFS4_BITMASK_SZ		3
+
 #define NFS4_POLL_RETRY_MIN	(HZ/10)
 #define NFS4_POLL_RETRY_MAX	(15*HZ)
 
@@ -274,6 +276,33 @@ const u32 nfs4_fs_locations_bitmap[3] = {
 	| FATTR4_WORD1_MOUNTED_ON_FILEID,
 };
 
+static void nfs4_bitmap_copy_adjust(__u32 *dst, const __u32 *src,
+		struct inode *inode)
+{
+	unsigned long cache_validity;
+
+	memcpy(dst, src, NFS4_BITMASK_SZ*sizeof(*dst));
+	if (!inode || !nfs4_have_delegation(inode, FMODE_READ))
+		return;
+
+	cache_validity = READ_ONCE(NFS_I(inode)->cache_validity);
+	if (!(cache_validity & NFS_INO_REVAL_FORCED))
+		cache_validity &= ~(NFS_INO_INVALID_CHANGE
+				| NFS_INO_INVALID_SIZE);
+
+	if (!(cache_validity & NFS_INO_INVALID_SIZE))
+		dst[0] &= ~FATTR4_WORD0_SIZE;
+
+	if (!(cache_validity & NFS_INO_INVALID_CHANGE))
+		dst[0] &= ~FATTR4_WORD0_CHANGE;
+}
+
+static void nfs4_bitmap_copy_adjust_setattr(__u32 *dst,
+		const __u32 *src, struct inode *inode)
+{
+	nfs4_bitmap_copy_adjust(dst, src, inode);
+}
+
 static void nfs4_setup_readdir(u64 cookie, __be32 *verifier, struct dentry *dentry,
 		struct nfs4_readdir_arg *readdir)
 {
@@ -3074,12 +3103,13 @@ static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 			   struct nfs4_label *olabel)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
+	__u32 bitmask[NFS4_BITMASK_SZ];
 	struct nfs4_state *state = ctx ? ctx->state : NULL;
 	struct nfs_setattrargs	arg = {
 		.fh		= NFS_FH(inode),
 		.iap		= sattr,
 		.server		= server,
-		.bitmask = server->attr_bitmask,
+		.bitmask = bitmask,
 		.label		= ilabel,
 	};
 	struct nfs_setattrres  res = {
@@ -3094,11 +3124,11 @@ static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 	};
 	int err;
 
-	arg.bitmask = nfs4_bitmask(server, ilabel);
-	if (ilabel)
-		arg.bitmask = nfs4_bitmask(server, olabel);
-
 	do {
+		nfs4_bitmap_copy_adjust_setattr(bitmask,
+				nfs4_bitmask(server, olabel),
+				inode);
+
 		err = _nfs4_do_setattr(inode, &arg, &res, cred, ctx);
 		switch (err) {
 		case -NFS4ERR_OPENMODE:
-- 
2.17.1

