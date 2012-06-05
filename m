Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:5912 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934338Ab2FEOE6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Jun 2012 10:04:58 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Andy Adamson <andros@netapp.com>
Subject: [PATCH 2/2] NFSv4: Fix up decode_attr_mdsthreshold
Date: Tue,  5 Jun 2012 10:04:43 -0400
Message-Id: <1338905083-19559-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1338905083-19559-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1338905083-19559-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix an incorrect use of 'likely()'. The FATTR4_WORD2_MDSTHRESHOLD
bit is only expected in NFSv4.1 OPEN calls, and so is actually
rather _unlikely_.

decode_attr_mdsthreshold needs to clear FATTR4_WORD2_MDSTHRESHOLD
from the attribute bitmap after it has decoded the data.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4xdr.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 9ca1428..18fae29 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4360,7 +4360,7 @@ static int decode_attr_mdsthreshold(struct xdr_stream *xdr,
 
 	if (unlikely(bitmap[2] & (FATTR4_WORD2_MDSTHRESHOLD - 1U)))
 		return -EIO;
-	if (likely(bitmap[2] & FATTR4_WORD2_MDSTHRESHOLD)) {
+	if (bitmap[2] & FATTR4_WORD2_MDSTHRESHOLD) {
 		/* Did the server return an unrequested attribute? */
 		if (unlikely(res == NULL))
 			return -EREMOTEIO;
@@ -4376,6 +4376,7 @@ static int decode_attr_mdsthreshold(struct xdr_stream *xdr,
 				__func__);
 
 		status = decode_first_threshold_item4(xdr, res);
+		bitmap[2] &= ~FATTR4_WORD2_MDSTHRESHOLD;
 	}
 	return status;
 out_overflow:
-- 
1.7.10.2

