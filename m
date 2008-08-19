From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] nfs: authenticated deep mounting
Date: Tue, 19 Aug 2008 16:34:36 -0400
Message-ID: <20080819203436.GC8331@fieldses.org>
References: <48AA9122.90805@few.vu.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, Trond Myklebust <trond@netapp.com>
To: EG Keizer <keie-vHs5IaWfoDhmR6Xm/wNWPw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:44960 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753901AbYHSUei (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Aug 2008 16:34:38 -0400
In-Reply-To: <48AA9122.90805-vHs5IaWfoDhmR6Xm/wNWPw@public.gmane.org>
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

On Tue, Aug 19, 2008 at 11:23:46AM +0200, EG Keizer wrote:
> Allow mount to do authenticated mounts below the root of the exported tree.

Thanks.  For some reason, if I look at your mail in a text editor I see
an extra space at the beginning of each line.  Which prevents patch from
applying it.  Anyway, with that fixed up, and some other trivial
changes, the below is what I get.  Makes sense to me; Trond?

--b.

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

