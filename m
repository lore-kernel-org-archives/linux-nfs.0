Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:34717 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752468AbbL1SiD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Dec 2015 13:38:03 -0500
Received: by mail-io0-f171.google.com with SMTP id e126so311204235ioa.1
        for <linux-nfs@vger.kernel.org>; Mon, 28 Dec 2015 10:38:02 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFS: Flush reclaim writes using FLUSH_COND_STABLE
Date: Mon, 28 Dec 2015 13:37:29 -0500
Message-Id: <1451327849-40281-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1451327849-40281-1-git-send-email-trond.myklebust@primarydata.com>
References: <1451327849-40281-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If there are already writes queued up for commit, then don't flush
just this page even if it is a reclaim issue.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/write.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 7a4fe7d82e65..1ea35f88eadb 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -244,7 +244,7 @@ static int wb_priority(struct writeback_control *wbc)
 {
 	int ret = 0;
 	if (wbc->for_reclaim)
-		return FLUSH_HIGHPRI | FLUSH_STABLE;
+		return FLUSH_HIGHPRI | FLUSH_COND_STABLE;
 	if (wbc->sync_mode == WB_SYNC_ALL)
 		ret = FLUSH_COND_STABLE;
 	return ret;
-- 
2.5.0

