Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55900 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751500AbaAGVFN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Jan 2014 16:05:13 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/4] nfsd4: nfsd4_encode_fattr cleanup
Date: Tue,  7 Jan 2014 16:04:33 -0500
Message-Id: <1389128674-16951-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1389128674-16951-1-git-send-email-bfields@redhat.com>
References: <1389128674-16951-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Remove some pointless goto's.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c |   17 ++++-------------
 1 file changed, 4 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 5bef9cb..3bffba6 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2230,8 +2230,10 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 		if ((buflen -= 4) < 0)
 			goto out_resource;
 		dummy = nfs4_file_type(stat.mode);
-		if (dummy == NF4BAD)
-			goto out_serverfault;
+		if (dummy == NF4BAD) {
+			status = nfserr_serverfault;
+			goto out;
+		}
 		WRITE32(dummy);
 	}
 	if (bmval0 & FATTR4_WORD0_FH_EXPIRE_TYPE) {
@@ -2325,8 +2327,6 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 			WRITE32(ace->flag);
 			WRITE32(ace->access_mask & NFS4_ACE_MASK_ALL);
 			status = nfsd4_encode_aclname(rqstp, ace, &p, &buflen);
-			if (status == nfserr_resource)
-				goto out_resource;
 			if (status)
 				goto out;
 		}
@@ -2387,8 +2387,6 @@ out_acl:
 	}
 	if (bmval0 & FATTR4_WORD0_FS_LOCATIONS) {
 		status = nfsd4_encode_fs_locations(rqstp, exp, &p, &buflen);
-		if (status == nfserr_resource)
-			goto out_resource;
 		if (status)
 			goto out;
 	}
@@ -2439,15 +2437,11 @@ out_acl:
 	}
 	if (bmval1 & FATTR4_WORD1_OWNER) {
 		status = nfsd4_encode_user(rqstp, stat.uid, &p, &buflen);
-		if (status == nfserr_resource)
-			goto out_resource;
 		if (status)
 			goto out;
 	}
 	if (bmval1 & FATTR4_WORD1_OWNER_GROUP) {
 		status = nfsd4_encode_group(rqstp, stat.gid, &p, &buflen);
-		if (status == nfserr_resource)
-			goto out_resource;
 		if (status)
 			goto out;
 	}
@@ -2550,9 +2544,6 @@ out_nfserr:
 out_resource:
 	status = nfserr_resource;
 	goto out;
-out_serverfault:
-	status = nfserr_serverfault;
-	goto out;
 }
 
 static inline int attributes_need_mount(u32 *bmval)
-- 
1.7.9.5

