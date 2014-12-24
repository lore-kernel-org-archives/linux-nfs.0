Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f170.google.com ([209.85.213.170]:63006 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751821AbaLXHNx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Dec 2014 02:13:53 -0500
Received: by mail-ig0-f170.google.com with SMTP id r2so7792183igi.5
        for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2014 23:13:52 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <Trond.Myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 16/49] NFSv4.1/NFSv3: Add pNFS callbacks for nfs3_(read|write|commit)_done()
Date: Tue, 23 Dec 2014 23:12:55 -0800
Message-Id: <1419405208-25975-17-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1419405208-25975-1-git-send-email-loghyr@primarydata.com>
References: <1419405208-25975-1-git-send-email-loghyr@primarydata.com>
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

