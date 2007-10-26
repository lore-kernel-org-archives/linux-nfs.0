From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 14/27] NFS: Use unsigned intermediates for
	manipulating header	lengths (NFSv2 XDR)
Date: Fri, 26 Oct 2007 13:31:52 -0400
Message-ID: <20071026173152.31475.96442.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IlT2R-0007GM-0q
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:32:03 -0700
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]
	helo=flpi185.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IlT2W-0008UI-EF
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:32:08 -0700
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

Clean up: prevent length underflow and mixed sign comparisons when
unmarshalling NFS version 2 read, readdir, and readlink replies.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs2xdr.c |   24 ++++++++++++++----------
 1 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 668ab96..1f7ea67 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -262,7 +262,9 @@ static int
 nfs_xdr_readres(struct rpc_rqst *req, __be32 *p, struct nfs_readres *res)
 {
 	struct kvec *iov = req->rq_rcv_buf.head;
-	int	status, count, recvd, hdrlen;
+	size_t hdrlen;
+	u32 count, recvd;
+	int status;
 
 	if ((status = ntohl(*p++)))
 		return -nfs_stat_to_errno(status);
@@ -273,7 +275,7 @@ nfs_xdr_readres(struct rpc_rqst *req, __be32 *p, struct nfs_readres *res)
 	hdrlen = (u8 *) p - (u8 *) iov->iov_base;
 	if (iov->iov_len < hdrlen) {
 		dprintk("NFS: READ reply header overflowed:"
-				"length %d > %Zu\n", hdrlen, iov->iov_len);
+				"length %Zu > %Zu\n", hdrlen, iov->iov_len);
 		return -errno_NFSERR_IO;
 	} else if (iov->iov_len != hdrlen) {
 		dprintk("NFS: READ header is short. iovec will be shifted.\n");
@@ -283,11 +285,11 @@ nfs_xdr_readres(struct rpc_rqst *req, __be32 *p, struct nfs_readres *res)
 	recvd = req->rq_rcv_buf.len - hdrlen;
 	if (count > recvd) {
 		dprintk("NFS: server cheating in read reply: "
-			"count %d > recvd %d\n", count, recvd);
+			"count %u > recvd %u\n", count, recvd);
 		count = recvd;
 	}
 
-	dprintk("RPC:      readres OK count %d\n", count);
+	dprintk("RPC:      readres OK count %u\n", count);
 	if (count < res->count)
 		res->count = count;
 
@@ -423,9 +425,10 @@ nfs_xdr_readdirres(struct rpc_rqst *req, __be32 *p, void *dummy)
 	struct xdr_buf *rcvbuf = &req->rq_rcv_buf;
 	struct kvec *iov = rcvbuf->head;
 	struct page **page;
-	int hdrlen, recvd;
+	size_t hdrlen;
+	unsigned int pglen, recvd;
+	u32 len;
 	int status, nr;
-	unsigned int len, pglen;
 	__be32 *end, *entry, *kaddr;
 
 	if ((status = ntohl(*p++)))
@@ -434,7 +437,7 @@ nfs_xdr_readdirres(struct rpc_rqst *req, __be32 *p, void *dummy)
 	hdrlen = (u8 *) p - (u8 *) iov->iov_base;
 	if (iov->iov_len < hdrlen) {
 		dprintk("NFS: READDIR reply header overflowed:"
-				"length %d > %Zu\n", hdrlen, iov->iov_len);
+				"length %Zu > %Zu\n", hdrlen, iov->iov_len);
 		return -errno_NFSERR_IO;
 	} else if (iov->iov_len != hdrlen) {
 		dprintk("NFS: READDIR header is short. iovec will be shifted.\n");
@@ -576,7 +579,8 @@ nfs_xdr_readlinkres(struct rpc_rqst *req, __be32 *p, void *dummy)
 {
 	struct xdr_buf *rcvbuf = &req->rq_rcv_buf;
 	struct kvec *iov = rcvbuf->head;
-	int hdrlen, len, recvd;
+	size_t hdrlen;
+	u32 len, recvd;
 	char	*kaddr;
 	int	status;
 
@@ -584,14 +588,14 @@ nfs_xdr_readlinkres(struct rpc_rqst *req, __be32 *p, void *dummy)
 		return -nfs_stat_to_errno(status);
 	/* Convert length of symlink */
 	len = ntohl(*p++);
-	if (len >= rcvbuf->page_len || len <= 0) {
+	if (len >= rcvbuf->page_len) {
 		dprintk("nfs: server returned giant symlink!\n");
 		return -ENAMETOOLONG;
 	}
 	hdrlen = (u8 *) p - (u8 *) iov->iov_base;
 	if (iov->iov_len < hdrlen) {
 		dprintk("NFS: READLINK reply header overflowed:"
-				"length %d > %Zu\n", hdrlen, iov->iov_len);
+				"length %Zu > %Zu\n", hdrlen, iov->iov_len);
 		return -errno_NFSERR_IO;
 	} else if (iov->iov_len != hdrlen) {
 		dprintk("NFS: READLINK header is short. iovec will be shifted.\n");


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
