Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:44578 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751348AbeCTUnp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Mar 2018 16:43:45 -0400
Received: by mail-io0-f194.google.com with SMTP id h23so4005800iob.11
        for <linux-nfs@vger.kernel.org>; Tue, 20 Mar 2018 13:43:45 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/8] NFS: Move the delegation return down into nfs4_proc_link()
Date: Tue, 20 Mar 2018 16:43:14 -0400
Message-Id: <20180320204320.93656-3-trond.myklebust@primarydata.com>
In-Reply-To: <20180320204320.93656-2-trond.myklebust@primarydata.com>
References: <20180320204320.93656-1-trond.myklebust@primarydata.com>
 <20180320204320.93656-2-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move the delegation return out of generic code.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/dir.c      | 2 --
 fs/nfs/nfs4proc.c | 2 ++
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 2f3f86726f5b..b4549e54007d 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1932,8 +1932,6 @@ nfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *dentry)
 		old_dentry, dentry);
 
 	trace_nfs_link_enter(inode, dir, dentry);
-	NFS_PROTO(inode)->return_delegation(inode);
-
 	d_drop(dentry);
 	error = NFS_PROTO(dir)->link(inode, dir, &dentry->d_name);
 	if (error == 0) {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 75b8ea08e6f7..8290a04907b0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4318,6 +4318,8 @@ static int _nfs4_proc_link(struct inode *inode, struct inode *dir, const struct
 	}
 	arg.bitmask = nfs4_bitmask(server, res.label);
 
+	nfs4_inode_return_delegation(inode);
+
 	status = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1);
 	if (!status) {
 		update_changeattr(dir, &res.cinfo, res.fattr->time_start);
-- 
2.14.3

