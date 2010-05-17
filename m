From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 12/24] NFS: Encode NFSv2 symlink argument using an xdr_stream
Date: Sun, 16 May 2010 22:47:23 -0400
Message-ID: <20100517024723.20258.12947.stgit@localhost.localdomain>
References: <20100517023905.20258.86631.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f171.google.com ([209.85.221.171]:63658 "EHLO
	mail-qy0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752314Ab0EQCrZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 16 May 2010 22:47:25 -0400
Received: by mail-qy0-f171.google.com with SMTP id 1so6350026qyk.5
        for <linux-nfs@vger.kernel.org>; Sun, 16 May 2010 19:47:25 -0700 (PDT)
In-Reply-To: <20100517023905.20258.86631.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs2xdr.c |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 48c8e88..42f7461 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -923,6 +923,27 @@ nfs_xdr_symlinkargs(struct rpc_rqst *req, __be32 *p, struct nfs_symlinkargs *arg
 }
 
 /*
+ * 2.2.14.  symlinkargs
+ *
+ *	struct symlinkargs {
+ *		diropargs from;
+ *		path to;
+ *		sattr attributes;
+ *	};
+ */
+static int nfs2_xdr_enc_symlinkargs(struct rpc_rqst *req, __be32 *p,
+				    struct nfs_symlinkargs *args)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_diropargs(&xdr, args->fromfh, args->fromname, args->fromlen);
+	encode_path(&xdr, args->pages, args->pathlen);
+	encode_sattr(&xdr, args->sattr);
+	return 0;
+}
+
+/*
  * Encode arguments to readdir call
  */
 static int

