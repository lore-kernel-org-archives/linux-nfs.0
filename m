From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/24] NFS: Encode NFSv2 read argument using an xdr_stream
Date: Sun, 16 May 2010 22:46:39 -0400
Message-ID: <20100517024639.20258.73627.stgit@localhost.localdomain>
References: <20100517023905.20258.86631.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f171.google.com ([209.85.221.171]:63658 "EHLO
	mail-qy0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752314Ab0EQCql (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 16 May 2010 22:46:41 -0400
Received: by mail-qy0-f171.google.com with SMTP id 1so6350026qyk.5
        for <linux-nfs@vger.kernel.org>; Sun, 16 May 2010 19:46:41 -0700 (PDT)
In-Reply-To: <20100517023905.20258.86631.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs2xdr.c |   35 +++++++++++++++++++++++++++++++++++
 1 files changed, 35 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 06f5a54..c763149 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -661,6 +661,41 @@ nfs_xdr_readargs(struct rpc_rqst *req, __be32 *p, struct nfs_readargs *args)
 }
 
 /*
+ * 2.2.7.  readargs
+ *
+ *	struct readargs {
+ *		fhandle file;
+ *		unsigned offset;
+ *		unsigned count;
+ *		unsigned totalcount;
+ *	};
+ */
+static int nfs2_xdr_enc_readargs(struct rpc_rqst *req, __be32 *p,
+				 struct nfs_readargs *args)
+{
+	struct rpc_auth	*auth = req->rq_task->tk_msg.rpc_cred->cr_auth;
+	u32 offset = (u32)args->offset;
+	u32 count = args->count;
+	struct xdr_stream xdr;
+	unsigned int replen;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_fhandle(&xdr, args->fh);
+	p = xdr_reserve_space(&xdr, 12);
+	BUG_ON(unlikely(p == NULL));
+	*p++ = cpu_to_be32(offset);
+	*p++ = cpu_to_be32(count);
+	*p++ = cpu_to_be32(count);
+
+	/* Prepare reply buffer to receive read data */
+	replen = (RPC_REPHDRSIZE + auth->au_rslack + NFS_readres_sz) << 2;
+	xdr_inline_pages(&req->rq_rcv_buf, replen,
+			 args->pages, args->pgbase, count);
+	req->rq_rcv_buf.flags |= XDRBUF_READ;
+	return 0;
+}
+
+/*
  * Decode READ reply
  */
 static int

