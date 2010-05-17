From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/24] NFS: Encode NFSv2 readlink argument using an xdr_stream
Date: Sun, 16 May 2010 22:46:30 -0400
Message-ID: <20100517024630.20258.71597.stgit@localhost.localdomain>
References: <20100517023905.20258.86631.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f171.google.com ([209.85.221.171]:63658 "EHLO
	mail-qy0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752314Ab0EQCqc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 16 May 2010 22:46:32 -0400
Received: by mail-qy0-f171.google.com with SMTP id 1so6350026qyk.5
        for <linux-nfs@vger.kernel.org>; Sun, 16 May 2010 19:46:32 -0700 (PDT)
In-Reply-To: <20100517023905.20258.86631.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs2xdr.c |   17 +++++++++++++++++
 1 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 2f9102a..06f5a54 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -616,6 +616,23 @@ static int nfs2_xdr_enc_removeargs(struct rpc_rqst *req, __be32 *p,
 	return 0;
 }
 
+static int nfs2_xdr_enc_readlinkargs(struct rpc_rqst *req, __be32 *p,
+				     struct nfs_readlinkargs *args)
+{
+	struct rpc_auth	*auth = req->rq_task->tk_msg.rpc_cred->cr_auth;
+	struct xdr_stream xdr;
+	unsigned int replen;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_fhandle(&xdr, args->fh);
+
+	/* Prepare reply buffer to receive readlink data */
+	replen = (RPC_REPHDRSIZE + auth->au_rslack + NFS_readlinkres_sz) << 2;
+	xdr_inline_pages(&req->rq_rcv_buf, replen, args->pages,
+						args->pgbase, args->pglen);
+	return 0;
+}
+
 /*
  * Arguments to a READ call. Since we read data directly into the page
  * cache, we also set up the reply iovec here so that iov[1] points

