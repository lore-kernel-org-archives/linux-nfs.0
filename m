From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] NFS: missing nfs_fattr_init in nfs3_proc_getacl and nfs3_proc_setacls (resend #2)
Date: Mon, 18 Aug 2008 09:17:58 -0400
Message-ID: <1219065478-28215-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:50854 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752007AbYHRNSC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Aug 2008 09:18:02 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The fattrs used in the NFSv3 getacl/setacl calls are not being properly
initialized. This occasionally causes nfs_update_inode to fall into
NFSv4 specific codepaths when handling post-op attrs from these calls.

Thanks to Cai Qian for noticing the spurious NFSv4 messages in debug
output from a v3 mount...

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/nfs3acl.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs3acl.c b/fs/nfs/nfs3acl.c
index 423842f..cef6255 100644
--- a/fs/nfs/nfs3acl.c
+++ b/fs/nfs/nfs3acl.c
@@ -229,6 +229,7 @@ struct posix_acl *nfs3_proc_getacl(struct inode *inode, int type)
 
 	dprintk("NFS call getacl\n");
 	msg.rpc_proc = &server->client_acl->cl_procinfo[ACLPROC3_GETACL];
+	nfs_fattr_init(&fattr);
 	status = rpc_call_sync(server->client_acl, &msg, 0);
 	dprintk("NFS reply getacl: %d\n", status);
 
@@ -322,6 +323,7 @@ static int nfs3_proc_setacls(struct inode *inode, struct posix_acl *acl,
 
 	dprintk("NFS call setacl\n");
 	msg.rpc_proc = &server->client_acl->cl_procinfo[ACLPROC3_SETACL];
+	nfs_fattr_init(&fattr);
 	status = rpc_call_sync(server->client_acl, &msg, 0);
 	nfs_access_zap_cache(inode);
 	nfs_zap_acl_cache(inode);
-- 
1.5.5.1

