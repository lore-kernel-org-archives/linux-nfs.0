Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:35110 "EHLO
	mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752068AbbJCMiJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 3 Oct 2015 08:38:09 -0400
Received: by qkap81 with SMTP id p81so53540967qka.2
        for <linux-nfs@vger.kernel.org>; Sat, 03 Oct 2015 05:38:08 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: use a multithreaded workqueue for nfsd4_callbacks
Date: Sat,  3 Oct 2015 08:38:02 -0400
Message-Id: <1443875882-12089-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I don't see any need to order callbacks with respect to one another.
Also, these are generally not involved in memory reclaim, so I don't see
the need for a rescuer thread here either.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/nfs4callback.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index e7f50c4081d6..7dabbb436290 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -1017,7 +1017,7 @@ static const struct rpc_call_ops nfsd4_cb_ops = {
 
 int nfsd4_create_callback_queue(void)
 {
-	callback_wq = create_singlethread_workqueue("nfsd4_callbacks");
+	callback_wq = alloc_workqueue("%s", WQ_UNBOUND, 0, "nfsd4_callbacks");
 	if (!callback_wq)
 		return -ENOMEM;
 	return 0;
-- 
2.4.3

