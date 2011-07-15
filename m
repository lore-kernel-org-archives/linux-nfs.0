Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:59697 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754978Ab1GOLH0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Jul 2011 07:07:26 -0400
From: Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org
CC: linux-nfs@vger.kernel.org, Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 09/10] nfs: use sk fragment destructors to delay I/O completion until page is released by network stack.
Date: Fri, 15 Jul 2011 12:07:10 +0100
Message-ID: <1310728031-19569-9-git-send-email-ian.campbell@citrix.com>
In-Reply-To: <1310728006.20648.3.camel@zakaz.uk.xensource.com>
References: <1310728006.20648.3.camel@zakaz.uk.xensource.com>
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Thos prevents an issue where an ACK is delayed, a retransmit is queued (either
at the RPC or TCP level) and the ACK arrives before the retransmission hits the
wire. If this happens then the write() system call and the userspace process
can continue potentially modifying the data before the retransmission occurs.

NB: this only covers the O_DIRECT write() case. I expect other cases to need
handling as well.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
---
 fs/nfs/direct.c            |   17 +++++++++++++++--
 fs/nfs/nfs2xdr.c           |    4 ++--
 fs/nfs/nfs3xdr.c           |    7 ++++---
 fs/nfs/nfs4xdr.c           |    6 +++---
 include/linux/nfs_xdr.h    |    4 ++++
 include/linux/sunrpc/xdr.h |    2 ++
 net/sunrpc/svcsock.c       |    2 +-
 net/sunrpc/xdr.c           |    4 +++-
 net/sunrpc/xprtsock.c      |    2 +-
 9 files changed, 35 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 8eea253..4735fd9 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -691,8 +691,7 @@ static void nfs_direct_write_release(void *calldata)
 out_unlock:
 	spin_unlock(&dreq->lock);
 
