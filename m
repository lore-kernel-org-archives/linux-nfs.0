Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:6416 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752755Ab3HVA02 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Aug 2013 20:26:28 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/6] NFSv3: Deal with a sparse warning in nfs3_proc_create
Date: Wed, 21 Aug 2013 20:26:21 -0400
Message-ID: <1377131186-40249-1-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs3proc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index f5c84c3..1db588a 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -336,8 +336,8 @@ nfs3_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 	data->arg.create.createmode = NFS3_CREATE_UNCHECKED;
 	if (flags & O_EXCL) {
 		data->arg.create.createmode  = NFS3_CREATE_EXCLUSIVE;
-		data->arg.create.verifier[0] = jiffies;
-		data->arg.create.verifier[1] = current->pid;
+		data->arg.create.verifier[0] = cpu_to_be32(jiffies);
+		data->arg.create.verifier[1] = cpu_to_be32(current->pid);
 	}
 
 	sattr->ia_mode &= ~current_umask();
-- 
1.8.3.1

