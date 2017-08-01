Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34391 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752166AbdHAUDE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Aug 2017 16:03:04 -0400
Received: by mail-io0-f193.google.com with SMTP id m88so2295429iod.1
        for <linux-nfs@vger.kernel.org>; Tue, 01 Aug 2017 13:03:04 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <anna.schumaker@netapp.com>
Cc: davej@codemonkey.org.uk, linux-nfs@vger.kernel.org
Subject: [PATCH 5/5] NFSv4: Cleanup setting of the migration flags.
Date: Tue,  1 Aug 2017 16:02:51 -0400
Message-Id: <20170801200251.130635-5-trond.myklebust@primarydata.com>
In-Reply-To: <20170801200251.130635-4-trond.myklebust@primarydata.com>
References: <20170801200251.130635-1-trond.myklebust@primarydata.com>
 <20170801200251.130635-2-trond.myklebust@primarydata.com>
 <20170801200251.130635-3-trond.myklebust@primarydata.com>
 <20170801200251.130635-4-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d9fc34dedcf8..15e91f003adc 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7498,13 +7498,10 @@ nfs4_run_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
 				sizeof(calldata->args.verifier.data));
 	}
 	calldata->args.client = clp;
-#ifdef CONFIG_NFS_V4_1_MIGRATION
-	calldata->args.flags = EXCHGID4_FLAG_SUPP_MOVED_REFER |
-	EXCHGID4_FLAG_BIND_PRINC_STATEID |
-	EXCHGID4_FLAG_SUPP_MOVED_MIGR,
-#else
 	calldata->args.flags = EXCHGID4_FLAG_SUPP_MOVED_REFER |
-	EXCHGID4_FLAG_BIND_PRINC_STATEID,
+	EXCHGID4_FLAG_BIND_PRINC_STATEID;
+#ifdef CONFIG_NFS_V4_1_MIGRATION
+	calldata->args.flags |= EXCHGID4_FLAG_SUPP_MOVED_MIGR;
 #endif
 	msg.rpc_argp = &calldata->args;
 	msg.rpc_resp = &calldata->res;
-- 
2.13.3

