Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:25111 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753926Ab3JRTPk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Oct 2013 15:15:40 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: <Trond.Myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 1/5] NFSv4: make nfs_find_best_sec static
Date: Fri, 18 Oct 2013 15:15:15 -0400
Message-ID: <1382123719-25194-2-git-send-email-dros@netapp.com>
In-Reply-To: <1382123719-25194-1-git-send-email-dros@netapp.com>
References: <1382123719-25194-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's not used outside of nfs4namespace.c anymore.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/nfs4_fs.h       | 1 -
 fs/nfs/nfs4namespace.c | 2 +-
 2 files changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 28842ab..cffed27 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -213,7 +213,6 @@ int nfs_atomic_open(struct inode *, struct dentry *, struct file *,
 extern struct file_system_type nfs4_fs_type;
 
 /* nfs4namespace.c */
-rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *);
 struct rpc_clnt *nfs4_create_sec_client(struct rpc_clnt *, struct inode *, struct qstr *);
 struct vfsmount *nfs4_submount(struct nfs_server *, struct dentry *,
 			       struct nfs_fh *, struct nfs_fattr *);
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 2288cd3..62ed517 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -145,7 +145,7 @@ static size_t nfs_parse_server_name(char *string, size_t len,
  * is searched in the order returned from the server, per RFC 3530
  * recommendation.
  */
-rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *flavors)
+static rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *flavors)
 {
 	rpc_authflavor_t pseudoflavor;
 	struct nfs4_secinfo4 *secinfo;
-- 
1.7.12.4 (Apple Git-37)

