Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:34629 "EHLO
	mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753755AbbLZXVs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 26 Dec 2015 18:21:48 -0500
Received: by mail-io0-f175.google.com with SMTP id e126so280362515ioa.1
        for <linux-nfs@vger.kernel.org>; Sat, 26 Dec 2015 15:21:48 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 12/14] pNFS/flexfiles: Fix a statistics gathering imbalance
Date: Sat, 26 Dec 2015 18:20:58 -0500
Message-Id: <1451172060-28238-12-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1451172060-28238-11-git-send-email-trond.myklebust@primarydata.com>
References: <1451172060-28238-1-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-2-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-3-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-4-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-5-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-6-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-7-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-8-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-9-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-10-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-11-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When we replay a failed read, write or commit to the dataserver, we
need to ensure that we call ff_layout_read_prepare_v3(),
ff_layout_write_prepare_v3 or ff_layout_commit_prepare_v3() so that we
reset the statistics.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 1da19d709458..14109a82ce84 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1130,7 +1130,7 @@ static int ff_layout_async_handle_error_v3(struct rpc_task *task,
 	return -NFS4ERR_RESET_TO_PNFS;
 out_retry:
 	task->tk_status = 0;
-	rpc_restart_call(task);
+	rpc_restart_call_prepare(task);
 	rpc_delay(task, NFS_JUKEBOX_RETRY_TIME);
 	return -EAGAIN;
 }
-- 
2.5.0

