Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f181.google.com ([209.85.220.181]:32798 "EHLO
	mail-vc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751448Ab3ADIXJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Jan 2013 03:23:09 -0500
From: Xi Wang <xi.wang@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Xi Wang <xi.wang@gmail.com>, stable@vger.kernel.org
Subject: [PATCH] nfs: fix null checking in nfs_get_option_str()
Date: Fri,  4 Jan 2013 03:22:57 -0500
Message-Id: <1357287777-12052-1-git-send-email-xi.wang@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following null pointer check is broken.

	*option = match_strdup(args);
	return !option;

The pointer `option' must be non-null, and thus `!option' is always false.
Use `!*option' instead.

The bug was introduced in commit c5cb09b6f8 ("Cleanup: Factor out some
cut-and-paste code.").

Signed-off-by: Xi Wang <xi.wang@gmail.com>
Cc: stable@vger.kernel.org
---
 fs/nfs/super.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index c25cadf8..2e7e8c8 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1152,7 +1152,7 @@ static int nfs_get_option_str(substring_t args[], char **option)
 {
 	kfree(*option);
 	*option = match_strdup(args);
-	return !option;
+	return !*option;
 }
 
 static int nfs_get_option_ul(substring_t args[], unsigned long *option)
-- 
1.7.10.4

