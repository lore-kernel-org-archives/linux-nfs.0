Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35068 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751366AbdBEB5n (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 4 Feb 2017 20:57:43 -0500
Received: by mail-it0-f68.google.com with SMTP id 203so5180957ith.2
        for <linux-nfs@vger.kernel.org>; Sat, 04 Feb 2017 17:57:43 -0800 (PST)
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH 2/3] nfsd/callback: Make sure skip the callback tag
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Cc: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <44bdb3c5-c7c8-f5da-b9d9-da4268d4bf49@gmail.com>
Date: Sun, 5 Feb 2017 09:57:37 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Although the callback tag is NULL, and hdr->nops is unused too
right now, but, if a testing with callback tag is an non-zero,
the nops will get a bad value.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4callback.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index fb6ca0a..ea74149 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -303,6 +303,7 @@ static int decode_cb_compound4res(struct xdr_stream *xdr,
 	p = xdr_inline_decode(xdr, length + 4);
 	if (unlikely(p == NULL))
 		goto out_overflow;
+	p += XDR_QUADLEN(length);
 	hdr->nops = be32_to_cpup(p);
 	return 0;
 out_overflow:
-- 
2.9.3

