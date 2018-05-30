Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:38161 "EHLO
        mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932074AbeE3SGS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 30 May 2018 14:06:18 -0400
Received: by mail-io0-f177.google.com with SMTP id l19-v6so12923312ioj.5
        for <linux-nfs@vger.kernel.org>; Wed, 30 May 2018 11:06:17 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-49-162-121.hsd1.mi.comcast.net. [68.49.162.121])
        by smtp.gmail.com with ESMTPSA id i201-v6sm8589368ite.33.2018.05.30.11.06.16
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 May 2018 11:06:16 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 01/19] pnfs: Remove redundant assignment from nfs4_proc_layoutget().
Date: Wed, 30 May 2018 14:05:35 -0400
Message-Id: <20180530180553.38769-2-trond.myklebust@hammerspace.com>
In-Reply-To: <20180530180553.38769-1-trond.myklebust@hammerspace.com>
References: <20180530180553.38769-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Fred Isaman <fred.isaman@gmail.com>

nfs_init_sequence() will clear this for us.

Signed-off-by: Fred Isaman <fred.isaman@gmail.com>
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4proc.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 66664d814b3c..6287fb6dee50 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8797,7 +8797,6 @@ nfs4_proc_layoutget(struct nfs4_layoutget *lgp, long *timeout, gfp_t gfp_flags)
 	lgp->args.layout.pglen = max_pages * PAGE_SIZE;
 
 	lgp->res.layoutp = &lgp->args.layout;
-	lgp->res.seq_res.sr_slot = NULL;
 	nfs4_init_sequence(&lgp->args.seq_args, &lgp->res.seq_res, 0, 0);
 
 	task = rpc_run_task(&task_setup_data);
-- 
2.17.0

