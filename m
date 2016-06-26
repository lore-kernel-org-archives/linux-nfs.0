Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35243 "EHLO
	mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751387AbcFZA0n (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 25 Jun 2016 20:26:43 -0400
Received: by mail-it0-f68.google.com with SMTP id g127so6551548ith.2
        for <linux-nfs@vger.kernel.org>; Sat, 25 Jun 2016 17:26:43 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 5/5] NFS: llseek(SEEK_HOLE) and llseek(SEEK_DATA) don't require data sync
Date: Sat, 25 Jun 2016 20:25:54 -0400
Message-Id: <1466900754-29584-5-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1466900754-29584-4-git-send-email-trond.myklebust@primarydata.com>
References: <1466900754-29584-1-git-send-email-trond.myklebust@primarydata.com>
 <1466900754-29584-2-git-send-email-trond.myklebust@primarydata.com>
 <1466900754-29584-3-git-send-email-trond.myklebust@primarydata.com>
 <1466900754-29584-4-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We want to ensure that we write the cached data to the server, but
don't require it be synced to disk. If the server reboots, we will
get a stateid error, which will cause us to retry anyway.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs42proc.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 778ad2778191..531f7d5b6803 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -269,7 +269,11 @@ static loff_t _nfs42_proc_llseek(struct file *filep,
 	if (status)
 		return status;
 
-	nfs_wb_all(inode);
+	status = filemap_write_and_wait_range(inode->i_mapping,
+			offset, LLONG_MAX);
+	if (status)
+		return status;
+
 	status = nfs4_call_sync(server->client, server, &msg,
 				&args.seq_args, &res.seq_res, 0);
 	if (status == -ENOTSUPP)
-- 
2.7.4

