From: Greg Banks <gnb@sgi.com>
Subject: [RFC,
	PATCH 4/5] knfsd: nfsrdma arranges to preserve chunk header across
	deferrals
Date: Thu, 24 May 2007 00:34:11 +1000
Message-ID: <20070523143411.GL14076@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Thomas Talpey <Thomas.Talpey@netapp.com>,
	Peter Leckie <pleckie@melbourne.sgi.com>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hqruo-00058W-HH
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 07:34:14 -0700
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX19Uawb4y4slZGXBZEcMrf3qqAx6+FACgus=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hqrur-0002WF-7d
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 07:34:17 -0700
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


Make the NFS/RDMA transport code pass enough information to the
generic code that the generic code can defer and revisit calls
over NFS/RDMA correctly, preserving the chunking header.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
---

 include/linux/sunrpc/svc_rdma.h |   10 +++++++++-
 net/sunrpc/svc_rdma_marshal.c   |    9 +++++----
 net/sunrpc/svc_rdma_recvfrom.c  |    5 +++--
 net/sunrpc/svc_rdma_sendto.c    |    2 +-
 4 files changed, 18 insertions(+), 8 deletions(-)

Index: linux-2.6.16/net/sunrpc/svc_rdma_marshal.c
===================================================================
--- linux-2.6.16.orig/net/sunrpc/svc_rdma_marshal.c	2007-05-23 23:52:47.570678914 +1000
+++ linux-2.6.16/net/sunrpc/svc_rdma_marshal.c	2007-05-23 23:52:54.533766827 +1000
@@ -201,7 +201,7 @@ static u32 *decode_reply_array(u32 *va, 
 	return (u32*)&ary->wc_array[ch_no];
 }
 
-int svc_rdma_xdr_decode_req(struct rpcrdma_msg **rdma_req, struct svc_rqst *rqstp)
+int svc_rdma_xdr_decode_req(struct svc_rqst *rqstp)
 {
 	struct rpcrdma_msg *rmsgp = NULL;
 	u32 *va;
@@ -238,8 +238,8 @@ int svc_rdma_xdr_decode_req(struct rpcrd
 		rqstp->rq_arg.head[0].iov_base = va;
 		hdrlen = (u32)((unsigned long)va - (unsigned long)rmsgp);
 		rqstp->rq_arg.head[0].iov_len -= hdrlen;
-		if (hdrlen > rqstp->rq_arg.len)
-			return -EINVAL;
+		BUG_ON(hdrlen > rqstp->rq_arg.len);
+		rqstp->rq_arg.len -= hdrlen;
 		return hdrlen;
 	}
 
@@ -261,8 +261,9 @@ int svc_rdma_xdr_decode_req(struct rpcrd
 	rqstp->rq_arg.head[0].iov_base = va;
 	hdr_len = (unsigned long)va - (unsigned long)rmsgp;
 	rqstp->rq_arg.head[0].iov_len -= hdr_len;
+	rqstp->rq_arg.len -= hdr_len;
+	rqstp->rq_arg.trans_header = hdr_len;
 
-	*rdma_req = rmsgp;
 	return hdr_len;
 }
 
Index: linux-2.6.16/include/linux/sunrpc/svc_rdma.h
===================================================================
--- linux-2.6.16.orig/include/linux/sunrpc/svc_rdma.h	2007-05-23 23:52:52.306058630 +1000
+++ linux-2.6.16/include/linux/sunrpc/svc_rdma.h	2007-05-23 23:52:54.545765256 +1000
@@ -136,9 +136,17 @@ struct svcxprt_rdma {
 #define RPCRDMA_MAX_REQUESTS    2048
 #define RPCRDMA_MAX_REQ_SIZE    4096
 
+static inline struct rpcrdma_msg *
+svc_rdma_get_chunk_header(struct svc_rqst *rqstp)
+{
+	struct xdr_buf *a = &rqstp->rq_arg;
+	return (struct rpcrdma_msg *)
+		(((char *)a->head[0].iov_base) - a->trans_header);
+}
+
 /* svc_rdma_marshal.c */
 extern void svc_rdma_rcl_chunk_counts(struct rpcrdma_read_chunk *, int *, int *);
-extern int svc_rdma_xdr_decode_req(struct rpcrdma_msg**, struct svc_rqst *);
+extern int svc_rdma_xdr_decode_req(struct svc_rqst *);
 extern int svc_rdma_xdr_encode_error(struct svcxprt_rdma*, struct rpcrdma_msg*,
 				     enum rpcrdma_errcode, u32*);
 extern void svc_rdma_xdr_encode_write_list(struct rpcrdma_msg *, int);
Index: linux-2.6.16/net/sunrpc/svc_rdma_recvfrom.c
===================================================================
--- linux-2.6.16.orig/net/sunrpc/svc_rdma_recvfrom.c	2007-05-23 23:52:52.182074871 +1000
+++ linux-2.6.16/net/sunrpc/svc_rdma_recvfrom.c	2007-05-24 00:25:19.034648728 +1000
@@ -479,8 +479,9 @@ int svc_rdma_recvfrom(struct svc_rqst *r
 	svc_rdma_put_context(ctxt, 0);
 
 	/* Decode the RDMA header. */
-	len = svc_rdma_xdr_decode_req(&rmsgp, rqstp);
-	DBG_DUMP_RDMAHDR(__FUNCTION__, page_address(rqstp->rq_argpages[0]));
+	len = svc_rdma_xdr_decode_req(rqstp);
+	rmsgp = svc_rdma_get_chunk_header(rqstp);
+	DBG_DUMP_RDMAHDR(__FUNCTION__, rmsgp);
 
 	/* If the request is invalid, reply with an error */
 	if (len < 0) {
Index: linux-2.6.16/net/sunrpc/svc_rdma_sendto.c
===================================================================
--- linux-2.6.16.orig/net/sunrpc/svc_rdma_sendto.c	2007-05-23 23:52:52.310058107 +1000
+++ linux-2.6.16/net/sunrpc/svc_rdma_sendto.c	2007-05-23 23:52:54.549764732 +1000
@@ -469,7 +469,7 @@ int svc_rdma_sendto(struct svc_rqst *rqs
 	(void)svc_rdma_post_recv(rdma);
 
 	/* Get the RDMA request header. */
-	rdma_argp = page_address(rqstp->rq_argpages[0]);
+	rdma_argp = svc_rdma_get_chunk_header(rqstp);
 	DBG_DUMP_RDMAHDR(__FUNCTION__, rdma_argp);
 
 	/* Build an SGE for the XDR */
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
