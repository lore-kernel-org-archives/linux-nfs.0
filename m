Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f181.google.com ([209.85.210.181]:58254 "EHLO
	mail-ia0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751439Ab3CPTzr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 16 Mar 2013 15:55:47 -0400
Received: by mail-ia0-f181.google.com with SMTP id o25so1906226iad.26
        for <linux-nfs@vger.kernel.org>; Sat, 16 Mar 2013 12:55:46 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v1 11/15] NFS: Clean up nfs4_proc_get_rootfh
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>,
        Bryan Schumaker <bjschuma@netapp.com>
Date: Sat, 16 Mar 2013 15:55:45 -0400
Message-ID: <20130316195545.27329.86881.stgit@seurat.1015granger.net>
In-Reply-To: <20130316195044.27329.11666.stgit@seurat.1015granger.net>
References: <20130316195044.27329.11666.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The long lines with no vertical white space make this function
difficult for humans to read.  Add a proper documenting comment
while we're here.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Bryan Schumaker <bjschuma@netapp.com>
---

 fs/nfs/nfs4proc.c |   32 ++++++++++++++++++++++----------
 1 files changed, 22 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c05e78b..addcdaf 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2484,24 +2484,36 @@ static int nfs4_find_root_sec(struct nfs_server *server, struct nfs_fh *fhandle,
 	return status;
 }
 
-/*
- * get the file handle for the "/" directory on the server
+static int nfs4_do_find_root_sec(struct nfs_server *server,
+		struct nfs_fh *fhandle, struct nfs_fsinfo *info)
+{
+	int mv = server->nfs_client->cl_minorversion;
+	return nfs_v4_minor_ops[mv]->find_root_sec(server, fhandle, info);
+}
+
+/**
+ * nfs4_proc_get_rootfh - get file handle for server's pseudoroot
+ * @server: initialized nfs_server handle
+ * @fhandle: we fill in the pseudo-fs root file handle
+ * @info: we fill in an FSINFO struct
+ *
+ * Returns zero on success, or a negative errno.
  */
 int nfs4_proc_get_rootfh(struct nfs_server *server, struct nfs_fh *fhandle,
 			 struct nfs_fsinfo *info)
 {
-	int minor_version = server->nfs_client->cl_minorversion;
-	int status = nfs4_lookup_root(server, fhandle, info);
-	if ((status == -NFS4ERR_WRONGSEC) && !(server->flags & NFS_MOUNT_SECFLAVOUR))
-		/*
-		 * A status of -NFS4ERR_WRONGSEC will be mapped to -EPERM
-		 * by nfs4_map_errors() as this function exits.
-		 */
-		status = nfs_v4_minor_ops[minor_version]->find_root_sec(server, fhandle, info);
+	int status;
+
+	status = nfs4_lookup_root(server, fhandle, info);
+	if ((status == -NFS4ERR_WRONGSEC) &&
+	    !(server->flags & NFS_MOUNT_SECFLAVOUR))
+		status = nfs4_do_find_root_sec(server, fhandle, info);
+
 	if (status == 0)
 		status = nfs4_server_capabilities(server, fhandle);
 	if (status == 0)
 		status = nfs4_do_fsinfo(server, fhandle, info);
+
 	return nfs4_map_errors(status);
 }
 

