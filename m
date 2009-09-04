From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 5/6] nfsd: clean up readdirplus encoding
Date: Fri,  4 Sep 2009 15:47:05 -0400
Message-ID: <1252093626-5560-6-git-send-email-bfields@citi.umich.edu>
References: <1252093626-5560-1-git-send-email-bfields@citi.umich.edu>
 <1252093626-5560-2-git-send-email-bfields@citi.umich.edu>
 <1252093626-5560-3-git-send-email-bfields@citi.umich.edu>
 <1252093626-5560-4-git-send-email-bfields@citi.umich.edu>
 <1252093626-5560-5-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:50169 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757293AbZIDTrE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Sep 2009 15:47:04 -0400
In-Reply-To: <1252093626-5560-5-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make the return from compose_entry_fh() zero or an error, even thoguh
the returned error isn't used, just to make the meaning of the return
immediately obvious.

Move some repeated code out of main function into helper.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs3xdr.c |   72 +++++++++++++++++++++++++----------------------------
 1 files changed, 34 insertions(+), 38 deletions(-)

diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 01d4ec1..f16184a 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -814,17 +814,6 @@ encode_entry_baggage(struct nfsd3_readdirres *cd, __be32 *p, const char *name,
 	return p;
 }
 
-static __be32 *
-encode_entryplus_baggage(struct nfsd3_readdirres *cd, __be32 *p,
-		struct svc_fh *fhp)
-{
-	p = encode_post_op_attr(cd->rqstp, p, fhp);
-	*p++ = xdr_one;			/* yes, a file handle follows */
-	p = encode_fh(p, fhp);
-	fh_put(fhp);
-	return p;
-}
-
 static int
 compose_entry_fh(struct nfsd3_readdirres *cd, struct svc_fh *fhp,
 		const char *name, int namlen)
@@ -843,22 +832,46 @@ compose_entry_fh(struct nfsd3_readdirres *cd, struct svc_fh *fhp,
 			if (dchild == dparent) {
 				/* filesystem root - cannot return filehandle for ".." */
 				dput(dchild);
-				return 1;
+				return -ENOENT;
 			}
 		} else
 			dchild = dget(dparent);
 	} else
 		dchild = lookup_one_len(name, dparent, namlen);
 	if (IS_ERR(dchild))
-		return 1;
-	if (d_mountpoint(dchild) ||
-	    fh_compose(fhp, exp, dchild, &cd->fh) != 0 ||
-	    !dchild->d_inode)
-		rv = 1;
+		return -ENOENT;
+	rv = -ENOENT;
+	if (d_mountpoint(dchild))
+		goto out;
+	rv = fh_compose(fhp, exp, dchild, &cd->fh);
+	if (rv)
+		goto out;
+	if (!dchild->d_inode)
+		goto out;
+	rv = 0;
+out:
 	dput(dchild);
 	return rv;
 }
 
+__be32 *encode_entryplus_baggage(struct nfsd3_readdirres *cd, __be32 *p, const char *name, int namlen)
+{
+	struct svc_fh	fh;
+	int err;
+
+	err = compose_entry_fh(cd, &fh, name, namlen);
+	if (err) {
+		*p++ = 0;
+		*p++ = 0;
+		return p;
+	}
+	p = encode_post_op_attr(cd->rqstp, p, &fh);
+	*p++ = xdr_one;			/* yes, a file handle follows */
+	p = encode_fh(p, &fh);
+	fh_put(&fh);
+	return p;
+}
+
 /*
  * Encode a directory entry. This one works for both normal readdir
  * and readdirplus.
@@ -929,16 +942,8 @@ encode_entry(struct readdir_cd *ccd, const char *name, int namlen,
 
 		p = encode_entry_baggage(cd, p, name, namlen, ino);
 
-		/* throw in readdirplus baggage */
-		if (plus) {
-			struct svc_fh	fh;
-
-			if (compose_entry_fh(cd, &fh, name, namlen) > 0) {
-				*p++ = 0;
-				*p++ = 0;
-			} else
-				p = encode_entryplus_baggage(cd, p, &fh);
-		}
+		if (plus)
+			p = encode_entryplus_baggage(cd, p, name, namlen);
 		num_entry_words = p - cd->buffer;
 	} else if (cd->rqstp->rq_respages[pn+1] != NULL) {
 		/* temporarily encode entry into next page, then move back to
@@ -951,17 +956,8 @@ encode_entry(struct readdir_cd *ccd, const char *name, int namlen,
 
 		p1 = encode_entry_baggage(cd, p1, name, namlen, ino);
 
-		/* throw in readdirplus baggage */
-		if (plus) {
-			struct svc_fh	fh;
-
-			if (compose_entry_fh(cd, &fh, name, namlen) > 0) {
-				/* zero out the filehandle */
-				*p1++ = 0;
-				*p1++ = 0;
-			} else
-				p1 = encode_entryplus_baggage(cd, p1, &fh);
-		}
+		if (plus)
+			p = encode_entryplus_baggage(cd, p1, name, namlen);
 
 		/* determine entry word length and lengths to go in pages */
 		num_entry_words = p1 - tmp;
-- 
1.6.0.4

