Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:36586 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754555AbbDXLEz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Apr 2015 07:04:55 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [RFC v3 03/45] nfsd: Checking for acl support does not require fetching any acls
Date: Fri, 24 Apr 2015 13:04:00 +0200
Message-Id: <b3a09e6f1071ea01de64aa3071cb533e79fb4b18.1429868795.git.agruenba@redhat.com>
In-Reply-To: <cover.1429868795.git.agruenba@redhat.com>
References: <cover.1429868795.git.agruenba@redhat.com>
In-Reply-To: <cover.1429868795.git.agruenba@redhat.com>
References: <cover.1429868795.git.agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Whether or not a file system supports acls can be determined with
IS_POSIXACL(inode) and does not require trying to fetch any acls; the code for
computing the supported_attrs and aclsupport attributes can be simplified.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/nfsd/nfs4xdr.c | 25 ++++++++++---------------
 1 file changed, 10 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 5fb7e78..e2d602d 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2227,7 +2227,6 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp,
 	u32 rdattr_err = 0;
 	__be32 status;
 	int err;
-	int aclsupport = 0;
 	struct nfs4_acl *acl = NULL;
 	void *context = NULL;
 	int contextlen;
@@ -2274,19 +2273,15 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp,
 			goto out;
 		fhp = tempfh;
 	}
-	if (bmval0 & (FATTR4_WORD0_ACL | FATTR4_WORD0_ACLSUPPORT
-			| FATTR4_WORD0_SUPPORTED_ATTRS)) {
+	if (bmval0 & FATTR4_WORD0_ACL) {
 		err = nfsd4_get_nfs4_acl(rqstp, dentry, &acl);
-		aclsupport = (err == 0);
-		if (bmval0 & FATTR4_WORD0_ACL) {
-			if (err == -EOPNOTSUPP)
-				bmval0 &= ~FATTR4_WORD0_ACL;
-			else if (err == -EINVAL) {
-				status = nfserr_attrnotsupp;
-				goto out;
-			} else if (err != 0)
-				goto out_nfserr;
-		}
+		if (err == -EOPNOTSUPP)
+			bmval0 &= ~FATTR4_WORD0_ACL;
+		else if (err == -EINVAL) {
+			status = nfserr_attrnotsupp;
+			goto out;
+		} else if (err != 0)
+			goto out_nfserr;
 	}
 
 #ifdef CONFIG_NFSD_V4_SECURITY_LABEL
@@ -2338,7 +2333,7 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp,
 		u32 word1 = nfsd_suppattrs1(minorversion);
 		u32 word2 = nfsd_suppattrs2(minorversion);
 
-		if (!aclsupport)
+		if (!IS_POSIXACL(dentry->d_inode))
 			word0 &= ~FATTR4_WORD0_ACL;
 		if (!contextsupport)
 			word2 &= ~FATTR4_WORD2_SECURITY_LABEL;
@@ -2486,7 +2481,7 @@ out_acl:
 		p = xdr_reserve_space(xdr, 4);
 		if (!p)
 			goto out_resource;
-		*p++ = cpu_to_be32(aclsupport ?
+		*p++ = cpu_to_be32(IS_POSIXACL(dentry->d_inode) ?
 			ACL4_SUPPORT_ALLOW_ACL|ACL4_SUPPORT_DENY_ACL : 0);
 	}
 	if (bmval0 & FATTR4_WORD0_CANSETTIME) {
-- 
2.1.0

