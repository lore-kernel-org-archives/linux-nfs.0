Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:34189 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754476AbcHWPkR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Aug 2016 11:40:17 -0400
Received: by mail-it0-f65.google.com with SMTP id e63so8426956ith.1
        for <linux-nfs@vger.kernel.org>; Tue, 23 Aug 2016 08:40:16 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] pNFS: The client must not do I/O to the DS if it's lease has expired
Date: Tue, 23 Aug 2016 11:39:33 -0400
Message-Id: <1471966773-10022-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that the client conforms to the normative behaviour described in
RFC5661 Section 12.7.2: "If a client believes its lease has expired,
it MUST NOT send I/O to the storage device until it has validated its
lease."

So ensure that we wait for the lease to be validated before using
the layout.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: stable@vger.kernel.org # v3.20+
---
 fs/nfs/pnfs.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index bf98f1b2595f..6daf034645c8 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1555,6 +1555,7 @@ pnfs_update_layout(struct inode *ino,
 	}
 
 lookup_again:
+	nfs4_client_recover_expired_lease(clp);
 	first = false;
 	spin_lock(&ino->i_lock);
 	lo = pnfs_find_alloc_layout(ino, ctx, gfp_flags);
-- 
2.7.4

