Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f47.google.com ([209.85.219.47]:47840 "EHLO
	mail-oa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752400AbaBTC2b (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Feb 2014 21:28:31 -0500
Received: by mail-oa0-f47.google.com with SMTP id m1so1472058oag.20
        for <linux-nfs@vger.kernel.org>; Wed, 19 Feb 2014 18:28:30 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/7] NFSv4.1: Ensure that the layout recall callback matches layout stateids
Date: Wed, 19 Feb 2014 21:28:21 -0500
Message-Id: <1392863305-14870-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1392863305-14870-2-git-send-email-trond.myklebust@primarydata.com>
References: <1392863305-14870-1-git-send-email-trond.myklebust@primarydata.com>
 <1392863305-14870-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It is not sufficient to compare filehandles when we receive a layout
recall from the server; we also need to check that the layout stateids
match.

Reported-by: shaobingqing <shaobingqing@bwstor.com.cn>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/callback_proc.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index ae2e87b95453..570c8a1d2f3d 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -112,7 +112,8 @@ out:
  * TODO: keep track of all layouts (and delegations) in a hash table
  * hashed by filehandle.
  */
-static struct pnfs_layout_hdr * get_layout_by_fh_locked(struct nfs_client *clp, struct nfs_fh *fh)
+static struct pnfs_layout_hdr * get_layout_by_fh_locked(struct nfs_client *clp,
+		struct nfs_fh *fh, nfs4_stateid *stateid)
 {
 	struct nfs_server *server;
 	struct inode *ino;
@@ -120,6 +121,8 @@ static struct pnfs_layout_hdr * get_layout_by_fh_locked(struct nfs_client *clp,
 
 	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
 		list_for_each_entry(lo, &server->layouts, plh_layouts) {
+			if (!nfs4_stateid_match_other(&lo->plh_stateid, stateid))
+				continue;
 			if (nfs_compare_fh(fh, &NFS_I(lo->plh_inode)->fh))
 				continue;
 			ino = igrab(lo->plh_inode);
@@ -141,13 +144,14 @@ static struct pnfs_layout_hdr * get_layout_by_fh_locked(struct nfs_client *clp,
 	return NULL;
 }
 
-static struct pnfs_layout_hdr * get_layout_by_fh(struct nfs_client *clp, struct nfs_fh *fh)
+static struct pnfs_layout_hdr * get_layout_by_fh(struct nfs_client *clp,
+		struct nfs_fh *fh, nfs4_stateid *stateid)
 {
 	struct pnfs_layout_hdr *lo;
 
 	spin_lock(&clp->cl_lock);
 	rcu_read_lock();
-	lo = get_layout_by_fh_locked(clp, fh);
+	lo = get_layout_by_fh_locked(clp, fh, stateid);
 	rcu_read_unlock();
 	spin_unlock(&clp->cl_lock);
 
@@ -162,9 +166,9 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 	u32 rv = NFS4ERR_NOMATCHING_LAYOUT;
 	LIST_HEAD(free_me_list);
 
-	lo = get_layout_by_fh(clp, &args->cbl_fh);
+	lo = get_layout_by_fh(clp, &args->cbl_fh, &args->cbl_stateid);
 	if (!lo)
-		return NFS4ERR_NOMATCHING_LAYOUT;
+		goto out;
 
 	ino = lo->plh_inode;
 	spin_lock(&ino->i_lock);
@@ -179,6 +183,7 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 	pnfs_free_lseg_list(&free_me_list);
 	pnfs_put_layout_hdr(lo);
 	iput(ino);
+out:
 	return rv;
 }
 
-- 
1.8.5.3

