Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:52573 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750846Ab3IGXSh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 7 Sep 2013 19:18:37 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH 6/6] NFS: nfs_compare_super shouldn't check the auth flavour unless 'sec=' was set
Date: Sat, 7 Sep 2013 19:18:13 -0400
Message-ID: <1378595893-60395-7-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1378595893-60395-6-git-send-email-Trond.Myklebust@netapp.com>
References: <1378595893-60395-1-git-send-email-Trond.Myklebust@netapp.com>
 <1378595893-60395-2-git-send-email-Trond.Myklebust@netapp.com>
 <1378595893-60395-3-git-send-email-Trond.Myklebust@netapp.com>
 <1378595893-60395-4-git-send-email-Trond.Myklebust@netapp.com>
 <1378595893-60395-5-git-send-email-Trond.Myklebust@netapp.com>
 <1378595893-60395-6-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Also don't worry about obsolete mount flags...

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/super.c | 17 +++++++++++++++--
 1 file changed, 15 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index b2dd6da..50bc31d 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2295,6 +2295,18 @@ void nfs_clone_super(struct super_block *sb, struct nfs_mount_info *mount_info)
  	nfs_initialise_sb(sb);
 }
 
+#define NFS_MOUNT_CMP_FLAGMASK ~(NFS_MOUNT_INTR \
+		| NFS_MOUNT_SECURE \
+		| NFS_MOUNT_TCP \
+		| NFS_MOUNT_VER3 \
+		| NFS_MOUNT_KERBEROS \
+		| NFS_MOUNT_NONLM \
+		| NFS_MOUNT_BROKEN_SUID \
+		| NFS_MOUNT_STRICTLOCK \
+		| NFS_MOUNT_UNSHARED \
+		| NFS_MOUNT_NORESVPORT \
+		| NFS_MOUNT_LEGACY_INTERFACE)
+
 static int nfs_compare_mount_options(const struct super_block *s, const struct nfs_server *b, int flags)
 {
 	const struct nfs_server *a = s->s_fs_info;
@@ -2305,7 +2317,7 @@ static int nfs_compare_mount_options(const struct super_block *s, const struct n
 		goto Ebusy;
 	if (a->nfs_client != b->nfs_client)
 		goto Ebusy;
-	if (a->flags != b->flags)
+	if ((a->flags ^ b->flags) & NFS_MOUNT_CMP_FLAGMASK)
 		goto Ebusy;
 	if (a->wsize != b->wsize)
 		goto Ebusy;
@@ -2319,7 +2331,8 @@ static int nfs_compare_mount_options(const struct super_block *s, const struct n
 		goto Ebusy;
 	if (a->acdirmax != b->acdirmax)
 		goto Ebusy;
-	if (clnt_a->cl_auth->au_flavor != clnt_b->cl_auth->au_flavor)
+	if (b->flags & NFS_MOUNT_SECFLAVOUR &&
+	   clnt_a->cl_auth->au_flavor != clnt_b->cl_auth->au_flavor)
 		goto Ebusy;
 	return 1;
 Ebusy:
-- 
1.8.3.1

