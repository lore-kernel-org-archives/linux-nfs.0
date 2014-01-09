Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55968 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757371AbaAIVdg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Jan 2014 16:33:36 -0500
Date: Thu, 9 Jan 2014 16:33:35 -0500
To: linux-nfs@vger.kernel.org
Cc: sandeen@redhat.com, jlayton@redhat.com
Subject: fix encode_entryplus_baggage stack usage
Message-ID: <20140109213335.GA21559@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Eric ran across an excessive stack with this (and a bunch of xfs code)
to blame.  Untested.  I don't know whether it's worth the minor extra
work here to avoid the alloc/free on each entry.

nfsd4_encode_fattr will need the same treatment.

--b.

commit 5b35a1f99f999555e82420e687e9d079ae796547
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Thu Jan 9 16:24:35 2014 -0500

    nfsd: fix encode_entryplus_baggage stack usage
    
    We stick an extra svc_fh in nfsd3_readdirres to save the need to
    kmalloc, though maybe it would be fine to kmalloc instead.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 1ee6bae..de6e39e 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -842,21 +842,21 @@ out:
 
 static __be32 *encode_entryplus_baggage(struct nfsd3_readdirres *cd, __be32 *p, const char *name, int namlen)
 {
-	struct svc_fh	fh;
+	struct svc_fh	*fh = &cd->scratch;
 	__be32 err;
 
-	fh_init(&fh, NFS3_FHSIZE);
-	err = compose_entry_fh(cd, &fh, name, namlen);
+	fh_init(fh, NFS3_FHSIZE);
+	err = compose_entry_fh(cd, fh, name, namlen);
 	if (err) {
 		*p++ = 0;
 		*p++ = 0;
 		goto out;
 	}
-	p = encode_post_op_attr(cd->rqstp, p, &fh);
+	p = encode_post_op_attr(cd->rqstp, p, fh);
 	*p++ = xdr_one;			/* yes, a file handle follows */
-	p = encode_fh(p, &fh);
+	p = encode_fh(p, fh);
 out:
-	fh_put(&fh);
+	fh_put(fh);
 	return p;
 }
 
diff --git a/fs/nfsd/xdr3.h b/fs/nfsd/xdr3.h
index b6d5542..335e04a 100644
--- a/fs/nfsd/xdr3.h
+++ b/fs/nfsd/xdr3.h
@@ -174,6 +174,9 @@ struct nfsd3_linkres {
 struct nfsd3_readdirres {
 	__be32			status;
 	struct svc_fh		fh;
+	/* Just to save kmalloc on every readdirplus entry (svc_fh is a
+	 * little large for the stack): */
+	struct svc_fh		scratch;
 	int			count;
 	__be32			verf[2];
 
