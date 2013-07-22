Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:55946 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756701Ab3GVQmQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Jul 2013 12:42:16 -0400
From: <andros@netapp.com>
To: <trond.myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH 3/4] NFSv4.1 Use clientid management rpc_clnt for secinfo
Date: Mon, 22 Jul 2013 12:42:07 -0400
Message-ID: <1374511328-49579-3-git-send-email-andros@netapp.com>
In-Reply-To: <1374511328-49579-1-git-send-email-andros@netapp.com>
References: <1374511328-49579-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

As per RFC 3530 and RFC 5661 Security Considerations

Commit 4edaa308 "NFS: Use "krb5i" to establish NFSv4 state whenever possible"
uses the nfs_client cl_rpcclient for all clientid management operations.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7761802..6a30a72 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5806,9 +5806,10 @@ static int _nfs4_proc_secinfo(struct inode *dir, const struct qstr *name, struct
 		.rpc_argp = &args,
 		.rpc_resp = &res,
 	};
+	struct rpc_clnt *clnt = NFS_SERVER(dir)->nfs_client->cl_rpcclient;
 
 	dprintk("NFS call  secinfo %s\n", name->name);
-	status = nfs4_call_sync(NFS_SERVER(dir)->client, NFS_SERVER(dir), &msg, &args.seq_args, &res.seq_res, 0);
+	status = nfs4_call_sync(clnt, NFS_SERVER(dir), &msg, &args.seq_args, &res.seq_res, 0);
 	dprintk("NFS reply  secinfo: %d\n", status);
 	return status;
 }
-- 
1.8.3.1

