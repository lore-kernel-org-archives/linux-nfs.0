Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f172.google.com ([209.85.160.172]:62663 "EHLO
	mail-gh0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968185Ab3HIQsi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Aug 2013 12:48:38 -0400
Received: by mail-gh0-f172.google.com with SMTP id r18so1299563ghr.3
        for <linux-nfs@vger.kernel.org>; Fri, 09 Aug 2013 09:48:37 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe44:ec31])
        by mx.google.com with ESMTPSA id v61sm20668921yhp.24.2013.08.09.09.48.36
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 09 Aug 2013 09:48:36 -0700 (PDT)
Subject: [PATCH v2 06/33] NFS: Remove unused call_sync minor version op
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 09 Aug 2013 12:48:35 -0400
Message-ID: <20130809164835.5362.67341.stgit@seurat.1015granger.net>
In-Reply-To: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
References: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4_fs.h  |    5 -----
 fs/nfs/nfs4proc.c |   13 -------------
 2 files changed, 18 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index bf2184e..8de9b93 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -38,11 +38,6 @@ struct nfs4_minor_version_ops {
 	u32	minor_version;
 	unsigned init_caps;
 
-	int	(*call_sync)(struct rpc_clnt *clnt,
-			struct nfs_server *server,
-			struct rpc_message *msg,
-			struct nfs4_sequence_args *args,
-			struct nfs4_sequence_res *res);
 	bool	(*match_stateid)(const nfs4_stateid *,
 			const nfs4_stateid *);
 	int	(*find_root_sec)(struct nfs_server *, struct nfs_fh *,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 940a39e..0ba7e35 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -790,16 +790,6 @@ static int nfs4_call_sync_sequence(struct rpc_clnt *clnt,
 }
 
 static
-int _nfs4_call_sync(struct rpc_clnt *clnt,
-		    struct nfs_server *server,
-		    struct rpc_message *msg,
-		    struct nfs4_sequence_args *args,
-		    struct nfs4_sequence_res *res)
-{
-	return rpc_call_sync(clnt, msg, 0);
-}
-
-static
 int nfs4_call_sync(struct rpc_clnt *clnt,
 		   struct nfs_server *server,
 		   struct rpc_message *msg,
@@ -7427,7 +7417,6 @@ static const struct nfs4_minor_version_ops nfs_v4_0_minor_ops = {
 		| NFS_CAP_ATOMIC_OPEN
 		| NFS_CAP_CHANGE_ATTR
 		| NFS_CAP_POSIX_LOCK,
-	.call_sync = _nfs4_call_sync,
 	.match_stateid = nfs4_match_stateid,
 	.find_root_sec = nfs4_find_root_sec,
 	.free_lock_state = nfs4_release_lockowner,
@@ -7446,7 +7435,6 @@ static const struct nfs4_minor_version_ops nfs_v4_1_minor_ops = {
 		| NFS_CAP_POSIX_LOCK
 		| NFS_CAP_STATEID_NFSV41
 		| NFS_CAP_ATOMIC_OPEN_V1,
-	.call_sync = nfs4_call_sync_sequence,
 	.match_stateid = nfs41_match_stateid,
 	.find_root_sec = nfs41_find_root_sec,
 	.free_lock_state = nfs41_free_lock_state,
@@ -7466,7 +7454,6 @@ static const struct nfs4_minor_version_ops nfs_v4_2_minor_ops = {
 		| NFS_CAP_POSIX_LOCK
 		| NFS_CAP_STATEID_NFSV41
 		| NFS_CAP_ATOMIC_OPEN_V1,
-	.call_sync = nfs4_call_sync_sequence,
 	.match_stateid = nfs41_match_stateid,
 	.find_root_sec = nfs41_find_root_sec,
 	.free_lock_state = nfs41_free_lock_state,

