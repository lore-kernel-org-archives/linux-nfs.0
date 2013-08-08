Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:50978 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965294Ab3HHO6D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Aug 2013 10:58:03 -0400
From: <andros@netapp.com>
To: <trond.myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 2/2] NFSv4.1 Use clientid management rpc_clnt for secinfo_no_name
Date: Thu, 8 Aug 2013 10:57:56 -0400
Message-ID: <1375973876-2522-3-git-send-email-andros@netapp.com>
In-Reply-To: <1375973876-2522-1-git-send-email-andros@netapp.com>
References: <1375973876-2522-1-git-send-email-andros@netapp.com>
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
 fs/nfs/nfs4proc.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f81dcec..f50ad28 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7090,6 +7090,10 @@ out:
 	return status;
 }
 
+/**
+ * Use the state managment nfs_client cl_rpcclient, which uses krb5i (if
+ * possible) as per RFC3530bis and RFC5661 Security Considerations sections
+ */
 static int
 _nfs41_proc_secinfo_no_name(struct nfs_server *server, struct nfs_fh *fhandle,
 		    struct nfs_fsinfo *info, struct nfs4_secinfo_flavors *flavors)
@@ -7105,7 +7109,8 @@ _nfs41_proc_secinfo_no_name(struct nfs_server *server, struct nfs_fh *fhandle,
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

