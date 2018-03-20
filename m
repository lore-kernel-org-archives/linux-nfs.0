Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:37289 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751390AbeCTUnv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Mar 2018 16:43:51 -0400
Received: by mail-it0-f65.google.com with SMTP id k79-v6so4114065ita.2
        for <linux-nfs@vger.kernel.org>; Tue, 20 Mar 2018 13:43:51 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 7/8] NFS: Remove the unused return_delegation() callback
Date: Tue, 20 Mar 2018 16:43:19 -0400
Message-Id: <20180320204320.93656-8-trond.myklebust@primarydata.com>
In-Reply-To: <20180320204320.93656-7-trond.myklebust@primarydata.com>
References: <20180320204320.93656-1-trond.myklebust@primarydata.com>
 <20180320204320.93656-2-trond.myklebust@primarydata.com>
 <20180320204320.93656-3-trond.myklebust@primarydata.com>
 <20180320204320.93656-4-trond.myklebust@primarydata.com>
 <20180320204320.93656-5-trond.myklebust@primarydata.com>
 <20180320204320.93656-6-trond.myklebust@primarydata.com>
 <20180320204320.93656-7-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs3proc.c       | 7 -------
 fs/nfs/nfs4proc.c       | 1 -
 fs/nfs/proc.c           | 7 -------
 include/linux/nfs_xdr.h | 1 -
 4 files changed, 16 deletions(-)

diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index ae03307bd8cd..cc04d988db7c 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -910,12 +910,6 @@ static int nfs3_have_delegation(struct inode *inode, fmode_t flags)
 	return 0;
 }
 
-static int nfs3_return_delegation(struct inode *inode)
-{
-	nfs_wb_all(inode);
-	return 0;
-}
-
 static const struct inode_operations nfs3_dir_inode_operations = {
 	.create		= nfs_create,
 	.lookup		= nfs_lookup,
@@ -992,7 +986,6 @@ const struct nfs_rpc_ops nfs_v3_clientops = {
 	.clear_acl_cache = forget_all_cached_acls,
 	.close_context	= nfs_close_context,
 	.have_delegation = nfs3_have_delegation,
-	.return_delegation = nfs3_return_delegation,
 	.alloc_client	= nfs_alloc_client,
 	.init_client	= nfs_init_client,
 	.free_client	= nfs_free_client,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e1550627c4d5..ef57a0eb5647 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -9649,7 +9649,6 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
 	.close_context  = nfs4_close_context,
 	.open_context	= nfs4_atomic_open,
 	.have_delegation = nfs4_have_delegation,
-	.return_delegation = nfs4_inode_return_delegation,
 	.alloc_client	= nfs4_alloc_client,
 	.init_client	= nfs4_init_client,
 	.free_client	= nfs4_free_client,
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 318b3f34a6d0..4e93d6308733 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -673,12 +673,6 @@ static int nfs_have_delegation(struct inode *inode, fmode_t flags)
 	return 0;
 }
 
-static int nfs_return_delegation(struct inode *inode)
-{
-	nfs_wb_all(inode);
-	return 0;
-}
-
 static const struct inode_operations nfs_dir_inode_operations = {
 	.create		= nfs_create,
 	.lookup		= nfs_lookup,
@@ -743,7 +737,6 @@ const struct nfs_rpc_ops nfs_v2_clientops = {
 	.lock_check_bounds = nfs_lock_check_bounds,
 	.close_context	= nfs_close_context,
 	.have_delegation = nfs_have_delegation,
-	.return_delegation = nfs_return_delegation,
 	.alloc_client	= nfs_alloc_client,
 	.init_client	= nfs_init_client,
 	.free_client	= nfs_free_client,
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index c4ba58b3c0f8..34d28564ecf3 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1635,7 +1635,6 @@ struct nfs_rpc_ops {
 				struct iattr *iattr,
 				int *);
 	int (*have_delegation)(struct inode *, fmode_t);
-	int (*return_delegation)(struct inode *);
 	struct nfs_client *(*alloc_client) (const struct nfs_client_initdata *);
 	struct nfs_client *(*init_client) (struct nfs_client *,
 				const struct nfs_client_initdata *);
-- 
2.14.3

