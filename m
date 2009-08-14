From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH RFC v2 19/21] nfs: nfs4xdr: simplify decode_exchange_id by reusing decode_opaque_inline
Date: Fri, 14 Aug 2009 17:20:10 +0300
Message-ID: <1250259610-14090-1-git-send-email-bhalevy@panasas.com>
References: <4A8571E2.8020800@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:26160
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932173AbZHNOUR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Aug 2009 10:20:17 -0400
In-Reply-To: <4A8571E2.8020800@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |   19 ++++++++++---------
 1 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 9187af9..d971138 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4144,6 +4144,7 @@ static int decode_exchange_id(struct xdr_stream *xdr,
 {
 	__be32 *p;
 	uint32_t dummy;
+	char *dummy_str;
 	int status;
 	struct nfs_client *clp = res->client;
 
@@ -4166,19 +4167,19 @@ static int decode_exchange_id(struct xdr_stream *xdr,
 	READ_BUF(8);
 
 	/* Throw away Major id */
-	READ_BUF(4);
-	dummy = be32_to_cpup(p++);
-	READ_BUF(dummy);
+	status = decode_opaque_inline(xdr, &dummy, &dummy_str);
+	if (unlikely(status))
+		return status;
 
 	/* Throw away server_scope */
-	READ_BUF(4);
-	dummy = be32_to_cpup(p++);
-	READ_BUF(dummy);
+	status = decode_opaque_inline(xdr, &dummy, &dummy_str);
+	if (unlikely(status))
+		return status;
 
 	/* Throw away Implementation id array */
-	READ_BUF(4);
-	dummy = be32_to_cpup(p++);
-	READ_BUF(dummy);
+	status = decode_opaque_inline(xdr, &dummy, &dummy_str);
+	if (unlikely(status))
+		return status;
 
 	return 0;
 }
-- 
1.6.4

