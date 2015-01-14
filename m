Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f53.google.com ([209.85.220.53]:51668 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753348AbbANQpa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Jan 2015 11:45:30 -0500
Received: by mail-pa0-f53.google.com with SMTP id kq14so11495611pab.12
        for <linux-nfs@vger.kernel.org>; Wed, 14 Jan 2015 08:45:30 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v4 16/50] NFSv4.1/NFSv3: Add pNFS callbacks for nfs3_(read|write|commit)_done()
Date: Wed, 14 Jan 2015 08:44:22 -0800
Message-Id: <1421253896-73106-17-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1421253896-73106-1-git-send-email-loghyr@primarydata.com>
References: <1421253896-73106-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Enable pNFS callbacks to allow flex files to work correctly with a
NFSv3-enabled data server.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs3proc.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 524f9f8..78e557c 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -800,6 +800,9 @@ static int nfs3_read_done(struct rpc_task *task, struct nfs_pgio_header *hdr)
 {
 	struct inode *inode = hdr->inode;
 
+	if (hdr->pgio_done_cb != NULL)
+		return hdr->pgio_done_cb(task, hdr);
+
 	if (nfs3_async_handle_jukebox(task, inode))
 		return -EAGAIN;
 
@@ -825,6 +828,9 @@ static int nfs3_write_done(struct rpc_task *task, struct nfs_pgio_header *hdr)
 {
 	struct inode *inode = hdr->inode;
 
+	if (hdr->pgio_done_cb != NULL)
+		return hdr->pgio_done_cb(task, hdr);
+
 	if (nfs3_async_handle_jukebox(task, inode))
 		return -EAGAIN;
 	if (task->tk_status >= 0)
@@ -845,6 +851,9 @@ static void nfs3_proc_commit_rpc_prepare(struct rpc_task *task, struct nfs_commi
 
 static int nfs3_commit_done(struct rpc_task *task, struct nfs_commit_data *data)
 {
+	if (data->commit_done_cb != NULL)
+		return data->commit_done_cb(task, data);
+
 	if (nfs3_async_handle_jukebox(task, data->inode))
 		return -EAGAIN;
 	nfs_refresh_inode(data->inode, data->res.fattr);
-- 
1.9.3

