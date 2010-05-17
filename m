From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 16/24] NFS: Decode NFSv2 stat reply using an xdr_stream
Date: Sun, 16 May 2010 22:47:59 -0400
Message-ID: <20100517024759.20258.17793.stgit@localhost.localdomain>
References: <20100517023905.20258.86631.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f171.google.com ([209.85.221.171]:63658 "EHLO
	mail-qy0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752444Ab0EQCsB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 16 May 2010 22:48:01 -0400
Received: by mail-qy0-f171.google.com with SMTP id 1so6350026qyk.5
        for <linux-nfs@vger.kernel.org>; Sun, 16 May 2010 19:48:00 -0700 (PDT)
In-Reply-To: <20100517023905.20258.86631.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs2xdr.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index f0eab7e..db04feb 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -871,6 +871,20 @@ nfs_xdr_stat(struct rpc_rqst *req, __be32 *p, void *dummy)
 	return status;
 }
 
+static int nfs2_xdr_dec_stat(struct rpc_rqst *req, __be32 *p,
+			     void *__unused)
+{
+	struct xdr_stream xdr;
+	enum nfs_stat status;
+
+	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
+	if (decode_stat(&xdr, &status) != 0)
+		return -EIO;
+	if (status != NFS_OK)
+		return nfs_stat_to_errno(status);
+	return 0;
+}
+
 /*
  * Decode attrstat reply
  * GETATTR, SETATTR, WRITE

