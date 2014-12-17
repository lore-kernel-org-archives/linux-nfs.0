Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:31011 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751620AbaLQWfc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Dec 2014 17:35:32 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 3/3] NFS: Add support for reading NFS4_CONTENT_HOLE segments
Date: Wed, 17 Dec 2014 17:35:26 -0500
Message-ID: <1418855726-14262-4-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1418855726-14262-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1418855726-14262-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch adds support for decoding a single hole segment returned by
the server.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs42xdr.c | 21 ++++++++++++++++++++-
 1 file changed, 20 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
index c0d266d..ced0d8c 100644
--- a/fs/nfs/nfs42xdr.c
+++ b/fs/nfs/nfs42xdr.c
@@ -216,6 +216,25 @@ out_overflow:
 	return -EIO;
 }
 
+static int decode_read_plus_hole(struct xdr_stream *xdr, struct nfs_pgio_res *res)
+{
+	__be32 *p;
+	uint64_t offset, length;
+
+	p = xdr_inline_decode(xdr, 8 + 8);
+	if (unlikely(!p))
+		goto out_overflow;
+
+	p = xdr_decode_hyper(p, &offset);
+	p = xdr_decode_hyper(p, &length);
+
+	res->count = xdr_read_hole(xdr, length);
+	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
 static int decode_read_plus(struct xdr_stream *xdr, struct nfs_pgio_res *res)
 {
 	__be32 *p;
@@ -245,7 +264,7 @@ static int decode_read_plus(struct xdr_stream *xdr, struct nfs_pgio_res *res)
 	if (type == NFS4_CONTENT_DATA)
 		status = decode_read_plus_data(xdr, res);
 	else
-		status = -ENOTSUPP;
+		status = decode_read_plus_hole(xdr, res);
 
 	if (segments > 1)
 		res->eof = 0;
-- 
2.1.3

