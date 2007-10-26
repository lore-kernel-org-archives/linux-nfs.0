From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 15/27] NFS: Use unsigned intermediates for
	manipulating header	lengths (NFSv3 XDR)
Date: Fri, 26 Oct 2007 13:31:57 -0400
Message-ID: <20071026173157.31475.97314.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IlT2Y-0007KI-QR
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:32:10 -0700
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]
	helo=flpi185.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IlT2e-00007k-5e
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:32:16 -0700
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
unmarshalling NFS version 3 read, readdir, and readlink replies.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs3xdr.c |   27 +++++++++++++++------------
 1 files changed, 15 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 616d326..3917e2f 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -506,9 +506,9 @@ nfs3_xdr_readdirres(struct rpc_rqst *req, __be32 *p, struct nfs3_readdirres *res
 	struct xdr_buf *rcvbuf = &req->rq_rcv_buf;
 	struct kvec *iov = rcvbuf->head;
 	struct page **page;
-	int hdrlen, recvd;
+	size_t hdrlen;
+	u32 len, recvd, pglen;
 	int status, nr;
-	unsigned int len, pglen;
 	__be32 *entry, *end, *kaddr;
 
 	status = ntohl(*p++);
@@ -527,7 +527,7 @@ nfs3_xdr_readdirres(struct rpc_rqst *req, __be32 *p, struct nfs3_readdirres *res
 	hdrlen = (u8 *) p - (u8 *) iov->iov_base;
 	if (iov->iov_len < hdrlen) {
 		dprintk("NFS: READDIR reply header overflowed:"
-				"length %d > %Zu\n", hdrlen, iov->iov_len);
+				"length %Zu > %Zu\n", hdrlen, iov->iov_len);
 		return -errno_NFSERR_IO;
 	} else if (iov->iov_len != hdrlen) {
 		dprintk("NFS: READDIR header is short. iovec will be shifted.\n");
@@ -549,7 +549,7 @@ nfs3_xdr_readdirres(struct rpc_rqst *req, __be32 *p, struct nfs3_readdirres *res
 		len = ntohl(*p++);		/* string length */
 		p += XDR_QUADLEN(len) + 2;	/* name + cookie */
 		if (len > NFS3_MAXNAMLEN) {
-			dprintk("NFS: giant filename in readdir (len %x)!\n",
+			dprintk("NFS: giant filename in readdir (len 0x%x)!\n",
 						len);
 			goto err_unmap;
 		}
@@ -570,7 +570,7 @@ nfs3_xdr_readdirres(struct rpc_rqst *req, __be32 *p, struct nfs3_readdirres *res
 				len = ntohl(*p++);
 				if (len > NFS3_FHSIZE) {
 					dprintk("NFS: giant filehandle in "
-						"readdir (len %x)!\n", len);
+						"readdir (len 0x%x)!\n", len);
 					goto err_unmap;
 				}
 				p += XDR_QUADLEN(len);
@@ -815,7 +815,8 @@ nfs3_xdr_readlinkres(struct rpc_rqst *req, __be32 *p, struct nfs_fattr *fattr)
 {
 	struct xdr_buf *rcvbuf = &req->rq_rcv_buf;
 	struct kvec *iov = rcvbuf->head;
-	int hdrlen, len, recvd;
+	size_t hdrlen;
+	u32 len, recvd;
 	char	*kaddr;
 	int	status;
 
@@ -827,7 +828,7 @@ nfs3_xdr_readlinkres(struct rpc_rqst *req, __be32 *p, struct nfs_fattr *fattr)
 
 	/* Convert length of symlink */
 	len = ntohl(*p++);
-	if (len >= rcvbuf->page_len || len <= 0) {
+	if (len >= rcvbuf->page_len) {
 		dprintk("nfs: server returned giant symlink!\n");
 		return -ENAMETOOLONG;
 	}
@@ -835,7 +836,7 @@ nfs3_xdr_readlinkres(struct rpc_rqst *req, __be32 *p, struct nfs_fattr *fattr)
 	hdrlen = (u8 *) p - (u8 *) iov->iov_base;
 	if (iov->iov_len < hdrlen) {
 		dprintk("NFS: READLINK reply header overflowed:"
-				"length %d > %Zu\n", hdrlen, iov->iov_len);
+				"length %Zu > %Zu\n", hdrlen, iov->iov_len);
 		return -errno_NFSERR_IO;
 	} else if (iov->iov_len != hdrlen) {
 		dprintk("NFS: READLINK header is short. "
@@ -863,7 +864,9 @@ static int
 nfs3_xdr_readres(struct rpc_rqst *req, __be32 *p, struct nfs_readres *res)
 {
 	struct kvec *iov = req->rq_rcv_buf.head;
-	int	status, count, ocount, recvd, hdrlen;
+	size_t hdrlen;
+	u32 count, ocount, recvd;
+	int status;
 
 	status = ntohl(*p++);
 	p = xdr_decode_post_op_attr(p, res->fattr);
@@ -871,7 +874,7 @@ nfs3_xdr_readres(struct rpc_rqst *req, __be32 *p, struct nfs_readres *res)
 	if (status != 0)
 		return -nfs_stat_to_errno(status);
 
-	/* Decode reply could and EOF flag. NFSv3 is somewhat redundant
+	/* Decode reply count and EOF flag. NFSv3 is somewhat redundant
 	 * in that it puts the count both in the res struct and in the
 	 * opaque data count. */
 	count    = ntohl(*p++);
@@ -886,7 +889,7 @@ nfs3_xdr_readres(struct rpc_rqst *req, __be32 *p, struct nfs_readres *res)
 	hdrlen = (u8 *) p - (u8 *) iov->iov_base;
 	if (iov->iov_len < hdrlen) {
 		dprintk("NFS: READ reply header overflowed:"
-				"length %d > %Zu\n", hdrlen, iov->iov_len);
+				"length %Zu > %Zu\n", hdrlen, iov->iov_len);
        		return -errno_NFSERR_IO;
 	} else if (iov->iov_len != hdrlen) {
 		dprintk("NFS: READ header is short. iovec will be shifted.\n");
@@ -896,7 +899,7 @@ nfs3_xdr_readres(struct rpc_rqst *req, __be32 *p, struct nfs_readres *res)
 	recvd = req->rq_rcv_buf.len - hdrlen;
 	if (count > recvd) {
 		dprintk("NFS: server cheating in read reply: "
-			"count %d > recvd %d\n", count, recvd);
+			"count %u > recvd %u\n", count, recvd);
 		count = recvd;
 		res->eof = 0;
 	}


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
