Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:33727 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750829AbbC1Pq2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Mar 2015 11:46:28 -0400
Received: by pdnc3 with SMTP id c3so127362031pdn.0
        for <linux-nfs@vger.kernel.org>; Sat, 28 Mar 2015 08:46:28 -0700 (PDT)
Message-ID: <5516CCCC.7060509@gmail.com>
Date: Sat, 28 Mar 2015 23:46:20 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, kinglongmee@gmail.com
Subject: [PATCH] nfs: fix bad checking of callback operation's taglen
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Does not need decrease of 12 here.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/callback_xdr.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 19ca95c..1737c2e 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -157,8 +157,8 @@ static __be32 decode_compound_hdr_arg(struct xdr_stream *xdr, struct cb_compound
 	if (unlikely(status != 0))
 		return status;
 	/* We do not like overly long tags! */
-	if (hdr->taglen > CB_OP_TAGLEN_MAXSZ - 12) {
-		printk("NFS: NFSv4 CALLBACK %s: client sent tag of length %u\n",
+	if (hdr->taglen > CB_OP_TAGLEN_MAXSZ) {
+		printk("NFS: NFSv4 CALLBACK %s: server sents tag of length %u\n",
 				__func__, hdr->taglen);
 		return htonl(NFS4ERR_RESOURCE);
 	}
-- 
2.3.4

