From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/24] NFS: Encode NFSv2 create argument using an xdr_stream
Date: Sun, 16 May 2010 22:46:57 -0400
Message-ID: <20100517024657.20258.977.stgit@localhost.localdomain>
References: <20100517023905.20258.86631.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f171.google.com ([209.85.221.171]:63658 "EHLO
	mail-qy0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752314Ab0EQCq7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 16 May 2010 22:46:59 -0400
Received: by mail-qy0-f171.google.com with SMTP id 1so6350026qyk.5
        for <linux-nfs@vger.kernel.org>; Sun, 16 May 2010 19:46:59 -0700 (PDT)
In-Reply-To: <20100517023905.20258.86631.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs2xdr.c |   19 +++++++++++++++++++
 1 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 13c9975..75583e8 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -810,6 +810,25 @@ nfs_xdr_createargs(struct rpc_rqst *req, __be32 *p, struct nfs_createargs *args)
 }
 
 /*
+ * 2.2.10.  createargs
+ *
+ *	struct createargs {
+ *		diropargs where;
+ *		sattr attributes;
+ *	};
+ */
+static int nfs2_xdr_enc_createargs(struct rpc_rqst *req, __be32 *p,
+				   const struct nfs_createargs *args)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_diropargs(&xdr, args->fh, args->name, args->len);
+	encode_sattr(&xdr, args->sattr);
+	return 0;
+}
+
+/*
  * Encode RENAME arguments
  */
 static int

