Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47902 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752216AbaCWBMa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 22 Mar 2014 21:12:30 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 32/50] nfsd4: don't try to encode conflicting owner if low on space
Date: Sat, 22 Mar 2014 21:12:03 -0400
Message-Id: <1395537141-10389-33-git-send-email-bfields@redhat.com>
In-Reply-To: <1395537141-10389-1-git-send-email-bfields@redhat.com>
References: <1395537141-10389-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

I ran into this corner case in testing: in theory clients can provide
state owners up to 1024 bytes long.  In the sessions case there might be
a risk of this pushing us over the DRC slot size.

The conflicting owner isn't really that important, so let's humor a
client that provides a small maxresponsize_cached by allowing ourselves
to return without the conflicting owner instead of outright failing the
operation.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c |  3 ++-
 fs/nfsd/nfs4xdr.c  | 16 +++++++++++++---
 2 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index bc221e4..9876de2 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1387,7 +1387,8 @@ out:
 #define op_encode_change_info_maxsz	(5)
 #define nfs4_fattr_bitmap_maxsz		(4)
 
-#define op_encode_lockowner_maxsz	(1 + XDR_QUADLEN(IDMAP_NAMESZ))
+/* We'll fall back on returning no lockowner if run out of space: */
+#define op_encode_lockowner_maxsz	(0)
 #define op_encode_lock_denied_maxsz	(8 + op_encode_lockowner_maxsz)
 
 #define nfs4_owner_maxsz		(1 + XDR_QUADLEN(IDMAP_NAMESZ))
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 8703cca..3620ac5d 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2861,9 +2861,20 @@ nfsd4_encode_lock_denied(struct xdr_stream *xdr, struct nfsd4_lock_denied *ld)
 	struct xdr_netobj *conf = &ld->ld_owner;
 	__be32 *p;
 
+again:
 	p = xdr_reserve_space(xdr, 32 + XDR_LEN(conf->len));
-	if (!p)
+	if (!p) {
+		/*
+		 * Don't fail to return the result just because we can't
+		 * return the conflicting open:
+		 */
+		if (conf->len) {
+			conf->len = 0;
+			conf->data = NULL;
+			goto again;
+		}
 		return nfserr_resource;
+	}
 	WRITE64(ld->ld_start);
 	WRITE64(ld->ld_length);
 	WRITE32(ld->ld_type);
@@ -2871,7 +2882,6 @@ nfsd4_encode_lock_denied(struct xdr_stream *xdr, struct nfsd4_lock_denied *ld)
 		WRITEMEM(&ld->ld_clientid, 8);
 		WRITE32(conf->len);
 		WRITEMEM(conf->data, conf->len);
-		kfree(conf->data);
 	}  else {  /* non - nfsv4 lock in conflict, no clientid nor owner */
 		WRITE64((u64)0); /* clientid */
 		WRITE32(0); /* length of owner name */
@@ -2888,7 +2898,7 @@ nfsd4_encode_lock(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_lo
 		nfserr = nfsd4_encode_stateid(xdr, &lock->lk_resp_stateid);
 	else if (nfserr == nfserr_denied)
 		nfserr = nfsd4_encode_lock_denied(xdr, &lock->lk_denied);
-
+	kfree(lock->lk_denied.ld_owner.data);
 	return nfserr;
 }
 
-- 
1.8.5.3

