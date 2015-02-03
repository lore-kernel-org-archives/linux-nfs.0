Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f174.google.com ([209.85.213.174]:64416 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752601AbbBCV7s (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Feb 2015 16:59:48 -0500
Received: by mail-ig0-f174.google.com with SMTP id b16so30324213igk.1
        for <linux-nfs@vger.kernel.org>; Tue, 03 Feb 2015 13:59:47 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Olga.Kornievskaia@netapp.com
Subject: [PATCH 2/2] NFSv4.1: Ask for no delegation on OPEN if already holding one
Date: Tue,  3 Feb 2015 16:59:44 -0500
Message-Id: <1423000784-93180-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1423000784-93180-1-git-send-email-trond.myklebust@primarydata.com>
References: <1423000784-93180-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we already hold a delegation, there should be no reason for the
server to issue it to us again. Unfortunately, there appear to be
servers out there that engage in this practice. While it is often
harmless to do so, there is one case where this creates a problem
and that is when the client is in the process of returning that
delegation.
This patch uses the NFSv4.1 NFS4_SHARE_WANT_NO_DELEG flag to inform
the server not to return a delegation in these cases.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 25 ++++++++++++++++++++++---
 1 file changed, 22 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index cd4295d84d54..fb41624bafc9 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -942,8 +942,10 @@ static bool nfs4_clear_cap_atomic_open_v1(struct nfs_server *server,
 
 static u32
 nfs4_map_atomic_open_share(struct nfs_server *server,
+		struct inode *inode,
 		fmode_t fmode, int openflags)
 {
+	struct nfs_delegation *delegation;
 	u32 res = 0;
 
 	switch (fmode & (FMODE_READ | FMODE_WRITE)) {
@@ -959,8 +961,25 @@ nfs4_map_atomic_open_share(struct nfs_server *server,
 	if (!(server->caps & NFS_CAP_ATOMIC_OPEN_V1))
 		goto out;
 	/* Want no delegation if we're using O_DIRECT */
-	if (openflags & O_DIRECT)
+	if (openflags & O_DIRECT) {
 		res |= NFS4_SHARE_WANT_NO_DELEG;
+		goto out;
+	}
+	if (inode == NULL)
+		goto out;
+	rcu_read_lock();
+	delegation = rcu_dereference(NFS_I(inode)->delegation);
+	/*
+	 * If we have a delegation, either ask for an upgrade or ask for
+	 * no delegation
+	 */
+	if (delegation) {
+		if ((fmode & FMODE_WRITE) && !(delegation->type & FMODE_WRITE))
+			res |= NFS4_SHARE_WANT_WRITE_DELEG;
+		else
+			res |= NFS4_SHARE_WANT_NO_DELEG;
+	}
+	rcu_read_unlock();
 out:
 	return res;
 }
@@ -1028,7 +1047,7 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
 	p->o_arg.open_flags = flags;
 	p->o_arg.fmode = fmode & (FMODE_READ|FMODE_WRITE);
 	p->o_arg.share_access = nfs4_map_atomic_open_share(server,
-			fmode, flags);
+			dentry->d_inode, fmode, flags);
 	/* don't put an ACCESS op in OPEN compound if O_EXCL, because ACCESS
 	 * will return permission denied for all bits until close */
 	if (!(flags & O_EXCL)) {
@@ -2724,7 +2743,7 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 	}
 	calldata->arg.share_access =
 		nfs4_map_atomic_open_share(NFS_SERVER(inode),
-				calldata->arg.fmode, 0);
+				NULL, calldata->arg.fmode, 0);
 
 	nfs_fattr_init(calldata->res.fattr);
 	calldata->timestamp = jiffies;
-- 
2.1.0

