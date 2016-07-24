Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34638 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751891AbcGXVhX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jul 2016 17:37:23 -0400
Received: by mail-io0-f193.google.com with SMTP id g86so10767303ioj.1
        for <linux-nfs@vger.kernel.org>; Sun, 24 Jul 2016 14:37:22 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] =?UTF-8?q?NFSv4.2:=20Fix=20warning=20"variable=20?= =?UTF-8?q?=E2=80=98stateids=E2=80=99=20set=20but=20not=20used"?=
Date: Sun, 24 Jul 2016 17:36:57 -0400
Message-Id: <1469396218-85598-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1469396218-85598-1-git-send-email-trond.myklebust@primarydata.com>
References: <1469396218-85598-1-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace it with a test for whether or not the sent a stateid in violation
of what we asked for.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs42xdr.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
index 6dc6f2aea0d6..8b2605882a20 100644
--- a/fs/nfs/nfs42xdr.c
+++ b/fs/nfs/nfs42xdr.c
@@ -330,13 +330,21 @@ static int decode_write_response(struct xdr_stream *xdr,
 				 struct nfs42_write_res *res)
 {
 	__be32 *p;
-	int stateids;
 
 	p = xdr_inline_decode(xdr, 4 + 8 + 4);
 	if (unlikely(!p))
 		goto out_overflow;
 
-	stateids = be32_to_cpup(p++);
+	/*
+	 * We never use asynchronous mode, so warn if a server returns
+	 * a stateid.
+	 */
+	if (unlikely(*p != 0)) {
+		pr_err_once("%s: server has set unrequested "
+				"asynchronous mode\n", __func__);
+		return -EREMOTEIO;
+	}
+	p++;
 	p = xdr_decode_hyper(p, &res->count);
 	res->verifier.committed = be32_to_cpup(p);
 	return decode_verifier(xdr, &res->verifier.verifier);
-- 
2.7.4

