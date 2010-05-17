From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/24] NFS: Encode NFSv2 write argument using an xdr_stream
Date: Sun, 16 May 2010 22:46:48 -0400
Message-ID: <20100517024648.20258.67514.stgit@localhost.localdomain>
References: <20100517023905.20258.86631.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f171.google.com ([209.85.221.171]:63658 "EHLO
	mail-qy0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752314Ab0EQCqu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 16 May 2010 22:46:50 -0400
Received: by mail-qy0-f171.google.com with SMTP id 1so6350026qyk.5
        for <linux-nfs@vger.kernel.org>; Sun, 16 May 2010 19:46:50 -0700 (PDT)
In-Reply-To: <20100517023905.20258.86631.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs2xdr.c |   35 +++++++++++++++++++++++++++++++++++
 1 files changed, 35 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index c763149..13c9975 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -761,6 +761,41 @@ nfs_xdr_writeargs(struct rpc_rqst *req, __be32 *p, struct nfs_writeargs *args)
 }
 
 /*
+ * 2.2.9.  writeargs
+ *
+ *	struct writeargs {
+ *		fhandle file;
+ *		unsigned beginoffset;
+ *		unsigned offset;
+ *		unsigned totalcount;
+ *		nfsdata data;
+ *	};
+ */
+static int nfs2_xdr_enc_writeargs(struct rpc_rqst *req, __be32 *p,
+				  struct nfs_writeargs *args)
+{
+	struct xdr_buf *sndbuf = &req->rq_snd_buf;
+	u32 offset = (u32)args->offset;
+	u32 count = args->count;
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_fhandle(&xdr, args->fh);
+	p = xdr_reserve_space(&xdr, 16);
+	BUG_ON(unlikely(p == NULL));
+	*p++ = cpu_to_be32(offset);
+	*p++ = cpu_to_be32(offset);
+	*p++ = cpu_to_be32(count);
+
+	/* nfsdata */
+	*p = cpu_to_be32(count);
+	xdr_write_pages(&xdr, args->pages, args->pgbase, count);
+
+	sndbuf->flags |= XDRBUF_WRITE;
+	return 0;
+}
+
+/*
  * Encode create arguments
  * CREATE, MKDIR
  */

