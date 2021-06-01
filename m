Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-19.4 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EDE5BC47096
	for <linux-nfs@archiver.kernel.org>; Tue,  1 Jun 2021 17:36:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id D4EE5613CE
	for <linux-nfs@archiver.kernel.org>; Tue,  1 Jun 2021 17:36:40 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S234294AbhFARiV (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 1 Jun 2021 13:38:21 -0400
Received: from mail.kernel.org ([198.145.29.99]:60188 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S233853AbhFARiV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 1 Jun 2021 13:38:21 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id D8C0561042;
        Tue,  1 Jun 2021 17:36:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1622568999;
        bh=GQc7mBd8skDb3dWoegKN2kqwZcPfuvWq76TTPL1/cfo=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=Mb4YiNPOH1IBSgioImxzu2vrRYuJHlh0ZXuB3I5UxnKIM217/G2Tc7aBNPACxx/h7
         IvB9NeO40/k1P649Gt5Pq+xLE5AESn//VFsmCtNTsnQhVxJui+NqLUApYfVNEjI7uW
         9EXo5R64J9FG+LUv1ZtOdIS8zhBpIDvSmUOT11ZeZ8E/no0d23lYl/fFA15zhb4sH4
         2OxEtZvw8pcpfqMgOeJ07L809nD/OBQ7tv1fk+e+HT5FH1nvRJMjDyClTwJ8/kBVSK
         ztq5leppAINpjQCL2IvxoPwNcGBmwxBte8qxm8qGk0eMK95DoiI9eB5QOMhr4sGt5C
         LkkgQsTeptLWg==
From:   trondmy@kernel.org
To:     zhangxiaoxu <zhangxiaoxu5@huawei.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFSv4: Fix second deadlock in nfs4_evict_inode()
Date:   Tue,  1 Jun 2021 13:36:34 -0400
Message-Id: <20210601173634.243152-2-trondmy@kernel.org>
X-Mailer: git-send-email 2.31.1
In-Reply-To: <20210601173634.243152-1-trondmy@kernel.org>
References: <20210601173634.243152-1-trondmy@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

If the inode is being evicted but has to return a layout first, then
that too can cause a deadlock in the corner case where the server
reboots.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4proc.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 673809644981..e25c16257545 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -9658,15 +9658,20 @@ int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp, bool sync)
 			&task_setup_data.rpc_client, &msg);
 
 	dprintk("--> %s\n", __func__);
+	lrp->inode = nfs_igrab_and_active(lrp->args.inode);
 	if (!sync) {
-		lrp->inode = nfs_igrab_and_active(lrp->args.inode);
 		if (!lrp->inode) {
 			nfs4_layoutreturn_release(lrp);
 			return -EAGAIN;
 		}
 		task_setup_data.flags |= RPC_TASK_ASYNC;
 	}
-	nfs4_init_sequence(&lrp->args.seq_args, &lrp->res.seq_res, 1, 0);
+	if (!lrp->inode)
+		nfs4_init_sequence(&lrp->args.seq_args, &lrp->res.seq_res, 1,
+				   1);
+	else
+		nfs4_init_sequence(&lrp->args.seq_args, &lrp->res.seq_res, 1,
+				   0);
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
-- 
2.31.1

