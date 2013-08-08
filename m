Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:30405 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965458Ab3HHO6D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Aug 2013 10:58:03 -0400
From: <andros@netapp.com>
To: <trond.myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 1/2] NFSv4.1 Use clientid management rpc_clnt for secinfo
Date: Thu, 8 Aug 2013 10:57:55 -0400
Message-ID: <1375973876-2522-2-git-send-email-andros@netapp.com>
In-Reply-To: <1375973876-2522-1-git-send-email-andros@netapp.com>
References: <1375973876-2522-1-git-send-email-andros@netapp.com>
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
 fs/nfs/nfs4proc.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a187f4d..f81dcec 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5794,6 +5794,10 @@ int nfs4_proc_fs_locations(struct rpc_clnt *client, struct inode *dir,
 	return err;
 }
 
+/**
+ * Use the state managment nfs_client cl_rpcclient, which uses krb5i (if
+ * possible) as per RFC3530bis and RFC5661 Security Considerations sections
+ */
 static int _nfs4_proc_secinfo(struct inode *dir, const struct qstr *name, struct nfs4_secinfo_flavors *flavors)
 {
 	int status;
@@ -5809,9 +5813,10 @@ static int _nfs4_proc_secinfo(struct inode *dir, const struct qstr *name, struct
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

