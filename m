Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx143.netapp.com ([216.240.21.24]:17204 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761503AbbA1UoD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Jan 2015 15:44:03 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 4/6] NFS: Add READ_PLUS support for hole segments
Date: Wed, 28 Jan 2015 15:43:48 -0500
Message-ID: <1422477830-28090-5-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1422477830-28090-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1422477830-28090-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch adds support for decoding a single hole segment returned by
the server.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs42xdr.c | 26 +++++++++++++++++++++++++-
 1 file changed, 25 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
index 3d7c01b..17126e8 100644
--- a/fs/nfs/nfs42xdr.c
+++ b/fs/nfs/nfs42xdr.c
@@ -212,6 +212,30 @@ out_overflow:
 	return -EIO;
 }
 
+static int decode_read_plus_hole(struct xdr_stream *xdr, struct nfs_pgio_res *res)
+{
+	__be32 *p;
+	uint64_t offset, length;
+	size_t recvd;
+
+	p = xdr_inline_decode(xdr, 8 + 8);
+	if (unlikely(!p))
+		goto out_overflow;
+
+	p = xdr_decode_hyper(p, &offset);
+	p = xdr_decode_hyper(p, &length);
+
+	recvd = xdr_expand_hole(xdr, 0, length);
+	if (recvd < length)
+		res->eof = 0;
+
+	res->count = recvd;
+	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
 static int decode_read_plus(struct xdr_stream *xdr, struct nfs_pgio_res *res)
 {
 	__be32 *p;
@@ -240,7 +264,7 @@ static int decode_read_plus(struct xdr_stream *xdr, struct nfs_pgio_res *res)
 	if (type == NFS4_CONTENT_DATA)
 		status = decode_read_plus_data(xdr, res);
 	else
-		status = -ENOTSUPP;
+		status = decode_read_plus_hole(xdr, res);
 
 	if (segments > 1)
 		res->eof = 0;
-- 
2.2.2

