From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Re: [PATCH] zerocopy NFS for 2.5.43
Date: Fri, 25 Oct 2002 22:41:04 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15801.15328.866301.720864@notabene.cse.unsw.edu.au>
References: <15786.23306.84580.323313@notabene.cse.unsw.edu.au>
	<20021018.221103.35656279.taka@valinux.co.jp>
	<15797.63730.223181.75888@notabene.cse.unsw.edu.au>
	<20021025.185234.08315285.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 185Ale-0002g9-00
	for <nfs@lists.sourceforge.net>; Fri, 25 Oct 2002 13:09:14 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <taka@valinux.co.jp>) (for <nfs@lists.sourceforge.net>) By tone
	With Smtp ; Sat, 26 Oct 2002 06:09:01 +1000
To: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: message from Hirokazu Takahashi on Friday October 25
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

On Friday October 25, taka@valinux.co.jp wrote:
> Hello,
> 
> > I have been thinking some more about this, trying to understand the
> > big picture, and I'm afraid that I think I want some more changes.
> > 
> > In particular, I think it would be good to use 'struct xdr_buf' from
> > sunrpc/xdr.h instead of svc_buf.  This is what the nfs client uses and
> > we could share some of the infrastructure.
> 
> I just realized it would be hard to use the xdr_buf as it couldn't
> handle data in a socket buffer. Each socket burfer consists of
> some non-page data and some pages and each of them might have its
> own offset and length.

You would only want this for single-copy write request  - right?

I think we have treat them as a special case and pass the skbuf all
the way up to nfsd in that case.
You would only want to try this if:
   The NIC had verified the checksum
   The packets was some minimum size (1K? 1 PAGE ??)
   We were using AUTH_UNIX, nothing more interesting like crypto
     security
   The first fragment were some minimum size (size of a write without
   the data).

I would make a special 'fast-path' for that case which didn't copy any
data but passed a skbuf up, and code in nfs*xdr.c would convert that
into an iovec[];

I am working on a patch which changes rpcsvc to use xdr_buf.  Some of
it works.  Some doesn't.  I include it below for your reference I
repeat: it doesn't work yet.  
Once it is done, adding the rest of zero-copy should be fairly easy.

> 
> > I'm not certain about receiving write requests.
> > I imagine that it might work to:
> >   1/ call xdr_partial_copy_from_skb to just copy the first 1K from the
> >     skb into the head iovec, and hold onto the skbuf (like we
> >     currently do).
> 
> And I came up with another idea that kNFSd could handles TCP data
> in a socket buffer directly without copy if we can enhancemence the
> tcp_read_sock() not to release it while kNFSd is using it.
> kNFSd would handle TCP data as if it were a UDP datagram.
> The differences are kNFSd may grab some TCP socket buffers at once
> and the buffers may be shared to other kNFSd's.

That might work... though TCP doesn't have the same concept of a
'packet' that udp does.  You might endup with a socket buffer that had
all of one request and part of the next... still I'm sure it is
possible.

NeilBrown


