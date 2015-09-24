Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:36470 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753627AbbIXM61 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Sep 2015 08:58:27 -0400
Received: by pacgz1 with SMTP id gz1so6161857pac.3
        for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2015 05:58:27 -0700 (PDT)
Subject: [PATCH 7/8] NFS: Fix bad checking of max taglen in callback request
To: Trond Myklebust <trond.myklebust@primarydata.com>
References: <5603F269.9060102@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <5603F368.1080304@gmail.com>
Date: Thu, 24 Sep 2015 20:58:16 +0800
MIME-Version: 1.0
In-Reply-To: <5603F269.9060102@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The taglen should be checked with CB_OP_TAGLEN_MAXSZ directly.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/callback_xdr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 9f0f0f6..4ad39fe 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -159,7 +159,7 @@ static __be32 decode_compound_hdr_arg(struct xdr_stream *xdr, struct cb_compound
 	if (unlikely(status != 0))
 		return status;
 	/* We do not like overly long tags! */
-	if (hdr->taglen > CB_OP_TAGLEN_MAXSZ - 12) {
+	if (hdr->taglen > CB_OP_TAGLEN_MAXSZ) {
 		printk("NFS: NFSv4 CALLBACK %s: client sent tag of length %u\n",
 				__func__, hdr->taglen);
 		return htonl(NFS4ERR_RESOURCE);
-- 
2.5.0

