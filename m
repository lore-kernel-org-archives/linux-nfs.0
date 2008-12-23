From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 14/69] NFS: "[no]resvport" mount option changes mountd
 client too
Date: Tue, 23 Dec 2008 18:02:09 -0500
Message-ID: <20081223230209.13743.7435.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:29099 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752332AbYLWXXn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:23:43 -0500
Received: from svlrsexc2-prd.hq.netapp.com ([10.57.115.31])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNNa7Q021304
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:23:39 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

If the admin has specified the "noresvport" option for an NFS mount
point, the kernel's NFS client uses an unprivileged source port for
the main NFS transport.  The kernel's mountd client should use an
unprivileged port in this case as well.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/internal.h   |    1 +
 fs/nfs/mount_clnt.c |    4 +++-
 fs/nfs/super.c      |    1 +
 3 files changed, 5 insertions(+), 1 deletions(-)


diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 4e98396..340ede8 100644
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
index e05a77b..d8e062f 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1345,6 +1345,7 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
 		.dirpath	= args->nfs_server.export_path,
 		.protocol	= args->mount_server.protocol,
 		.fh		= root_fh,
+		.noresvport	= args->flags & NFS_MOUNT_NORESVPORT,
 	};
 	int status;
 

