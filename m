Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:2372 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752759Ab3HGUJ7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Aug 2013 16:09:59 -0400
From: <andros@netapp.com>
To: <trond.myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 1/6] NFSv4.1 Fix an rpc client leak
Date: Wed, 7 Aug 2013 16:09:52 -0400
Message-ID: <1375906192-1988-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

nfs4_proc_lookup_mountpoint clones an rpc client to perform a lookup across
a mountpoint. If the security of the mountpoint is different than that of
the clonded rpc client, a secinfo query is sent, and if successful, a new
rpc client is cloned an returned to nfs4_proc_lookup_mountpoint replacing
the original cloned client pointer. In this case, the originoal cloned client
is not reaped - which results in a leak of multiple rpc clients, as the
parent of the original cloned client will not be dereferenced, and it's
parent will not be dereferenced...

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 0e64ccc..ee30a4f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3073,12 +3073,15 @@ nfs4_proc_lookup_mountpoint(struct inode *dir, struct qstr *name,
 {
 	int status;
 	struct rpc_clnt *client = rpc_clone_client(NFS_CLIENT(dir));
+	struct rpc_clnt *clnt = client;
 
 	status = nfs4_proc_lookup_common(&client, dir, name, fhandle, fattr, NULL);
 	if (status < 0) {
 		rpc_shutdown_client(client);
 		return ERR_PTR(status);
 	}
+	if (clnt != client)
+		rpc_shutdown_client(clnt);
 	return client;
 }
 
-- 
1.8.3.1

