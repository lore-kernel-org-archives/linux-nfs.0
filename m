Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47698 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757062Ab1DMSbe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Apr 2011 14:31:34 -0400
Message-ID: <4DA5EC02.8030109@netapp.com>
Date: Wed, 13 Apr 2011 14:31:30 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH 4/6] NFS: Attempt mount with default sec flavor first
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


nfs4_lookup_root() is already configured to use either RPC_AUTH_UNIX
or a user specified flavor (through -o sec=<whatever>).  We should
use this flavor first, and only attempt negotiation if it fails
with -EPERM.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/nfs4proc.c |   24 ++++++++++++++++--------
 1 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8833472..7e27ebf 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2208,19 +2208,15 @@ out:
 	return ret;
 }
 
-/*
- * get the file handle for the "/" directory on the server
- */
-static int nfs4_proc_get_root(struct nfs_server *server, struct nfs_fh *fhandle,
+static int nfs4_find_root_sec(struct nfs_server *server, struct nfs_fh *fhandle,
 			      struct nfs_fsinfo *info)
 {
 	int i, len, status = 0;
 	rpc_authflavor_t flav_array[NFS_MAX_SECFLAVORS];
 
-	flav_array[0] = RPC_AUTH_UNIX;
-	len = gss_mech_list_pseudoflavors(&flav_array[1]);
-	flav_array[1+len] = RPC_AUTH_NULL;
-	len += 2;
+	len = gss_mech_list_pseudoflavors(&flav_array[0]);
+	flav_array[len] = RPC_AUTH_NULL;
+	len += 1;
 
 	for (i = 0; i < len; i++) {
 		status = nfs4_lookup_root_sec(server, fhandle, info, flav_array[i]);
@@ -2228,6 +2224,18 @@ static int nfs4_proc_get_root(struct nfs_server *server, struct nfs_fh *fhandle,
 			continue;
 		break;
 	}
+	return status;
+}
+
+/*
+ * get the file handle for the "/" directory on the server
+ */
+static int nfs4_proc_get_root(struct nfs_server *server, struct nfs_fh *fhandle,
+			      struct nfs_fsinfo *info)
+{
+	int status = nfs4_lookup_root(server, fhandle, info);
+	if (status == -EPERM)
+		status = nfs4_find_root_sec(server, fhandle, info);
 	if (status == 0)
 		status = nfs4_server_capabilities(server, fhandle);
 	if (status == 0)
-- 
1.7.4.4

