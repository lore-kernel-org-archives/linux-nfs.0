Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43369 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752369AbaEVTce (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 May 2014 15:32:34 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 06/52] nfsd4: fix write reply size estimate
Date: Thu, 22 May 2014 15:31:41 -0400
Message-Id: <1400787148-25941-7-git-send-email-bfields@redhat.com>
In-Reply-To: <1400787148-25941-1-git-send-email-bfields@redhat.com>
References: <1400787148-25941-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

The write reply also includes count and stable_how.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 44cd477..b0e075c 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1530,7 +1530,7 @@ static inline u32 nfsd4_setclientid_rsize(struct svc_rqst *rqstp, struct nfsd4_o
 
 static inline u32 nfsd4_write_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
 {
-	return (op_encode_hdr_size + op_encode_verifier_maxsz) * sizeof(__be32);
+	return (op_encode_hdr_size + 2 + op_encode_verifier_maxsz) * sizeof(__be32);
 }
 
 static inline u32 nfsd4_exchange_id_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
-- 
1.9.0

