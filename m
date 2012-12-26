Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([222.73.24.84]:19473 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753821Ab2LZJ7z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Dec 2012 04:59:55 -0500
Received: from fnstmail02.fnst.cn.fujitsu.com (tang.cn.fujitsu.com [127.0.0.1])
	by tang.cn.fujitsu.com (8.14.3/8.13.1) with ESMTP id qBQ9PJhO017478
	for <linux-nfs@vger.kernel.org>; Wed, 26 Dec 2012 17:25:20 +0800
Message-ID: <50DAC3F9.6070801@cn.fujitsu.com>
Date: Wed, 26 Dec 2012 17:31:37 +0800
From: fanchaoting <fanchaoting@cn.fujitsu.com>
MIME-Version: 1.0
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH] nfs4-acl-tools: when who's length is very big, nfs4_getacl
 core dump
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Fan Chaoting <fanchaoting@cn.fujitsu.com>

nfsv4 server can return an arbitrary
sized who's len(eg. wholen = 62343534343) in an FATTR4_WORD0_ACL request.
It can cause program core dump when call 'malloc((wholen + 1) * sizeof(char))'.

 This patch checked if who's len bigger than xattr_size when getfacl.

 This patch also fixed some code style.

Signed-off-by: Fan Chaoting <fanchaoting@cn.fujitsu.com>

the reproduce of this problem:
#####################################################################

1. change the nfs server's code.

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 731587c..5b12a6f 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2163,6 +2163,13 @@ out_acl:
        }

        *attrlenp = htonl((char *)p - (char *)attrlenp - 4);
+
+       static int j;
+       j++;
+
+       if (j % 10 == 0 & bmval0 & FATTR4_WORD0_ACL) {
+               *attrlenp = 6000;
+       }
        *countp = p - buffer;
        status = nfs_ok;

@@ -3323,7 +3330,7 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
        else
                iov = &rqstp->rq_res.head[0];
        iov->iov_len = ((char*)resp->p) - (char*)iov->iov_base;
-       BUG_ON(iov->iov_len > PAGE_SIZE);
+//     BUG_ON(iov->iov_len > PAGE_SIZE);
        if (nfsd4_has_session(cs)) {
                if (cs->status != nfserr_replay_cache) {
                        nfsd4_store_cache_entry(resp);

2. mount -t nfs4 -o acl NFSSERVERIP:/ /mnt
3. touch /mnt/test
4. nfs4_getfacl  /mnt/test               <--core dump

######################################################################

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

