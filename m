From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 16/27] NFS: Use unsigned intermediates for
	manipulating header	lengths (NFSv4 XDR)
Date: Fri, 26 Oct 2007 13:32:03 -0400
Message-ID: <20071026173203.31475.4819.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IlT2b-0007KS-BO
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:32:13 -0700
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]
	helo=flpi185.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IlT2g-00008d-P3
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:32:18 -0700
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

Clean up: prevent length underflow and mixed sign comparison when
unmarshalling NFS version 4 getacl, readdir, and readlink replies.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4xdr.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 51dd380..2e1fe17 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -3476,10 +3476,11 @@ static int decode_readdir(struct xdr_stream *xdr, struct rpc_rqst *req, struct n
 	struct xdr_buf	*rcvbuf = &req->rq_rcv_buf;
 	struct page	*page = *rcvbuf->pages;
 	struct kvec	*iov = rcvbuf->head;
-	unsigned int	nr, pglen = rcvbuf->page_len;
+	size_t		hdrlen;
+	u32		recvd, pglen = rcvbuf->page_len;
 	__be32		*end, *entry, *p, *kaddr;
-	uint32_t	len, attrlen, xlen;
-	int 		hdrlen, recvd, status;
+	unsigned int	nr;
+	int		status;
 
 	status = decode_op_hdr(xdr, OP_READDIR);
 	if (status)
@@ -3503,6 +3504,7 @@ static int decode_readdir(struct xdr_stream *xdr, struct rpc_rqst *req, struct n
 	end = p + ((pglen + readdir->pgbase) >> 2);
 	entry = p;
 	for (nr = 0; *p++; nr++) {
+		u32 len, attrlen, xlen;
 		if (end - p < 3)
 			goto short_pkt;
 		dprintk("cookie = %Lu, ", *((unsigned long long *)p));
@@ -3551,7 +3553,8 @@ static int decode_readlink(struct xdr_stream *xdr, struct rpc_rqst *req)
 {
 	struct xdr_buf *rcvbuf = &req->rq_rcv_buf;
 	struct kvec *iov = rcvbuf->head;
-	int hdrlen, len, recvd;
+	size_t hdrlen;
+	u32 len, recvd;
 	__be32 *p;
 	char *kaddr;
 	int status;
@@ -3646,7 +3649,8 @@ static int decode_getacl(struct xdr_stream *xdr, struct rpc_rqst *req,
 	if (unlikely(bitmap[0] & (FATTR4_WORD0_ACL - 1U)))
 		return -EIO;
 	if (likely(bitmap[0] & FATTR4_WORD0_ACL)) {
-		int hdrlen, recvd;
+		size_t hdrlen;
+		u32 recvd;
 
 		/* We ignore &savep and don't do consistency checks on
 		 * the attr length.  Let userspace figure it out.... */


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
