From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 13/24] NFS: Encode NFSv2 readdir argument using an xdr_stream
Date: Sun, 16 May 2010 22:47:32 -0400
Message-ID: <20100517024732.20258.40871.stgit@localhost.localdomain>
References: <20100517023905.20258.86631.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f171.google.com ([209.85.221.171]:63658 "EHLO
	mail-qy0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752216Ab0EQCre (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 16 May 2010 22:47:34 -0400
Received: by mail-qy0-f171.google.com with SMTP id 1so6350026qyk.5
        for <linux-nfs@vger.kernel.org>; Sun, 16 May 2010 19:47:34 -0700 (PDT)
In-Reply-To: <20100517023905.20258.86631.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs2xdr.c |   30 ++++++++++++++++++++++++++++++
 1 files changed, 30 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 42f7461..47809ac 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -966,6 +966,36 @@ nfs_xdr_readdirargs(struct rpc_rqst *req, __be32 *p, struct nfs_readdirargs *arg
 }
 
 /*
+ * 2.2.17.  readdirargs
+ *
+ *	struct readdirargs {
+ *		fhandle dir;
+ *		nfscookie cookie;
+ *		unsigned count;
+ *	};
+ */
+static int nfs2_xdr_enc_readdirargs(struct rpc_rqst *req, __be32 *p,
+				    struct nfs_readdirargs *args)
+{
+	struct rpc_auth	*auth = req->rq_task->tk_msg.rpc_cred->cr_auth;
+	u32 count = args->count;
+	unsigned int replen;
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_fhandle(&xdr, args->fh);
+	p = xdr_reserve_space(&xdr, 8);
+	BUG_ON(unlikely(p == NULL));
+	*p++ = cpu_to_be32(args->cookie);
+	*p = cpu_to_be32(count);
+
+	/* Prepare reply buffer to receive readdir data */
+	replen = (RPC_REPHDRSIZE + auth->au_rslack + NFS_readdirres_sz) << 2;
+	xdr_inline_pages(&req->rq_rcv_buf, replen, args->pages, 0, count);
+	return 0;
+}
+
+/*
  * Decode the result of a readdir call.
  * We're not really decoding anymore, we just leave the buffer untouched
  * and only check that it is syntactically correct.

