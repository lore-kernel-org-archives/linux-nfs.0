From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: PATCH - nfsv4 - 2 of 2 - teach nfsv4 response creation to handle multi-page responses
Date: Wed, 13 Nov 2002 09:46:24 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15825.33984.91600.758100@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18Bjnk-0007UH-00
	for <nfs@lists.sourceforge.net>; Tue, 12 Nov 2002 14:46:32 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.204] == wireless-204.wireless.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Wed, 13 Nov 2002 09:46:24 +1100
To: Linus Torvalds <torvalds@transmeta.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>



This patch allows NFSv4 responses to cover move than one page.
There are still limits though.  There can be at most one
'data' response which includes READ, READLINK, READDIR.
For these responses, the interesting data goes in a separate page
or, for READ, list of pages.

All responses before the 'data' response must fit in one page,
and all responses after it must also fit in one (separate)
page.



 ----------- Diffstat output ------------
 fs/nfsd/nfs4proc.c        |    8 ++-
 fs/nfsd/nfs4xdr.c         |  105 +++++++++++++++++++++++++++++++++++-----------
 include/linux/nfsd/xdr4.h |    5 ++
 3 files changed, 91 insertions(+), 27 deletions(-)

diff fs/nfsd/nfs4proc.c~current~ fs/nfsd/nfs4proc.c
--- fs/nfsd/nfs4proc.c~current~	2002-11-12 15:42:38.000000000 +1100
+++ fs/nfsd/nfs4proc.c	2002-11-12 15:42:42.000000000 +1100
@@ -566,11 +566,14 @@ nfsd4_proc_compound(struct svc_rqst *rqs
 	fh_init(&current_fh, NFS4_FHSIZE);
 	fh_init(&save_fh, NFS4_FHSIZE);
 
-	resp->p = rqstp->rq_resbuf.buf + 3 + XDR_QUADLEN(args->taglen);
-	resp->end = rqstp->rq_resbuf.base + rqstp->rq_resbuf.buflen;
+	resp->xbuf = &rqstp->rq_res;
+	resp->p = rqstp->rq_res.head[0].iov_base + rqstp->rq_res.head[0].iov_len;
+	resp->p += 3 + XDR_QUADLEN(args->taglen);
+	resp->end = rqstp->rq_res.head[0].iov_base + PAGE_SIZE;
 	resp->taglen = args->taglen;
 	resp->tag = args->tag;
 	resp->opcnt = 0;
+	resp->rqstp = rqstp;
 
 	/*
 	 * According to RFC3010, this takes precedence over all other errors.
@@ -596,6 +599,7 @@ nfsd4_proc_compound(struct svc_rqst *rqs
 		 * failed response to the next operation.  If we don't
 		 * have enough room, fail with ERR_RESOURCE.
 		 */
+/* FIXME - is slack_space *really* words, or bytes??? - neilb */
 		slack_space = (char *)resp->end - (char *)resp->p;
 		if (slack_space < COMPOUND_SLACK_SPACE + COMPOUND_ERR_SLACK_SPACE) {
 			BUG_ON(slack_space < COMPOUND_ERR_SLACK_SPACE);

diff fs/nfsd/nfs4xdr.c~current~ fs/nfsd/nfs4xdr.c
--- fs/nfsd/nfs4xdr.c~current~	2002-11-12 15:42:38.000000000 +1100
+++ fs/nfsd/nfs4xdr.c	2002-11-12 15:42:42.000000000 +1100
@@ -1689,27 +1689,52 @@ static int
 nfsd4_encode_read(struct nfsd4_compoundres *resp, int nfserr, struct nfsd4_read *read)
 {
 	u32 eof;
-	unsigned long maxcount;
+	int v, pn;
+	unsigned long maxcount, len;
 	ENCODE_HEAD;
 
 	if (nfserr)
 		return nfserr;
+	if (resp->xbuf->page_len)
+		return nfserr_resource;
 
-	maxcount = (char *)resp->end - (char *)resp->p - COMPOUND_ERR_SLACK_SPACE - 8;
+	RESERVE_SPACE(8); /* eof flag and byte count */
+
+	maxcount = NFSSVC_MAXBLKSIZE;
 	if (maxcount > read->rd_length)
 		maxcount = read->rd_length;
-	RESERVE_SPACE(maxcount + 8);
+
+	len = maxcount;
+	v = 0;
+	while (len > 0) {
+		pn = resp->rqstp->rq_resused;
+		svc_take_page(resp->rqstp);
+		read->rd_iov[v].iov_base = page_address(resp->rqstp->rq_respages[pn]);
+		read->rd_iov[v].iov_len = len < PAGE_SIZE ? len : PAGE_SIZE;
+		v++;
+		len -= PAGE_SIZE;
+	}
+	read->rd_vlen = v;
 
 	nfserr = nfsd_read(read->rd_rqstp, read->rd_fhp,
-			   read->rd_offset, (char *)p + 8, &maxcount);
+			   read->rd_offset,
+			   read->rd_iov, read->rd_vlen,
+			   &maxcount);
 	if (nfserr)
 		return nfserr;
 	eof = (read->rd_offset + maxcount >= read->rd_fhp->fh_dentry->d_inode->i_size);
 
 	WRITE32(eof);
 	WRITE32(maxcount);
-	p += XDR_QUADLEN(maxcount);
 	ADJUST_ARGS();
+	resp->xbuf->head[0].iov_len = ((char*)resp->p) - (char*)resp->xbuf->head[0].iov_base;
+	resp->p = resp->xbuf->tail[0].iov_base;
+	resp->xbuf->page_len = maxcount;
+	if (maxcount&3) {
+		*(resp->p) = 0;
+		resp->xbuf->tail[0].iov_base += maxcount&3;
+		resp->xbuf->tail[0].iov_len = 4 - (maxcount&3);
+	}
 	return 0;
 }
 
@@ -1717,13 +1742,24 @@ static int
 nfsd4_encode_readlink(struct nfsd4_compoundres *resp, int nfserr, struct nfsd4_readlink *readlink)
 {
 	int maxcount;
+	char *page;
 	ENCODE_HEAD;
 
 	if (nfserr)
 		return nfserr;
+	if (resp->xbuf->page_len)
+		return nfserr_resource;
 
-	maxcount = (char *)resp->end - (char *)resp->p - COMPOUND_ERR_SLACK_SPACE - 4;
-	RESERVE_SPACE(maxcount + 4);
+	svc_take_page(resp->rqstp);
+	page = page_address(resp->rqstp->rq_respages[resp->rqstp->rq_resused-1]);
+
+	svc_take_page(resp->rqstp);
+	resp->xbuf->tail[0].iov_base = 
+		page_address(resp->rqstp->rq_respages[resp->rqstp->rq_resused-1]);
+	resp->xbuf->tail[0].iov_len = 0;
+
+	maxcount = PAGE_SIZE;
+	RESERVE_SPACE(4);
 
 	/*
 	 * XXX: By default, the ->readlink() VFS op will truncate symlinks
@@ -1731,13 +1767,20 @@ nfsd4_encode_readlink(struct nfsd4_compo
 	 * not, one easy fix is: if ->readlink() precisely fills the buffer,
 	 * assume that truncation occured, and return NFS4ERR_RESOURCE.
 	 */
-	nfserr = nfsd_readlink(readlink->rl_rqstp, readlink->rl_fhp, (char *)p + 4, &maxcount);
+	nfserr = nfsd_readlink(readlink->rl_rqstp, readlink->rl_fhp, page, &maxcount);
 	if (nfserr)
 		return nfserr;
 
 	WRITE32(maxcount);
-	p += XDR_QUADLEN(maxcount);
 	ADJUST_ARGS();
+	resp->xbuf->head[0].iov_len = ((char*)resp->p) - (char*)resp->xbuf->head[0].iov_base;
+	resp->p = resp->xbuf->tail[0].iov_base;
+	resp->xbuf->page_len = maxcount;
+	if (maxcount&3) {
+		*(resp->p) = 0;
+		resp->xbuf->tail[0].iov_base += maxcount&3;
+		resp->xbuf->tail[0].iov_len = 4 - (maxcount&3);
+	}
 	return 0;
 }
 
@@ -1745,15 +1788,26 @@ static int
 nfsd4_encode_readdir(struct nfsd4_compoundres *resp, int nfserr, struct nfsd4_readdir *readdir)
 {
 	int maxcount;
+	u32 *page;
 	loff_t offset;
 	ENCODE_HEAD;
 
 	if (nfserr)
 		return nfserr;
+	if (resp->xbuf->page_len)
+		return nfserr_resource;
+	svc_take_page(resp->rqstp);
+	page = page_address(resp->rqstp->rq_respages[resp->rqstp->rq_resused-1]);
+
+	svc_take_page(resp->rqstp);
+	resp->xbuf->tail[0].iov_base = 
+		page_address(resp->rqstp->rq_respages[resp->rqstp->rq_resused-1]);
+	resp->xbuf->tail[0].iov_len = 0;
+
+	maxcount = PAGE_SIZE;
 
 	RESERVE_SPACE(16);
 
-	maxcount = (char *)resp->end - (char *)p - COMPOUND_ERR_SLACK_SPACE;
 	if (maxcount > readdir->rd_maxcount)
 		maxcount = readdir->rd_maxcount;
 
@@ -1772,7 +1826,7 @@ nfsd4_encode_readdir(struct nfsd4_compou
 
 	readdir->common.err = 0;
 	readdir->buflen = maxcount;
-	readdir->buffer = p;
+	readdir->buffer = page;
 	readdir->offset = NULL;
 
 	offset = readdir->rd_cookie;
@@ -1787,7 +1841,13 @@ nfsd4_encode_readdir(struct nfsd4_compou
 		if (readdir->offset)
 			xdr_encode_hyper(readdir->offset, offset);
 
-		p = readdir->buffer;
+		ADJUST_ARGS();
+		resp->xbuf->head[0].iov_len = ((char*)resp->p) - (char*)resp->xbuf->head[0].iov_base;
+		resp->p = resp->xbuf->tail[0].iov_base;
+		resp->xbuf->page_len = maxcount;
+
+		RESERVE_SPACE(8);
+		
 		*p++ = 0;	/* no more entries */
 		*p++ = htonl(readdir->common.err == nfserr_eof);
 		ADJUST_ARGS();
@@ -1971,17 +2031,6 @@ nfsd4_encode_operation(struct nfsd4_comp
  * END OF "GENERIC" ENCODE ROUTINES.
  */
 
-static inline int
-xdr_ressize_check(struct svc_rqst *rqstp, u32 *p)
-{
-	struct svc_buf	*buf = &rqstp->rq_resbuf;
-
-	buf->len = p - buf->base;
-	dprintk("nfsd: ressize_check p %p base %p len %d\n",
-			p, buf->base, buf->buflen);
-	return (buf->len <= buf->buflen);
-}
-
 int
 nfs4svc_encode_voidres(struct svc_rqst *rqstp, u32 *p, void *dummy)
 {
@@ -1996,7 +2045,7 @@ nfs4svc_decode_compoundargs(struct svc_r
 	args->p = p;
 	args->end = rqstp->rq_arg.head[0].iov_base + rqstp->rq_arg.head[0].iov_len;
 	args->pagelist = rqstp->rq_arg.pages;
-	args->pagelen = rqstp->rq_args.page_len;
+	args->pagelen = rqstp->rq_arg.page_len;
 	args->tmpp = NULL;
 	args->to_free = NULL;
 	args->ops = args->iops;
@@ -2027,12 +2076,18 @@ nfs4svc_encode_compoundres(struct svc_rq
 	/*
 	 * All that remains is to write the tag and operation count...
 	 */
+	struct iovec *iov;
 	*p++ = htonl(resp->taglen);
 	memcpy(p, resp->tag, resp->taglen);
 	p += XDR_QUADLEN(resp->taglen);
 	*p++ = htonl(resp->opcnt);
 
-	BUG_ON(!xdr_ressize_check(rqstp, resp->p));
+	if (rqstp->rq_res.page_len) 
+		iov = &rqstp->rq_res.tail[0];
+	else
+		iov = &rqstp->rq_res.head[0];
+	iov->iov_len = ((char*)resp->p) - (char*)iov->iov_base;
+	BUG_ON(iov->iov_len > PAGE_SIZE);
 	return 1;
 }
 

diff include/linux/nfsd/xdr4.h~current~ include/linux/nfsd/xdr4.h
--- include/linux/nfsd/xdr4.h~current~	2002-11-12 15:42:38.000000000 +1100
+++ include/linux/nfsd/xdr4.h	2002-11-12 15:42:42.000000000 +1100
@@ -173,6 +173,9 @@ struct nfsd4_read {
 	stateid_t	rd_stateid;         /* request */
 	u64		rd_offset;          /* request */
 	u32		rd_length;          /* request */
+	struct iovec	rd_iov[RPCSVC_MAXPAGES];
+	int		rd_vlen;
+	
 	struct svc_rqst *rd_rqstp;          /* response */
 	struct svc_fh * rd_fhp;             /* response */
 };
@@ -311,6 +314,8 @@ struct nfsd4_compoundres {
 	/* scratch variables for XDR encode */
 	u32 *				p;
 	u32 *				end;
+	struct xdr_buf *		xbuf;
+	struct svc_rqst *		rqstp;
 
 	u32				taglen;
 	char *				tag;


-------------------------------------------------------
This sf.net email is sponsored by: 
To learn the basics of securing your web site with SSL, 
click here to get a FREE TRIAL of a Thawte Server Certificate: 
http://www.gothawte.com/rd522.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
