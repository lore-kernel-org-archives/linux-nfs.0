Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:25395 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933274AbdGKQo0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 11 Jul 2017 12:44:26 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>,
        <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [RFC v3 07/42] NFS COPY xdr handle async reply
Date: Tue, 11 Jul 2017 12:43:41 -0400
Message-ID: <20170711164416.1982-8-kolga@netapp.com>
In-Reply-To: <20170711164416.1982-1-kolga@netapp.com>
References: <20170711164416.1982-1-kolga@netapp.com>
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
index 3c6ca02..27da108 100644
--- a/fs/nfs/nfs42xdr.c
+++ b/fs/nfs/nfs42xdr.c
@@ -418,21 +418,23 @@ static int decode_write_response(struct xdr_stream *xdr,
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
index eaaf540..60eafa0 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1374,6 +1374,7 @@ struct nfs42_copy_args {
 };
 
 struct nfs42_write_res {
+	nfs4_stateid		stateid;
 	u64			count;
 	struct nfs_writeverf	verifier;
 };
-- 
1.8.3.1

