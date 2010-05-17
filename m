From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/24] NFS: Encode NFSv2 rename argument using an xdr_stream
Date: Sun, 16 May 2010 22:47:06 -0400
Message-ID: <20100517024706.20258.94169.stgit@localhost.localdomain>
References: <20100517023905.20258.86631.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f171.google.com ([209.85.221.171]:63658 "EHLO
	mail-qy0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752314Ab0EQCrI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 16 May 2010 22:47:08 -0400
Received: by mail-qy0-f171.google.com with SMTP id 1so6350026qyk.5
        for <linux-nfs@vger.kernel.org>; Sun, 16 May 2010 19:47:07 -0700 (PDT)
In-Reply-To: <20100517023905.20258.86631.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs2xdr.c |   19 +++++++++++++++++++
 1 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 75583e8..493c3a1 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -843,6 +843,25 @@ nfs_xdr_renameargs(struct rpc_rqst *req, __be32 *p, struct nfs_renameargs *args)
 }
 
 /*
+ * 2.2.12.  renameargs
+ *
+ *	struct renameargs {
+ *		diropargs from;
+ *		diropargs to;
+ *	};
+ */
+static int nfs2_xdr_enc_renameargs(struct rpc_rqst *req, __be32 *p,
+				   struct nfs_renameargs *args)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_diropargs(&xdr, args->fromfh, args->fromname, args->fromlen);
+	encode_diropargs(&xdr, args->tofh, args->toname, args->tolen);
+	return 0;
+}
+
+/*
  * Encode LINK arguments
  */
 static int

