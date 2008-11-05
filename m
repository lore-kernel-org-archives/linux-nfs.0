From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 7/8] NFS: "[no]resvport" mount option changes mountd client too
Date: Wed, 05 Nov 2008 15:25:35 -0500
Message-ID: <20081105202535.14469.29122.stgit@ingres.1015granger.net>
References: <20081105202040.14469.32458.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:38516 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754479AbYKEUZr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 15:25:47 -0500
In-Reply-To: <20081105202040.14469.32458.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the admin has specified the "noresvport" option for an NFS mount
point, the kernel's NFS client uses an unprivileged source port for
the main NFS transport.  The kernel's mountd client should use an
unprivileged port in this case as well.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/internal.h   |    1 +
 fs/nfs/mount_clnt.c |    4 +++-
 fs/nfs/super.c      |    1 +
 3 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index fa8174c..82d899f 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -72,6 +72,7 @@ struct nfs_mount_request {
 	u32			version;
 	unsigned short		protocol;
 	struct nfs_fh		*fh;
+	int			noresvport;
 };
 
 extern int nfs_mount(struct nfs_mount_request *info);
diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index 7e37113..ca905a5 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -50,7 +50,6 @@ int nfs_mount(struct nfs_mount_request *info)
 		.program	= &mnt_program,
 		.version	= info->version,
 		.authflavor	= RPC_AUTH_UNIX,
-		.flags		= 0,
 	};
 	struct rpc_clnt		*mnt_clnt;
 	int			status;
@@ -59,6 +58,9 @@ int nfs_mount(struct nfs_mount_request *info)
 		(info->hostname ? info->hostname : "server"),
 			info->dirpath);
 
+	if (info->noresvport)
+		args.flags |= RPC_CLNT_CREATE_NONPRIVPORT;
+
 	mnt_clnt = rpc_create(&args);
 	if (IS_ERR(mnt_clnt))
 		goto out_clnt_err;
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 773594f..54ffae3 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1226,6 +1226,7 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
 		.dirpath	= args->nfs_server.export_path,
 		.protocol	= args->mount_server.protocol,
 		.fh		= root_fh,
+		.noresvport	= args->flags & NFS_MOUNT_NORESVPORT,
 	};
 	int status;
 

