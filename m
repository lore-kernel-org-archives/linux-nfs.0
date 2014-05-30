Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f174.google.com ([74.125.82.174]:60132 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752272AbaE3JJa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 May 2014 05:09:30 -0400
From: Thierry Reding <thierry.reding@gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH] NFS: Use smp_mb__{before,after}_atomic()
Date: Fri, 30 May 2014 11:06:55 +0200
Message-Id: <1401440815-4227-1-git-send-email-thierry.reding@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Thierry Reding <treding@nvidia.com>

Commit febdbfe8a91c (arch: Prepare for smp_mb__{before,after}_atomic())
deprecated the smp_mb__{before,after}_{atomic,clear}_{dec,inc,bit}*()
functions in favour of the unified smp_mb__{before,after}_atomic().

While at it, convert the smb_mb__before_atomic()/clear_bit() pattern to
the more idiomatic clear_bit_unlock().

Signed-off-by: Thierry Reding <treding@nvidia.com>
---
 fs/nfs/pagelist.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 353331969626..c00d4f1de8ef 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -173,9 +173,8 @@ nfs_page_group_unlock(struct nfs_page *req)
 
 	WARN_ON_ONCE(head != head->wb_head);
 
-	smp_mb__before_clear_bit();
-	clear_bit(PG_HEADLOCK, &head->wb_flags);
-	smp_mb__after_clear_bit();
+	clear_bit_unlock(PG_HEADLOCK, &head->wb_flags);
+	smp_mb__after_atomic();
 	wake_up_bit(&head->wb_flags, PG_HEADLOCK);
 }
 
-- 
1.9.2

