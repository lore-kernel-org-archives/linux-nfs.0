From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 2 of 5 - Support zero-copy read for NFSD
Date: Thu, 07 Nov 2002 11:56:36 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E189ayK-0008Jq-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 189ayS-0001bt-00
	for <nfs@lists.sourceforge.net>; Wed, 06 Nov 2002 16:56:44 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.204] == wireless-204.wireless.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Thu, 7 Nov 2002 11:56:35 +1100
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


### Comments for ChangeSet

From: Hirokazu Takahashi <taka@valinux.co.jp>

This patch changes read and readdir in nfsd.

read:
  If the file supports readpage, we use it to collect pages out of the page
  cache and to attache them directly to the outgoing nfs reply.
  The reduces the number of copies by one, and if the filesystem/device 
  driver didn't copy the data, and if the network card can support not copying
  the data, then you get zero-copy reads.

readdir:
  A separate page is used for stoing the readdir response so that a fill
  PAGE_SIZE bytes of reply can be supported.





 ----------- Diffstat output ------------
 ./fs/nfsd/nfs3proc.c         |   27 ++++------------
 ./fs/nfsd/nfs3xdr.c          |   21 ++++++++++--
 ./fs/nfsd/nfsproc.c          |   11 +-----
 ./fs/nfsd/nfsxdr.c           |   13 ++++++-
 ./fs/nfsd/vfs.c              |   70 ++++++++++++++++++++++++++++++++++++++++---
 ./include/linux/nfsd/xdr.h   |    1 
 ./include/linux/nfsd/xdr3.h  |    1 
 ./include/linux/sunrpc/svc.h |   13 +++++++
 8 files changed, 119 insertions(+), 38 deletions(-)

--- ./include/linux/sunrpc/svc.h	2002/11/06 23:12:08	1.2
+++ ./include/linux/sunrpc/svc.h	2002/11/06 23:12:16	1.3
@@ -192,6 +192,19 @@ static void inline svc_pushback_allpages
 	}
 }
 
