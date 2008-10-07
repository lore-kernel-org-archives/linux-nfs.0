From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 18/30] NFS: missing nfs_fattr_init in nfs3_proc_getacl and
	nfs3_proc_setacls (resend #2)
Date: Tue, 07 Oct 2008 18:19:53 -0400
Message-ID: <20081007221953.20945.55695.stgit@localhost.localdomain>
References: <20081007221952.20945.69529.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4712 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756098AbYJGWcs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Oct 2008 18:32:48 -0400
In-Reply-To: <20081007221952.20945.69529.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@redhat.com>

The fattrs used in the NFSv3 getacl/setacl calls are not being properly
initialized. This occasionally causes nfs_update_inode to fall into
NFSv4 specific codepaths when handling post-op attrs from these calls.

Thanks to Cai Qian for noticing the spurious NFSv4 messages in debug
output from a v3 mount...

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
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

