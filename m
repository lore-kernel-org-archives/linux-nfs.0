Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:15345 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753190Ab3H0U7B (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Aug 2013 16:59:01 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
CC: <andros@netapp.com>
Subject: [PATCH 08/15] NFSv4: Fix a potentially Oopsable condition in __nfs_idmap_unregister
Date: Tue, 27 Aug 2013 16:58:45 -0400
Message-ID: <1377637132-53318-8-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1377637132-53318-7-git-send-email-Trond.Myklebust@netapp.com>
References: <1377637132-53318-1-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-2-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-3-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-4-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-5-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-6-git-send-email-Trond.Myklebust@netapp.com>
 <1377637132-53318-7-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that __nfs_idmap_unregister can be called twice without
consequences.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/idmap.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index e9b0c59..8b7e94a 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -404,8 +404,10 @@ static struct key_type key_type_id_resolver_legacy = {
 
 static void __nfs_idmap_unregister(struct rpc_pipe *pipe)
 {
-	if (pipe->dentry)
+	if (pipe->dentry) {
 		rpc_unlink(pipe->dentry);
+		pipe->dentry = NULL;
+	}
 }
 
 static int __nfs_idmap_register(struct dentry *dir,
-- 
1.8.3.1

