Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 183.141.211.66.inaddr.G4.NET ([66.211.141.183]:50516 "EHLO
	Dobby.4dicksons.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750800Ab2LUULF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Dec 2012 15:11:05 -0500
From: Steve Dickson <steved@redhat.com>
To: David Quigley <selinux@davequigley.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH] lnfs: remove export flag for label NFS exports
Date: Fri, 21 Dec 2012 15:05:50 -0500
Message-Id: <1356120350-6325-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It was deemed through code review, that having an
"security_label" export flag was not needed.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 fs/nfsd/export.c                 | 3 ---
 fs/nfsd/nfs4xdr.c                | 5 +----
 include/uapi/linux/nfsd/export.h | 1 -
 3 files changed, 1 insertion(+), 8 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 251eca7..a3946cf 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -1112,9 +1112,6 @@ static struct flags {
 	{ NFSEXP_ASYNC, {"async", "sync"}},
 	{ NFSEXP_GATHERED_WRITES, {"wdelay", "no_wdelay"}},
 	{ NFSEXP_NOHIDE, {"nohide", ""}},
-#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
-	{ NFSEXP_SECURITY_LABEL, {"security_label", ""}},
-#endif
 	{ NFSEXP_CROSSMOUNT, {"crossmnt", ""}},
 	{ NFSEXP_NOSUBTREECHECK, {"no_subtree_check", ""}},
 	{ NFSEXP_NOAUTHNLM, {"insecure_locks", ""}},
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 58e205c..a234ed4 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2214,10 +2214,7 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 		if (!aclsupport)
 			word0 &= ~FATTR4_WORD0_ACL;
 #ifdef CONFIG_NFSD_V4_SECURITY_LABEL
-		if (exp->ex_flags & NFSEXP_SECURITY_LABEL)
-			word2 |= FATTR4_WORD2_SECURITY_LABEL;
-		else
-			word2 &= ~FATTR4_WORD2_SECURITY_LABEL;
+		word2 |= FATTR4_WORD2_SECURITY_LABEL;
 #else
 		word2 &= ~FATTR4_WORD2_SECURITY_LABEL;
 #endif
diff --git a/include/uapi/linux/nfsd/export.h b/include/uapi/linux/nfsd/export.h
index e6c76d9..b892b6a 100644
--- a/include/uapi/linux/nfsd/export.h
+++ b/include/uapi/linux/nfsd/export.h
@@ -28,7 +28,6 @@
 #define NFSEXP_ALLSQUASH	0x0008
 #define NFSEXP_ASYNC		0x0010
 #define NFSEXP_GATHERED_WRITES	0x0020
-#define NFSEXP_SECURITY_LABEL	0x0040  /* Support security label fattr4 */
 /* 80 100 currently unused */
 #define NFSEXP_NOHIDE		0x0200
 #define NFSEXP_NOSUBTREECHECK	0x0400
-- 
1.7.11.7

