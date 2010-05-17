From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 21/24] NFS: Decode NFSv2 write reply using an xdr_stream
Date: Sun, 16 May 2010 22:48:43 -0400
Message-ID: <20100517024842.20258.70361.stgit@localhost.localdomain>
References: <20100517023905.20258.86631.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f171.google.com ([209.85.221.171]:63658 "EHLO
	mail-qy0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752923Ab0EQCso (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 16 May 2010 22:48:44 -0400
Received: by mail-qy0-f171.google.com with SMTP id 1so6350026qyk.5
        for <linux-nfs@vger.kernel.org>; Sun, 16 May 2010 19:48:44 -0700 (PDT)
In-Reply-To: <20100517023905.20258.86631.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs2xdr.c |   19 +++++++++++++++++++
 1 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 807c1b1..565a5c6 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -1090,6 +1090,25 @@ nfs_xdr_writeres(struct rpc_rqst *req, __be32 *p, struct nfs_writeres *res)
 	return nfs_xdr_attrstat(req, p, res->fattr);
 }
 
+static int nfs2_xdr_dec_writeres(struct rpc_rqst *req, __be32 *p,
+				 struct nfs_writeres *result)
+{
+	struct xdr_stream xdr;
+	enum nfs_stat status;
+
+	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
+	if (decode_stat(&xdr, &status) != 0)
+		return -EIO;
+	if (status != NFS_OK)
+		return nfs_stat_to_errno(status);
+	if (decode_fattr(&xdr, result->fattr) != 0)
+		return -EIO;
+
+	/* All NFSv2 writes are "file sync" writes */
+	result->verf->committed = NFS_FILE_SYNC;
+	return 0;
+}
+
 /*
  * Decode STATFS reply
  */

