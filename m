From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 20/24] NFS: Decode NFSv2 read reply using an xdr_stream
Date: Sun, 16 May 2010 22:48:34 -0400
Message-ID: <20100517024834.20258.49846.stgit@localhost.localdomain>
References: <20100517023905.20258.86631.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f171.google.com ([209.85.221.171]:63658 "EHLO
	mail-qy0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752894Ab0EQCsg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 16 May 2010 22:48:36 -0400
Received: by mail-qy0-f171.google.com with SMTP id 1so6350026qyk.5
        for <linux-nfs@vger.kernel.org>; Sun, 16 May 2010 19:48:35 -0700 (PDT)
In-Reply-To: <20100517023905.20258.86631.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs2xdr.c |   49 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 49 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 164c06d..807c1b1 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -1032,6 +1032,55 @@ static int nfs2_xdr_dec_readlinkres(struct rpc_rqst *req, __be32 *p,
 }
 
 /*
+ * 2.2.7.  readres
+ *
+ *	union readres switch (stat status) {
+ *	case NFS_OK:
+ *		fattr attributes;
+ *		nfsdata data;
+ *	default:
+ *		void;
+ *	};
+ */
+static int nfs2_xdr_dec_readres(struct rpc_rqst *req, __be32 *p,
+				struct nfs_readres *result)
+{
+	struct xdr_stream xdr;
+	enum nfs_stat status;
+	u32 recvd, count;
+	size_t hdrlen;
+
+	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
+	if (decode_stat(&xdr, &status) != 0)
+		return -EIO;
+	if (status != NFS_OK)
+		return nfs_stat_to_errno(status);
+	if (decode_fattr(&xdr, result->fattr) != 0)
+		return -EIO;
+
+	/* nfsdata */
+	p = xdr_inline_decode(&xdr, 4);
+	if (unlikely(p == NULL)) {
+		print_overflow_msg(__func__, &xdr);
+		return -EIO;
+	}
+	count = be32_to_cpup(p);
+	hdrlen = (u8 *)xdr.p - (u8 *)xdr.iov->iov_base;
+	recvd = xdr.buf->len - hdrlen;
+	if (count > recvd) {
+		dprintk("NFS: server cheating in read result: "
+			"count %u > recvd %u\n", count, recvd);
+		count = recvd;
+	}
+	xdr_read_pages(&xdr, count);
+
+	/* NFSv2 doesn't pass EOF flag on the wire. */
+	result->eof = 0;
+	result->count = count;
+	return count;
+}
+
+/*
  * Decode WRITE reply
  */
 static int

