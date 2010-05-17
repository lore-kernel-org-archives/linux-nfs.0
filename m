From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 19/24] NFS: Decode NFSv2 readlink reply using an xdr_stream
Date: Sun, 16 May 2010 22:48:25 -0400
Message-ID: <20100517024825.20258.99905.stgit@localhost.localdomain>
References: <20100517023905.20258.86631.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f171.google.com ([209.85.221.171]:63658 "EHLO
	mail-qy0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752444Ab0EQCs1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 16 May 2010 22:48:27 -0400
Received: by mail-qy0-f171.google.com with SMTP id 1so6350026qyk.5
        for <linux-nfs@vger.kernel.org>; Sun, 16 May 2010 19:48:27 -0700 (PDT)
In-Reply-To: <20100517023905.20258.86631.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs2xdr.c |   24 ++++++++++++++++++++++++
 1 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index b464c0b..164c06d 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -1008,6 +1008,30 @@ nfs_xdr_readlinkres(struct rpc_rqst *req, __be32 *p, void *dummy)
 }
 
 /*
+ * 2.2.6.  readlinkres
+ *
+ *	union readlinkres switch (stat status) {
+ *	case NFS_OK:
+ *		path data;
+ *	default:
+ *		void;
+ *	};
+ */
+static int nfs2_xdr_dec_readlinkres(struct rpc_rqst *req, __be32 *p,
+				    void *__unused)
+{
+	struct xdr_stream xdr;
+	enum nfs_stat status;
+
+	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
+	if (decode_stat(&xdr, &status) != 0)
+		return -EIO;
+	if (status != NFS_OK)
+		return nfs_stat_to_errno(status);
+	return decode_path(&xdr);
+}
+
+/*
  * Decode WRITE reply
  */
 static int

