Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f53.google.com ([209.85.216.53]:59513 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752519AbaHCRDW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Aug 2014 13:03:22 -0400
Received: by mail-qa0-f53.google.com with SMTP id v10so6004532qac.12
        for <linux-nfs@vger.kernel.org>; Sun, 03 Aug 2014 10:03:22 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 06/11] nfs: Ensure that nfs_callback_start_svc sets the server rq_task...
Date: Sun,  3 Aug 2014 13:03:08 -0400
Message-Id: <1407085393-3175-7-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1407085393-3175-6-git-send-email-trond.myklebust@primarydata.com>
References: <1407085393-3175-1-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-2-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-3-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-4-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-5-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-6-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/callback.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 073b4cf67ed9..5350bc23afe4 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -244,6 +244,7 @@ static int nfs_callback_start_svc(int minorversion, struct rpc_xprt *xprt,
 		cb_info->task = NULL;
 		return ret;
 	}
+	rqstp->rq_task = cb_info->task;
 	dprintk("nfs_callback_up: service started\n");
 	return 0;
 }
-- 
1.9.3

