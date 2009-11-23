From: Alexandros Batsakis <batsakis@netapp.com>
Subject: [PATCH 02/10] nfs41: add support for callback with RPC version number 4
Date: Mon, 23 Nov 2009 13:54:39 -0800
Message-ID: <1259013287-3349-2-git-send-email-batsakis@netapp.com>
References: <1259013287-3349-1-git-send-email-batsakis@netapp.com>
Cc: Alexandros Batsakis <batsakis@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:42997 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757242AbZKWV7Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Nov 2009 16:59:24 -0500
In-Reply-To: <1259013287-3349-1-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The NFSv4.1 spec-29 (18.36.3) says that the server MUST use an ONC RPC
(program) version number equal to 4 in callbacks sent to the client.
For now we allow both versions 1 and 4.

Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
---
 fs/nfs/callback.c     |    1 +
 fs/nfs/callback_xdr.c |    7 +++++++
 fs/nfs/internal.h     |    1 +
 fs/nfs/nfs4_fs.h      |    1 +
 4 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 293fa05..71d9766 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -397,6 +397,7 @@ static int nfs_callback_authenticate(struct svc_rqst *rqstp)
  */
 static struct svc_version *nfs4_callback_version[] = {
 	[1] = &nfs4_callback_version1,
+	[4] = &nfs4_callback_version4,
 };
 
 static struct svc_stat nfs4_callback_stats;
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 76b0aa0..0fda5e6 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -718,3 +718,10 @@ struct svc_version nfs4_callback_version1 = {
 	.vs_dispatch = NULL,
 };
 
+struct svc_version nfs4_callback_version4 = {
+	.vs_vers = 4,
+	.vs_nproc = ARRAY_SIZE(nfs4_callback_procedures1),
+	.vs_proc = nfs4_callback_procedures1,
+	.vs_xdrsize = NFS4_CALLBACK_XDRSIZE,
+	.vs_dispatch = NULL,
+};
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index d946936..4664dc5 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -156,6 +156,7 @@ struct vfsmount *nfs_do_refmount(const struct vfsmount *mnt_parent, struct dentr
 
 /* callback_xdr.c */
 extern struct svc_version nfs4_callback_version1;
+extern struct svc_version nfs4_callback_version4;
 
 /* pagelist.c */
 extern int __init nfs_init_nfspagecache(void);
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 6ea07a3..df1299e 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -287,6 +287,7 @@ struct nfs4_mount_data;
 
 /* callback_xdr.c */
 extern struct svc_version nfs4_callback_version1;
+extern struct svc_version nfs4_callback_version4;
 
 #else
 
-- 
1.6.2.5