+static void inline svc_pushback_unused_pages(struct svc_rqst *rqstp)
+{
+        while (rqstp->rq_resused) {
+		if (rqstp->rq_respages[--rqstp->rq_resused] != NULL) {
+			rqstp->rq_argpages[rqstp->rq_arghi++] =
+				rqstp->rq_respages[rqstp->rq_resused];
+			rqstp->rq_respages[rqstp->rq_resused] = NULL;
+		}
+		if (rqstp->rq_res.pages == &rqstp->rq_respages[rqstp->rq_resused])
+			break;
+	}
+}
+
 static void inline svc_free_allpages(struct svc_rqst *rqstp)
 {
         while (rqstp->rq_resused) {
--- ./include/linux/nfsd/xdr.h	2002/11/06 23:12:14	1.1
+++ ./include/linux/nfsd/xdr.h	2002/11/06 23:12:16	1.2
@@ -77,6 +77,7 @@ struct nfsd_readdirargs {
 	struct svc_fh		fh;
 	__u32			cookie;
 	__u32			count;
+	u32 *			buffer;
 };
 
 struct nfsd_attrstat {
--- ./include/linux/nfsd/xdr3.h	2002/11/06 23:12:14	1.1
+++ ./include/linux/nfsd/xdr3.h	2002/11/06 23:12:16	1.2
@@ -96,6 +96,7 @@ struct nfsd3_readdirargs {
 	__u32			dircount;
 	__u32			count;
 	__u32 *			verf;
+	u32 *			buffer;
 };
 
 struct nfsd3_commitargs {
--- ./fs/nfsd/nfsxdr.c	2002/11/06 23:12:08	1.2
+++ ./fs/nfsd/nfsxdr.c	2002/11/06 23:12:16	1.3
@@ -337,6 +337,11 @@ nfssvc_decode_readdirargs(struct svc_rqs
 		return 0;
 	args->cookie = ntohl(*p++);
 	args->count  = ntohl(*p++);
+	if (args->count > PAGE_SIZE)
+		args->count = PAGE_SIZE;
+
+	svc_take_page(rqstp);
+	args->buffer = page_address(rqstp->rq_respages[rqstp->rq_resused-1]);
 
 	return xdr_argsize_check(rqstp, p);
 }
@@ -385,7 +390,6 @@ nfssvc_encode_readres(struct svc_rqst *r
 	xdr_ressize_check(rqstp, p);
 
 	/* now update rqstp->rq_res to reflect data aswell */
-	rqstp->rq_res.page_base = 0;
 	rqstp->rq_res.page_len = resp->count;
 	if (resp->count & 3) {
 		/* need to pad the tail */
@@ -404,11 +408,16 @@ int
 nfssvc_encode_readdirres(struct svc_rqst *rqstp, u32 *p,
 					struct nfsd_readdirres *resp)
 {
+	xdr_ressize_check(rqstp, p);
 	p = resp->buffer;
 	*p++ = 0;			/* no more entries */
 	*p++ = htonl((resp->common.err == nfserr_eof));
+	rqstp->rq_res.page_len = ((unsigned long)p & ~PAGE_MASK);
+	rqstp->rq_res.len =
+			rqstp->rq_res.head[0].iov_len+
+			rqstp->rq_res.page_len;
 
-	return xdr_ressize_check(rqstp, p);
+	return 1;
 }
 
 int
--- ./fs/nfsd/vfs.c	2002/11/06 23:12:14	1.1
+++ ./fs/nfsd/vfs.c	2002/11/06 23:12:16	1.2
@@ -13,6 +13,7 @@
  * dentry, don't worry--they have been taken care of.
  *
  * Copyright (C) 1995-1999 Olaf Kirch <okir@monad.swb.de>
+ * Zerocpy NFS support (C) 2002 Hirokazu Takahashi <taka@valinux.co.jp>
  */
 
 #include <linux/config.h>
@@ -28,6 +29,7 @@
 #include <linux/net.h>
 #include <linux/unistd.h>
 #include <linux/slab.h>
+#include <linux/pagemap.h>
 #include <linux/in.h>
 #include <linux/module.h>
 #include <linux/namei.h>
@@ -571,6 +573,61 @@ found:
 }
 
 /*
+ * Grab and keep cached pages assosiated with a file in the svc_rqst
+ * so that they can be passed to the netowork sendmsg/sendpage routines
+ * directrly. They will be released after the sending has completed.
+ */
+static int
+nfsd_read_actor(read_descriptor_t *desc, struct page *page, unsigned long offset , unsigned long size)
+{
+	unsigned long count = desc->count;
+	struct svc_rqst *rqstp = (struct svc_rqst *)desc->buf;
+
+	if (size > count)
+		size = count;
+
+	if (rqstp->rq_res.page_len == 0) {
+		get_page(page);
+		rqstp->rq_respages[rqstp->rq_resused++] = page;
+		rqstp->rq_res.page_base = offset;
+		rqstp->rq_res.page_len = size;
+	} else if (page != rqstp->rq_respages[rqstp->rq_resused-1]) {
+		get_page(page);
+		rqstp->rq_respages[rqstp->rq_resused++] = page;
+		rqstp->rq_res.page_len += size;
+	} else {
+		rqstp->rq_res.page_len += size;
+	}
+
+	desc->count = count - size;
+	desc->written += size;
+	return size;
+}
+
+static inline ssize_t
+nfsd_getpages(struct file *filp, struct svc_rqst *rqstp, unsigned long count)
+{
+	read_descriptor_t desc;
+	ssize_t	retval;
+
+	if (!count)
+		return 0;
+
+	svc_pushback_unused_pages(rqstp);
+
+	desc.written = 0;
+	desc.count = count;
+	desc.buf = (char *)rqstp;
+	desc.error = 0;
+	do_generic_file_read(filp, &filp->f_pos, &desc, nfsd_read_actor);
+
+	retval = desc.written;
+	if (!retval)
+		retval = desc.error;
+	return retval;
+}
+
+/*
  * Read data from a file. count must contain the requested read count
  * on entry. On return, *count contains the number of bytes actually read.
  * N.B. After this call fhp needs an fh_put
@@ -601,10 +658,15 @@ nfsd_read(struct svc_rqst *rqstp, struct
 	if (ra)
 		file.f_ra = ra->p_ra;
 
-	oldfs = get_fs();
-	set_fs(KERNEL_DS);
-	err = vfs_readv(&file, vec, vlen, *count, &offset);
-	set_fs(oldfs);
+	if (inode->i_mapping->a_ops->readpage) {
+		file.f_pos = offset;
+		err = nfsd_getpages(&file, rqstp, *count);
+	} else {
+		oldfs = get_fs();
+		set_fs(KERNEL_DS);
+		err = vfs_readv(&file, vec, vlen, *count, &offset);
+		set_fs(oldfs);
+	}
 
 	/* Write back readahead params */
 	if (ra)
--- ./fs/nfsd/nfs3xdr.c	2002/11/06 23:12:08	1.2
+++ ./fs/nfsd/nfs3xdr.c	2002/11/06 23:12:16	1.3
@@ -490,6 +490,12 @@ nfs3svc_decode_readdirargs(struct svc_rq
 	args->dircount = ~0;
 	args->count  = ntohl(*p++);
 
+	if (args->count > PAGE_SIZE)
+		args->count = PAGE_SIZE;
+
+	svc_take_page(rqstp);
+	args->buffer = page_address(rqstp->rq_respages[rqstp->rq_resused-1]);
+
 	return xdr_argsize_check(rqstp, p);
 }
 
@@ -504,6 +510,9 @@ nfs3svc_decode_readdirplusargs(struct sv
 	args->dircount = ntohl(*p++);
 	args->count    = ntohl(*p++);
 
+	svc_take_page(rqstp);
+	args->buffer = page_address(rqstp->rq_respages[rqstp->rq_resused-1]);
+
 	return xdr_argsize_check(rqstp, p);
 }
 
@@ -600,7 +609,6 @@ nfs3svc_encode_readres(struct svc_rqst *
 		*p++ = htonl(resp->count);	/* xdr opaque count */
 		xdr_ressize_check(rqstp, p);
 		/* now update rqstp->rq_res to reflect data aswell */
-		rqstp->rq_res.page_base = 0;
 		rqstp->rq_res.page_len = resp->count;
 		if (resp->count & 3) {
 			/* need to pad the tail */
@@ -676,12 +684,17 @@ nfs3svc_encode_readdirres(struct svc_rqs
 	if (resp->status == 0) {
 		/* stupid readdir cookie */
 		memcpy(p, resp->verf, 8); p += 2;
+		xdr_ressize_check(rqstp, p);
 		p = resp->buffer;
 		*p++ = 0;		/* no more entries */
 		*p++ = htonl(resp->common.err == nfserr_eof);
-	}
-
-	return xdr_ressize_check(rqstp, p);
+		rqstp->rq_res.page_len = ((unsigned long)p & ~PAGE_MASK);
+		rqstp->rq_res.len =
+			rqstp->rq_res.head[0].iov_len+
+			rqstp->rq_res.page_len;
+		return 1;
+	} else
+		return xdr_ressize_check(rqstp, p);
 }
 
 /*
--- ./fs/nfsd/nfsproc.c	2002/11/06 23:12:14	1.1
+++ ./fs/nfsd/nfsproc.c	2002/11/06 23:12:16	1.2
@@ -467,7 +467,6 @@ static int
 nfsd_proc_readdir(struct svc_rqst *rqstp, struct nfsd_readdirargs *argp,
 					  struct nfsd_readdirres  *resp)
 {
-	u32 *		buffer;
 	int		nfserr, count;
 	loff_t		offset;
 
@@ -475,19 +474,15 @@ nfsd_proc_readdir(struct svc_rqst *rqstp
 		SVCFH_fmt(&argp->fh),		
 		argp->count, argp->cookie);
 
-	/* Reserve buffer space for status */
-	svcbuf_reserve(&rqstp->rq_res, &buffer, &count, 1);
-
 	/* Shrink to the client read size */
-	if (count > (argp->count >> 2))
-		count = argp->count >> 2;
+	count = (argp->count >> 2) - 2;
 
 	/* Make sure we've room for the NULL ptr & eof flag */
 	count -= 2;
 	if (count < 0)
 		count = 0;
 
-	resp->buffer = buffer;
+	resp->buffer = argp->buffer;
 	resp->offset = NULL;
 	resp->buflen = count;
 	resp->common.err = nfs_ok;
@@ -496,7 +491,7 @@ nfsd_proc_readdir(struct svc_rqst *rqstp
 	nfserr = nfsd_readdir(rqstp, &argp->fh, &offset, 
 			      &resp->common, nfssvc_encode_entry);
 
-	resp->count = resp->buffer - buffer;
+	resp->count = resp->buffer - argp->buffer;
 	if (resp->offset)
 		*resp->offset = (u32)offset;
 
--- ./fs/nfsd/nfs3proc.c	2002/11/06 23:12:14	1.1
+++ ./fs/nfsd/nfs3proc.c	2002/11/06 23:12:16	1.2
@@ -436,35 +436,28 @@ static int
 nfsd3_proc_readdir(struct svc_rqst *rqstp, struct nfsd3_readdirargs *argp,
 					   struct nfsd3_readdirres  *resp)
 {
-	u32 *		buffer;
 	int		nfserr, count;
-	unsigned int	want;
 
 	dprintk("nfsd: READDIR(3)  %s %d bytes at %d\n",
 				SVCFH_fmt(&argp->fh),
 				argp->count, (u32) argp->cookie);
 
-	/* Reserve buffer space for status, attributes and verifier */
-	svcbuf_reserve(&rqstp->rq_res, &buffer, &count,
-				1 + NFS3_POST_OP_ATTR_WORDS + 2);
-
 	/* Make sure we've room for the NULL ptr & eof flag, and shrink to
 	 * client read size */
-	if ((count -= 2) > (want = (argp->count >> 2) - 2))
-		count = want;
+	count = (argp->count >> 2) - 2;
 
 	/* Read directory and encode entries on the fly */
 	fh_copy(&resp->fh, &argp->fh);
 
 	resp->buflen = count;
 	resp->common.err = nfs_ok;
-	resp->buffer = buffer;
+	resp->buffer = argp->buffer;
 	resp->offset = NULL;
 	resp->rqstp = rqstp;
 	nfserr = nfsd_readdir(rqstp, &resp->fh, (loff_t*) &argp->cookie, 
 					&resp->common, nfs3svc_encode_entry);
 	memcpy(resp->verf, argp->verf, 8);
-	resp->count = resp->buffer - buffer;
+	resp->count = resp->buffer - argp->buffer;
 	if (resp->offset)
 		xdr_encode_hyper(resp->offset, argp->cookie);
 
@@ -479,35 +472,29 @@ static int
 nfsd3_proc_readdirplus(struct svc_rqst *rqstp, struct nfsd3_readdirargs *argp,
 					       struct nfsd3_readdirres  *resp)
 {
-	u32 *	buffer;
-	int	nfserr, count, want;
+	int	nfserr, count;
 	loff_t	offset;
 
 	dprintk("nfsd: READDIR+(3) %s %d bytes at %d\n",
 				SVCFH_fmt(&argp->fh),
 				argp->count, (u32) argp->cookie);
 
-	/* Reserve buffer space for status, attributes and verifier */
-	svcbuf_reserve(&rqstp->rq_res, &buffer, &count,
-				1 + NFS3_POST_OP_ATTR_WORDS + 2);
-
 	/* Make sure we've room for the NULL ptr & eof flag, and shrink to
 	 * client read size */
-	if ((count -= 2) > (want = argp->count >> 2))
-		count = want;
+	count = (argp->count >> 2) - 2;
 
 	/* Read directory and encode entries on the fly */
 	fh_copy(&resp->fh, &argp->fh);
 
 	resp->buflen = count;
 	resp->common.err = nfs_ok;
-	resp->buffer = buffer;
+	resp->buffer = argp->buffer;
 	resp->rqstp = rqstp;
 	offset = argp->cookie;
 	nfserr = nfsd_readdir(rqstp, &resp->fh, &offset, 
 			      &resp->common, nfs3svc_encode_entry_plus);
 	memcpy(resp->verf, argp->verf, 8);
-	resp->count = resp->buffer - buffer;
+	resp->count = resp->buffer - argp->buffer;
 	if (resp->offset)
 		xdr_encode_hyper(resp->offset, offset);
 


-------------------------------------------------------
This sf.net email is sponsored by: See the NEW Palm 
Tungsten T handheld. Power & Color in a compact size!
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
