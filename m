From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 09/69] NFS: Move declaration of nfs_mount() to
 fs/nfs/internal.h
Date: Tue, 23 Dec 2008 18:02:07 -0500
Message-ID: <20081223230207.13743.80834.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:44861 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752492AbYLWXXp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:23:45 -0500
Received: from sacrsexc2-prd.hq.netapp.com ([10.99.115.28])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNNaFh006177
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:23:41 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Clean up:  The nfs_mount() function is not to be used outside of the
NFS client.  Move its public declaration to fs/nfs/internal.h.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/internal.h      |    4 ++++
 fs/nfs/nfsroot.c       |    2 ++
 include/linux/nfs_fs.h |    6 ------
 3 files changed, 6 insertions(+), 6 deletions(-)


diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index d212ee4..7a38cc7 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -63,6 +63,10 @@ struct nfs_parsed_mount_data {
 	struct security_mnt_opts lsm_opts;
 };
 
+/* mount_clnt.c */
+extern int nfs_mount(struct sockaddr *, size_t, char *, char *,
+					int, int, struct nfs_fh *);
+
 /* client.c */
 extern struct rpc_program nfs_program;
 
diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
index f1c0a06..a96e5fd 100644
--- a/fs/nfs/nfsroot.c
+++ b/fs/nfs/nfsroot.c
@@ -86,6 +86,8 @@
 #include <net/ipconfig.h>
 #include <linux/parser.h>
 
+#include "internal.h"
+
 /* Define this to allow debugging output */
 #undef NFSROOT_DEBUG
 #define NFSDBG_FACILITY NFSDBG_ROOT
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 4eaa834..f110772 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -533,12 +533,6 @@ static inline void nfs3_forget_cached_acls(struct inode *inode)
 #endif /* CONFIG_NFS_V3_ACL */
 
 /*
- * linux/fs/mount_clnt.c
- */
-extern int  nfs_mount(struct sockaddr *, size_t, char *, char *,
-		      int, int, struct nfs_fh *);
-
-/*
  * inline functions
  */
 

