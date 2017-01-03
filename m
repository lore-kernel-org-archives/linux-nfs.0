Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36623 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760270AbdACSW6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Jan 2017 13:22:58 -0500
Received: by mail-pg0-f67.google.com with SMTP id n5so34265160pgh.3
        for <linux-nfs@vger.kernel.org>; Tue, 03 Jan 2017 10:22:57 -0800 (PST)
From: Nicholas Piggin <npiggin@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nicholas Piggin <npiggin@gmail.com>, linux-nfs@vger.kernel.org,
        linux-mm@kvack.org, NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH 1/2] nfs: no PG_private waiters remain, remove waker
Date: Wed,  4 Jan 2017 04:22:33 +1000
Message-Id: <20170103182234.30141-2-npiggin@gmail.com>
In-Reply-To: <20170103182234.30141-1-npiggin@gmail.com>
References: <20170103182234.30141-1-npiggin@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since commit 4f52b6bb ("NFS: Don't call COMMIT in ->releasepage()"),
no tasks wait on PagePrivate, so the wake introduced in commit 95905446
("NFS: avoid deadlocks with loop-back mounted NFS filesystems.") can
be removed.

Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
---
 fs/nfs/write.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index b00d53d13d47..006068526542 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -728,8 +728,6 @@ static void nfs_inode_remove_request(struct nfs_page *req)
 		if (likely(head->wb_page && !PageSwapCache(head->wb_page))) {
 			set_page_private(head->wb_page, 0);
 			ClearPagePrivate(head->wb_page);
-			smp_mb__after_atomic();
-			wake_up_page(head->wb_page, PG_private);
 			clear_bit(PG_MAPPED, &head->wb_flags);
 		}
 		nfsi->nrequests--;
-- 
2.11.0

