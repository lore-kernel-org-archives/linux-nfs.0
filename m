Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:33839 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754232AbcEPSrz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 May 2016 14:47:55 -0400
Received: by mail-qg0-f46.google.com with SMTP id 90so93798216qgz.1
        for <linux-nfs@vger.kernel.org>; Mon, 16 May 2016 11:47:55 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 4/4] NFS: Reclaim writes via writepage are opportunistic
Date: Mon, 16 May 2016 14:47:27 -0400
Message-Id: <1463424447-57302-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1463424447-57302-3-git-send-email-trond.myklebust@primarydata.com>
References: <1463424447-57302-1-git-send-email-trond.myklebust@primarydata.com>
 <1463424447-57302-2-git-send-email-trond.myklebust@primarydata.com>
 <1463424447-57302-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

No need to make them a priority any more, or to make them succeed.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/write.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 5f4fd53e5764..7c3c62892b0b 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -245,8 +245,7 @@ static void nfs_mark_uptodate(struct nfs_page *req)
 static int wb_priority(struct writeback_control *wbc)
 {
 	int ret = 0;
-	if (wbc->for_reclaim)
-		return FLUSH_HIGHPRI | FLUSH_COND_STABLE;
+
 	if (wbc->sync_mode == WB_SYNC_ALL)
 		ret = FLUSH_COND_STABLE;
 	return ret;
-- 
2.5.5

