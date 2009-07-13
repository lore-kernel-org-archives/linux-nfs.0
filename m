From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/5] NFS: Refactor nfs_mount() to move rpc_create() to helper
Date: Mon, 13 Jul 2009 15:17:24 -0400
Message-ID: <20090713191724.1951.3235.stgit@matisse.1015granger.net>
References: <20090713191417.1951.75470.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:45017
	"EHLO matisse.1015granger.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754813AbZGMTR1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2009 15:17:27 -0400
In-Reply-To: <20090713191417.1951.75470.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up:  We want to add another function to mount_clnt.c that can
send an RPC request, so move creation of an RPC client for sending a
MNT request into a separate helper function so it can be shared.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/mount_clnt.c |   51 ++++++++++++++++++++++++++++++---------------------
 1 files changed, 30 insertions(+), 21 deletions(-)

diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index 38ef9ea..b5ed325 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -135,6 +135,32 @@ struct mnt_fhstatus {
 	struct nfs_fh *fh;
 };
 
+static struct
+rpc_clnt *nfs_mount_rpc_create(const struct nfs_mount_request *info,
+			       const struct rpc_timeout *timeout)
+{
+	struct rpc_create_args args = {
+		.protocol	= info->protocol,
+		.address	= info->sap,
+		.addrsize	= info->salen,
+		.timeout	= timeout,
+		.servername	= info->hostname,
+		.program	= &mnt_program,
+		.version	= info->version,
+		.authflavor	= RPC_AUTH_UNIX,
+	};
+	struct rpc_clnt *clnt;
+
+	if (info->noresvport)
+		args.flags |= RPC_CLNT_CREATE_NONPRIVPORT;
+
+	clnt = rpc_create(&args);
+	if (unlikely(IS_ERR(clnt)))
+		dprintk("NFS: failed to create MNT RPC client, error=%ld\n",
+				PTR_ERR(clnt));
+	return clnt;
+}
+
 /**
  * nfs_mount - Obtain an NFS file handle for the given host and path
  * @info: pointer to mount request arguments
@@ -152,29 +178,17 @@ int nfs_mount(struct nfs_mount_request *info)
 		.rpc_argp	= info->dirpath,
 		.rpc_resp	= &result,
 	};
-	struct rpc_create_args args = {
-		.protocol	= info->protocol,
-		.address	= info->sap,
-		.addrsize	= info->salen,
-		.servername	= info->hostname,
-		.program	= &mnt_program,
-		.version	= info->version,
-		.authflavor	= RPC_AUTH_UNIX,
-	};
 	struct rpc_clnt		*mnt_clnt;
 	int			status;
 
+	mnt_clnt = nfs_mount_rpc_create(info, NULL);
+	if (unlikely(IS_ERR(mnt_clnt)))
+		return PTR_ERR(mnt_clnt);
+
 	dprintk("NFS: sending MNT request for %s:%s\n",
 		(info->hostname ? info->hostname : "server"),
 			info->dirpath);
 
-	if (info->noresvport)
-		args.flags |= RPC_CLNT_CREATE_NONPRIVPORT;
-
-	mnt_clnt = rpc_create(&args);
-	if (IS_ERR(mnt_clnt))
-		goto out_clnt_err;
-
 	if (info->version == NFS_MNT3_VERSION)
 		msg.rpc_proc = &mnt_clnt->cl_procinfo[MOUNTPROC3_MNT];
 	else
@@ -194,11 +208,6 @@ int nfs_mount(struct nfs_mount_request *info)
 out:
 	return status;
 
-out_clnt_err:
-	status = PTR_ERR(mnt_clnt);
-	dprintk("NFS: failed to create MNT RPC client, status=%d\n", status);
-	goto out;
-
 out_call_err:
 	dprintk("NFS: MNT request failed, status=%d\n", status);
 	goto out;

