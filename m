Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:63273 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935150AbaFTRaf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Jun 2014 13:30:35 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH] nfs: Fix unused variable error
Date: Fri, 20 Jun 2014 13:30:26 -0400
Message-ID: <1403285426-1835-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

inode is unused when CONFIG_SUNRPC_DEBUG=n.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/pagelist.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 8143d6b..6e2c0bc 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -552,7 +552,6 @@ static void nfs_pgio_prepare(struct rpc_task *task, void *calldata)
 int nfs_initiate_pgio(struct rpc_clnt *clnt, struct nfs_pgio_header *hdr,
 		      const struct rpc_call_ops *call_ops, int how, int flags)
 {
-	struct inode *inode = hdr->inode;
 	struct rpc_task *task;
 	struct rpc_message msg = {
 		.rpc_argp = &hdr->args,
@@ -575,8 +574,8 @@ int nfs_initiate_pgio(struct rpc_clnt *clnt, struct nfs_pgio_header *hdr,
 	dprintk("NFS: %5u initiated pgio call "
 		"(req %s/%llu, %u bytes @ offset %llu)\n",
 		hdr->task.tk_pid,
-		inode->i_sb->s_id,
-		(unsigned long long)NFS_FILEID(inode),
+		hdr->inode->i_sb->s_id,
+		(unsigned long long)NFS_FILEID(hdr->inode),
 		hdr->args.count,
 		(unsigned long long)hdr->args.offset);
 
-- 
2.0.0

