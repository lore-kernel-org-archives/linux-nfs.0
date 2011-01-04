Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:50133 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751027Ab1ADXXf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jan 2011 18:23:35 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Simon Kirby <sim@hostway.ca>, linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/4] nfsd4: return nfs errno from name_to_id functions
Date: Tue,  4 Jan 2011 18:23:30 -0500
Message-Id: <1294183410-14688-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1294178391.5896.31.camel@heimdal.trondhjem.org>
References: <1294178391.5896.31.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This avoids the need for the confusing ESRCH mapping.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/idmap.h     |    4 ++--
 fs/nfsd/nfs4idmap.c |   13 +++++++------
 fs/nfsd/nfs4xdr.c   |   10 +++++-----
 fs/nfsd/nfsproc.c   |    1 -
 4 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/idmap.h b/fs/nfsd/idmap.h
index 5147589..2f3be13 100644
--- a/fs/nfsd/idmap.h
+++ b/fs/nfsd/idmap.h
@@ -54,8 +54,8 @@ static inline void nfsd_idmap_shutdown(void)
 }
 #endif
 
-int nfsd_map_name_to_uid(struct svc_rqst *, const char *, size_t, __u32 *);
-int nfsd_map_name_to_gid(struct svc_rqst *, const char *, size_t, __u32 *);
+__be32 nfsd_map_name_to_uid(struct svc_rqst *, const char *, size_t, __u32 *);
+__be32 nfsd_map_name_to_gid(struct svc_rqst *, const char *, size_t, __u32 *);
 int nfsd_map_uid_to_name(struct svc_rqst *, __u32, char *);
 int nfsd_map_gid_to_name(struct svc_rqst *, __u32, char *);
 
diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
index cbd5997..6d2c397 100644
--- a/fs/nfsd/nfs4idmap.c
+++ b/fs/nfsd/nfs4idmap.c
@@ -37,6 +37,7 @@
 #include <linux/sched.h>
 #include <linux/slab.h>
 #include "idmap.h"
+#include "nfsd.h"
 
 /*
  * Cache entry
@@ -514,7 +515,7 @@ rqst_authname(struct svc_rqst *rqstp)
 	return clp->name;
 }
 
-static int
+static __be32
 idmap_name_to_id(struct svc_rqst *rqstp, int type, const char *name, u32 namelen,
 		uid_t *id)
 {
@@ -524,15 +525,15 @@ idmap_name_to_id(struct svc_rqst *rqstp, int type, const char *name, u32 namelen
 	int ret;
 
 	if (namelen + 1 > sizeof(key.name))
-		return -ESRCH; /* nfserr_badowner */
+		return nfserr_badowner;
 	memcpy(key.name, name, namelen);
 	key.name[namelen] = '\0';
 	strlcpy(key.authname, rqst_authname(rqstp), sizeof(key.authname));
 	ret = idmap_lookup(rqstp, nametoid_lookup, &key, &nametoid_cache, &item);
 	if (ret == -ENOENT)
-		ret = -ESRCH; /* nfserr_badowner */
+		return nfserr_badowner;
 	if (ret)
-		return ret;
+		return nfserrno(ret);
 	*id = item->id;
 	cache_put(&item->h, &nametoid_cache);
 	return 0;
@@ -560,14 +561,14 @@ idmap_id_to_name(struct svc_rqst *rqstp, int type, uid_t id, char *name)
 	return ret;
 }
 
-int
+__be32
 nfsd_map_name_to_uid(struct svc_rqst *rqstp, const char *name, size_t namelen,
 		__u32 *id)
 {
 	return idmap_name_to_id(rqstp, IDMAP_TYPE_USER, name, namelen, id);
 }
 
-int
+__be32
 nfsd_map_name_to_gid(struct svc_rqst *rqstp, const char *name, size_t namelen,
 		__u32 *id)
 {
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 2a0814d..ca37869 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -289,17 +289,17 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
 			len += XDR_QUADLEN(dummy32) << 2;
 			READMEM(buf, dummy32);
 			ace->whotype = nfs4_acl_get_whotype(buf, dummy32);
-			host_err = 0;
+			status = nfs_ok;
 			if (ace->whotype != NFS4_ACL_WHO_NAMED)
 				ace->who = 0;
 			else if (ace->flag & NFS4_ACE_IDENTIFIER_GROUP)
-				host_err = nfsd_map_name_to_gid(argp->rqstp,
+				status = nfsd_map_name_to_gid(argp->rqstp,
 						buf, dummy32, &ace->who);
 			else
-				host_err = nfsd_map_name_to_uid(argp->rqstp,
+				status = nfsd_map_name_to_uid(argp->rqstp,
 						buf, dummy32, &ace->who);
-			if (host_err)
-				goto out_nfserr;
+			if (status)
+				return status;
 		}
 	} else
 		*acl = NULL;
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 8f05dcd..e15dc45 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -738,7 +738,6 @@ nfserrno (int errno)
 		{ nfserr_jukebox, -EAGAIN },
 		{ nfserr_jukebox, -EWOULDBLOCK },
 		{ nfserr_jukebox, -ENOMEM },
-		{ nfserr_badowner, -ESRCH },
 		{ nfserr_io, -ETXTBSY },
 		{ nfserr_notsupp, -EOPNOTSUPP },
 		{ nfserr_toosmall, -ETOOSMALL },
-- 
1.7.1

