Return-Path: <SRS0=390i=5N=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12838C43331
	for <linux-nfs@archiver.kernel.org>; Sat, 28 Mar 2020 16:00:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D43542073B
	for <linux-nfs@archiver.kernel.org>; Sat, 28 Mar 2020 16:00:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1585411245;
	bh=C2p5QfZF4yvel01Z8hXZlMU1t/u4Pteqp/iiDmofIN0=;
	h=From:To:Subject:Date:List-ID:From;
	b=PuhGCaDO7nwjCzMWssubI1N7zgm5leoeKFSTHcdkaK5uF08WU5o4bzG2WcJEuAVUv
	 HD4b52E3R/iKFeDjpZlUL+DoHZbhFn0H5CYvTsBem3bSA6jYejoUDoQEwzFMvgiouV
	 8TO7PWXt+eEG3rKLpt9QGF51YPYsoqavDobYYXvE=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726899AbgC1QAp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 28 Mar 2020 12:00:45 -0400
Received: from mail.kernel.org ([198.145.29.99]:44958 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726518AbgC1QAp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 28 Mar 2020 12:00:45 -0400
Received: from localhost.localdomain (c-68-36-133-222.hsd1.mi.comcast.net [68.36.133.222])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 90ACD206DB
        for <linux-nfs@vger.kernel.org>; Sat, 28 Mar 2020 16:00:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1585411244;
        bh=C2p5QfZF4yvel01Z8hXZlMU1t/u4Pteqp/iiDmofIN0=;
        h=From:To:Subject:Date:From;
        b=dj0ywUgKYoKL3anZVtovX7lu6lD9WAJRets+S7B0s4+6toblPppacyo04/XhUd/+U
         IMK6xSfn9uPFKMChTLZtmfKBGXgJf7VxHmvm3dQ9QHkzEw3ilrrKQQwlx80V/BB3+k
         2wANUl8qZfIllWAIkbVVBE47HieDVZISUJG7tY6U=
From:   trondmy@kernel.org
To:     linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Remove unused FLUSH_SYNC support in nfs_initiate_pgio()
Date:   Sat, 28 Mar 2020 11:58:31 -0400
Message-Id: <20200328155831.1372523-1-trondmy@kernel.org>
X-Mailer: git-send-email 2.25.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

If the FLUSH_SYNC flag is set, nfs_initiate_pgio() will currently
wait for completion, and then return the status of the I/O operation.
What we actually want to report in nfs_pageio_doio() is whether or
not the RPC call was launched successfully, whereas actual I/O
status is intended handled in the reply callbacks.

Since FLUSH_SYNC is never set by any of the callers anyway, let's
just remove that code altogether.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/pagelist.c | 15 +++------------
 1 file changed, 3 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index c9c3edefc5be..be5e209399ea 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -629,7 +629,6 @@ int nfs_initiate_pgio(struct rpc_clnt *clnt, struct nfs_pgio_header *hdr,
 		.workqueue = nfsiod_workqueue,
 		.flags = RPC_TASK_ASYNC | RPC_TASK_CRED_NOREF | flags,
 	};
-	int ret = 0;
 
 	hdr->rw_ops->rw_initiate(hdr, &msg, rpc_ops, &task_setup_data, how);
 
@@ -641,18 +640,10 @@ int nfs_initiate_pgio(struct rpc_clnt *clnt, struct nfs_pgio_header *hdr,
 		(unsigned long long)hdr->args.offset);
 
 	task = rpc_run_task(&task_setup_data);
-	if (IS_ERR(task)) {
-		ret = PTR_ERR(task);
-		goto out;
-	}
-	if (how & FLUSH_SYNC) {
-		ret = rpc_wait_for_completion_task(task);
-		if (ret == 0)
-			ret = task->tk_status;
-	}
+	if (IS_ERR(task))
+		return PTR_ERR(task);
 	rpc_put_task(task);
-out:
-	return ret;
+	return 0;
 }
 EXPORT_SYMBOL_GPL(nfs_initiate_pgio);
 
-- 
2.25.1

