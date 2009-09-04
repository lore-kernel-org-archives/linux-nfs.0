From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 6/6] nfsd: fix leak on error in nfsv3 readdir
Date: Fri,  4 Sep 2009 15:47:06 -0400
Message-ID: <1252093626-5560-7-git-send-email-bfields@citi.umich.edu>
References: <1252093626-5560-1-git-send-email-bfields@citi.umich.edu>
 <1252093626-5560-2-git-send-email-bfields@citi.umich.edu>
 <1252093626-5560-3-git-send-email-bfields@citi.umich.edu>
 <1252093626-5560-4-git-send-email-bfields@citi.umich.edu>
 <1252093626-5560-5-git-send-email-bfields@citi.umich.edu>
 <1252093626-5560-6-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:50171 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757299AbZIDTrE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Sep 2009 15:47:04 -0400
In-Reply-To: <1252093626-5560-6-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Note the !dchild->d_inode case can leak the filehandle.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs3xdr.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index f16184a..edf926e 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -825,7 +825,6 @@ compose_entry_fh(struct nfsd3_readdirres *cd, struct svc_fh *fhp,
 	dparent = cd->fh.fh_dentry;
 	exp  = cd->fh.fh_export;
 
-	fh_init(fhp, NFS3_FHSIZE);
 	if (isdotent(name, namlen)) {
 		if (namlen == 2) {
 			dchild = dget_parent(dparent);
@@ -859,15 +858,17 @@ __be32 *encode_entryplus_baggage(struct nfsd3_readdirres *cd, __be32 *p, const c
 	struct svc_fh	fh;
 	int err;
 
+	fh_init(&fh, NFS3_FHSIZE);
 	err = compose_entry_fh(cd, &fh, name, namlen);
 	if (err) {
 		*p++ = 0;
 		*p++ = 0;
-		return p;
+		goto out;
 	}
 	p = encode_post_op_attr(cd->rqstp, p, &fh);
 	*p++ = xdr_one;			/* yes, a file handle follows */
 	p = encode_fh(p, &fh);
+out:
 	fh_put(&fh);
 	return p;
 }
-- 
1.6.0.4

