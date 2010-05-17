From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/24] NFS: Encode v2 setattr argument using an xdr_stream
Date: Sun, 16 May 2010 22:46:12 -0400
Message-ID: <20100517024612.20258.81660.stgit@localhost.localdomain>
References: <20100517023905.20258.86631.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f171.google.com ([209.85.221.171]:63658 "EHLO
	mail-qy0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752158Ab0EQCqP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 16 May 2010 22:46:15 -0400
Received: by mail-qy0-f171.google.com with SMTP id 1so6350026qyk.5
        for <linux-nfs@vger.kernel.org>; Sun, 16 May 2010 19:46:14 -0700 (PDT)
In-Reply-To: <20100517023905.20258.86631.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs2xdr.c |   19 +++++++++++++++++++
 1 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 12307e9..ab94ed2 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -553,6 +553,25 @@ nfs_xdr_sattrargs(struct rpc_rqst *req, __be32 *p, struct nfs_sattrargs *args)
 }
 
 /*
+ * 2.2.3.  sattrargs
+ *
+ *	struct sattrargs {
+ *		fhandle file;
+ *		sattr attributes;
+ *	};
+ */
+static int nfs2_xdr_enc_sattrargs(struct rpc_rqst *req, __be32 *p,
+				  struct nfs_sattrargs *args)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_fhandle(&xdr, args->fh);
+	encode_sattr(&xdr, args->sattr);
+	return 0;
+}
+
+/*
  * Encode directory ops argument
  * LOOKUP, RMDIR
  */

