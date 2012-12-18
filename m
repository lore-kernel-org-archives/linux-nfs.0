Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60451 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753794Ab2LREp6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Dec 2012 23:45:58 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/4] nfsd4: cleanup: replace rq_resused count by rq_next_page pointer
Date: Mon, 17 Dec 2012 23:45:51 -0500
Message-Id: <1355805953-2473-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1355805953-2473-1-git-send-email-bfields@redhat.com>
References: <1355805953-2473-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

It may be a matter of personal taste, but I find this makes the code
clearer.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs2acl.c                       |    2 +-
 fs/nfsd/nfs3acl.c                       |    2 +-
 fs/nfsd/nfs3proc.c                      |    6 +++---
 fs/nfsd/nfs3xdr.c                       |   33 +++++++++++++++----------------
 fs/nfsd/nfs4xdr.c                       |   24 +++++++++++-----------
 fs/nfsd/nfsxdr.c                        |   11 ++++++-----
 fs/nfsd/vfs.c                           |   18 ++++++++---------
 include/linux/sunrpc/svc.h              |    6 +++---
 net/sunrpc/svc.c                        |    2 +-
 net/sunrpc/svcsock.c                    |    2 ++
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |   10 +++++-----
 net/sunrpc/xprtrdma/svc_rdma_sendto.c   |    4 +++-
 12 files changed, 61 insertions(+), 59 deletions(-)

diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index b314888..9170861 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -253,7 +253,7 @@ static int nfsaclsvc_encode_getaclres(struct svc_rqst *rqstp, __be32 *p,
 		(resp->mask & NFS_ACL)   ? resp->acl_access  : NULL,
 		(resp->mask & NFS_DFACL) ? resp->acl_default : NULL);
 	while (w > 0) {
-		if (!rqstp->rq_respages[rqstp->rq_resused++])
+		if (!*(rqstp->rq_next_page++))
 			return 0;
 		w -= PAGE_SIZE;
 	}
diff --git a/fs/nfsd/nfs3acl.c b/fs/nfsd/nfs3acl.c
index a596e9d..9cbc1a8 100644
--- a/fs/nfsd/nfs3acl.c
+++ b/fs/nfsd/nfs3acl.c
@@ -184,7 +184,7 @@ static int nfs3svc_encode_getaclres(struct svc_rqst *rqstp, __be32 *p,
 			(resp->mask & NFS_ACL)   ? resp->acl_access  : NULL,
 			(resp->mask & NFS_DFACL) ? resp->acl_default : NULL);
 		while (w > 0) {
-			if (!rqstp->rq_respages[rqstp->rq_resused++])
+			if (!*(rqstp->rq_next_page++))
 				return 0;
 			w -= PAGE_SIZE;
 		}
diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 97d90d1..1fc02df 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -460,7 +460,7 @@ nfsd3_proc_readdirplus(struct svc_rqst *rqstp, struct nfsd3_readdirargs *argp,
 	__be32	nfserr;
 	int	count = 0;
 	loff_t	offset;
-	int	i;
+	struct page **p;
 	caddr_t	page_addr = NULL;
 
 	dprintk("nfsd: READDIR+(3) %s %d bytes at %d\n",
@@ -484,8 +484,8 @@ nfsd3_proc_readdirplus(struct svc_rqst *rqstp, struct nfsd3_readdirargs *argp,
 				     &resp->common,
 				     nfs3svc_encode_entry_plus);
 	memcpy(resp->verf, argp->verf, 8);
-	for (i=1; i<rqstp->rq_resused ; i++) {
-		page_addr = page_address(rqstp->rq_respages[i]);
+	for (p = rqstp->rq_respages + 1; p < rqstp->rq_next_page; p++) {
+		page_addr = page_address(*p);
 
 		if (((caddr_t)resp->buffer >= page_addr) &&
 		    ((caddr_t)resp->buffer < page_addr + PAGE_SIZE)) {
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 2b8618d..324c0ba 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -325,7 +325,7 @@ nfs3svc_decode_readargs(struct svc_rqst *rqstp, __be32 *p,
 					struct nfsd3_readargs *args)
 {
 	unsigned int len;
-	int v,pn;
+	int v;
 	u32 max_blocksize = svc_max_payload(rqstp);
 
 	if (!(p = decode_fh(p, &args->fh)))
@@ -340,8 +340,9 @@ nfs3svc_decode_readargs(struct svc_rqst *rqstp, __be32 *p,
 	/* set up the kvec */
 	v=0;
 	while (len > 0) {
-		pn = rqstp->rq_resused++;
-		rqstp->rq_vec[v].iov_base = page_address(rqstp->rq_respages[pn]);
+		struct page *p = *(rqstp->rq_next_page++);
+
+		rqstp->rq_vec[v].iov_base = page_address(p);
 		rqstp->rq_vec[v].iov_len = len < PAGE_SIZE? len : PAGE_SIZE;
 		len -= rqstp->rq_vec[v].iov_len;
 		v++;
@@ -463,8 +464,7 @@ nfs3svc_decode_symlinkargs(struct svc_rqst *rqstp, __be32 *p,
 	len = ntohl(*p++);
 	if (len == 0 || len > NFS3_MAXPATHLEN || len >= PAGE_SIZE)
 		return 0;
-	args->tname = new =
-		page_address(rqstp->rq_respages[rqstp->rq_resused++]);
+	args->tname = new = page_address(*(rqstp->rq_next_page++));
 	args->tlen = len;
 	/* first copy and check from the first page */
 	old = (char*)p;
@@ -535,8 +535,7 @@ nfs3svc_decode_readlinkargs(struct svc_rqst *rqstp, __be32 *p,
 {
 	if (!(p = decode_fh(p, &args->fh)))
 		return 0;
-	args->buffer =
-		page_address(rqstp->rq_respages[rqstp->rq_resused++]);
+	args->buffer = page_address(*(rqstp->rq_next_page++));
 
 	return xdr_argsize_check(rqstp, p);
 }
@@ -567,8 +566,7 @@ nfs3svc_decode_readdirargs(struct svc_rqst *rqstp, __be32 *p,
 	if (args->count > PAGE_SIZE)
 		args->count = PAGE_SIZE;
 
-	args->buffer =
-		page_address(rqstp->rq_respages[rqstp->rq_resused++]);
+	args->buffer = page_address(*(rqstp->rq_next_page++));
 
 	return xdr_argsize_check(rqstp, p);
 }
@@ -577,7 +575,7 @@ int
 nfs3svc_decode_readdirplusargs(struct svc_rqst *rqstp, __be32 *p,
 					struct nfsd3_readdirargs *args)
 {
-	int len, pn;
+	int len;
 	u32 max_blocksize = svc_max_payload(rqstp);
 
 	if (!(p = decode_fh(p, &args->fh)))
@@ -592,9 +590,9 @@ nfs3svc_decode_readdirplusargs(struct svc_rqst *rqstp, __be32 *p,
 	args->count = len;
 
 	while (len > 0) {
-		pn = rqstp->rq_resused++;
+		struct page *p = *(rqstp->rq_next_page++);
 		if (!args->buffer)
-			args->buffer = page_address(rqstp->rq_respages[pn]);
+			args->buffer = page_address(p);
 		len -= PAGE_SIZE;
 	}
 
@@ -880,7 +878,7 @@ encode_entry(struct readdir_cd *ccd, const char *name, int namlen,
 		       					common);
 	__be32		*p = cd->buffer;
 	caddr_t		curr_page_addr = NULL;
-	int		pn;		/* current page number */
+	struct page **	page;
 	int		slen;		/* string (name) length */
 	int		elen;		/* estimated entry length in words */
 	int		num_entry_words = 0;	/* actual number of words */
@@ -917,8 +915,9 @@ encode_entry(struct readdir_cd *ccd, const char *name, int namlen,
 	}
 
 	/* determine which page in rq_respages[] we are currently filling */
-	for (pn=1; pn < cd->rqstp->rq_resused; pn++) {
-		curr_page_addr = page_address(cd->rqstp->rq_respages[pn]);
+	for (page = cd->rqstp->rq_respages + 1;
+				page < cd->rqstp->rq_next_page; page++) {
+		curr_page_addr = page_address(*page);
 
 		if (((caddr_t)cd->buffer >= curr_page_addr) &&
 		    ((caddr_t)cd->buffer <  curr_page_addr + PAGE_SIZE))
@@ -933,14 +932,14 @@ encode_entry(struct readdir_cd *ccd, const char *name, int namlen,
 		if (plus)
 			p = encode_entryplus_baggage(cd, p, name, namlen);
 		num_entry_words = p - cd->buffer;
-	} else if (cd->rqstp->rq_respages[pn+1] != NULL) {
+	} else if (*(page+1) != NULL) {
 		/* temporarily encode entry into next page, then move back to
 		 * current and next page in rq_respages[] */
 		__be32 *p1, *tmp;
 		int len1, len2;
 
 		/* grab next page for temporary storage of entry */
-		p1 = tmp = page_address(cd->rqstp->rq_respages[pn+1]);
+		p1 = tmp = page_address(*(page+1));
 
 		p1 = encode_entry_baggage(cd, p1, name, namlen, ino);
 
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index d7a3be5..0dc1158 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2906,7 +2906,8 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 		  struct nfsd4_read *read)
 {
 	u32 eof;
-	int v, pn;
+	int v;
+	struct page *page;
 	unsigned long maxcount; 
 	long len;
 	__be32 *p;
@@ -2925,16 +2926,15 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 	len = maxcount;
 	v = 0;
 	while (len > 0) {
-		pn = resp->rqstp->rq_resused;
-		if (!resp->rqstp->rq_respages[pn]) { /* ran out of pages */
+		page = *(resp->rqstp->rq_next_page);
+		if (!page) { /* ran out of pages */
 			maxcount -= len;
 			break;
 		}
-		resp->rqstp->rq_vec[v].iov_base =
-			page_address(resp->rqstp->rq_respages[pn]);
+		resp->rqstp->rq_vec[v].iov_base = page_address(page);
 		resp->rqstp->rq_vec[v].iov_len =
 			len < PAGE_SIZE ? len : PAGE_SIZE;
-		resp->rqstp->rq_resused++;
+		resp->rqstp->rq_next_page++;
 		v++;
 		len -= PAGE_SIZE;
 	}
@@ -2980,10 +2980,10 @@ nfsd4_encode_readlink(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd
 		return nfserr;
 	if (resp->xbuf->page_len)
 		return nfserr_resource;
-	if (!resp->rqstp->rq_respages[resp->rqstp->rq_resused])
+	if (!*resp->rqstp->rq_next_page)
 		return nfserr_resource;
 
-	page = page_address(resp->rqstp->rq_respages[resp->rqstp->rq_resused++]);
+	page = page_address(*(resp->rqstp->rq_next_page++));
 
 	maxcount = PAGE_SIZE;
 	RESERVE_SPACE(4);
@@ -3031,7 +3031,7 @@ nfsd4_encode_readdir(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
 		return nfserr;
 	if (resp->xbuf->page_len)
 		return nfserr_resource;
-	if (!resp->rqstp->rq_respages[resp->rqstp->rq_resused])
+	if (!*resp->rqstp->rq_next_page)
 		return nfserr_resource;
 
 	RESERVE_SPACE(NFS4_VERIFIER_SIZE);
@@ -3059,7 +3059,7 @@ nfsd4_encode_readdir(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
 		goto err_no_verf;
 	}
 
-	page = page_address(resp->rqstp->rq_respages[resp->rqstp->rq_resused++]);
+	page = page_address(*(resp->rqstp->rq_next_page++));
 	readdir->common.err = 0;
 	readdir->buflen = maxcount;
 	readdir->buffer = page;
@@ -3082,8 +3082,8 @@ nfsd4_encode_readdir(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
 	p = readdir->buffer;
 	*p++ = 0;	/* no more entries */
 	*p++ = htonl(readdir->common.err == nfserr_eof);
-	resp->xbuf->page_len = ((char*)p) - (char*)page_address(
-		resp->rqstp->rq_respages[resp->rqstp->rq_resused-1]);
+	resp->xbuf->page_len = ((char*)p) -
+		(char*)page_address(*(resp->rqstp->rq_next_page-1));
 
 	/* Use rest of head for padding and remaining ops: */
 	resp->xbuf->tail[0].iov_base = tailbase;
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index 65ec595..979b421 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -246,7 +246,7 @@ nfssvc_decode_readargs(struct svc_rqst *rqstp, __be32 *p,
 					struct nfsd_readargs *args)
 {
 	unsigned int len;
-	int v,pn;
+	int v;
 	if (!(p = decode_fh(p, &args->fh)))
 		return 0;
 
@@ -262,8 +262,9 @@ nfssvc_decode_readargs(struct svc_rqst *rqstp, __be32 *p,
 	 */
 	v=0;
 	while (len > 0) {
-		pn = rqstp->rq_resused++;
-		rqstp->rq_vec[v].iov_base = page_address(rqstp->rq_respages[pn]);
+		struct page *p = *(rqstp->rq_next_page++);
+
+		rqstp->rq_vec[v].iov_base = page_address(p);
 		rqstp->rq_vec[v].iov_len = len < PAGE_SIZE?len:PAGE_SIZE;
 		len -= rqstp->rq_vec[v].iov_len;
 		v++;
@@ -355,7 +356,7 @@ nfssvc_decode_readlinkargs(struct svc_rqst *rqstp, __be32 *p, struct nfsd_readli
 {
 	if (!(p = decode_fh(p, &args->fh)))
 		return 0;
-	args->buffer = page_address(rqstp->rq_respages[rqstp->rq_resused++]);
+	args->buffer = page_address(*(rqstp->rq_next_page++));
 
 	return xdr_argsize_check(rqstp, p);
 }
@@ -396,7 +397,7 @@ nfssvc_decode_readdirargs(struct svc_rqst *rqstp, __be32 *p,
 	if (args->count > PAGE_SIZE)
 		args->count = PAGE_SIZE;
 
-	args->buffer = page_address(rqstp->rq_respages[rqstp->rq_resused++]);
+	args->buffer = page_address(*(rqstp->rq_next_page++));
 
 	return xdr_argsize_check(rqstp, p);
 }
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index b31e46e..f0a6d88 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -886,7 +886,7 @@ nfsd_splice_actor(struct pipe_inode_info *pipe, struct pipe_buffer *buf,
 		  struct splice_desc *sd)
 {
 	struct svc_rqst *rqstp = sd->u.data;
-	struct page **pp = rqstp->rq_respages + rqstp->rq_resused;
+	struct page **pp = rqstp->rq_next_page;
 	struct page *page = buf->page;
 	size_t size;
 
@@ -894,17 +894,15 @@ nfsd_splice_actor(struct pipe_inode_info *pipe, struct pipe_buffer *buf,
 
 	if (rqstp->rq_res.page_len == 0) {
 		get_page(page);
-		put_page(*pp);
-		*pp = page;
-		rqstp->rq_resused++;
+		put_page(*rqstp->rq_next_page);
+		*(rqstp->rq_next_page++) = page;
 		rqstp->rq_res.page_base = buf->offset;
 		rqstp->rq_res.page_len = size;
 	} else if (page != pp[-1]) {
 		get_page(page);
-		if (*pp)
-			put_page(*pp);
-		*pp = page;
-		rqstp->rq_resused++;
+		if (*rqstp->rq_next_page)
+			put_page(*rqstp->rq_next_page);
+		*(rqstp->rq_next_page++) = page;
 		rqstp->rq_res.page_len += size;
 	} else
 		rqstp->rq_res.page_len += size;
@@ -936,8 +934,8 @@ nfsd_vfs_read(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 			.u.data		= rqstp,
 		};
 
-		WARN_ON_ONCE(rqstp->rq_resused != 1);
-		rqstp->rq_resused = 1;
+		WARN_ON_ONCE(rqstp->rq_next_page != rqstp->rq_respages + 1);
+		rqstp->rq_next_page = rqstp->rq_respages + 1;
 		host_err = splice_direct_to_actor(file, &sd, nfsd_direct_splice_actor);
 	} else {
 		oldfs = get_fs();
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index d83db80..676ddf5 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -243,6 +243,7 @@ struct svc_rqst {
 	struct page *		rq_pages[RPCSVC_MAXPAGES];
 	struct page *		*rq_respages;	/* points into rq_pages */
 	int			rq_resused;	/* number of pages used for result */
+	struct page *		*rq_next_page; /* next reply page to use */
 
 	struct kvec		rq_vec[RPCSVC_MAXPAGES]; /* generally useful.. */
 
@@ -338,9 +339,8 @@ xdr_ressize_check(struct svc_rqst *rqstp, __be32 *p)
 
 static inline void svc_free_res_pages(struct svc_rqst *rqstp)
 {
-	while (rqstp->rq_resused) {
-		struct page **pp = (rqstp->rq_respages +
-				    --rqstp->rq_resused);
+	while (rqstp->rq_next_page != rqstp->rq_respages) {
+		struct page **pp = --rqstp->rq_next_page;
 		if (*pp) {
 			put_page(*pp);
 			*pp = NULL;
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 529400d..c6abf1a 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1297,7 +1297,7 @@ svc_process(struct svc_rqst *rqstp)
 	 * Setup response xdr_buf.
 	 * Initially it has just one page
 	 */
-	rqstp->rq_resused = 1;
+	rqstp->rq_next_page = &rqstp->rq_respages[1];
 	resv->iov_base = page_address(rqstp->rq_respages[0]);
 	resv->iov_len = 0;
 	rqstp->rq_res.pages = rqstp->rq_respages + 1;
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index d8e5adf..dcd5669 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -601,6 +601,7 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
 		rqstp->rq_respages = rqstp->rq_pages + 1 +
 			DIV_ROUND_UP(rqstp->rq_arg.page_len, PAGE_SIZE);
 	}
+	rqstp->rq_next_page = rqstp->rq_respages+1;
 
 	if (serv->sv_stats)
 		serv->sv_stats->netudpcnt++;
@@ -1066,6 +1067,7 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 						svsk->sk_datalen + want);
 
 	rqstp->rq_respages = &rqstp->rq_pages[pnum];
+	rqstp->rq_next_page = rqstp->rq_respages + 1;
 
 	/* Now receive data */
 	len = svc_partial_recvfrom(rqstp, vec, pnum, want, base);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index 41cb63b..0ce7552 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -521,11 +521,11 @@ next_sge:
 		rqstp->rq_pages[ch_no] = NULL;
 
 	/*
-	 * Detach res pages. svc_release must see a resused count of
-	 * zero or it will attempt to put them.
+	 * Detach res pages. If svc_release sees any it will attempt to
+	 * put them.
 	 */
-	while (rqstp->rq_resused)
-		rqstp->rq_respages[--rqstp->rq_resused] = NULL;
+	while (rqstp->rq_next_page != rqstp->rq_respages)
+		*(--rqstp->rq_next_page) = NULL;
 
 	return err;
 }
@@ -550,7 +550,7 @@ static int rdma_read_complete(struct svc_rqst *rqstp,
 
 	/* rq_respages starts after the last arg page */
 	rqstp->rq_respages = &rqstp->rq_arg.pages[page_no];
-	rqstp->rq_resused = 0;
+	rqstp->rq_next_page = &rqstp->rq_arg.pages[page_no];
 
 	/* Rebuild rq_arg head and tail. */
 	rqstp->rq_arg.head[0] = head->arg.head[0];
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 42eb7ba..c1d124d 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -548,6 +548,7 @@ static int send_reply(struct svcxprt_rdma *rdma,
 	int sge_no;
 	int sge_bytes;
 	int page_no;
+	int pages;
 	int ret;
 
 	/* Post a recv buffer to handle another request. */
@@ -611,7 +612,8 @@ static int send_reply(struct svcxprt_rdma *rdma,
 	 * respages array. They are our pages until the I/O
 	 * completes.
 	 */
-	for (page_no = 0; page_no < rqstp->rq_resused; page_no++) {
+	pages = rqstp->rq_next_page - rqstp->rq_respages;
+	for (page_no = 0; page_no < pages; page_no++) {
 		ctxt->pages[page_no+1] = rqstp->rq_respages[page_no];
 		ctxt->count++;
 		rqstp->rq_respages[page_no] = NULL;
-- 
1.7.9.5

