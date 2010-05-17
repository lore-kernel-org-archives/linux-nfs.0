From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 05/24] NFS: Encode dirop argument using an xdr_stream
Date: Sun, 16 May 2010 22:46:22 -0400
Message-ID: <20100517024621.20258.14294.stgit@localhost.localdomain>
References: <20100517023905.20258.86631.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f171.google.com ([209.85.221.171]:63658 "EHLO
	mail-qy0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752274Ab0EQCqY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 16 May 2010 22:46:24 -0400
Received: by mail-qy0-f171.google.com with SMTP id 1so6350026qyk.5
        for <linux-nfs@vger.kernel.org>; Sun, 16 May 2010 19:46:23 -0700 (PDT)
In-Reply-To: <20100517023905.20258.86631.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs2xdr.c |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index ab94ed2..2f9102a 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -584,6 +584,16 @@ nfs_xdr_diropargs(struct rpc_rqst *req, __be32 *p, struct nfs_diropargs *args)
 	return 0;
 }
 
+static int nfs2_xdr_enc_diropargs(struct rpc_rqst *req, __be32 *p,
+				  struct nfs_diropargs *args)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_diropargs(&xdr, args->fh, args->name, args->len);
+	return 0;
+}
+
 /*
  * Encode REMOVE argument
  */
@@ -596,6 +606,16 @@ nfs_xdr_removeargs(struct rpc_rqst *req, __be32 *p, const struct nfs_removeargs
 	return 0;
 }
 
+static int nfs2_xdr_enc_removeargs(struct rpc_rqst *req, __be32 *p,
+				   struct nfs_removeargs *args)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_diropargs(&xdr, args->fh, args->name.name, args->name.len);
+	return 0;
+}
+
 /*
  * Arguments to a READ call. Since we read data directly into the page
  * cache, we also set up the reply iovec here so that iov[1] points

