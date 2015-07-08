Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:34237 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758854AbbGHS0g (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Jul 2015 14:26:36 -0400
Received: by lbnk3 with SMTP id k3so61445290lbn.1
        for <linux-nfs@vger.kernel.org>; Wed, 08 Jul 2015 11:26:35 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4.2/flexfiles: Fix a typo in the flexfiles layoutstats code
Date: Wed,  8 Jul 2015 20:26:27 +0200
Message-Id: <1436379987-4388-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index c12951b9551e..b3289d701eea 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1852,7 +1852,7 @@ ff_layout_mirror_prepare_stats(struct nfs42_layoutstat_args *args,
 	struct nfs42_layoutstat_devinfo *devinfo;
 	int i;
 
-	for (i = 0; i <= FF_LAYOUT_MIRROR_COUNT(pls); i++) {
+	for (i = 0; i < FF_LAYOUT_MIRROR_COUNT(pls); i++) {
 		if (*dev_count >= dev_limit)
 			break;
 		mirror = FF_LAYOUT_COMP(pls, i);
-- 
2.4.3

