From: NeilBrown <neilb@suse.de>
Subject: [PATCH 007 of 8] knfsd: Various nfsd xdr cleanups.
Date: Mon, 7 May 2007 10:35:57 +1000
Message-ID: <1070507003557.24190@suse.de>
References: <20070507103211.23855.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HkrD9-00057Z-Ib
	for nfs@lists.sourceforge.net; Sun, 06 May 2007 17:36:19 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HkrDB-0002p0-9Z
	for nfs@lists.sourceforge.net; Sun, 06 May 2007 17:36:22 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


1/ decode_sattr and decode_sattr3 never return NULL, so remove
   several checks for that. ditto for xdr_decode_hyper.
2/ replace some open coded XDR_QUADLEN calls with calls to
   XDR_QUADLEN
3/ in decode_writeargs, simply an 'if' to use a single
   calculation.
   .page_len is the length of that part of the packet that did
   not fit in the first page (the head).
   So the length of the data part is the remainder of the 
   head, plus page_len.

3/ other minor cleanups.

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs3xdr.c |   55 ++++++++++++++++++----------------------------------
 ./fs/nfsd/nfsxdr.c  |   39 +++++++++++++-----------------------
 2 files changed, 34 insertions(+), 60 deletions(-)

diff .prev/fs/nfsd/nfs3xdr.c ./fs/nfsd/nfs3xdr.c
--- .prev/fs/nfsd/nfs3xdr.c	2007-05-07 10:30:15.000000000 +1000
+++ ./fs/nfsd/nfs3xdr.c	2007-05-07 10:31:05.000000000 +1000
@@ -239,7 +239,7 @@ static __be32 *
 encode_post_op_attr(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *fhp)
 {
 	struct dentry *dentry = fhp->fh_dentry;
-	if (dentry && dentry->d_inode != NULL) {
+	if (dentry && dentry->d_inode) {
 	        int err;
 		struct kstat stat;
 
@@ -300,9 +300,9 @@ int
 nfs3svc_decode_sattrargs(struct svc_rqst *rqstp, __be32 *p,
 					struct nfsd3_sattrargs *args)
 {
-	if (!(p = decode_fh(p, &args->fh))
-	 || !(p = decode_sattr3(p, &args->attrs)))
+	if (!(p = decode_fh(p, &args->fh)))
 		return 0;
+	p = decode_sattr3(p, &args->attrs);
 
 	if ((args->check_guard = ntohl(*p++)) != 0) { 
 		struct timespec time; 
@@ -343,9 +343,9 @@ nfs3svc_decode_readargs(struct svc_rqst 
 	int v,pn;
 	u32 max_blocksize = svc_max_payload(rqstp);
 
-	if (!(p = decode_fh(p, &args->fh))
-	 || !(p = xdr_decode_hyper(p, &args->offset)))
+	if (!(p = decode_fh(p, &args->fh)))
 		return 0;
+	p = xdr_decode_hyper(p, &args->offset);
 
 	len = args->count = ntohl(*p++);
 
@@ -372,9 +372,9 @@ nfs3svc_decode_writeargs(struct svc_rqst
 	unsigned int len, v, hdr, dlen;
 	u32 max_blocksize = svc_max_payload(rqstp);
 
-	if (!(p = decode_fh(p, &args->fh))
-	 || !(p = xdr_decode_hyper(p, &args->offset)))
+	if (!(p = decode_fh(p, &args->fh)))
 		return 0;
+	p = xdr_decode_hyper(p, &args->offset);
 
 	args->count = ntohl(*p++);
 	args->stable = ntohl(*p++);
@@ -388,29 +388,16 @@ nfs3svc_decode_writeargs(struct svc_rqst
 	/*
 	 * Check to make sure that we got the right number of
 	 * bytes.
-	 *
-	 * If more than one page was used, then compute the length
-	 * of the data in the request as the total size of the
-	 * request minus the transport protocol headers minus the
-	 * RPC protocol headers minus the NFS protocol fields
-	 * already consumed.  If the request fits into a single
-	 * page, then compete the length of the data as the size
-	 * of the NFS portion of the request minus the NFS
-	 * protocol fields already consumed.
 	 */
 	hdr = (void*)p - rqstp->rq_arg.head[0].iov_base;
-	if (rqstp->rq_respages != rqstp->rq_pages + 1) {
-		dlen = rqstp->rq_arg.len -
-			(PAGE_SIZE - rqstp->rq_arg.head[0].iov_len) - hdr;
-	} else {
-		dlen = rqstp->rq_arg.head[0].iov_len - hdr;
-	}
+	dlen = rqstp->rq_arg.head[0].iov_len + rqstp->rq_arg.page_len
+		- hdr;
 	/*
 	 * Round the length of the data which was specified up to
 	 * the next multiple of XDR units and then compare that
 	 * against the length which was actually received.
 	 */
-	if (dlen != ((len + 3) & ~0x3))
+	if (dlen != XDR_QUADLEN(len)*4)
 		return 0;
 
 	if (args->count > max_blocksize) {
@@ -442,8 +429,7 @@ nfs3svc_decode_createargs(struct svc_rqs
 	switch (args->createmode = ntohl(*p++)) {
 	case NFS3_CREATE_UNCHECKED:
 	case NFS3_CREATE_GUARDED:
-		if (!(p = decode_sattr3(p, &args->attrs)))
-			return 0;
+		p = decode_sattr3(p, &args->attrs);
 		break;
 	case NFS3_CREATE_EXCLUSIVE:
 		args->verf = p;
@@ -459,10 +445,10 @@ int
 nfs3svc_decode_mkdirargs(struct svc_rqst *rqstp, __be32 *p,
 					struct nfsd3_createargs *args)
 {
-	if (!(p = decode_fh(p, &args->fh))
-	 || !(p = decode_filename(p, &args->name, &args->len))
-	 || !(p = decode_sattr3(p, &args->attrs)))
+	if (!(p = decode_fh(p, &args->fh)) ||
+	    !(p = decode_filename(p, &args->name, &args->len)))
 		return 0;
+	p = decode_sattr3(p, &args->attrs);
 
 	return xdr_argsize_check(rqstp, p);
 }
@@ -476,11 +462,12 @@ nfs3svc_decode_symlinkargs(struct svc_rq
 	char *old, *new;
 	struct kvec *vec;
 
-	if (!(p = decode_fh(p, &args->ffh))
-	 || !(p = decode_filename(p, &args->fname, &args->flen))
-	 || !(p = decode_sattr3(p, &args->attrs))
+	if (!(p = decode_fh(p, &args->ffh)) ||
+	    !(p = decode_filename(p, &args->fname, &args->flen))
 		)
 		return 0;
+	p = decode_sattr3(p, &args->attrs);
+
 	/* now decode the pathname, which might be larger than the first page.
 	 * As we have to check for nul's anyway, we copy it into a new page
 	 * This page appears in the rq_res.pages list, but as pages_len is always
@@ -530,10 +517,8 @@ nfs3svc_decode_mknodargs(struct svc_rqst
 	args->ftype = ntohl(*p++);
 
 	if (args->ftype == NF3BLK  || args->ftype == NF3CHR
-	 || args->ftype == NF3SOCK || args->ftype == NF3FIFO) {
-		if (!(p = decode_sattr3(p, &args->attrs)))
-			return 0;
-	}
+	 || args->ftype == NF3SOCK || args->ftype == NF3FIFO)
+		p = decode_sattr3(p, &args->attrs);
 
 	if (args->ftype == NF3BLK || args->ftype == NF3CHR) {
 		args->major = ntohl(*p++);

diff .prev/fs/nfsd/nfsxdr.c ./fs/nfsd/nfsxdr.c
--- .prev/fs/nfsd/nfsxdr.c	2007-05-07 10:30:15.000000000 +1000
+++ ./fs/nfsd/nfsxdr.c	2007-05-07 10:31:05.000000000 +1000
@@ -231,9 +231,10 @@ int
 nfssvc_decode_sattrargs(struct svc_rqst *rqstp, __be32 *p,
 					struct nfsd_sattrargs *args)
 {
-	if (!(p = decode_fh(p, &args->fh))
-	 || !(p = decode_sattr(p, &args->attrs)))
+	p = decode_fh(p, &args->fh);
+	if (!p)
 		return 0;
+	p = decode_sattr(p, &args->attrs);
 
 	return xdr_argsize_check(rqstp, p);
 }
@@ -303,29 +304,17 @@ nfssvc_decode_writeargs(struct svc_rqst 
 	/*
 	 * Check to make sure that we got the right number of
 	 * bytes.
-	 *
-	 * If more than one page was used, then compute the length
-	 * of the data in the request as the total size of the
-	 * request minus the transport protocol headers minus the
-	 * RPC protocol headers minus the NFS protocol fields
-	 * already consumed.  If the request fits into a single
-	 * page, then compete the length of the data as the size
-	 * of the NFS portion of the request minus the NFS
-	 * protocol fields already consumed.
 	 */
 	hdr = (void*)p - rqstp->rq_arg.head[0].iov_base;
-	if (rqstp->rq_respages != rqstp->rq_pages + 1) {
-		dlen = rqstp->rq_arg.len -
-			(PAGE_SIZE - rqstp->rq_arg.head[0].iov_len) - hdr;
-	} else {
-		dlen = rqstp->rq_arg.head[0].iov_len - hdr;
-	}
+	dlen = rqstp->rq_arg.head[0].iov_len + rqstp->rq_arg.page_len
+		- hdr;
+
 	/*
 	 * Round the length of the data which was specified up to
 	 * the next multiple of XDR units and then compare that
 	 * against the length which was actually received.
 	 */
-	if (dlen != ((len + 3) & ~0x3))
+	if (dlen != XDR_QUADLEN(len)*4)
 		return 0;
 
 	rqstp->rq_vec[0].iov_base = (void*)p;
@@ -346,10 +335,10 @@ int
 nfssvc_decode_createargs(struct svc_rqst *rqstp, __be32 *p,
 					struct nfsd_createargs *args)
 {
-	if (!(p = decode_fh(p, &args->fh))
-	 || !(p = decode_filename(p, &args->name, &args->len))
-	 || !(p = decode_sattr(p, &args->attrs)))
+	if (   !(p = decode_fh(p, &args->fh))
+	    || !(p = decode_filename(p, &args->name, &args->len)))
 		return 0;
+	p = decode_sattr(p, &args->attrs);
 
 	return xdr_argsize_check(rqstp, p);
 }
@@ -393,11 +382,11 @@ int
 nfssvc_decode_symlinkargs(struct svc_rqst *rqstp, __be32 *p,
 					struct nfsd_symlinkargs *args)
 {
-	if (!(p = decode_fh(p, &args->ffh))
-	 || !(p = decode_filename(p, &args->fname, &args->flen))
-	 || !(p = decode_pathname(p, &args->tname, &args->tlen))
-	 || !(p = decode_sattr(p, &args->attrs)))
+	if (   !(p = decode_fh(p, &args->ffh))
+	    || !(p = decode_filename(p, &args->fname, &args->flen))
+	    || !(p = decode_pathname(p, &args->tname, &args->tlen)))
 		return 0;
+	p = decode_sattr(p, &args->attrs);
 
 	return xdr_argsize_check(rqstp, p);
 }

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
