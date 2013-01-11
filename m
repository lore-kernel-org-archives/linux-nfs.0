Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([222.73.24.84]:13967 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751591Ab3AKJvz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jan 2013 04:51:55 -0500
Message-ID: <50EFE0D1.9090907@cn.fujitsu.com>
Date: Fri, 11 Jan 2013 17:52:17 +0800
From: fanchaoting <fanchaoting@cn.fujitsu.com>
MIME-Version: 1.0
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Subject: [PATCH] nfs4-acl-tools: when who's length is very big, nfs4_getacl
 core dump
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfsv4 server can return a very large who's len(eg. wholen = 62343534343) 
in an FATTR4_WORD0_ACL request.It can cause nfs4_getacl core dump 
when call 'malloc((wholen + 1) * sizeof(char))'.

 This patch checked if who's len bigger than xattr_size when getfacl.

 This patch also fixed some code style.

Signed-off-by: Fan Chaoting <fanchaoting@cn.fujitsu.com>
---
 libnfs4acl/acl_nfs4_xattr_load.c |    6 ++++++
 libnfs4acl/nfs4_acl_for_path.c   |    8 ++++----
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/libnfs4acl/acl_nfs4_xattr_load.c b/libnfs4acl/acl_nfs4_xattr_load.c
index 089a139..ced1c95 100644
--- a/libnfs4acl/acl_nfs4_xattr_load.c
+++ b/libnfs4acl/acl_nfs4_xattr_load.c
@@ -139,6 +139,12 @@ struct nfs4_acl * acl_nfs4_xattr_load(char *xattr_v, int xattr_size, u32 is_dir)
 			goto err1;
 		}
 
+		/*wholen should less than xattr_size*/
+		if (wholen > xattr_size) {
+			errno = EINVAL;
+			goto err1;
+		}
+
 		who = (char *) malloc((wholen+1) * sizeof(char));
 		if (who == NULL) {
 			errno = ENOMEM;
diff --git a/libnfs4acl/nfs4_acl_for_path.c b/libnfs4acl/nfs4_acl_for_path.c
index 7461005..577dd1f 100644
--- a/libnfs4acl/nfs4_acl_for_path.c
+++ b/libnfs4acl/nfs4_acl_for_path.c
@@ -92,14 +92,14 @@ static int nfs4_getxattr(const char *path, void *value, size_t size)
 
 	res = getxattr(path, ACL_NFS4_XATTR, value, size);
 	if (res < -10000) {
-		fprintf(stderr,"An internal NFS server error code (%d) was returned; this should never happen.\n",res);
+		fprintf(stderr, "An internal NFS server error code (%d) was returned; this should never happen.\n", res);
 	} else if (res < 0) {
 		if (errno == ENOATTR)
-			fprintf(stderr,"Attribute not found on file.\n");
+			fprintf(stderr, "Attribute not found on file.\n");
 		else if (errno == EREMOTEIO)
-		    fprintf(stderr,"An NFS server error occurred.\n");
+		    fprintf(stderr, "An NFS server error occurred.\n");
 		else if (errno == EOPNOTSUPP)
-			fprintf(stderr,"Operation to request attribute not supported.\n");
+			fprintf(stderr, "Operation to request attribute not supported.\n");
 		else
 			perror("Failed getxattr operation");
 	}
-- 1.7.1 

--

