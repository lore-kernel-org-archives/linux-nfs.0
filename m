From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 23/24] NFS: Decode NFSv2 statfs reply using an xdr_stream
Date: Sun, 16 May 2010 22:49:00 -0400
Message-ID: <20100517024900.20258.82101.stgit@localhost.localdomain>
References: <20100517023905.20258.86631.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f171.google.com ([209.85.221.171]:63658 "EHLO
	mail-qy0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753021Ab0EQCtC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 16 May 2010 22:49:02 -0400
Received: by mail-qy0-f171.google.com with SMTP id 1so6350026qyk.5
        for <linux-nfs@vger.kernel.org>; Sun, 16 May 2010 19:49:02 -0700 (PDT)
In-Reply-To: <20100517023905.20258.86631.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs2xdr.c |   41 +++++++++++++++++++++++++++++++++++++++++
 1 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 1d65103..3d373d1 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -1260,6 +1260,47 @@ nfs_xdr_statfsres(struct rpc_rqst *req, __be32 *p, struct nfs2_fsstat *res)
 }
 
 /*
+ * 2.2.18.  statfsres
+ *
+ *	union statfsres (stat status) {
+ *	case NFS_OK:
+ *		struct {
+ *			unsigned tsize;
+ *			unsigned bsize;
+ *			unsigned blocks;
+ *			unsigned bfree;
+ *			unsigned bavail;
+ *		} info;
+ *	default:
+ *		void;
+ *	};
+ */
+static int nfs2_xdr_dec_statfsres(struct rpc_rqst *req, __be32 *p,
+				  struct nfs2_fsstat *result)
+{
+	struct xdr_stream xdr;
+	enum nfs_stat status;
+
+	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
+	if (decode_stat(&xdr, &status) != 0)
+		return -EIO;
+	if (status != NFS_OK)
+		return nfs_stat_to_errno(status);
+
+	/* info */
+	p = xdr_inline_decode(&xdr, NFS_info_sz << 2);
+	if (unlikely(p == NULL))
+		return -EIO;
+	result->tsize  = be32_to_cpup(p++);
+	result->bsize  = be32_to_cpup(p++);
+	result->blocks = be32_to_cpup(p++);
+	result->bfree  = be32_to_cpup(p++);
+	result->bavail = be32_to_cpup(p);
+	return 0;
+}
+
+
+/*
  * We need to translate between nfs status return values and
  * the local errno values which may not be the same.
  */

