Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-o-3.desy.de ([131.169.56.156]:56150 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761145AbbBIQ5z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Feb 2015 11:57:55 -0500
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 0C58B28076B
	for <linux-nfs@vger.kernel.org>; Mon,  9 Feb 2015 17:57:54 +0100 (CET)
Received: from ZITSWEEP1.win.desy.de (zitsweep1.win.desy.de [131.169.97.95])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id EF2CE13EAF
	for <linux-nfs@vger.kernel.org>; Mon,  9 Feb 2015 17:57:53 +0100 (MET)
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH] nfs: do not initialize back channel with DS
Date: Mon,  9 Feb 2015 17:57:45 +0100
Message-Id: <1423501065-14320-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 fs/nfs/nfs4proc.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 2e7c9f7..7f9674d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7236,9 +7236,12 @@ static int _nfs4_proc_create_session(struct nfs_client *clp,
 		.rpc_cred = cred,
 	};
 	int status;
+	int flags = SESSION4_PERSIST;
 
 	nfs4_init_channel_attrs(&args);
-	args.flags = (SESSION4_PERSIST | SESSION4_BACK_CHAN);
+	if (!is_ds_only_client(clp))
+		flags |= SESSION4_BACK_CHAN;
+	args.flags = flags;
 
 	status = rpc_call_sync(session->clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
 	trace_nfs4_create_session(clp, status);
-- 
2.1.0