-	if (put_dreq(dreq))
-		nfs_direct_write_complete(dreq, data->inode);
+	skb_frag_destructor_unref(data->args.pages_destructor);
 }
 
 static const struct rpc_call_ops nfs_write_direct_ops = {
@@ -703,6 +702,15 @@ static const struct rpc_call_ops nfs_write_direct_ops = {
 	.rpc_release = nfs_direct_write_release,
 };
 
+static int nfs_write_page_destroy(void *calldata)
+{
+	struct nfs_write_data *data = calldata;
+	struct nfs_direct_req *dreq = (struct nfs_direct_req *) data->req;
+	if (put_dreq(dreq))
+		nfs_direct_write_complete(dreq, data->inode);
+	return 0;
+}
+
 /*
  * For each wsize'd chunk of the user's buffer, dispatch an NFS WRITE
  * operation.  If nfs_writedata_alloc() or get_user_pages() fails,
@@ -769,6 +777,10 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
 
 		list_move_tail(&data->pages, &dreq->rewrite_list);
 
+		atomic_set(&data->pagevec_destructor.ref, 1);
+		data->pagevec_destructor.destroy = nfs_write_page_destroy;
+		data->pagevec_destructor.data = data;
+
 		data->req = (struct nfs_page *) dreq;
 		data->inode = inode;
 		data->cred = msg.rpc_cred;
@@ -778,6 +790,7 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
 		data->args.offset = pos;
 		data->args.pgbase = pgbase;
 		data->args.pages = data->pagevec;
+		data->args.pages_destructor = &data->pagevec_destructor;
 		data->args.count = bytes;
 		data->args.stable = sync;
 		data->res.fattr = &data->fattr;
diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 792cb13..6dc77f0 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -431,7 +431,7 @@ static void encode_path(struct xdr_stream *xdr, struct page **pages, u32 length)
 	BUG_ON(length > NFS2_MAXPATHLEN);
 	p = xdr_reserve_space(xdr, 4);
 	*p = cpu_to_be32(length);
-	xdr_write_pages(xdr, pages, 0, length);
+	xdr_write_pages(xdr, pages, NULL, 0, length);
 }
 
 static int decode_path(struct xdr_stream *xdr)
@@ -659,7 +659,7 @@ static void encode_writeargs(struct xdr_stream *xdr,
 
 	/* nfsdata */
 	*p = cpu_to_be32(count);
-	xdr_write_pages(xdr, args->pages, args->pgbase, count);
+	xdr_write_pages(xdr, args->pages, NULL, args->pgbase, count);
 }
 
 static void nfs2_xdr_enc_writeargs(struct rpc_rqst *req,
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 183c6b1..f7a83a1 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -238,7 +238,7 @@ static void encode_nfspath3(struct xdr_stream *xdr, struct page **pages,
 {
 	BUG_ON(length > NFS3_MAXPATHLEN);
 	encode_uint32(xdr, length);
-	xdr_write_pages(xdr, pages, 0, length);
+	xdr_write_pages(xdr, pages, NULL, 0, length);
 }
 
 static int decode_nfspath3(struct xdr_stream *xdr)
@@ -994,7 +994,8 @@ static void encode_write3args(struct xdr_stream *xdr,
 	*p++ = cpu_to_be32(args->count);
 	*p++ = cpu_to_be32(args->stable);
 	*p = cpu_to_be32(args->count);
-	xdr_write_pages(xdr, args->pages, args->pgbase, args->count);
+	xdr_write_pages(xdr, args->pages, args->pages_destructor,
+			args->pgbase, args->count);
 }
 
 static void nfs3_xdr_enc_write3args(struct rpc_rqst *req,
@@ -1331,7 +1332,7 @@ static void nfs3_xdr_enc_setacl3args(struct rpc_rqst *req,
 
 	base = req->rq_slen;
 	if (args->npages != 0)
-		xdr_write_pages(xdr, args->pages, 0, args->len);
+		xdr_write_pages(xdr, args->pages, NULL, 0, args->len);
 	else
 		xdr_reserve_space(xdr, NFS_ACL_INLINE_BUFSIZE);
 
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 6870bc6..ac9931d 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1031,7 +1031,7 @@ static void encode_create(struct xdr_stream *xdr, const struct nfs4_create_arg *
 	case NF4LNK:
 		p = reserve_space(xdr, 4);
 		*p = cpu_to_be32(create->u.symlink.len);
-		xdr_write_pages(xdr, create->u.symlink.pages, 0, create->u.symlink.len);
+		xdr_write_pages(xdr, create->u.symlink.pages, NULL, 0, create->u.symlink.len);
 		break;
 
 	case NF4BLK: case NF4CHR:
@@ -1573,7 +1573,7 @@ encode_setacl(struct xdr_stream *xdr, struct nfs_setaclargs *arg, struct compoun
 	BUG_ON(arg->acl_len % 4);
 	p = reserve_space(xdr, 4);
 	*p = cpu_to_be32(arg->acl_len);
-	xdr_write_pages(xdr, arg->acl_pages, arg->acl_pgbase, arg->acl_len);
+	xdr_write_pages(xdr, arg->acl_pages, NULL, arg->acl_pgbase, arg->acl_len);
 	hdr->nops++;
 	hdr->replen += decode_setacl_maxsz;
 }
@@ -1647,7 +1647,7 @@ static void encode_write(struct xdr_stream *xdr, const struct nfs_writeargs *arg
 	*p++ = cpu_to_be32(args->stable);
 	*p = cpu_to_be32(args->count);
 
-	xdr_write_pages(xdr, args->pages, args->pgbase, args->count);
+	xdr_write_pages(xdr, args->pages, NULL, args->pgbase, args->count);
 	hdr->nops++;
 	hdr->replen += decode_write_maxsz;
 }
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 00848d8..4bbc2bf 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -5,6 +5,8 @@
 #include <linux/nfs3.h>
 #include <linux/sunrpc/gss_api.h>
 
+#include <linux/skbuff.h>
+
 /*
  * To change the maximum rsize and wsize supported by the NFS client, adjust
  * NFS_MAX_FILE_IO_SIZE.  64KB is a typical maximum, but some servers can
@@ -470,6 +472,7 @@ struct nfs_writeargs {
 	enum nfs3_stable_how	stable;
 	unsigned int		pgbase;
 	struct page **		pages;
+	struct skb_frag_destructor *pages_destructor;
 	const u32 *		bitmask;
 	struct nfs4_sequence_args	seq_args;
 };
@@ -1121,6 +1124,7 @@ struct nfs_write_data {
 	struct list_head	pages;		/* Coalesced requests we wish to flush */
 	struct nfs_page		*req;		/* multi ops per nfs_page */
 	struct page		**pagevec;
+	struct skb_frag_destructor pagevec_destructor;
 	unsigned int		npages;		/* Max length of pagevec */
 	struct nfs_writeargs	args;		/* argument struct */
 	struct nfs_writeres	res;		/* result struct */
diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index a20970e..cebb531 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -57,6 +57,7 @@ struct xdr_buf {
 			tail[1];	/* Appended after page data */
 
 	struct page **	pages;		/* Array of contiguous pages */
+	struct skb_frag_destructor *destructor;
 	unsigned int	page_base,	/* Start of page data */
 			page_len,	/* Length of page data */
 			flags;		/* Flags for data disposition */
@@ -214,6 +215,7 @@ typedef int	(*kxdrdproc_t)(void *rqstp, struct xdr_stream *xdr, void *obj);
 extern void xdr_init_encode(struct xdr_stream *xdr, struct xdr_buf *buf, __be32 *p);
 extern __be32 *xdr_reserve_space(struct xdr_stream *xdr, size_t nbytes);
 extern void xdr_write_pages(struct xdr_stream *xdr, struct page **pages,
+		struct skb_frag_destructor *destroy,
 		unsigned int base, unsigned int len);
 extern void xdr_init_decode(struct xdr_stream *xdr, struct xdr_buf *buf, __be32 *p);
 extern void xdr_init_decode_pages(struct xdr_stream *xdr, struct xdr_buf *buf,
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index a80b1d3..40c2420 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -194,7 +194,7 @@ int svc_send_common(struct socket *sock, struct xdr_buf *xdr,
 	while (pglen > 0) {
 		if (slen == size)
 			flags = 0;
-		result = kernel_sendpage(sock, *ppage, NULL, base, size, flags);
+		result = kernel_sendpage(sock, *ppage, xdr->destructor, base, size, flags);
 		if (result > 0)
 			len += result;
 		if (result != size)
diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index f008c14..9c7dded 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -525,12 +525,14 @@ EXPORT_SYMBOL_GPL(xdr_reserve_space);
  * @len: length of data in bytes
  *
  */
-void xdr_write_pages(struct xdr_stream *xdr, struct page **pages, unsigned int base,
+void xdr_write_pages(struct xdr_stream *xdr, struct page **pages,
+		 struct skb_frag_destructor *destroy, unsigned int base,
 		 unsigned int len)
 {
 	struct xdr_buf *buf = xdr->buf;
 	struct kvec *iov = buf->tail;
 	buf->pages = pages;
+	buf->destructor = destroy;
 	buf->page_base = base;
 	buf->page_len = len;
 
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 72abb73..aa31294 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -397,7 +397,7 @@ static int xs_send_pagedata(struct socket *sock, struct xdr_buf *xdr, unsigned i
 		remainder -= len;
 		if (remainder != 0 || more)
 			flags |= MSG_MORE;
-		err = sock->ops->sendpage(sock, *ppage, base, len, flags);
+		err = sock->ops->sendpage_destructor(sock, *ppage, xdr->destructor, base, len, flags);
 		if (remainder == 0 || err != len)
 			break;
 		sent += err;
-- 
1.7.2.5

