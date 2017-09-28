Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:37252 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752114AbdI1R2b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 28 Sep 2017 13:28:31 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v4 06/12] NFS COPY xdr handle async reply
Date: Thu, 28 Sep 2017 13:28:13 -0400
Message-ID: <20170928172819.50703-7-kolga@netapp.com>
In-Reply-To: <20170928172819.50703-1-kolga@netapp.com>
References: <20170928172819.50703-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If server returns async reply, it must include a callback stateid,
wr_callback_id in the write_response4.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs42xdr.c       | 22 ++++++++++++----------
 include/linux/nfs_xdr.h |  1 +
 2 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
index 940621a..9e557ad 100644
--- a/fs/nfs/nfs42xdr.c
+++ b/fs/nfs/nfs42xdr.c
@@ -426,21 +426,23 @@ static int decode_write_response(struct xdr_stream *xdr,
 				 struct nfs42_write_res *res)
 {
 	__be32 *p;
+	int status, count;
 
-	p = xdr_inline_decode(xdr, 4 + 8 + 4);
+	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
 		goto out_overflow;
-
-	/*
-	 * We never use asynchronous mode, so warn if a server returns
-	 * a stateid.
-	 */
-	if (unlikely(*p != 0)) {
-		pr_err_once("%s: server has set unrequested "
-				"asynchronous mode\n", __func__);
+	count = be32_to_cpup(p);
+	if (count > 1)
 		return -EREMOTEIO;
+	else if (count == 1) {
+		status = decode_opaque_fixed(xdr, &res->stateid,
+				NFS4_STATEID_SIZE);
+		if (unlikely(status))
+			goto out_overflow;
 	}
-	p++;
+	p = xdr_inline_decode(xdr, 8 + 4);
+	if (unlikely(!p))
+		goto out_overflow;
 	p = xdr_decode_hyper(p, &res->count);
 	res->verifier.committed = be32_to_cpup(p);
 	return decode_verifier(xdr, &res->verifier.verifier);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 5ffd745..784ec8d 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1387,6 +1387,7 @@ struct nfs42_copy_args {
 };
 
 struct nfs42_write_res {
+	nfs4_stateid		stateid;
 	u64			count;
 	struct nfs_writeverf	verifier;
 };
-- 
1.8.3.1

