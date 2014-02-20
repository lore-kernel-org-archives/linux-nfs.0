Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f48.google.com ([209.85.219.48]:45830 "EHLO
	mail-oa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751752AbaBTC23 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Feb 2014 21:28:29 -0500
Received: by mail-oa0-f48.google.com with SMTP id l6so1476400oag.35
        for <linux-nfs@vger.kernel.org>; Wed, 19 Feb 2014 18:28:28 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/7] NFSv4.1: Fix wraparound issues in pnfs_seqid_is_newer()
Date: Wed, 19 Feb 2014 21:28:19 -0500
Message-Id: <1392863305-14870-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Subtraction of signed integers does not have well defined wraparound
semantics in the C99 standard. In order to be wraparound-safe, we
have to use unsigned subtraction, and then cast the result.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 4755858e37a0..6e67ada6c22c 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -662,7 +662,7 @@ pnfs_destroy_all_layouts(struct nfs_client *clp)
  */
 static bool pnfs_seqid_is_newer(u32 s1, u32 s2)
 {
-	return (s32)s1 - (s32)s2 > 0;
+	return (s32)(s1 - s2) > 0;
 }
 
 /* update lo->plh_stateid with new if is more recent */
-- 
1.8.5.3

