Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:25841 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752582Ab3AWWzk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Jan 2013 17:55:40 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r0NMteFj007731
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 23 Jan 2013 17:55:40 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/7] nfsd4: nfsd4_encode_fattr cleanup
Date: Wed, 23 Jan 2013 17:55:34 -0500
Message-Id: <1358981738-5649-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1358981738-5649-1-git-send-email-bfields@redhat.com>
References: <1358981738-5649-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Remove some pointless goto's.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c | 17 ++++-------------
 1 file changed, 4 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index fcb5bed..f1b6aac 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2129,8 +2129,10 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
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
@@ -2226,8 +2228,6 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 			status = nfsd4_encode_aclname(rqstp, ace->whotype,
 				ace->who, ace->flag & NFS4_ACE_IDENTIFIER_GROUP,
 				&p, &buflen);
-			if (status == nfserr_resource)
-				goto out_resource;
 			if (status)
 				goto out;
 		}
@@ -2288,8 +2288,6 @@ out_acl:
 	}
 	if (bmval0 & FATTR4_WORD0_FS_LOCATIONS) {
 		status = nfsd4_encode_fs_locations(rqstp, exp, &p, &buflen);
-		if (status == nfserr_resource)
-			goto out_resource;
 		if (status)
 			goto out;
 	}
@@ -2340,15 +2338,11 @@ out_acl:
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
@@ -2444,9 +2438,6 @@ out_nfserr:
 out_resource:
 	status = nfserr_resource;
 	goto out;
-out_serverfault:
-	status = nfserr_serverfault;
-	goto out;
 }
 
 static inline int attributes_need_mount(u32 *bmval)
-- 
1.7.11.7

