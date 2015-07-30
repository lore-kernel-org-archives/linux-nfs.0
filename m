Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34820 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751478AbbG3NxE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jul 2015 09:53:04 -0400
Received: by pabkd10 with SMTP id kd10so23970719pab.2
        for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2015 06:53:04 -0700 (PDT)
Message-ID: <55BA2C2C.10507@gmail.com>
Date: Thu, 30 Jul 2015 21:52:44 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: [PATCH 2/5] nfsd: Fix a encode bug of FS_LAYOUT_TYPES and LAYOUT_TYPES
References: <55BA2B46.90204@gmail.com>
In-Reply-To: <55BA2B46.90204@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Each bitmap needs one layout_type information,
if setting both, nfsd only return one right now.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4xdr.c | 45 +++++++++++++++++++++++++++++++--------------
 1 file changed, 31 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index f11003c..76d6653 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2140,6 +2140,27 @@ nfsd4_encode_aclname(struct xdr_stream *xdr, struct svc_rqst *rqstp,
 		return nfsd4_encode_user(xdr, rqstp, ace->who_uid);
 }
 
+static inline __be32
+nfsd4_encode_layout_type(struct xdr_stream *xdr, enum pnfs_layouttype layout_type)
+{
+	__be32 *p;
+
+	if (layout_type) {
+		p = xdr_reserve_space(xdr, 8);
+		if (!p)
+			return nfserr_resource;
+		*p++ = cpu_to_be32(1);
+		*p++ = cpu_to_be32(layout_type);
+	} else {
+		p = xdr_reserve_space(xdr, 4);
+		if (!p)
+			return nfserr_resource;
+		*p++ = cpu_to_be32(0);
+	}
+
+	return 0;
+}
+
 #define WORD0_ABSENT_FS_ATTRS (FATTR4_WORD0_FS_LOCATIONS | FATTR4_WORD0_FSID | \
 			      FATTR4_WORD0_RDATTR_ERROR)
 #define WORD1_ABSENT_FS_ATTRS FATTR4_WORD1_MOUNTED_ON_FILEID
@@ -2694,20 +2715,16 @@ out_acl:
 		p = xdr_encode_hyper(p, ino);
 	}
 #ifdef CONFIG_NFSD_PNFS
-	if ((bmval1 & FATTR4_WORD1_FS_LAYOUT_TYPES) ||
-	    (bmval2 & FATTR4_WORD2_LAYOUT_TYPES)) {
-		if (exp->ex_layout_type) {
-			p = xdr_reserve_space(xdr, 8);
-			if (!p)
-				goto out_resource;
-			*p++ = cpu_to_be32(1);
-			*p++ = cpu_to_be32(exp->ex_layout_type);
-		} else {
-			p = xdr_reserve_space(xdr, 4);
-			if (!p)
-				goto out_resource;
-			*p++ = cpu_to_be32(0);
-		}
+	if (bmval1 & FATTR4_WORD1_FS_LAYOUT_TYPES) {
+		status = nfsd4_encode_layout_type(xdr, exp->ex_layout_type);
+		if (status)
+			goto out;
+	}
+
+	if (bmval2 & FATTR4_WORD2_LAYOUT_TYPES) {
+		status = nfsd4_encode_layout_type(xdr, exp->ex_layout_type);
+		if (status)
+			goto out;
 	}
 
 	if (bmval2 & FATTR4_WORD2_LAYOUT_BLKSIZE) {
-- 
2.4.3

