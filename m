Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f171.google.com ([209.85.213.171]:53212 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753131AbbAMQDz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Jan 2015 11:03:55 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v2 10/10] svcrdma: Handle additional inline content
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date: Tue, 13 Jan 2015 11:03:53 -0500
Message-ID: <20150113160353.8118.98740.stgit@klimt.1015granger.net>
In-Reply-To: <20150113155904.8118.57718.stgit@klimt.1015granger.net>
References: <20150113155904.8118.57718.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Most NFS RPCs place their large payload argument at the end of the
RPC header (eg, NFSv3 WRITE). For NFSv3 WRITE and SYMLINK, RPC/RDMA
sends the complete RPC header inline, and the payload argument in
the read list. Data in the read list is the last part of the XDR
stream.

One important case is not like this, however. NFSv4 COMPOUND is a
counted array of operations. A WRITE operation, with its large data
payload, can appear in the middle of the compound's operations
array. Thus NFSv4 WRITE compounds can have header content after the
WRITE payload.

The Linux client, for example, performs an NFSv4 WRITE like this:

  { PUTFH, WRITE, GETATTR }

Though RFC 5667 is not precise about this, the proper way to convey
this compound is to place the GETATTR inline, _after_ the front of
the RPC header. The receiver inserts the read list payload into the
XDR stream after the initial WRITE arguments, and before the GETATTR
operation, thanks to the value of the read list "position" field.

The Linux client currently sends the GETATTR at the end of the
RPC/RDMA read list, which is incorrect. It will be corrected in the
future.

The Linux server currently rejects NFSv4 compounds with inline
content after the read list. For the above NFSv4 WRITE compound, the
NFS compound header indicates there are three operations, but the
server finds nonsense when it looks in the XDR stream for the third
operation, and the compound fails with OP_ILLEGAL.

Move trailing inline content to the end of the XDR buffer's page
list. This presents incoming NFSv4 WRITE compounds to NFSD in the
same way the socket transport does.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |   55 +++++++++++++++++++++++++++++++
 1 files changed, 55 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index a345cad..f9f13a3 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -364,6 +364,56 @@ rdma_rcl_chunk_count(struct rpcrdma_read_chunk *ch)
 	return count;
 }
 
+/* If there was additional inline content, append it to the end of arg.pages.
+ * Tail copy has to be done after the reader function has determined how many
+ * pages are needed for RDMA READ.
+ */
+static int
+rdma_copy_tail(struct svc_rqst *rqstp, struct svc_rdma_op_ctxt *head,
+	       u32 position, u32 byte_count, u32 page_offset, int page_no)
+{
+	char *srcp, *destp;
+	int ret;
+
+	ret = 0;
+	srcp = head->arg.head[0].iov_base + position;
+	byte_count = head->arg.head[0].iov_len - position;
+	if (byte_count > PAGE_SIZE) {
+		dprintk("svcrdma: large tail unsupported\n");
+		return 0;
+	}
+
+	/* Fit as much of the tail on the current page as possible */
+	if (page_offset != PAGE_SIZE) {
+		destp = page_address(rqstp->rq_arg.pages[page_no]);
+		destp += page_offset;
+		while (byte_count--) {
+			*destp++ = *srcp++;
+			page_offset++;
+			if (page_offset == PAGE_SIZE && byte_count)
+				goto more;
+		}
+		goto done;
+	}
+
+more:
+	/* Fit the rest on the next page */
+	page_no++;
+	destp = page_address(rqstp->rq_arg.pages[page_no]);
+	while (byte_count--)
+		*destp++ = *srcp++;
+
+	rqstp->rq_respages = &rqstp->rq_arg.pages[page_no+1];
+	rqstp->rq_next_page = rqstp->rq_respages + 1;
+
+done:
+	byte_count = head->arg.head[0].iov_len - position;
+	head->arg.page_len += byte_count;
+	head->arg.len += byte_count;
+	head->arg.buflen += byte_count;
+	return 1;
+}
+
 static int rdma_read_chunks(struct svcxprt_rdma *xprt,
 			    struct rpcrdma_msg *rmsgp,
 			    struct svc_rqst *rqstp,
@@ -440,9 +490,14 @@ static int rdma_read_chunks(struct svcxprt_rdma *xprt,
 		head->arg.page_len += pad;
 		head->arg.len += pad;
 		head->arg.buflen += pad;
+		page_offset += pad;
 	}
 
 	ret = 1;
+	if (position && position < head->arg.head[0].iov_len)
+		ret = rdma_copy_tail(rqstp, head, position,
+				     byte_count, page_offset, page_no);
+	head->arg.head[0].iov_len = position;
 	head->position = position;
 
  err:

