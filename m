Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:33157 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751287AbbG3NzS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jul 2015 09:55:18 -0400
Received: by pdbnt7 with SMTP id nt7so25091754pdb.0
        for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2015 06:55:17 -0700 (PDT)
Message-ID: <55BA2CB6.8040806@gmail.com>
Date: Thu, 30 Jul 2015 21:55:02 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: [PATCH 4/5] NFSD: Set the attributes used to store the verifier for
 EXCLUSIVE4_1
References: <55BA2B46.90204@gmail.com>
In-Reply-To: <55BA2B46.90204@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

According to rfc5661 18.16.4,
"If EXCLUSIVE4_1 was used, the client determines the attributes
 used for the verifier by comparing attrset with cva_attrs.attrmask;"

So, EXCLUSIVE4_1 also needs those bitmask used to store the verifier.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4proc.c | 12 ++++++------
 fs/nfsd/vfs.c      |  6 ------
 fs/nfsd/vfs.h      |  6 ++++++
 3 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 90cfda7..91f05e8 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -276,13 +276,13 @@ do_open_lookup(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate, stru
 			nfsd4_security_inode_setsecctx(*resfh, &open->op_label, open->op_bmval);
 
 		/*
-		 * Following rfc 3530 14.2.16, use the returned bitmask
-		 * to indicate which attributes we used to store the
-		 * verifier:
+		 * Following rfc 3530 14.2.16, and rfc 5661 18.16.4
+		 * use the returned bitmask to indicate which attributes
+		 * we used to store the verifier:
 		 */
-		if (open->op_createmode == NFS4_CREATE_EXCLUSIVE && status == 0)
-			open->op_bmval[1] = (FATTR4_WORD1_TIME_ACCESS |
-							FATTR4_WORD1_TIME_MODIFY);
+		if (nfsd_create_is_exclusive(open->op_createmode) && status == 0)
+			open->op_bmval[1] |= (FATTR4_WORD1_TIME_ACCESS |
+						FATTR4_WORD1_TIME_MODIFY);
 	} else
 		/*
 		 * Note this may exit with the parent still locked.
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index b5e077a..45c0497 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1249,12 +1249,6 @@ out_nfserr:
 
 #ifdef CONFIG_NFSD_V3
 
-static inline int nfsd_create_is_exclusive(int createmode)
-{
-	return createmode == NFS3_CREATE_EXCLUSIVE
-	       || createmode == NFS4_CREATE_EXCLUSIVE4_1;
-}
-
 /*
  * NFSv3 and NFSv4 version of nfsd_create
  */
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 5be875e..fee2451 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -131,4 +131,10 @@ static inline __be32 fh_getattr(struct svc_fh *fh, struct kstat *stat)
 	return nfserrno(vfs_getattr(&p, stat));
 }
 
+static inline int nfsd_create_is_exclusive(int createmode)
+{
+	return createmode == NFS3_CREATE_EXCLUSIVE
+	       || createmode == NFS4_CREATE_EXCLUSIVE4_1;
+}
+
 #endif /* LINUX_NFSD_VFS_H */
-- 
2.4.3

