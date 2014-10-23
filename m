Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:8870 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752865AbaJWSBM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Oct 2014 14:01:12 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFS: Use nfs_server_capable() for checknig NFS_CAP_SEEK
Date: Thu, 23 Oct 2014 14:00:54 -0400
Message-ID: <1414087254-10130-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This should make the code easier to maintain in the future.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs42proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 0886f1d..056f5aa 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -50,7 +50,7 @@ loff_t nfs42_proc_llseek(struct file *filep, loff_t offset, int whence)
 	struct nfs_server *server = NFS_SERVER(inode);
 	int status;
 
-	if (!(server->caps & NFS_CAP_SEEK))
+	if (!nfs_server_capable(inode, NFS_CAP_SEEK))
 		return -ENOTSUPP;
 
 	status = nfs42_set_rw_stateid(&args.sa_stateid, filep, FMODE_READ);
-- 
2.1.2

