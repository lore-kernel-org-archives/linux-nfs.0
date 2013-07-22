Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:55946 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757162Ab3GVQmR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Jul 2013 12:42:17 -0400
From: <andros@netapp.com>
To: <trond.myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH 4/4] NFSv4.1 Use clientid management rpc_clnt for secinfo_no_name
Date: Mon, 22 Jul 2013 12:42:08 -0400
Message-ID: <1374511328-49579-4-git-send-email-andros@netapp.com>
In-Reply-To: <1374511328-49579-1-git-send-email-andros@netapp.com>
References: <1374511328-49579-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

As per RFC 5661 Security Considerations

Commit 4edaa308 "NFS: Use "krb5i" to establish NFSv4 state whenever possible"
uses the nfs_client cl_rpcclient for all clientid management operations.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6a30a72..0452b61 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7098,7 +7098,8 @@ _nfs41_proc_secinfo_no_name(struct nfs_server *server, struct nfs_fh *fhandle,
 		.rpc_argp = &args,
 		.rpc_resp = &res,
 	};
-	return nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
+	return nfs4_call_sync(server->nfs_client->cl_rpcclient, server, &msg,
+				&args.seq_args, &res.seq_res, 0);
 }
 
 static int
-- 
1.8.3.1

