Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bk0-f46.google.com ([209.85.214.46]:35946 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761384Ab2FGTGq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jun 2012 15:06:46 -0400
Received: by mail-bk0-f46.google.com with SMTP id ji2so899257bkc.19
        for <linux-nfs@vger.kernel.org>; Thu, 07 Jun 2012 12:06:45 -0700 (PDT)
From: Idan Kedar <idank@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] pnfsblock: disable unloading the module when mounted
Date: Thu,  7 Jun 2012 22:06:31 +0300
Message-Id: <1339095991-26753-3-git-send-email-idank@tonian.com>
In-Reply-To: <1339095991-26753-1-git-send-email-idank@tonian.com>
References: <1339095991-26753-1-git-send-email-idank@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Idan Kedar <idank@tonian.com>
---
 fs/nfs/blocklayout/blocklayout.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 48cfac3..c0a1464 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -1005,6 +1005,7 @@ static const struct nfs_pageio_ops bl_pg_write_ops = {
 static struct pnfs_layoutdriver_type blocklayout_type = {
 	.id				= LAYOUT_BLOCK_VOLUME,
 	.name				= "LAYOUT_BLOCK_VOLUME",
+	.owner				= THIS_MODULE,
 	.read_pagelist			= bl_read_pagelist,
 	.write_pagelist			= bl_write_pagelist,
 	.alloc_layout_hdr		= bl_alloc_layout_hdr,
-- 
1.7.6.5

