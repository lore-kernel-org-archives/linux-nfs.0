Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.0 required=3.0 tests=BAYES_00,INCLUDES_CR_TRAILER,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06780C4361B
	for <linux-nfs@archiver.kernel.org>; Fri, 11 Dec 2020 19:10:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id B6F3922D03
	for <linux-nfs@archiver.kernel.org>; Fri, 11 Dec 2020 19:10:37 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2395171AbgLKR1H (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 11 Dec 2020 12:27:07 -0500
Received: from mail.kernel.org ([198.145.29.99]:50816 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2395254AbgLKR0q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 11 Dec 2020 12:26:46 -0500
From:   trondmy@kernel.org
Authentication-Results: mail.kernel.org; dkim=permerror (bad message/signature format)
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 14/15] NFSv4.2: Deal with potential READ_PLUS data extent buffer overflow
Date:   Fri, 11 Dec 2020 12:25:20 -0500
Message-Id: <20201211172521.5567-15-trondmy@kernel.org>
X-Mailer: git-send-email 2.29.2
In-Reply-To: <20201211172521.5567-14-trondmy@kernel.org>
References: <20201211172521.5567-1-trondmy@kernel.org>
 <20201211172521.5567-2-trondmy@kernel.org>
 <20201211172521.5567-3-trondmy@kernel.org>
 <20201211172521.5567-4-trondmy@kernel.org>
 <20201211172521.5567-5-trondmy@kernel.org>
 <20201211172521.5567-6-trondmy@kernel.org>
 <20201211172521.5567-7-trondmy@kernel.org>
 <20201211172521.5567-8-trondmy@kernel.org>
 <20201211172521.5567-9-trondmy@kernel.org>
 <20201211172521.5567-10-trondmy@kernel.org>
 <20201211172521.5567-11-trondmy@kernel.org>
 <20201211172521.5567-12-trondmy@kernel.org>
 <20201211172521.5567-13-trondmy@kernel.org>
 <20201211172521.5567-14-trondmy@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

If the server returns more data than we have buffer space for, then
we need to truncate and exit early.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs42xdr.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
index 9ef5261a1a70..8386ca45a43f 100644
--- a/fs/nfs/nfs42xdr.c
+++ b/fs/nfs/nfs42xdr.c
@@ -1026,6 +1026,7 @@ static int decode_deallocate(struct xdr_stream *xdr, struct nfs42_falloc_res *re
 }
 
 static int decode_read_plus_data(struct xdr_stream *xdr,
+				 struct nfs_pgio_args *args,
 				 struct nfs_pgio_res *res)
 {
 	uint32_t count, recvd;
@@ -1041,8 +1042,12 @@ static int decode_read_plus_data(struct xdr_stream *xdr,
 	recvd = xdr_align_data(xdr, res->count, xdr_align_size(count));
 	if (recvd > count)
 		recvd = count;
+	if (res->count + recvd > args->count) {
+		if (args->count > res->count)
+			res->count += args->count - res->count;
+		return 1;
+	}
 	res->count += recvd;
-
 	if (count > recvd)
 		return 1;
 	return 0;
@@ -1119,7 +1124,7 @@ static int decode_read_plus(struct xdr_stream *xdr, struct nfs_pgio_res *res)
 
 		type = be32_to_cpup(p++);
 		if (type == NFS4_CONTENT_DATA)
-			status = decode_read_plus_data(xdr, res);
+			status = decode_read_plus_data(xdr, args, res);
 		else if (type == NFS4_CONTENT_HOLE)
 			status = decode_read_plus_hole(xdr, args, res, &eof);
 		else
-- 
2.29.2

