From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH] SAUASHME: pnfs-submit: prevent buffer overrun in decode_and_add_ds
Date: Tue, 29 Jun 2010 14:02:27 +0300
Message-ID: <1277809347-13087-1-git-send-email-bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:21676 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755341Ab0F2LCa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jun 2010 07:02:30 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If len == 29, r_addr[len] = '\0' will overrun r_addr.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4filelayoutdev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 8e9d04a..3d84fef 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -332,7 +332,7 @@ decode_and_add_ds(uint32_t **pp, struct inode *inode)
 	tmp[0] = be32_to_cpup(p++);
 
 	len = be32_to_cpup(p++);
-	if (len > 29) {
+	if (len >= sizeof(r_addr)) {
 		printk("%s: ERROR: Device ip/port too long (%d)\n",
 			__func__, len);
 		goto out_err;
-- 
1.6.6.1

