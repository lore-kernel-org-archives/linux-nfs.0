Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46918 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756178AbaFZBsO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Jun 2014 21:48:14 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trondmy@gmail.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 7/8] nfsd4: remove nfs4_acl_new
Date: Wed, 25 Jun 2014 21:48:07 -0400
Message-Id: <1403747288-21590-7-git-send-email-bfields@redhat.com>
In-Reply-To: <1403747288-21590-1-git-send-email-bfields@redhat.com>
References: <20140624204418.GG2343@pad.redhat.com>
 <1403747288-21590-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

This is a not-that-useful kmalloc wrapper.  And I'd like one of the
callers to actually use something other than kmalloc.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/acl.h     |    2 +-
 fs/nfsd/nfs4acl.c |   18 ++++++++----------
 fs/nfsd/nfs4xdr.c |    2 +-
 3 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/acl.h b/fs/nfsd/acl.h
index a986ceb..4cd7c69 100644
--- a/fs/nfsd/acl.h
+++ b/fs/nfsd/acl.h
@@ -47,7 +47,7 @@ struct svc_rqst;
 #define NFS4_ACL_MAX ((PAGE_SIZE - sizeof(struct nfs4_acl)) \
 			/ sizeof(struct nfs4_ace))
 
-struct nfs4_acl *nfs4_acl_new(int);
+int nfs4_acl_bytes(int entries);
 int nfs4_acl_get_whotype(char *, u32);
 __be32 nfs4_acl_write_who(struct xdr_stream *xdr, int who);
 
diff --git a/fs/nfsd/nfs4acl.c b/fs/nfsd/nfs4acl.c
index b0cf00d..acf6974 100644
--- a/fs/nfsd/nfs4acl.c
+++ b/fs/nfsd/nfs4acl.c
@@ -161,11 +161,12 @@ nfsd4_get_nfs4_acl(struct svc_rqst *rqstp, struct dentry *dentry,
 			size += 2 * dpacl->a_count;
 	}
 
-	*acl = nfs4_acl_new(size);
+	*acl = kmalloc(nfs4_acl_bytes(size), GFP_KERNEL);
 	if (*acl == NULL) {
 		error = -ENOMEM;
 		goto out;
 	}
+	(*acl)->naces = 0;
 
 	_posix_to_nfsv4_one(pacl, *acl, flags & ~NFS4_ACL_TYPE_DEFAULT);
 
@@ -872,16 +873,13 @@ ace2type(struct nfs4_ace *ace)
 	return -1;
 }
 
-struct nfs4_acl *
-nfs4_acl_new(int n)
+/*
+ * return the size of the struct nfs4_acl required to represent an acl
+ * with @entries entries.
+ */
+int nfs4_acl_bytes(int entries)
 {
-	struct nfs4_acl *acl;
-
-	acl = kmalloc(sizeof(*acl) + n*sizeof(struct nfs4_ace), GFP_KERNEL);
-	if (acl == NULL)
-		return NULL;
-	acl->naces = 0;
-	return acl;
+	return sizeof(struct nfs4_acl) + entries * sizeof(struct nfs4_ace);
 }
 
 static struct {
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 8fb0f37..be4f19c 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -309,7 +309,7 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
 		if (nace > NFS4_ACL_MAX)
 			return nfserr_fbig;
 
-		*acl = nfs4_acl_new(nace);
+		*acl = kmalloc(nfs4_acl_size(nace), GFP_KERNEL);
 		if (*acl == NULL)
 			return nfserr_jukebox;
 
-- 
1.7.9.5

