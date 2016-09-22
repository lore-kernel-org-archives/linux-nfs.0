Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47312 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753411AbcIVLTE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 22 Sep 2016 07:19:04 -0400
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: fix dprintk in nfsd4_encode_getdeviceinfo
Date: Thu, 22 Sep 2016 07:19:02 -0400
Message-Id: <1474543142-3534-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfserr is big-endian, so we should convert it to host-endian before
printing it.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4xdr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 0aa0236a1429..7f8232e32dc7 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -4062,7 +4062,7 @@ nfsd4_encode_getdeviceinfo(struct nfsd4_compoundres *resp, __be32 nfserr,
 	u32 starting_len = xdr->buf->len, needed_len;
 	__be32 *p;
 
-	dprintk("%s: err %d\n", __func__, nfserr);
+	dprintk("%s: err %d\n", __func__, be32_to_cpu(nfserr));
 	if (nfserr)
 		goto out;
 
-- 
2.7.4

