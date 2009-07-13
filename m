From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/5] NFS: Add ability to send MOUNTPROC_UMNT to the kernel's
	mountd client
Date: Mon, 13 Jul 2009 15:17:32 -0400
Message-ID: <20090713191731.1951.28069.stgit@matisse.1015granger.net>
References: <20090713191417.1951.75470.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:45020
	"EHLO matisse.1015granger.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754817AbZGMTRe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2009 15:17:34 -0400
In-Reply-To: <20090713191417.1951.75470.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

After certain failure modes of an NFS mount, an NFS client should send
a MOUNTPROC_UMNT request to remove the just-added mount entry from the
server's mount table.  While no-one should rely on the accuracy of the
server's mount table, this is just being a good neighbor.

Since NFS mount processing is handled in the kernel now, we will need
a function in the kernel's mountd client that can post a MOUNTRPC_UMNT
request, in order to handle these failure modes.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/internal.h   |    1 +
 fs/nfs/mount_clnt.c |   60 +++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 61 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index fa9a0d0..d3823d7 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -102,6 +102,7 @@ struct nfs_mount_request {
 };
 
 extern int nfs_mount(struct nfs_mount_request *info);
+extern int nfs_umount(const struct nfs_mount_request *info);
 
 /* client.c */
 extern struct rpc_program nfs_program;
diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index b5ed325..67148e4 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -218,6 +218,52 @@ out_mnt_err:
 	goto out;
 }
 
+/**
+ * nfs_umount - Notify a server that we have unmounted this export
+ * @info: pointer to umount request arguments
+ *
+ * MOUNTPROC_UMNT is advisory, so we set a short timeout.
+ */
+int nfs_umount(const struct nfs_mount_request *info)
+{
+	static const struct rpc_timeout nfs_umnt_timeout = {
+		.to_initval = 1 * HZ,
+		.to_maxval = 3 * HZ,
+		.to_retries = 2,
+	};
+	struct mountres	result;
+	struct rpc_message msg	= {
+		.rpc_argp	= info->dirpath,
+		.rpc_resp	= &result,
+	};
+	struct rpc_clnt *clnt;
+	int status;
+
+	clnt = nfs_mount_rpc_create(info, &nfs_umnt_timeout);
+	if (IS_ERR(clnt))
+		return PTR_ERR(clnt);
+
+	dprintk("NFS: sending UMNT request for %s:%s\n",
+		(info->hostname ? info->hostname : "server"),
+			info->dirpath);
+
+	if (info->version == NFS_MNT3_VERSION)
+		msg.rpc_proc = &clnt->cl_procinfo[MOUNTPROC3_UMNT];
+	else
+		msg.rpc_proc = &clnt->cl_procinfo[MOUNTPROC_UMNT];
+
+	status = rpc_call_sync(clnt, &msg, 0);
+	rpc_shutdown_client(clnt);
+
+	if (status < 0) {
+		dprintk("NFS: UMNT request failed, status=%d\n", status);
+		return status;
+	}
+
+	dprintk("NFS: UMNT request succeeded\n");
+	return 0;
+}
+
 /*
  * XDR encode/decode functions for MOUNT
  */
@@ -416,6 +462,13 @@ static struct rpc_procinfo mnt_procedures[] = {
 		.p_statidx	= MOUNTPROC_MNT,
 		.p_name		= "MOUNT",
 	},
+	[MOUNTPROC_UMNT] = {
+		.p_proc		= MOUNTPROC_UMNT,
+		.p_encode	= (kxdrproc_t)mnt_enc_dirpath,
+		.p_arglen	= MNT_enc_dirpath_sz,
+		.p_statidx	= MOUNTPROC_UMNT,
+		.p_name		= "UMOUNT",
+	},
 };
 
 static struct rpc_procinfo mnt3_procedures[] = {
@@ -428,6 +481,13 @@ static struct rpc_procinfo mnt3_procedures[] = {
 		.p_statidx	= MOUNTPROC3_MNT,
 		.p_name		= "MOUNT",
 	},
+	[MOUNTPROC3_UMNT] = {
+		.p_proc		= MOUNTPROC3_UMNT,
+		.p_encode	= (kxdrproc_t)mnt_enc_dirpath,
+		.p_arglen	= MNT_enc_dirpath_sz,
+		.p_statidx	= MOUNTPROC3_UMNT,
+		.p_name		= "UMOUNT",
+	},
 };
 
 