-----incomplete, buggy, don't-use-it patch starts here----
--- ./fs/nfsd/nfssvc.c	2002/10/21 03:23:44	1.2
+++ ./fs/nfsd/nfssvc.c	2002/10/25 05:08:01
@@ -277,7 +277,8 @@ nfsd_dispatch(struct svc_rqst *rqstp, u3
 
 	/* Decode arguments */
 	xdr = proc->pc_decode;
-	if (xdr && !xdr(rqstp, rqstp->rq_argbuf.buf, rqstp->rq_argp)) {
+	if (xdr && !xdr(rqstp, (u32*)rqstp->rq_arg.head[0].iov_base,
+			rqstp->rq_argp)) {
 		dprintk("nfsd: failed to decode arguments!\n");
 		nfsd_cache_update(rqstp, RC_NOCACHE, NULL);
 		*statp = rpc_garbage_args;
@@ -293,14 +294,15 @@ nfsd_dispatch(struct svc_rqst *rqstp, u3
 	}
 		
 	if (rqstp->rq_proc != 0)
-		svc_putu32(&rqstp->rq_resbuf, nfserr);
+		svc_putu32(&rqstp->rq_res.head[0], nfserr);
 
 	/* Encode result.
 	 * For NFSv2, additional info is never returned in case of an error.
 	 */
 	if (!(nfserr && rqstp->rq_vers == 2)) {
 		xdr = proc->pc_encode;
-		if (xdr && !xdr(rqstp, rqstp->rq_resbuf.buf, rqstp->rq_resp)) {
+		if (xdr && !xdr(rqstp, (u32*)rqstp->rq_res.head[0].iov_base,
+				rqstp->rq_resp)) {
 			/* Failed to encode result. Release cache entry */
 			dprintk("nfsd: failed to encode result!\n");
 			nfsd_cache_update(rqstp, RC_NOCACHE, NULL);
--- ./fs/nfsd/vfs.c	2002/10/24 01:35:37	1.1
+++ ./fs/nfsd/vfs.c	2002/10/24 04:13:31
@@ -571,13 +571,35 @@ found:
 }
 
 /*
+ * reduce iovec:
+ * Reduce the effective size of the passed iovec to
+ * match the count
+ */
+static void reduce_iovec(struct iovec *vec, int *vlenp, int count)
+{
+	int vlen = *vlenp;
+	int i;
+
+	i = 0;
+	while (i < vlen && count > vec->iov_len) {
+		count -= vec->iov_len;
+		i++;
+	}
+	if (i >= vlen)
+		return; /* ERROR??? */
+	vec->iov_len -= count;
+	if (count) i++;
+	*vlenp = i;
+}
+
+/*
  * Read data from a file. count must contain the requested read count
  * on entry. On return, *count contains the number of bytes actually read.
  * N.B. After this call fhp needs an fh_put
  */
 int
 nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp, loff_t offset,
-          char *buf, unsigned long *count)
+          struct iovec *vec, int vlen, unsigned long *count)
 {
 	struct raparms	*ra;
 	mm_segment_t	oldfs;
@@ -601,9 +623,10 @@ nfsd_read(struct svc_rqst *rqstp, struct
 	if (ra)
 		file.f_ra = ra->p_ra;
 
+	reduce_iovec(vec, &vlen, *count);
 	oldfs = get_fs();
 	set_fs(KERNEL_DS);
-	err = vfs_read(&file, buf, *count, &offset);
+	err = vfs_readv(&file, vec, vlen, *count, &offset);
 	set_fs(oldfs);
 
 	/* Write back readahead params */
@@ -629,7 +652,8 @@ out:
  */
 int
 nfsd_write(struct svc_rqst *rqstp, struct svc_fh *fhp, loff_t offset,
-				char *buf, unsigned long cnt, int *stablep)
+				struct iovec *vec, int vlen,
+	   			unsigned long cnt, int *stablep)
 {
 	struct svc_export	*exp;
 	struct file		file;
@@ -675,9 +699,10 @@ nfsd_write(struct svc_rqst *rqstp, struc
 	if (stable && !EX_WGATHER(exp))
 		file.f_flags |= O_SYNC;
 
+	reduce_iovec(vec, &vlen, cnt);
 	/* Write the data. */
 	oldfs = get_fs(); set_fs(KERNEL_DS);
-	err = vfs_write(&file, buf, cnt, &offset);
+	err = vfs_writev(&file, vec, vlen, cnt, &offset);
 	if (err >= 0)
 		nfsdstats.io_write += cnt;
 	set_fs(oldfs);
--- ./fs/nfsd/nfsctl.c	2002/10/21 06:35:17	1.2
+++ ./fs/nfsd/nfsctl.c	2002/10/24 11:22:53
@@ -130,13 +130,12 @@ static int exports_open(struct inode *in
 	char *namebuf = kmalloc(PAGE_SIZE, GFP_KERNEL);
 	if (namebuf == NULL)
 		return -ENOMEM;
-	else
-		((struct seq_file *)file->private_data)->private = namebuf;
 
 	res = seq_open(file, &nfs_exports_op);
-	if (!res)
+	if (res)
 		kfree(namebuf);
-
+	else
+		((struct seq_file *)file->private_data)->private = namebuf;
 	return res;
 }
 static int exports_release(struct inode *inode, struct file *file)
--- ./fs/nfsd/nfsxdr.c	2002/10/24 01:06:36	1.1
+++ ./fs/nfsd/nfsxdr.c	2002/10/25 05:31:51
@@ -14,6 +14,7 @@
 #include <linux/sunrpc/svc.h>
 #include <linux/nfsd/nfsd.h>
 #include <linux/nfsd/xdr.h>
+#include <linux/mm.h>
 
 #define NFSDDBG_FACILITY		NFSDDBG_XDR
 
@@ -176,27 +177,6 @@ encode_fattr(struct svc_rqst *rqstp, u32
 	return p;
 }
 
-/*
- * Check buffer bounds after decoding arguments
- */
-static inline int
-xdr_argsize_check(struct svc_rqst *rqstp, u32 *p)
-{
-	struct svc_buf	*buf = &rqstp->rq_argbuf;
-
-	return p - buf->base <= buf->buflen;
-}
-
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
 
 /*
  * XDR decode functions
@@ -241,13 +221,29 @@ int
 nfssvc_decode_readargs(struct svc_rqst *rqstp, u32 *p,
 					struct nfsd_readargs *args)
 {
+	int len;
+	int v,pn;
 	if (!(p = decode_fh(p, &args->fh)))
 		return 0;
 
 	args->offset    = ntohl(*p++);
-	args->count     = ntohl(*p++);
-	args->totalsize = ntohl(*p++);
+	len = args->count     = ntohl(*p++);
+	p++; /* totalcount - unused */
 
+	/* FIXME range check ->count */
+	/* set up somewhere to store response.
+	 * We take pages, put them on reslist and include in iovec
+	 */
+	v=0; 
+	while (len > 0) {
+		pn=rqstp->rq_resused;
+		take_page(rqstp);
+		args->vec[v].iov_base = page_address(rqstp->rq_respages[pn]);
+		args->vec[v].iov_len = PAGE_SIZE;
+		v++;
+		len -= PAGE_SIZE;
+	}
+	args->vlen = v;
 	return xdr_argsize_check(rqstp, p);
 }
 
@@ -255,17 +251,27 @@ int
 nfssvc_decode_writeargs(struct svc_rqst *rqstp, u32 *p,
 					struct nfsd_writeargs *args)
 {
+	int len;
+	int v;
 	if (!(p = decode_fh(p, &args->fh)))
 		return 0;
 
 	p++;				/* beginoffset */
 	args->offset = ntohl(*p++);	/* offset */
 	p++;				/* totalcount */
-	args->len = ntohl(*p++);
-	args->data = (char *) p;
-	p += XDR_QUADLEN(args->len);
-
-	return xdr_argsize_check(rqstp, p);
+	len = args->len = ntohl(*p++);
+	args->vec[0].iov_base = (void*)p;
+	args->vec[0].iov_len = rqstp->rq_arg.head[0].iov_len -
+				(((void*)p) - rqstp->rq_arg.head[0].iov_base);
+	v = 0;
+	while (len > args->vec[v].iov_len) {
+		len -= args->vec[v].iov_len;
+		v++;
+		args->vec[v].iov_base = page_address(rqstp->rq_argpages[v]);
+		args->vec[v].iov_len = PAGE_SIZE;
+	}
+	args->vlen = v+1;
+	return 1; /* FIXME */
 }
 
 int
@@ -371,9 +377,22 @@ nfssvc_encode_readres(struct svc_rqst *r
 {
 	p = encode_fattr(rqstp, p, &resp->fh);
 	*p++ = htonl(resp->count);
-	p += XDR_QUADLEN(resp->count);
+	xdr_ressize_check(rqstp, p);
 
-	return xdr_ressize_check(rqstp, p);
+	/* now update rqstp->rq_res to reflect data aswell */
+	rqstp->rq_res.page_base = 0;
+	rqstp->rq_res.page_len = resp->count;
+	if (resp->count & 3) {
+		/* need to pad with tail */
+		rqstp->rq_res.tail[0].iov_base = p;
+		*p = 0;
+		rqstp->rq_res.tail[0].iov_len = 4 - (resp->count&3);
+	}
+	rqstp->rq_res.len = 
+		rqstp->rq_res.head[0].iov_len+
+		rqstp->rq_res.page_len+
+		rqstp->rq_res.tail[0].iov_len;
+	return 1;
 }
 
 int
--- ./fs/nfsd/nfs3xdr.c	2002/10/24 01:07:00	1.1
+++ ./fs/nfsd/nfs3xdr.c	2002/10/25 05:14:26
@@ -269,27 +269,6 @@ encode_wcc_data(struct svc_rqst *rqstp, 
 	return encode_post_op_attr(rqstp, p, fhp);
 }
 
-/*
- * Check buffer bounds after decoding arguments
- */
-static inline int
-xdr_argsize_check(struct svc_rqst *rqstp, u32 *p)
-{
-	struct svc_buf	*buf = &rqstp->rq_argbuf;
-
-	return p - buf->base <= buf->buflen;
-}
-
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
 
 /*
  * XDR decode functions
--- ./fs/nfsd/nfscache.c	2002/10/24 03:37:10	1.1
+++ ./fs/nfsd/nfscache.c	2002/10/24 04:30:23
@@ -41,7 +41,7 @@ static struct svc_cacherep *	lru_tail;
 static struct svc_cacherep *	nfscache;
 static int			cache_disabled = 1;
 
-static int	nfsd_cache_append(struct svc_rqst *rqstp, struct svc_buf *data);
+static int	nfsd_cache_append(struct svc_rqst *rqstp, struct iovec *vec);
 
 /* 
  * locking for the reply cache:
@@ -107,7 +107,7 @@ nfsd_cache_shutdown(void)
 
 	for (rp = lru_head; rp; rp = rp->c_lru_next) {
 		if (rp->c_state == RC_DONE && rp->c_type == RC_REPLBUFF)
-			kfree(rp->c_replbuf.buf);
+			kfree(rp->c_replvec.iov_base);
 	}
 
 	cache_disabled = 1;
@@ -242,8 +242,8 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
 
 	/* release any buffer */
 	if (rp->c_type == RC_REPLBUFF) {
-		kfree(rp->c_replbuf.buf);
-		rp->c_replbuf.buf = NULL;
+		kfree(rp->c_replvec.iov_base);
+		rp->c_replvec.iov_base = NULL;
 	}
 	rp->c_type = RC_NOCACHE;
  out:
@@ -272,11 +272,11 @@ found_entry:
 	case RC_NOCACHE:
 		break;
 	case RC_REPLSTAT:
-		svc_putu32(&rqstp->rq_resbuf, rp->c_replstat);
+		svc_putu32(&rqstp->rq_res.head[0], rp->c_replstat);
 		rtn = RC_REPLY;
 		break;
 	case RC_REPLBUFF:
-		if (!nfsd_cache_append(rqstp, &rp->c_replbuf))
+		if (!nfsd_cache_append(rqstp, &rp->c_replvec))
 			goto out;	/* should not happen */
 		rtn = RC_REPLY;
 		break;
@@ -308,13 +308,14 @@ void
 nfsd_cache_update(struct svc_rqst *rqstp, int cachetype, u32 *statp)
 {
 	struct svc_cacherep *rp;
-	struct svc_buf	*resp = &rqstp->rq_resbuf, *cachp;
+	struct iovec	*resv = &rqstp->rq_res.head[0], *cachv;
 	int		len;
 
 	if (!(rp = rqstp->rq_cacherep) || cache_disabled)
 		return;
 
-	len = resp->len - (statp - resp->base);
+	len = resv->iov_len - ((char*)statp - (char*)resv->iov_base);
+	len >>= 2;
 	
 	/* Don't cache excessive amounts of data and XDR failures */
 	if (!statp || len > (256 >> 2)) {
@@ -329,16 +330,16 @@ nfsd_cache_update(struct svc_rqst *rqstp
 		rp->c_replstat = *statp;
 		break;
 	case RC_REPLBUFF:
-		cachp = &rp->c_replbuf;
-		cachp->buf = (u32 *) kmalloc(len << 2, GFP_KERNEL);
-		if (!cachp->buf) {
+		cachv = &rp->c_replvec;
+		cachv->iov_base = kmalloc(len << 2, GFP_KERNEL);
+		if (!cachv->iov_base) {
 			spin_lock(&cache_lock);
 			rp->c_state = RC_UNUSED;
 			spin_unlock(&cache_lock);
 			return;
 		}
-		cachp->len = len;
-		memcpy(cachp->buf, statp, len << 2);
+		cachv->iov_len = len << 2;
+		memcpy(cachv->iov_base, statp, len << 2);
 		break;
 	}
 	spin_lock(&cache_lock);
@@ -353,19 +354,20 @@ nfsd_cache_update(struct svc_rqst *rqstp
 
 /*
  * Copy cached reply to current reply buffer. Should always fit.
+ * FIXME as reply is in a page, we should just attach the page, and
+ * keep a refcount....
  */
 static int
-nfsd_cache_append(struct svc_rqst *rqstp, struct svc_buf *data)
+nfsd_cache_append(struct svc_rqst *rqstp, struct iovec *data)
 {
-	struct svc_buf	*resp = &rqstp->rq_resbuf;
+	struct iovec	*vec = &rqstp->rq_res.head[0];
 
-	if (resp->len + data->len > resp->buflen) {
+	if (vec->iov_len + data->iov_len > PAGE_SIZE) {
 		printk(KERN_WARNING "nfsd: cached reply too large (%d).\n",
-				data->len);
+				data->iov_len);
 		return 0;
 	}
-	memcpy(resp->buf, data->buf, data->len << 2);
-	resp->buf += data->len;
-	resp->len += data->len;
+	memcpy((char*)vec->iov_base + vec->iov_len, data->iov_base, data->iov_len);
+	vec->iov_len += data->iov_len;
 	return 1;
 }
--- ./fs/nfsd/nfsproc.c	2002/10/24 02:23:57	1.1
+++ ./fs/nfsd/nfsproc.c	2002/10/25 05:32:04
@@ -30,11 +30,11 @@ typedef struct svc_buf	svc_buf;
 #define NFSDDBG_FACILITY		NFSDDBG_PROC
 
 
-static void
-svcbuf_reserve(struct svc_buf *buf, u32 **ptr, int *len, int nr)
+static inline void
+svcbuf_reserve(struct xdr_buf *buf, u32 **ptr, int *len, int nr)
 {
-	*ptr = buf->buf + nr;
-	*len = buf->buflen - buf->len - nr;
+	*ptr = (u32*)(buf->head[0].iov_base+buf->head[0].iov_len) + nr;
+	*len = ((PAGE_SIZE-buf->head[0].iov_len)>>2) - nr;
 }
 
 static int
@@ -109,7 +109,7 @@ nfsd_proc_readlink(struct svc_rqst *rqst
 	dprintk("nfsd: READLINK %s\n", SVCFH_fmt(&argp->fh));
 
 	/* Reserve room for status and path length */
-	svcbuf_reserve(&rqstp->rq_resbuf, &path, &dummy, 2);
+	svcbuf_reserve(&rqstp->rq_res, &path, &dummy, 2);
 
 	/* Read the symlink. */
 	resp->len = NFS_MAXPATHLEN;
@@ -127,8 +127,7 @@ static int
 nfsd_proc_read(struct svc_rqst *rqstp, struct nfsd_readargs *argp,
 				       struct nfsd_readres  *resp)
 {
-	u32 *	buffer;
-	int	nfserr, avail;
+	int	nfserr;
 
 	dprintk("nfsd: READ    %s %d bytes at %d\n",
 		SVCFH_fmt(&argp->fh),
@@ -137,22 +136,21 @@ nfsd_proc_read(struct svc_rqst *rqstp, s
 	/* Obtain buffer pointer for payload. 19 is 1 word for
 	 * status, 17 words for fattr, and 1 word for the byte count.
 	 */
-	svcbuf_reserve(&rqstp->rq_resbuf, &buffer, &avail, 19);
 
-	if ((avail << 2) < argp->count) {
+	if ((32768/*FIXME*/) < argp->count) {
 		printk(KERN_NOTICE
 			"oversized read request from %08x:%d (%d bytes)\n",
 				ntohl(rqstp->rq_addr.sin_addr.s_addr),
 				ntohs(rqstp->rq_addr.sin_port),
 				argp->count);
-		argp->count = avail << 2;
+		argp->count = 32768;
 	}
 	svc_reserve(rqstp, (19<<2) + argp->count + 4);
 
 	resp->count = argp->count;
 	nfserr = nfsd_read(rqstp, fh_copy(&resp->fh, &argp->fh),
 				  argp->offset,
-				  (char *) buffer,
+			   	  argp->vec, argp->vlen,
 				  &resp->count);
 
 	return nfserr;
@@ -175,7 +173,7 @@ nfsd_proc_write(struct svc_rqst *rqstp, 
 
 	nfserr = nfsd_write(rqstp, fh_copy(&resp->fh, &argp->fh),
 				   argp->offset,
-				   argp->data,
+				   argp->vec, argp->vlen,
 				   argp->len,
 				   &stable);
 	return nfserr;
@@ -477,7 +475,7 @@ nfsd_proc_readdir(struct svc_rqst *rqstp
 		argp->count, argp->cookie);
 
 	/* Reserve buffer space for status */
-	svcbuf_reserve(&rqstp->rq_resbuf, &buffer, &count, 1);
+	svcbuf_reserve(&rqstp->rq_res, &buffer, &count, 1);
 
 	/* Shrink to the client read size */
 	if (count > (argp->count >> 2))
--- ./fs/nfsd/nfs3proc.c	2002/10/24 04:37:41	1.1
+++ ./fs/nfsd/nfs3proc.c	2002/10/25 05:34:44
@@ -43,11 +43,11 @@ static int	nfs3_ftypes[] = {
 /*
  * Reserve room in the send buffer
  */
-static void
-svcbuf_reserve(struct svc_buf *buf, u32 **ptr, int *len, int nr)
+static inline void
+svcbuf_reserve(struct xdr_buf *buf, u32 **ptr, int *len, int nr)
 {
-	*ptr = buf->buf + nr;
-	*len = buf->buflen - buf->len - nr;
+	*ptr = (u32*)(buf->head[0].iov_base+buf->head[0].iov_len) + nr;
+	*len = ((PAGE_SIZE-buf->head[0].iov_len)>>2) - nr;
 }
 
 /*
@@ -150,7 +150,7 @@ nfsd3_proc_readlink(struct svc_rqst *rqs
 	dprintk("nfsd: READLINK(3) %s\n", SVCFH_fmt(&argp->fh));
 
 	/* Reserve room for status, post_op_attr, and path length */
-	svcbuf_reserve(&rqstp->rq_resbuf, &path, &dummy,
+	svcbuf_reserve(&rqstp->rq_res, &path, &dummy,
 				1 + NFS3_POST_OP_ATTR_WORDS + 1);
 
 	/* Read the symlink. */
@@ -179,7 +179,7 @@ nfsd3_proc_read(struct svc_rqst *rqstp, 
 	 * 1 (status) + 22 (post_op_attr) + 1 (count) + 1 (eof)
 	 * + 1 (xdr opaque byte count) = 26
 	 */
-	svcbuf_reserve(&rqstp->rq_resbuf, &buffer, &avail,
+	svcbuf_reserve(&rqstp->rq_res, &buffer, &avail,
 			1 + NFS3_POST_OP_ATTR_WORDS + 3);
 	resp->count = argp->count;
 	if ((avail << 2) < resp->count)
@@ -447,7 +447,7 @@ nfsd3_proc_readdir(struct svc_rqst *rqst
 				argp->count, (u32) argp->cookie);
 
 	/* Reserve buffer space for status, attributes and verifier */
-	svcbuf_reserve(&rqstp->rq_resbuf, &buffer, &count,
+	svcbuf_reserve(&rqstp->rq_res, &buffer, &count,
 				1 + NFS3_POST_OP_ATTR_WORDS + 2);
 
 	/* Make sure we've room for the NULL ptr & eof flag, and shrink to
@@ -482,7 +482,7 @@ nfsd3_proc_readdirplus(struct svc_rqst *
 				argp->count, (u32) argp->cookie);
 
 	/* Reserve buffer space for status, attributes and verifier */
-	svcbuf_reserve(&rqstp->rq_resbuf, &buffer, &count,
+	svcbuf_reserve(&rqstp->rq_res, &buffer, &count,
 				1 + NFS3_POST_OP_ATTR_WORDS + 2);
 
 	/* Make sure we've room for the NULL ptr & eof flag, and shrink to
--- ./fs/lockd/xdr.c	2002/10/24 01:01:26	1.1
+++ ./fs/lockd/xdr.c	2002/10/25 05:14:36
@@ -216,25 +216,6 @@ nlm_encode_testres(u32 *p, struct nlm_re
 	return p;
 }
 
-/*
- * Check buffer bounds after decoding arguments
- */
-static inline int
-xdr_argsize_check(struct svc_rqst *rqstp, u32 *p)
-{
-	struct svc_buf	*buf = &rqstp->rq_argbuf;
-
-	return p - buf->base <= buf->buflen;
-}
-
-static inline int
-xdr_ressize_check(struct svc_rqst *rqstp, u32 *p)
-{
-	struct svc_buf	*buf = &rqstp->rq_resbuf;
-
-	buf->len = p - buf->base;
-	return (buf->len <= buf->buflen);
-}
 
 /*
  * First, the server side XDR functions
--- ./fs/lockd/xdr4.c	2002/10/24 01:05:40	1.1
+++ ./fs/lockd/xdr4.c	2002/10/25 05:14:44
@@ -223,26 +223,6 @@ nlm4_encode_testres(u32 *p, struct nlm_r
 
 
 /*
- * Check buffer bounds after decoding arguments
- */
-static int
-xdr_argsize_check(struct svc_rqst *rqstp, u32 *p)
-{
-	struct svc_buf	*buf = &rqstp->rq_argbuf;
-
-	return p - buf->base <= buf->buflen;
-}
-
-static int
-xdr_ressize_check(struct svc_rqst *rqstp, u32 *p)
-{
-	struct svc_buf	*buf = &rqstp->rq_resbuf;
-
-	buf->len = p - buf->base;
-	return (buf->len <= buf->buflen);
-}
-
-/*
  * First, the server side XDR functions
  */
 int
--- ./fs/read_write.c	2002/10/24 01:22:09	1.1
+++ ./fs/read_write.c	2002/10/24 02:54:13
@@ -207,6 +207,53 @@ ssize_t vfs_read(struct file *file, char
 	return ret;
 }
 
+ssize_t vfs_readv(struct file *file, struct iovec *vec, int vlen, size_t count, loff_t *pos)
+{
+	struct inode *inode = file->f_dentry->d_inode;
+	ssize_t ret;
+
+	if (!(file->f_mode & FMODE_READ))
+		return -EBADF;
+	if (!file->f_op || (!file->f_op->read && !file->f_op->aio_read))
+		return -EINVAL;
+
+	ret = locks_verify_area(FLOCK_VERIFY_READ, inode, file, *pos, count);
+	if (!ret) {
+		ret = security_ops->file_permission (file, MAY_READ);
+		if (!ret) {
+			if (file->f_op->readv)
+				ret = file->f_op->readv(file, vec, vlen, pos);
+			else {
+				/* do it by hand */
+				struct iovec *vector = vec;
+				ret = 0;
+				while (vlen > 0) {
+					void * base =  vector->iov_base;
+					size_t len = vector->iov_len;
+					ssize_t nr;
+					vector++;
+					vlen--;
+					if (file->f_op->read)
+						nr = file->f_op->read(file, base, len, pos);
+					else
+						nr = do_sync_read(file, base, len, pos);
+					if (nr < 0) {
+						if (!ret) ret = nr;
+						break;
+					}
+					ret += nr;
+					if (nr != len)
+						break;
+				}
+			}
+			if (ret > 0)
+				dnotify_parent(file->f_dentry, DN_ACCESS);
+		}
+	}
+
+	return ret;
+}
+
 ssize_t do_sync_write(struct file *filp, const char *buf, size_t len, loff_t *ppos)
 {
 	struct kiocb kiocb;
@@ -247,6 +294,53 @@ ssize_t vfs_write(struct file *file, con
 	return ret;
 }
 
+ssize_t vfs_writev(struct file *file, const struct iovec *vec, int vlen, size_t count, loff_t *pos)
+{
+	struct inode *inode = file->f_dentry->d_inode;
+	ssize_t ret;
+
+	if (!(file->f_mode & FMODE_WRITE))
+		return -EBADF;
+	if (!file->f_op || (!file->f_op->write && !file->f_op->aio_write))
+		return -EINVAL;
+
+	ret = locks_verify_area(FLOCK_VERIFY_WRITE, inode, file, *pos, count);
+	if (!ret) {
+		ret = security_ops->file_permission (file, MAY_WRITE);
+		if (!ret) {
+			if (file->f_op->writev)
+				ret = file->f_op->writev(file, vec, vlen, pos);
+			else {
+				/* do it by hand */
+				struct iovec *vector = vec;
+				ret = 0;
+				while (vlen > 0) {
+					void * base = vector->iov_base;
+					size_t len = vector->iov_len;
+					ssize_t nr;
+					vector++;
+					vlen--;
+					if (file->f_op->write)
+						nr = file->f_op->write(file, base, len, pos);
+					else
+						nr = do_sync_write(file, base, len, pos);
+					if (nr < 0) {
+						if (!ret) ret = nr;
+						break;
+					}
+					ret += nr;
+					if (nr != len)
+						break;
+				}
+			}
+			if (ret > 0)
+				dnotify_parent(file->f_dentry, DN_MODIFY);
+		}
+	}
+
+	return ret;
+}
+
 asmlinkage ssize_t sys_read(unsigned int fd, char * buf, size_t count)
 {
 	struct file *file;
--- ./include/linux/sunrpc/svc.h	2002/10/23 00:38:26	1.1
+++ ./include/linux/sunrpc/svc.h	2002/10/25 05:14:06
@@ -48,43 +48,49 @@ struct svc_serv {
  * This is use to determine the max number of pages nfsd is
  * willing to return in a single READ operation.
  */
-#define RPCSVC_MAXPAYLOAD	16384u
+#define RPCSVC_MAXPAYLOAD	(64*1024u)
 
 /*
- * Buffer to store RPC requests or replies in.
- * Each server thread has one of these beasts.
+ * RPC Requsts and replies are stored in one or more pages.
+ * We maintain an array of pages for each server thread.
+ * Requests are copied into these pages as they arrive.  Remaining
+ * pages are available to write the reply into.
  *
- * Area points to the allocated memory chunk currently owned by the
- * buffer. Base points to the buffer containing the request, which is
- * different from area when directly reading from an sk_buff. buf is
- * the current read/write position while processing an RPC request.
+ * Currently pages are all re-used by the same server.  Later we 
+ * will use ->sendpage to transmit pages with reduced copying.  In
+ * that case we will need to give away the page and allocate new ones.
+ * In preparation for this, we explicitly move pages off the recv
+ * list onto the transmit list, and back.
  *
- * The array of iovecs can hold additional data that the server process
- * may not want to copy into the RPC reply buffer, but pass to the 
- * network sendmsg routines directly. The prime candidate for this
- * will of course be NFS READ operations, but one might also want to
- * do something about READLINK and READDIR. It might be worthwhile
- * to implement some generic readdir cache in the VFS layer...
+ * We use xdr_buf for holding responses as it fits well with NFS
+ * read responses (that have a header, and some data pages, and possibly
+ * a tail) and means we can share some client side routines.
  *
- * On the receiving end of the RPC server, the iovec may be used to hold
- * the list of IP fragments once we get to process fragmented UDP
- * datagrams directly.
- */
-#define RPCSVC_MAXIOV		((RPCSVC_MAXPAYLOAD+PAGE_SIZE-1)/PAGE_SIZE + 1)
-struct svc_buf {
-	u32 *			area;	/* allocated memory */
-	u32 *			base;	/* base of RPC datagram */
-	int			buflen;	/* total length of buffer */
-	u32 *			buf;	/* read/write pointer */
-	int			len;	/* current end of buffer */
-
-	/* iovec for zero-copy NFS READs */
-	struct iovec		iov[RPCSVC_MAXIOV];
-	int			nriov;
-};
-#define svc_getu32(argp, val)	{ (val) = *(argp)->buf++; (argp)->len--; }
-#define svc_putu32(resp, val)	{ *(resp)->buf++ = (val); (resp)->len++; }
+ * The xdr_buf.head iovec always points to the first page in the rq_*pages
+ * list.  The xdr_buf.pages pointer points to the second page on that
+ * list.  xdr_buf.tail points to the end of the first page.
+ * This assumes that the non-page part of an rpc reply will fit
+ * in a page - NFSd ensures this.  lockd also has no trouble.
+ */
+#define RPCSVC_MAXPAGES		((RPCSVC_MAXPAYLOAD+PAGE_SIZE-1)/PAGE_SIZE + 1)
+
+static inline u32 svc_getu32(struct iovec *iov)
+{
+	u32 val, *vp;
+	vp = iov->iov_base;
+	val = *vp++;
+	iov->iov_base = (void*)vp;
+	iov->iov_len -= sizeof(u32);
+	return val;
+}
+static inline void svc_putu32(struct iovec *iov, u32 val)
+{
+	u32 *vp = iov->iov_base + iov->iov_len;
+	*vp = val;
+	iov->iov_len += sizeof(u32);
+}
 
+	
 /*
  * The context of a single thread, including the request currently being
  * processed.
@@ -102,9 +108,15 @@ struct svc_rqst {
 	struct svc_cred		rq_cred;	/* auth info */
 	struct sk_buff *	rq_skbuff;	/* fast recv inet buffer */
 	struct svc_deferred_req*rq_deferred;	/* deferred request we are replaying */
-	struct svc_buf		rq_defbuf;	/* default buffer */
-	struct svc_buf		rq_argbuf;	/* argument buffer */
-	struct svc_buf		rq_resbuf;	/* result buffer */
+
+	struct xdr_buf		rq_arg;
+	struct xdr_buf		rq_res;
+	struct page *		rq_argpages[RPCSVC_MAXPAGES];
+	struct page *		rq_respages[RPCSVC_MAXPAGES];
+	short			rq_argused;	/* pages used for argument */
+	short			rq_arghi;	/* pages available in argument page list */
+	short			rq_resused;	/* pages used for result */
+
 	u32			rq_xid;		/* transmission id */
 	u32			rq_prog;	/* program number */
 	u32			rq_vers;	/* program version */
@@ -136,6 +148,38 @@ struct svc_rqst {
 	wait_queue_head_t	rq_wait;	/* synchronization */
 };
 
+/*
+ * Check buffer bounds after decoding arguments
+ */
+static inline int
+xdr_argsize_check(struct svc_rqst *rqstp, u32 *p)
+{
+	char *cp = (char *)p;
+	struct iovec *vec = &rqstp->rq_arg.head[0];
+	return cp - (char*)vec->iov_base <= vec->iov_len;
+}
+
+static inline int
+xdr_ressize_check(struct svc_rqst *rqstp, u32 *p)
+{
+	struct iovec *vec = &rqstp->rq_res.head[0];
+	char *cp = (char*)p;
+
+	vec->iov_len = cp - (char*)vec->iov_base;
+	rqstp->rq_res.len = vec->iov_len;
+
+	return vec->iov_len <= PAGE_SIZE;
+}
+
+static int inline take_page(struct svc_rqst *rqstp)
+{
+	if (rqstp->rq_arghi <= rqstp->rq_argused)
+		return -ENOMEM;
+	rqstp->rq_respages[rqstp->rq_resused++] =
+		rqstp->rq_argpages[--rqstp->rq_arghi];
+	return 0;
+}
+
 struct svc_deferred_req {
 	struct svc_serv		*serv;
 	u32			prot;	/* protocol (UDP or TCP) */
--- ./include/linux/nfsd/xdr.h	2002/10/24 01:49:48	1.1
+++ ./include/linux/nfsd/xdr.h	2002/10/25 02:21:03
@@ -29,16 +29,16 @@ struct nfsd_readargs {
 	struct svc_fh		fh;
 	__u32			offset;
 	__u32			count;
-	__u32			totalsize;
+	struct iovec		vec[RPCSVC_MAXPAGES];
+	int			vlen;
 };
 
 struct nfsd_writeargs {
 	svc_fh			fh;
-	__u32			beginoffset;
 	__u32			offset;
-	__u32			totalcount;
-	__u8 *			data;
 	int			len;
+	struct iovec		vec[RPCSVC_MAXPAGES];
+	int			vlen;
 };
 
 struct nfsd_createargs {
--- ./include/linux/nfsd/nfsd.h	2002/10/24 04:04:03	1.1
+++ ./include/linux/nfsd/nfsd.h	2002/10/24 04:13:19
@@ -97,9 +97,9 @@ int		nfsd_open(struct svc_rqst *, struct
 				int, struct file *);
 void		nfsd_close(struct file *);
 int		nfsd_read(struct svc_rqst *, struct svc_fh *,
-				loff_t, char *, unsigned long *);
+				loff_t, struct iovec *,int, unsigned long *);
 int		nfsd_write(struct svc_rqst *, struct svc_fh *,
-				loff_t, char *, unsigned long, int *);
+				loff_t, struct iovec *,int, unsigned long, int *);
 int		nfsd_readlink(struct svc_rqst *, struct svc_fh *,
 				char *, int *);
 int		nfsd_symlink(struct svc_rqst *, struct svc_fh *,
--- ./include/linux/nfsd/cache.h	2002/10/24 03:41:12	1.1
+++ ./include/linux/nfsd/cache.h	2002/10/24 03:41:35
@@ -32,12 +32,12 @@ struct svc_cacherep {
 	u32			c_vers;
 	unsigned long		c_timestamp;
 	union {
-		struct svc_buf	u_buffer;
+		struct iovec	u_vec;
 		u32		u_status;
 	}			c_u;
 };
 
-#define c_replbuf		c_u.u_buffer
+#define c_replvec		c_u.u_vec
 #define c_replstat		c_u.u_status
 
 /* cache entry states */
--- ./include/linux/fs.h	2002/10/24 01:34:48	1.1
+++ ./include/linux/fs.h	2002/10/24 02:53:14
@@ -793,6 +793,8 @@ struct seq_file;
 
 extern ssize_t vfs_read(struct file *, char *, size_t, loff_t *);
 extern ssize_t vfs_write(struct file *, const char *, size_t, loff_t *);
+extern ssize_t vfs_readv(struct file *, struct iovec *, int, size_t, loff_t *);
+extern ssize_t vfs_writev(struct file *, const struct iovec *, int, size_t, loff_t *);
 
 /*
  * NOTE: write_inode, delete_inode, clear_inode, put_inode can be called
--- ./net/sunrpc/svc.c	2002/10/23 12:35:50	1.1
+++ ./net/sunrpc/svc.c	2002/10/25 05:41:14
@@ -13,6 +13,7 @@
 #include <linux/net.h>
 #include <linux/in.h>
 #include <linux/unistd.h>
+#include <linux/mm.h>
 
 #include <linux/sunrpc/types.h>
 #include <linux/sunrpc/xdr.h>
@@ -35,7 +36,6 @@ svc_create(struct svc_program *prog, uns
 
 	if (!(serv = (struct svc_serv *) kmalloc(sizeof(*serv), GFP_KERNEL)))
 		return NULL;
-
 	memset(serv, 0, sizeof(*serv));
 	serv->sv_program   = prog;
 	serv->sv_nrthreads = 1;
@@ -105,35 +105,41 @@ svc_destroy(struct svc_serv *serv)
 }
 
 /*
- * Allocate an RPC server buffer
- * Later versions may do nifty things by allocating multiple pages
- * of memory directly and putting them into the bufp->iov.
+ * Allocate an RPC server's buffer space.
+ * We allocate pages and place them in rq_argpages.
  */
-int
-svc_init_buffer(struct svc_buf *bufp, unsigned int size)
+static int
+svc_init_buffer(struct svc_rqst *rqstp, unsigned int size)
 {
-	if (!(bufp->area = (u32 *) kmalloc(size, GFP_KERNEL)))
-		return 0;
-	bufp->base   = bufp->area;
-	bufp->buf    = bufp->area;
-	bufp->len    = 0;
-	bufp->buflen = size >> 2;
-
-	bufp->iov[0].iov_base = bufp->area;
-	bufp->iov[0].iov_len  = size;
-	bufp->nriov = 1;
-
-	return 1;
+	int pages = 2 + (size+ PAGE_SIZE -1) / PAGE_SIZE;
+	int arghi;
+	
+	rqstp->rq_argused = 0;
+	rqstp->rq_resused = 0;
+	arghi = 0;
+	while (pages) {
+		struct page *p = alloc_page(GFP_KERNEL);
+		if (!p)
+			break;
+		printk("allocated page %d (%d to go)\n", arghi, pages-1);
+		rqstp->rq_argpages[arghi++] = p;
+		pages--;
+	}
+	rqstp->rq_arghi = arghi;
+	return ! pages;
 }
 
 /*
  * Release an RPC server buffer
  */
-void
-svc_release_buffer(struct svc_buf *bufp)
+static void
+svc_release_buffer(struct svc_rqst *rqstp)
 {
-	kfree(bufp->area);
-	bufp->area = 0;
+	while (rqstp->rq_arghi)
+		put_page(rqstp->rq_argpages[--rqstp->rq_arghi]);
+	while (rqstp->rq_resused)
+		put_page(rqstp->rq_respages[--rqstp->rq_resused]);
+	rqstp->rq_argused = 0;
 }
 
 /*
@@ -154,7 +160,7 @@ svc_create_thread(svc_thread_fn func, st
 
 	if (!(rqstp->rq_argp = (u32 *) kmalloc(serv->sv_xdrsize, GFP_KERNEL))
 	 || !(rqstp->rq_resp = (u32 *) kmalloc(serv->sv_xdrsize, GFP_KERNEL))
-	 || !svc_init_buffer(&rqstp->rq_defbuf, serv->sv_bufsz))
+	 || !svc_init_buffer(rqstp, serv->sv_bufsz))
 		goto out_thread;
 
 	serv->sv_nrthreads++;
@@ -180,7 +186,7 @@ svc_exit_thread(struct svc_rqst *rqstp)
 {
 	struct svc_serv	*serv = rqstp->rq_server;
 
-	svc_release_buffer(&rqstp->rq_defbuf);
+	svc_release_buffer(rqstp);
 	if (rqstp->rq_resp)
 		kfree(rqstp->rq_resp);
 	if (rqstp->rq_argp)
@@ -242,37 +248,49 @@ svc_process(struct svc_serv *serv, struc
 	struct svc_program	*progp;
 	struct svc_version	*versp = NULL;	/* compiler food */
 	struct svc_procedure	*procp = NULL;
-	struct svc_buf *	argp = &rqstp->rq_argbuf;
-	struct svc_buf *	resp = &rqstp->rq_resbuf;
+	struct iovec *		argv = &rqstp->rq_arg.head[0];
+	struct iovec *		resv = &rqstp->rq_res.head[0];
 	kxdrproc_t		xdr;
-	u32			*bufp, *statp;
+	u32			*statp;
 	u32			dir, prog, vers, proc,
 				auth_stat, rpc_stat;
 
 	rpc_stat = rpc_success;
-	bufp = argp->buf;
 
-	if (argp->len < 5)
+	if (argv->iov_len < 6*4)
 		goto err_short_len;
 
-	dir  = ntohl(*bufp++);
-	vers = ntohl(*bufp++);
+	/* setup response xdr_buf.
+	 * Initially it has just one page 
+	 */
+	take_page(rqstp); /* must succeed */
+	resv->iov_base = page_address(rqstp->rq_respages[0]);
+	resv->iov_len = 0;
+	rqstp->rq_res.pages = rqstp->rq_respages+1;
+	rqstp->rq_res.len = 0;
+	/* tcp needs a space for the record length... */
+	if (rqstp->rq_prot == IPPROTO_TCP)
+		svc_putu32(resv, 0);
+
+	rqstp->rq_xid = svc_getu32(argv);
+	svc_putu32(resv, rqstp->rq_xid);
+
+	dir  = ntohl(svc_getu32(argv));
+	vers = ntohl(svc_getu32(argv));
 
 	/* First words of reply: */
-	svc_putu32(resp, xdr_one);		/* REPLY */
-	svc_putu32(resp, xdr_zero);		/* ACCEPT */
+	svc_putu32(resv, xdr_one);		/* REPLY */
 
 	if (dir != 0)		/* direction != CALL */
 		goto err_bad_dir;
 	if (vers != 2)		/* RPC version number */
 		goto err_bad_rpc;
 
-	rqstp->rq_prog = prog = ntohl(*bufp++);	/* program number */
-	rqstp->rq_vers = vers = ntohl(*bufp++);	/* version number */
-	rqstp->rq_proc = proc = ntohl(*bufp++);	/* procedure number */
+	svc_putu32(resv, xdr_zero);		/* ACCEPT */
 
-	argp->buf += 5;
-	argp->len -= 5;
+	rqstp->rq_prog = prog = ntohl(svc_getu32(argv));	/* program number */
+	rqstp->rq_vers = vers = ntohl(svc_getu32(argv));	/* version number */
+	rqstp->rq_proc = proc = ntohl(svc_getu32(argv));	/* procedure number */
 
 	/*
 	 * Decode auth data, and add verifier to reply buffer.
@@ -307,8 +325,8 @@ svc_process(struct svc_serv *serv, struc
 	serv->sv_stats->rpccnt++;
 
 	/* Build the reply header. */
-	statp = resp->buf;
-	svc_putu32(resp, rpc_success);		/* RPC_SUCCESS */
+	statp = resv->iov_base +resv->iov_len;
+	svc_putu32(resv, rpc_success);		/* RPC_SUCCESS */
 
 	/* Bump per-procedure stats counter */
 	procp->pc_count++;
@@ -327,14 +345,14 @@ svc_process(struct svc_serv *serv, struc
 	if (!versp->vs_dispatch) {
 		/* Decode arguments */
 		xdr = procp->pc_decode;
-		if (xdr && !xdr(rqstp, rqstp->rq_argbuf.buf, rqstp->rq_argp))
+		if (xdr && !xdr(rqstp, argv->iov_base, rqstp->rq_argp))
 			goto err_garbage;
 
 		*statp = procp->pc_func(rqstp, rqstp->rq_argp, rqstp->rq_resp);
 
 		/* Encode reply */
 		if (*statp == rpc_success && (xdr = procp->pc_encode)
-		 && !xdr(rqstp, rqstp->rq_resbuf.buf, rqstp->rq_resp)) {
+		 && !xdr(rqstp, resv->iov_base+resv->iov_len, rqstp->rq_resp)) {
 			dprintk("svc: failed to encode reply\n");
 			/* serv->sv_stats->rpcsystemerr++; */
 			*statp = rpc_system_err;
@@ -347,7 +365,7 @@ svc_process(struct svc_serv *serv, struc
 
 	/* Check RPC status result */
 	if (*statp != rpc_success)
-		resp->len = statp + 1 - resp->base;
+		resv->iov_len = ((void*)statp)  - resv->iov_base + 4;
 
 	/* Release reply info */
 	if (procp->pc_release)
@@ -369,7 +387,7 @@ svc_process(struct svc_serv *serv, struc
 
 err_short_len:
 #ifdef RPC_PARANOIA
-	printk("svc: short len %d, dropping request\n", argp->len);
+	printk("svc: short len %d, dropping request\n", argv->iov_len);
 #endif
 	goto dropit;			/* drop request */
 
@@ -382,18 +400,19 @@ err_bad_dir:
 
 err_bad_rpc:
 	serv->sv_stats->rpcbadfmt++;
-	resp->buf[-1] = xdr_one;	/* REJECT */
-	svc_putu32(resp, xdr_zero);	/* RPC_MISMATCH */
-	svc_putu32(resp, xdr_two);	/* Only RPCv2 supported */
-	svc_putu32(resp, xdr_two);
+	svc_putu32(resv, xdr_one);	/* REJECT */
+	svc_putu32(resv, xdr_zero);	/* RPC_MISMATCH */
+	svc_putu32(resv, xdr_two);	/* Only RPCv2 supported */
+	svc_putu32(resv, xdr_two);
 	goto sendit;
 
 err_bad_auth:
 	dprintk("svc: authentication failed (%d)\n", ntohl(auth_stat));
 	serv->sv_stats->rpcbadauth++;
-	resp->buf[-1] = xdr_one;	/* REJECT */
-	svc_putu32(resp, xdr_one);	/* AUTH_ERROR */
-	svc_putu32(resp, auth_stat);	/* status */
+	resv->iov_len -= 4;
+	svc_putu32(resv, xdr_one);	/* REJECT */
+	svc_putu32(resv, xdr_one);	/* AUTH_ERROR */
+	svc_putu32(resv, auth_stat);	/* status */
 	goto sendit;
 
 err_bad_prog:
@@ -403,7 +422,7 @@ err_bad_prog:
 	/* else it is just a Solaris client seeing if ACLs are supported */
 #endif
 	serv->sv_stats->rpcbadfmt++;
-	svc_putu32(resp, rpc_prog_unavail);
+	svc_putu32(resv, rpc_prog_unavail);
 	goto sendit;
 
 err_bad_vers:
@@ -411,9 +430,9 @@ err_bad_vers:
 	printk("svc: unknown version (%d)\n", vers);
 #endif
 	serv->sv_stats->rpcbadfmt++;
-	svc_putu32(resp, rpc_prog_mismatch);
-	svc_putu32(resp, htonl(progp->pg_lovers));
-	svc_putu32(resp, htonl(progp->pg_hivers));
+	svc_putu32(resv, rpc_prog_mismatch);
+	svc_putu32(resv, htonl(progp->pg_lovers));
+	svc_putu32(resv, htonl(progp->pg_hivers));
 	goto sendit;
 
 err_bad_proc:
@@ -421,7 +440,7 @@ err_bad_proc:
 	printk("svc: unknown procedure (%d)\n", proc);
 #endif
 	serv->sv_stats->rpcbadfmt++;
-	svc_putu32(resp, rpc_proc_unavail);
+	svc_putu32(resv, rpc_proc_unavail);
 	goto sendit;
 
 err_garbage:
@@ -429,6 +448,6 @@ err_garbage:
 	printk("svc: failed to decode args\n");
 #endif
 	serv->sv_stats->rpcbadfmt++;
-	svc_putu32(resp, rpc_garbage_args);
+	svc_putu32(resv, rpc_garbage_args);
 	goto sendit;
 }
--- ./net/sunrpc/svcsock.c	2002/10/21 23:40:50	1.2
+++ ./net/sunrpc/svcsock.c	2002/10/25 07:22:30
@@ -234,7 +234,7 @@ svc_sock_received(struct svc_sock *svsk)
  */
 void svc_reserve(struct svc_rqst *rqstp, int space)
 {
-	space += rqstp->rq_resbuf.len<<2;
+	space += rqstp->rq_res.head[0].iov_len;
 
 	if (space < rqstp->rq_reserved) {
 		struct svc_sock *svsk = rqstp->rq_sock;
@@ -278,13 +278,12 @@ svc_sock_release(struct svc_rqst *rqstp)
 	 * But first, check that enough space was reserved
 	 * for the reply, otherwise we have a bug!
 	 */
-	if ((rqstp->rq_resbuf.len<<2) >  rqstp->rq_reserved)
+	if ((rqstp->rq_res.len) >  rqstp->rq_reserved)
 		printk(KERN_ERR "RPC request reserved %d but used %d\n",
 		       rqstp->rq_reserved,
-		       rqstp->rq_resbuf.len<<2);
+		       rqstp->rq_res.len);
 
-	rqstp->rq_resbuf.buf = rqstp->rq_resbuf.base;
-	rqstp->rq_resbuf.len = 0;
+	rqstp->rq_res.head[0].iov_len = 0;
 	svc_reserve(rqstp, 0);
 	rqstp->rq_sock = NULL;
 
@@ -480,13 +479,15 @@ svc_write_space(struct sock *sk)
 /*
  * Receive a datagram from a UDP socket.
  */
+extern int
+csum_partial_copy_to_xdr(struct xdr_buf *xdr, struct sk_buff *skb);
+
 static int
 svc_udp_recvfrom(struct svc_rqst *rqstp)
 {
 	struct svc_sock	*svsk = rqstp->rq_sock;
 	struct svc_serv	*serv = svsk->sk_server;
 	struct sk_buff	*skb;
-	u32		*data;
 	int		err, len;
 
 	if (test_and_clear_bit(SK_CHNGBUF, &svsk->sk_flags))
@@ -512,33 +513,19 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 	}
 	set_bit(SK_DATA, &svsk->sk_flags); /* there may be more data... */
 
-	/* Sorry. */
-	if (skb_is_nonlinear(skb)) {
-		if (skb_linearize(skb, GFP_KERNEL) != 0) {
-			kfree_skb(skb);
-			svc_sock_received(svsk);
-			return 0;
-		}
-	}
+	len  = skb->len - sizeof(struct udphdr);
 
-	if (skb->ip_summed != CHECKSUM_UNNECESSARY) {
-		if ((unsigned short)csum_fold(skb_checksum(skb, 0, skb->len, skb->csum))) {
-			skb_free_datagram(svsk->sk_sk, skb);
-			svc_sock_received(svsk);
-			return 0;
-		}
+	if (csum_partial_copy_to_xdr(&rqstp->rq_arg, skb)) {
+		/* checksum error */
+		skb_free_datagram(svsk->sk_sk, skb);
+		svc_sock_received(svsk);
+		return 0;
 	}
 
 
-	len  = skb->len - sizeof(struct udphdr);
-	data = (u32 *) (skb->data + sizeof(struct udphdr));
-
-	rqstp->rq_skbuff      = skb;
-	rqstp->rq_argbuf.base = data;
-	rqstp->rq_argbuf.buf  = data;
-	rqstp->rq_argbuf.len  = (len >> 2);
-	rqstp->rq_argbuf.buflen = (len >> 2);
-	/* rqstp->rq_resbuf      = rqstp->rq_defbuf; */
+	rqstp->rq_arg.len = len;
+	rqstp->rq_arg.page_len = len - rqstp->rq_arg.head[0].iov_len;
+	rqstp->rq_argused += (rqstp->rq_arg.page_len + PAGE_SIZE - 1)/ PAGE_SIZE;
 	rqstp->rq_prot        = IPPROTO_UDP;
 
 	/* Get sender address */
@@ -546,6 +533,8 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 	rqstp->rq_addr.sin_port = skb->h.uh->source;
 	rqstp->rq_addr.sin_addr.s_addr = skb->nh.iph->saddr;
 
+	skb_free_datagram(svsk->sk_sk, skb);
+
 	if (serv->sv_stats)
 		serv->sv_stats->netudpcnt++;
 
@@ -559,21 +548,37 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 static int
 svc_udp_sendto(struct svc_rqst *rqstp)
 {
-	struct svc_buf	*bufp = &rqstp->rq_resbuf;
 	int		error;
+	struct iovec vec[RPCSVC_MAXPAGES];
+	int v;
+	int base, len;
 
 	/* Set up the first element of the reply iovec.
 	 * Any other iovecs that may be in use have been taken
 	 * care of by the server implementation itself.
 	 */
-	/* bufp->base = bufp->area; */
-	bufp->iov[0].iov_base = bufp->base;
-	bufp->iov[0].iov_len  = bufp->len << 2;
+	vec[0] = rqstp->rq_res.head[0];
+	v=1;
+	base=rqstp->rq_res.page_base;
+	len = rqstp->rq_res.page_len;
+	while (len) {
+		vec[v].iov_base = page_address(rqstp->rq_res.pages[v-1]) + base;
+		vec[v].iov_len = PAGE_SIZE-base;
+		if (len <= vec[v].iov_len)
+			vec[v].iov_len = len;
+		len -= vec[v].iov_len;
+		base = 0;
+		v++;
+	}
+	if (rqstp->rq_res.tail[0].iov_len) {
+		vec[v] = rqstp->rq_res.tail[0];
+		v++;
+	}
 
-	error = svc_sendto(rqstp, bufp->iov, bufp->nriov);
+	error = svc_sendto(rqstp, vec, v);
 	if (error == -ECONNREFUSED)
 		/* ICMP error on earlier request. */
-		error = svc_sendto(rqstp, bufp->iov, bufp->nriov);
+		error = svc_sendto(rqstp, vec, v);
 
 	return error;
 }
@@ -785,8 +790,9 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 {
 	struct svc_sock	*svsk = rqstp->rq_sock;
 	struct svc_serv	*serv = svsk->sk_server;
-	struct svc_buf	*bufp = &rqstp->rq_argbuf;
 	int		len;
+	struct iovec vec[RPCSVC_MAXPAGES];
+	int pnum, vlen;
 
 	dprintk("svc: tcp_recv %p data %d conn %d close %d\n",
 		svsk, test_bit(SK_DATA, &svsk->sk_flags),
@@ -851,7 +857,7 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		}
 		svsk->sk_reclen &= 0x7fffffff;
 		dprintk("svc: TCP record, %d bytes\n", svsk->sk_reclen);
-		if (svsk->sk_reclen > (bufp->buflen<<2)) {
+		if (svsk->sk_reclen > (32768 /*FIXME*/)) {
 			printk(KERN_NOTICE "RPC: bad TCP reclen 0x%08lx (large)\n",
 			       (unsigned long) svsk->sk_reclen);
 			goto err_delete;
@@ -869,30 +875,35 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		svc_sock_received(svsk);
 		return -EAGAIN;	/* record not complete */
 	}
+	len = svsk->sk_reclen;
 	set_bit(SK_DATA, &svsk->sk_flags);
 
-	/* Frob argbuf */
-	bufp->iov[0].iov_base += 4;
-	bufp->iov[0].iov_len  -= 4;
+	vec[0] = rqstp->rq_arg.head[0];
+	vlen = PAGE_SIZE;
+	pnum = 1;
+	while (vlen < len) {
+		vec[pnum].iov_base = page_address(rqstp->rq_argpages[rqstp->rq_argused++]);
+		vec[pnum].iov_len = PAGE_SIZE;
+		pnum++;
+		vlen += PAGE_SIZE;
+	}
 
 	/* Now receive data */
-	len = svc_recvfrom(rqstp, bufp->iov, bufp->nriov, svsk->sk_reclen);
+	len = svc_recvfrom(rqstp, vec, pnum, len);
 	if (len < 0)
 		goto error;
 
 	dprintk("svc: TCP complete record (%d bytes)\n", len);
-
-	/* Position reply write pointer immediately after args,
-	 * allowing for record length */
-	rqstp->rq_resbuf.base = rqstp->rq_argbuf.base + 1 + (len>>2);
-	rqstp->rq_resbuf.buf  = rqstp->rq_resbuf.base + 1;
-	rqstp->rq_resbuf.len  = 1;
-	rqstp->rq_resbuf.buflen= rqstp->rq_argbuf.buflen - (len>>2) - 1;
+	rqstp->rq_arg.len = len;
+	rqstp->rq_arg.page_base = 0;
+	if (len <= rqstp->rq_arg.head[0].iov_len) {
+		rqstp->rq_arg.head[0].iov_len = len;
+		rqstp->rq_arg.page_len = 0;
+	} else {
+		rqstp->rq_arg.page_len = len - rqstp->rq_arg.head[0].iov_len;
+	}
 
 	rqstp->rq_skbuff      = 0;
-	rqstp->rq_argbuf.buf += 1;
-	rqstp->rq_argbuf.len  = (len >> 2);
-	rqstp->rq_argbuf.buflen = (len >> 2) +1;
 	rqstp->rq_prot	      = IPPROTO_TCP;
 
 	/* Reset TCP read info */
@@ -928,23 +939,44 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 static int
 svc_tcp_sendto(struct svc_rqst *rqstp)
 {
-	struct svc_buf	*bufp = &rqstp->rq_resbuf;
+	struct xdr_buf	*xbufp = &rqstp->rq_res;
+	struct iovec vec[RPCSVC_MAXPAGES];
+	int v;
+	int base, len;
 	int sent;
+	u32 reclen;
 
 	/* Set up the first element of the reply iovec.
 	 * Any other iovecs that may be in use have been taken
 	 * care of by the server implementation itself.
 	 */
-	bufp->iov[0].iov_base = bufp->base;
-	bufp->iov[0].iov_len  = bufp->len << 2;
-	bufp->base[0] = htonl(0x80000000|((bufp->len << 2) - 4));
+	reclen = htonl(0x80000000|((xbufp->len ) - 4));
+	memcpy(xbufp->head[0].iov_base, &reclen, 4);
+
+	vec[0] = rqstp->rq_res.head[0];
+	v=1;
+	base= xbufp->page_base;
+	len = xbufp->page_len;
+	while (len) {
+		vec[v].iov_base = page_address(xbufp->pages[v-1]) + base;
+		vec[v].iov_len = PAGE_SIZE-base;
+		if (len <= vec[v].iov_len)
+			vec[v].iov_len = len;
+		len -= vec[v].iov_len;
+		base = 0;
+		v++;
+	}
+	if (xbufp->tail[0].iov_len) {
+		vec[v] = xbufp->tail[0];
+		v++;
+	}
 
-	sent = svc_sendto(rqstp, bufp->iov, bufp->nriov);
-	if (sent != bufp->len<<2) {
+	sent = svc_sendto(rqstp, vec, v);
+	if (sent != xbufp->len) {
 		printk(KERN_NOTICE "rpc-srv/tcp: %s: %s %d when sending %d bytes - shutting down socket\n",
 		       rqstp->rq_sock->sk_server->sv_name,
 		       (sent<0)?"got error":"sent only",
-		       sent, bufp->len << 2);
+		       sent, xbufp->len);
 		svc_delete_socket(rqstp->rq_sock);
 		sent = -EAGAIN;
 	}
@@ -1016,6 +1048,8 @@ svc_recv(struct svc_serv *serv, struct s
 {
 	struct svc_sock		*svsk =NULL;
 	int			len;
+	int 			pages;
+	struct xdr_buf		*arg;
 	DECLARE_WAITQUEUE(wait, current);
 
 	dprintk("svc: server %p waiting for data (to = %ld)\n",
@@ -1031,9 +1065,35 @@ svc_recv(struct svc_serv *serv, struct s
 			 rqstp);
 
 	/* Initialize the buffers */
-	rqstp->rq_argbuf = rqstp->rq_defbuf;
-	rqstp->rq_resbuf = rqstp->rq_defbuf;
+	/* first reclaim pages that were moved to response list */
+	while (rqstp->rq_resused) 
+		rqstp->rq_argpages[rqstp->rq_arghi++] =
+			rqstp->rq_respages[--rqstp->rq_resused];
+	/* now allocate needed pages.  If we get a failure, sleep briefly */
+	pages = 2 + (serv->sv_bufsz + PAGE_SIZE -1) / PAGE_SIZE;
+	while (rqstp->rq_arghi < pages) {
+		struct page *p = alloc_page(GFP_KERNEL);
+		if (!p) {
+			set_current_state(TASK_UNINTERRUPTIBLE);
+			schedule_timeout(HZ/2);
+			current->state = TASK_RUNNING;
+			continue;
+		}
+		rqstp->rq_argpages[rqstp->rq_arghi++] = p;
+	}
 
+	/* Make arg->head point to first page and arg->pages point to rest */
+	arg = &rqstp->rq_arg;
+	arg->head[0].iov_base = page_address(rqstp->rq_argpages[0]);
+	arg->head[0].iov_len = PAGE_SIZE;
+	rqstp->rq_argused = 1;
+	arg->pages = rqstp->rq_argpages + 1;
+	arg->page_base = 0;
+	/* save at least one page for response */
+	arg->page_len = (pages-2)*PAGE_SIZE;
+	arg->len = (pages-1)*PAGE_SIZE;
+	arg->tail[0].iov_len = 0;
+	
 	if (signalled())
 		return -EINTR;
 
@@ -1109,12 +1169,6 @@ svc_recv(struct svc_serv *serv, struct s
 	rqstp->rq_userset = 0;
 	rqstp->rq_chandle.defer = svc_defer;
 
-	svc_getu32(&rqstp->rq_argbuf, rqstp->rq_xid);
-	svc_putu32(&rqstp->rq_resbuf, rqstp->rq_xid);
-
-	/* Assume that the reply consists of a single buffer. */
-	rqstp->rq_resbuf.nriov = 1;
-
 	if (serv->sv_stats)
 		serv->sv_stats->netcnt++;
 	return len;
@@ -1354,23 +1408,25 @@ static struct cache_deferred_req *
 svc_defer(struct cache_req *req)
 {
 	struct svc_rqst *rqstp = container_of(req, struct svc_rqst, rq_chandle);
-	int size = sizeof(struct svc_deferred_req) + (rqstp->rq_argbuf.buflen << 2);
+	int size = sizeof(struct svc_deferred_req) + (rqstp->rq_arg.head[0].iov_len);
 	struct svc_deferred_req *dr;
 
+	if (rqstp->rq_arg.page_len)
+		return NULL; /* if more than a page, give up FIXME */
 	if (rqstp->rq_deferred) {
 		dr = rqstp->rq_deferred;
 		rqstp->rq_deferred = NULL;
 	} else {
 		/* FIXME maybe discard if size too large */
-		dr = kmalloc(size<<2, GFP_KERNEL);
+		dr = kmalloc(size, GFP_KERNEL);
 		if (dr == NULL)
 			return NULL;
 
 		dr->serv = rqstp->rq_server;
 		dr->prot = rqstp->rq_prot;
 		dr->addr = rqstp->rq_addr;
-		dr->argslen = rqstp->rq_argbuf.buflen;
-		memcpy(dr->args, rqstp->rq_argbuf.base, dr->argslen<<2);
+		dr->argslen = rqstp->rq_arg.head[0].iov_len >> 2;
+		memcpy(dr->args, rqstp->rq_arg.head[0].iov_base, dr->argslen<<2);
 	}
 	spin_lock(&rqstp->rq_server->sv_lock);
 	rqstp->rq_sock->sk_inuse++;
@@ -1388,10 +1444,10 @@ static int svc_deferred_recv(struct svc_
 {
 	struct svc_deferred_req *dr = rqstp->rq_deferred;
 
-	rqstp->rq_argbuf.base = dr->args;
-	rqstp->rq_argbuf.buf  = dr->args;
-	rqstp->rq_argbuf.len  = dr->argslen;
-	rqstp->rq_argbuf.buflen = dr->argslen;
+	rqstp->rq_arg.head[0].iov_base = dr->args;
+	rqstp->rq_arg.head[0].iov_len = dr->argslen<<2;
+	rqstp->rq_arg.page_len = 0;
+	rqstp->rq_arg.len = dr->argslen<<2;
 	rqstp->rq_prot        = dr->prot;
 	rqstp->rq_addr        = dr->addr;
 	return dr->argslen<<2;
--- ./net/sunrpc/svcauth.c	2002/10/24 06:01:17	1.1
+++ ./net/sunrpc/svcauth.c	2002/10/24 06:01:52
@@ -40,8 +40,7 @@ svc_authenticate(struct svc_rqst *rqstp,
 	*statp = rpc_success;
 	*authp = rpc_auth_ok;
 
-	svc_getu32(&rqstp->rq_argbuf, flavor);
-	flavor = ntohl(flavor);
+	flavor = ntohl(svc_getu32(&rqstp->rq_arg.head[0]));
 
 	dprintk("svc: svc_authenticate (%d)\n", flavor);
 	if (flavor >= RPC_AUTH_MAXFLAVOR || !(aops = authtab[flavor])) {
--- ./net/sunrpc/xprt.c	2002/10/24 00:34:53	1.1
+++ ./net/sunrpc/xprt.c	2002/10/24 01:00:36
@@ -655,7 +655,7 @@ skb_read_and_csum_bits(skb_reader_t *des
  * We have set things up such that we perform the checksum of the UDP
  * packet in parallel with the copies into the RPC client iovec.  -DaveM
  */
-static int
+int
 csum_partial_copy_to_xdr(struct xdr_buf *xdr, struct sk_buff *skb)
 {
 	skb_reader_t desc;
--- ./net/sunrpc/svcauth_unix.c	2002/10/24 06:09:05	1.1
+++ ./net/sunrpc/svcauth_unix.c	2002/10/25 07:14:44
@@ -287,20 +287,20 @@ void svcauth_unix_purge(void)
 static int
 svcauth_null_accept(struct svc_rqst *rqstp, u32 *authp, int proc)
 {
-	struct svc_buf	*argp = &rqstp->rq_argbuf;
-	struct svc_buf	*resp = &rqstp->rq_resbuf;
+	struct iovec	*argv = &rqstp->rq_arg.head[0];
+	struct iovec	*resv = &rqstp->rq_res.head[0];
 	int		rv=0;
 	struct ip_map key, *ipm;
 
-	if ((argp->len -= 3) < 0) {
+	if (argv->iov_len < 3*4)
 		return SVC_GARBAGE;
-	}
-	if (*(argp->buf)++ != 0) {	/* we already skipped the flavor */
+
+	if (svc_getu32(argv) != 0) { 
 		dprintk("svc: bad null cred\n");
 		*authp = rpc_autherr_badcred;
 		return SVC_DENIED;
 	}
-	if (*(argp->buf)++ != RPC_AUTH_NULL || *(argp->buf)++ != 0) {
+	if (svc_getu32(argv) != RPC_AUTH_NULL || svc_getu32(argv) != 0) {
 		dprintk("svc: bad null verf\n");
 		*authp = rpc_autherr_badverf;
 		return SVC_DENIED;
@@ -312,8 +312,8 @@ svcauth_null_accept(struct svc_rqst *rqs
 	rqstp->rq_cred.cr_groups[0] = NOGROUP;
 
 	/* Put NULL verifier */
-	svc_putu32(resp, RPC_AUTH_NULL);
-	svc_putu32(resp, 0);
+	svc_putu32(resv, RPC_AUTH_NULL);
+	svc_putu32(resv, 0);
 
 	key.m_class = rqstp->rq_server->sv_program->pg_class;
 	key.m_addr = rqstp->rq_addr.sin_addr;
@@ -368,64 +368,70 @@ struct auth_ops svcauth_null = {
 int
 svcauth_unix_accept(struct svc_rqst *rqstp, u32 *authp, int proc)
 {
-	struct svc_buf	*argp = &rqstp->rq_argbuf;
-	struct svc_buf	*resp = &rqstp->rq_resbuf;
+	struct iovec	*argv = &rqstp->rq_arg.head[0];
+	struct iovec	*resv = &rqstp->rq_res.head[0];
 	struct svc_cred	*cred = &rqstp->rq_cred;
-	u32		*bufp = argp->buf, slen, i;
-	int		len   = argp->len;
+	u32		slen, i;
+	int		len   = argv->iov_len;
 	int		rv=0;
 	struct ip_map key, *ipm;
 
-	if ((len -= 3) < 0)
+	if ((len -= 3*4) < 0)
 		return SVC_GARBAGE;
 
-	bufp++;					/* length */
-	bufp++;					/* time stamp */
-	slen = XDR_QUADLEN(ntohl(*bufp++));	/* machname length */
-	if (slen > 64 || (len -= slen + 3) < 0)
+	svc_getu32(argv);			/* length */
+	svc_getu32(argv);			/* time stamp */
+	slen = XDR_QUADLEN(ntohl(svc_getu32(argv)));	/* machname length */
+	if (slen > 64 || (len -= (slen + 3)*4) < 0)
 		goto badcred;
-	bufp += slen;				/* skip machname */
-
-	cred->cr_uid = ntohl(*bufp++);		/* uid */
-	cred->cr_gid = ntohl(*bufp++);		/* gid */
+printk("namelen %d name %.*s\n", slen, slen*4, (char*)argv->iov_base);
+	argv->iov_base = (void*)((u32*)argv->iov_base + slen);	/* skip machname */
 
-	slen = ntohl(*bufp++);			/* gids length */
-	if (slen > 16 || (len -= slen + 2) < 0)
+	cred->cr_uid = ntohl(svc_getu32(argv));		/* uid */
+	cred->cr_gid = ntohl(svc_getu32(argv));		/* gid */
+printk("uid=%d gid=%d\n", cred->cr_uid, cred->cr_gid);
+	slen = ntohl(svc_getu32(argv));			/* gids length */
+	printk("%d gids (%d)\n", slen, len);
+	if (slen > 16 || (len -= (slen + 2)*4) < 0)
 		goto badcred;
-	for (i = 0; i < NGROUPS && i < slen; i++)
-		cred->cr_groups[i] = ntohl(*bufp++);
+	for (i = 0; i < slen; i++)
+		if (i < NGROUPS)
+			cred->cr_groups[i] = ntohl(svc_getu32(argv));
+		else
+			svc_getu32(argv);
 	if (i < NGROUPS)
 		cred->cr_groups[i] = NOGROUP;
-	bufp += (slen - i);
+	printk("..got %d\n", i);
 
-	if (*bufp++ != RPC_AUTH_NULL || *bufp++ != 0) {
+	if (svc_getu32(argv) != RPC_AUTH_NULL || svc_getu32(argv) != 0) {
+		printk("nogo\n");
 		*authp = rpc_autherr_badverf;
 		return SVC_DENIED;
 	}
 
-	argp->buf = bufp;
-	argp->len = len;
-
 	/* Put NULL verifier */
-	svc_putu32(resp, RPC_AUTH_NULL);
-	svc_putu32(resp, 0);
+	svc_putu32(resv, RPC_AUTH_NULL);
+	svc_putu32(resv, 0);
+	printk("put NULL\n");
 
 	key.m_class = rqstp->rq_server->sv_program->pg_class;
 	key.m_addr = rqstp->rq_addr.sin_addr;
 
+	printk("key is <%s>, %x\n", key.m_class, key.m_addr.s_addr);
+
 	ipm = ip_map_lookup(&key, 0);
 
 	rqstp->rq_client = NULL;
-
+	printk(ipm?"Yes\n": "No\n");
 	if (ipm)
 		switch (cache_check(&ip_map_cache, &ipm->h, &rqstp->rq_chandle)) {
-		case -EAGAIN:
+		case -EAGAIN:printk("EAGAIN\n");
 			rv = SVC_DROP;
 			break;
-		case -ENOENT:
+		case -ENOENT:printk("NOENT\n");
 			rv = SVC_OK; /* rq_client is NULL */
 			break;
-		case 0:
+		case 0: printk("Zero\n");
 			rqstp->rq_client = &ipm->m_client->h;
 			cache_get(&rqstp->rq_client->h);
 			ip_map_put(&ipm->h, &ip_map_cache);
@@ -434,7 +440,7 @@ svcauth_unix_accept(struct svc_rqst *rqs
 		default: BUG();
 		}
 	else rv = SVC_DROP;
-
+	if (rqstp->rq_client==NULL) printk("clinet NULL and proc %d\n", proc);
 	if (rqstp->rq_client == NULL && proc != 0)
 		goto badcred;
 	return rv;
--- ./kernel/ksyms.c	2002/10/24 01:33:59	1.1
+++ ./kernel/ksyms.c	2002/10/24 01:34:08
@@ -254,7 +254,9 @@ EXPORT_SYMBOL(find_inode_number);
 EXPORT_SYMBOL(is_subdir);
 EXPORT_SYMBOL(get_unused_fd);
 EXPORT_SYMBOL(vfs_read);
+EXPORT_SYMBOL(vfs_readv);
 EXPORT_SYMBOL(vfs_write);
+EXPORT_SYMBOL(vfs_writev);
 EXPORT_SYMBOL(vfs_create);
 EXPORT_SYMBOL(vfs_mkdir);
 EXPORT_SYMBOL(vfs_mknod);


-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0004en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
