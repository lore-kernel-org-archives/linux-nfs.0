From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/24] NFS: Encode NFSv2 fhandle argument using an xdr_stream
Date: Sun, 16 May 2010 22:46:04 -0400
Message-ID: <20100517024603.20258.71261.stgit@localhost.localdomain>
References: <20100517023905.20258.86631.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f171.google.com ([209.85.221.171]:63658 "EHLO
	mail-qy0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752097Ab0EQCqG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 16 May 2010 22:46:06 -0400
Received: by mail-qy0-f171.google.com with SMTP id 1so6350026qyk.5
        for <linux-nfs@vger.kernel.org>; Sun, 16 May 2010 19:46:05 -0700 (PDT)
In-Reply-To: <20100517023905.20258.86631.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs2xdr.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 9d5159f..12307e9 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -530,6 +530,16 @@ nfs_xdr_fhandle(struct rpc_rqst *req, __be32 *p, struct nfs_fh *fh)
 	return 0;
 }
 
+static int nfs2_xdr_enc_fhandle(struct rpc_rqst *req, __be32 *p,
+				struct nfs_fh *fh)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_fhandle(&xdr, fh);
+	return 0;
+}
+
 /*
  * Encode SETATTR arguments
  */

