From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: [PATCH 06/19] SUNRPC: mark bulk read/write data in xdrbuf
Date: Mon, 10 Sep 2007 13:44:58 -0400
Message-ID: <EXNANE01r9oD6XMLDth000004b5@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IUnYb-0003Eg-Ci
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 11:00:21 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IUnYf-0006ok-Uw
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 11:00:26 -0700
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com
	[10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id
	l8AI017Z020680
	for <nfs@lists.sourceforge.net>; Mon, 10 Sep 2007 11:00:19 -0700 (PDT)
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

SUNRPC: mark bulk read/write data in xdrbuf

Adds a flag word to the xdrbuf struct which indicates any bulk
disposition of the data. This enables RPC transport providers to
marshal it efficiently/appropriately, and may enable other
optimizations.

Signed-off-by: Tom Talpey <tmt@netapp.com>

---

 fs/nfs/nfs2xdr.c           |    2 ++
 fs/nfs/nfs3xdr.c           |    2 ++
 fs/nfs/nfs4xdr.c           |    2 ++
 include/linux/sunrpc/xdr.h |    5 ++++-
 net/sunrpc/clnt.c          |    1 +
 5 files changed, 11 insertions(+), 1 deletion(-)

Index: kernel/fs/nfs/nfs2xdr.c
===================================================================
--- kernel.orig/fs/nfs/nfs2xdr.c
+++ kernel/fs/nfs/nfs2xdr.c
@@ -251,6 +251,7 @@ nfs_xdr_readargs(struct rpc_rqst *req, _
 	replen = (RPC_REPHDRSIZE + auth->au_rslack + NFS_readres_sz) << 2;
 	xdr_inline_pages(&req->rq_rcv_buf, replen,
 			 args->pages, args->pgbase, count);
+	req->rq_rcv_buf.flags |= XDRBUF_READ;
 	return 0;
 }
 
@@ -313,6 +314,7 @@ nfs_xdr_writeargs(struct rpc_rqst *req, 
 
 	/* Copy the page array */
 	xdr_encode_pages(sndbuf, args->pages, args->pgbase, count);
+	sndbuf->flags |= XDRBUF_WRITE;
 	return 0;
 }
 
Index: kernel/fs/nfs/nfs3xdr.c
===================================================================
--- kernel.orig/fs/nfs/nfs3xdr.c
+++ kernel/fs/nfs/nfs3xdr.c
@@ -346,6 +346,7 @@ nfs3_xdr_readargs(struct rpc_rqst *req, 
 	replen = (RPC_REPHDRSIZE + auth->au_rslack + NFS3_readres_sz) << 2;
 	xdr_inline_pages(&req->rq_rcv_buf, replen,
 			 args->pages, args->pgbase, count);
+	req->rq_rcv_buf.flags |= XDRBUF_READ;
 	return 0;
 }
 
@@ -367,6 +368,7 @@ nfs3_xdr_writeargs(struct rpc_rqst *req,
 
 	/* Copy the page array */
 	xdr_encode_pages(sndbuf, args->pages, args->pgbase, count);
+	sndbuf->flags |= XDRBUF_WRITE;
 	return 0;
 }
 
Index: kernel/fs/nfs/nfs4xdr.c
===================================================================
--- kernel.orig/fs/nfs/nfs4xdr.c
+++ kernel/fs/nfs/nfs4xdr.c
@@ -1865,6 +1865,7 @@ static int nfs4_xdr_enc_read(struct rpc_
 	replen = (RPC_REPHDRSIZE + auth->au_rslack + NFS4_dec_read_sz) << 2;
 	xdr_inline_pages(&req->rq_rcv_buf, replen,
 			 args->pages, args->pgbase, args->count);
+	req->rq_rcv_buf.flags |= XDRBUF_READ;
 out:
 	return status;
 }
@@ -1941,6 +1942,7 @@ static int nfs4_xdr_enc_write(struct rpc
 	status = encode_write(&xdr, args);
 	if (status)
 		goto out;
+	req->rq_snd_buf.flags |= XDRBUF_WRITE;
 	status = encode_getfattr(&xdr, args->bitmask);
 out:
 	return status;
Index: kernel/include/linux/sunrpc/xdr.h
===================================================================
--- kernel.orig/include/linux/sunrpc/xdr.h
+++ kernel/include/linux/sunrpc/xdr.h
@@ -70,7 +70,10 @@ struct xdr_buf {
 
 	struct page **	pages;		/* Array of contiguous pages */
 	unsigned int	page_base,	/* Start of page data */
-			page_len;	/* Length of page data */
+			page_len,	/* Length of page data */
+			flags;		/* Flags for data disposition */
+#define XDRBUF_READ		0x01		/* target of file read */
+#define XDRBUF_WRITE		0x02		/* source of file write */
 
 	unsigned int	buflen,		/* Total length of storage buffer */
 			len;		/* Length of XDR encoded message */
Index: kernel/net/sunrpc/clnt.c
===================================================================
--- kernel.orig/net/sunrpc/clnt.c
+++ kernel/net/sunrpc/clnt.c
@@ -871,6 +871,7 @@ rpc_xdr_buf_init(struct xdr_buf *buf, vo
 	buf->head[0].iov_len = len;
 	buf->tail[0].iov_len = 0;
 	buf->page_len = 0;
+	buf->flags = 0;
 	buf->len = 0;
 	buf->buflen = len;
 }

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
