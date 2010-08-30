Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:65347 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755981Ab0H3QoG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Aug 2010 12:44:06 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Cc: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 3/3] SQUASHME: pnfs: get machince creds for getdevicelist
Date: Mon, 30 Aug 2010 19:44:03 +0300
Message-Id: <1283186643-17081-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4C7BDD8C.40509@panasas.com>
References: <4C7BDD8C.40509@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 33c4057..48a763e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5784,11 +5784,13 @@ static int _nfs4_getdevicelist(struct nfs_server *server,
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_GETDEVICELIST],
 		.rpc_argp = &args,
 		.rpc_resp = &res,
+		.rpc_cred = nfs4_get_machine_cred(server->nfs_client),
 	};
 	int status;
 
 	dprintk("--> %s\n", __func__);
 	status = nfs4_call_sync(server, &msg, &args, &res, 0);
+	put_rpccred(msg.rpc_cred);
 	dprintk("<-- %s status=%d\n", __func__, status);
 	return status;
 }
-- 
1.7.2.2

