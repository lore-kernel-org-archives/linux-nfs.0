Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:53460 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1732111AbeHAU16 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 1 Aug 2018 16:27:58 -0400
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.rdu2.redhat.com [10.11.54.4])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id A05BA40241C4
        for <linux-nfs@vger.kernel.org>; Wed,  1 Aug 2018 18:40:52 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: "J . Bruce Fields" <bfields@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] Turn ENOATTR errors into ENODATA errrors
Date: Wed,  1 Aug 2018 14:40:52 -0400
Message-Id: <20180801184052.21215-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The defining  of ENOATTR, which was an defined as ENODATA,
was removed from the attr/xattr.h in modern releases

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 libnfs4acl/nfs4_acl_for_path.c | 2 +-
 libnfs4acl/nfs4_set_acl.c      | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/libnfs4acl/nfs4_acl_for_path.c b/libnfs4acl/nfs4_acl_for_path.c
index a51dc34..2fbf6c9 100644
--- a/libnfs4acl/nfs4_acl_for_path.c
+++ b/libnfs4acl/nfs4_acl_for_path.c
@@ -94,7 +94,7 @@ static int nfs4_getxattr(const char *path, void *value, size_t size)
 	if (res < -10000) {
 		fprintf(stderr,"An internal NFS server error code (%d) was returned; this should never happen.\n",res);
 	} else if (res < 0) {
-		if (errno == ENOATTR)
+		if (errno == ENODATA)
 			fprintf(stderr,"Attribute not found on file: %s\n", path);
 		else if (errno == EREMOTEIO)
 		    fprintf(stderr,"An NFS server error occurred.\n");
diff --git a/libnfs4acl/nfs4_set_acl.c b/libnfs4acl/nfs4_set_acl.c
index b9edf2b..6c9b072 100644
--- a/libnfs4acl/nfs4_set_acl.c
+++ b/libnfs4acl/nfs4_set_acl.c
@@ -55,7 +55,7 @@ int nfs4_set_acl(struct nfs4_acl *acl, const char *path)
 	} else if (res < 0) {
 		if (errno == EOPNOTSUPP)
 			fprintf(stderr,"Operation to set ACL not supported.\n");
-		else if (errno == ENOATTR)
+		else if (errno == ENODATA)
 			fprintf(stderr,"ACL Attribute not found on file.\n");
 		else if (errno == EREMOTEIO)
 			fprintf(stderr,"An NFS server error occurred.\n");
-- 
2.17.1

