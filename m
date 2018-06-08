Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f42.google.com ([209.85.214.42]:36638 "EHLO
        mail-it0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752478AbeFHUpR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jun 2018 16:45:17 -0400
Received: by mail-it0-f42.google.com with SMTP id j135-v6so4051740itj.1
        for <linux-nfs@vger.kernel.org>; Fri, 08 Jun 2018 13:45:17 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (50-36-175-81.alma.mi.frontiernet.net. [50.36.175.81])
        by smtp.gmail.com with ESMTPSA id x97-v6sm1297412ita.18.2018.06.08.13.45.15
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 08 Jun 2018 13:45:15 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 2/2] NFSv4: Return NFS4ERR_DELAY when a layout recall fails due to igrab()
Date: Fri,  8 Jun 2018 16:44:50 -0400
Message-Id: <20180608204450.33707-2-trond.myklebust@hammerspace.com>
In-Reply-To: <20180608204450.33707-1-trond.myklebust@hammerspace.com>
References: <20180608204450.33707-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/callback_proc.c | 26 ++++++++++++++------------
 1 file changed, 14 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index eacd09dcdad1..3a49bb19ef07 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -128,7 +128,6 @@ static struct inode *nfs_layout_find_inode_by_stateid(struct nfs_client *clp,
 	struct inode *inode;
 	struct pnfs_layout_hdr *lo;
 
-restart:
 	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
 		list_for_each_entry(lo, &server->layouts, plh_layouts) {
 			if (stateid != NULL &&
@@ -136,20 +135,20 @@ static struct inode *nfs_layout_find_inode_by_stateid(struct nfs_client *clp,
 				continue;
 			inode = igrab(lo->plh_inode);
 			if (!inode)
-				continue;
+				return ERR_PTR(-EAGAIN);
 			if (!nfs_sb_active(inode->i_sb)) {
 				rcu_read_unlock();
 				spin_unlock(&clp->cl_lock);
 				iput(inode);
 				spin_lock(&clp->cl_lock);
 				rcu_read_lock();
-				goto restart;
+				return ERR_PTR(-EAGAIN);
 			}
 			return inode;
 		}
 	}
 
-	return NULL;
+	return ERR_PTR(-ENOENT);
 }
 
 /*
@@ -166,7 +165,6 @@ static struct inode *nfs_layout_find_inode_by_fh(struct nfs_client *clp,
 	struct inode *inode;
 	struct pnfs_layout_hdr *lo;
 
-restart:
 	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
 		list_for_each_entry(lo, &server->layouts, plh_layouts) {
 			nfsi = NFS_I(lo->plh_inode);
@@ -176,20 +174,20 @@ static struct inode *nfs_layout_find_inode_by_fh(struct nfs_client *clp,
 				continue;
 			inode = igrab(lo->plh_inode);
 			if (!inode)
-				continue;
+				return ERR_PTR(-EAGAIN);
 			if (!nfs_sb_active(inode->i_sb)) {
 				rcu_read_unlock();
 				spin_unlock(&clp->cl_lock);
 				iput(inode);
 				spin_lock(&clp->cl_lock);
 				rcu_read_lock();
-				goto restart;
+				return ERR_PTR(-EAGAIN);
 			}
 			return inode;
 		}
 	}
 
-	return NULL;
+	return ERR_PTR(-ENOENT);
 }
 
 static struct inode *nfs_layout_find_inode(struct nfs_client *clp,
@@ -201,7 +199,7 @@ static struct inode *nfs_layout_find_inode(struct nfs_client *clp,
 	spin_lock(&clp->cl_lock);
 	rcu_read_lock();
 	inode = nfs_layout_find_inode_by_stateid(clp, stateid);
-	if (!inode)
+	if (inode == ERR_PTR(-ENOENT))
 		inode = nfs_layout_find_inode_by_fh(clp, fh);
 	rcu_read_unlock();
 	spin_unlock(&clp->cl_lock);
@@ -256,8 +254,11 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 	LIST_HEAD(free_me_list);
 
 	ino = nfs_layout_find_inode(clp, &args->cbl_fh, &args->cbl_stateid);
-	if (!ino)
-		goto out;
+	if (IS_ERR(ino)) {
+		if (ino == ERR_PTR(-EAGAIN))
+			rv = NFS4ERR_DELAY;
+		goto out_noput;
+	}
 
 	pnfs_layoutcommit_inode(ino, false);
 
@@ -303,9 +304,10 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 	nfs_commit_inode(ino, 0);
 	pnfs_put_layout_hdr(lo);
 out:
+	nfs_iput_and_deactive(ino);
+out_noput:
 	trace_nfs4_cb_layoutrecall_file(clp, &args->cbl_fh, ino,
 			&args->cbl_stateid, -rv);
-	nfs_iput_and_deactive(ino);
 	return rv;
 }
 
-- 
2.17.1

