From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 2/7] nfs: authenticated deep mounting
Date: Fri, 26 Sep 2008 19:35:12 -0400
Message-ID: <1222472117-9773-3-git-send-email-bfields@citi.umich.edu>
References: <1222472117-9773-1-git-send-email-bfields@citi.umich.edu>
 <1222472117-9773-2-git-send-email-bfields@citi.umich.edu>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
	EG Keizer <keie-vHs5IaWfoDhmR6Xm/wNWPw@public.gmane.org>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:58547 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752821AbYIZXfV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Sep 2008 19:35:21 -0400
In-Reply-To: <1222472117-9773-2-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: EG Keizer <keie-vHs5IaWfoDhmR6Xm/wNWPw@public.gmane.org>

Allow mount to do authenticated mounts below the root of the exported tree.
The wording in RFC 2623, sec 2.3.2. allows fsinfo with UNIX authentication
on the root of the export. Mounts are not always done on the root
of the exported tree. Especially autoumounts often mount below the root of
the exported tree.
Some server implementations (justly) require full authentication for the
so-called deep mounts. The old code used AUTH_SYS only. This caused deep
mounts to fail on systems requiring stronger authentication..
The client should try both authentication types and use the first one that
succeeds.
This method was already partially implemented. This patch completes
the implementation for NFS2 and NFS3.
This patch was developed to allow Debian systems to automount home directories
on Solaris servers with krb5 authentication.

Tested on kernel 2.6.24-etchnhalf.1

Signed-off-by: E.G. Keizer <keie-vHs5IaWfoDhmR6Xm/wNWPw@public.gmane.org>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfs/nfs3proc.c |   20 ++++++++++++++++++--
 fs/nfs/proc.c     |   10 ++++++++--
 2 files changed, 26 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 1e750e4..c55be7a 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -699,7 +699,7 @@ nfs3_proc_statfs(struct nfs_server *server, struct nfs_fh *fhandle,
 }
 
 static int
-nfs3_proc_fsinfo(struct nfs_server *server, struct nfs_fh *fhandle,
+do_proc_fsinfo(struct rpc_clnt *client, struct nfs_fh *fhandle,
 		 struct nfs_fsinfo *info)
 {
 	struct rpc_message msg = {
@@ -711,11 +711,27 @@ nfs3_proc_fsinfo(struct nfs_server *server, struct nfs_fh *fhandle,
 
 	dprintk("NFS call  fsinfo\n");
 	nfs_fattr_init(info->fattr);
-	status = rpc_call_sync(server->nfs_client->cl_rpcclient, &msg, 0);
+	status = rpc_call_sync(client, &msg, 0);
 	dprintk("NFS reply fsinfo: %d\n", status);
 	return status;
 }
 
+/*
+ * Bare-bones access to fsinfo: this is for nfs_get_root/nfs_get_sb via
+ * nfs_create_server
+ */
+static int
+nfs3_proc_fsinfo(struct nfs_server *server, struct nfs_fh *fhandle,
+		   struct nfs_fsinfo *info)
+{
+	int	status;
+
+	status = do_proc_fsinfo(server->client, fhandle, info);
+	if (status && server->nfs_client->cl_rpcclient != server->client)
+		status = do_proc_fsinfo(server->nfs_client->cl_rpcclient, fhandle, info);
+	return status;
+}
+
 static int
 nfs3_proc_pathconf(struct nfs_server *server, struct nfs_fh *fhandle,
 		   struct nfs_pathconf *info)
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 4dbb84d..1934652 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -65,14 +65,20 @@ nfs_proc_get_root(struct nfs_server *server, struct nfs_fh *fhandle,
 
 	dprintk("%s: call getattr\n", __func__);
 	nfs_fattr_init(fattr);
-	status = rpc_call_sync(server->nfs_client->cl_rpcclient, &msg, 0);
+	status = rpc_call_sync(server->client, &msg, 0);
+	/* Retry with default authentication if different */
+	if (status && server->nfs_client->cl_rpcclient != server->client)
+		status = rpc_call_sync(server->nfs_client->cl_rpcclient, &msg, 0);
 	dprintk("%s: reply getattr: %d\n", __func__, status);
 	if (status)
 		return status;
 	dprintk("%s: call statfs\n", __func__);
 	msg.rpc_proc = &nfs_procedures[NFSPROC_STATFS];
 	msg.rpc_resp = &fsinfo;
-	status = rpc_call_sync(server->nfs_client->cl_rpcclient, &msg, 0);
+	status = rpc_call_sync(server->client, &msg, 0);
+	/* Retry with default authentication if different */
+	if (status && server->nfs_client->cl_rpcclient != server->client)
+		status = rpc_call_sync(server->nfs_client->cl_rpcclient, &msg, 0);
 	dprintk("%s: reply statfs: %d\n", __func__, status);
 	if (status)
 		return status;
-- 
1.5.5.rc1

