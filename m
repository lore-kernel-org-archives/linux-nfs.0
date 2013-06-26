Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f44.google.com ([209.85.219.44]:35090 "EHLO
	mail-oa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752349Ab3FZTpn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Jun 2013 15:45:43 -0400
Received: by mail-oa0-f44.google.com with SMTP id l10so15494397oag.3
        for <linux-nfs@vger.kernel.org>; Wed, 26 Jun 2013 12:45:42 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, chuck.lever@oracle.com
Subject: [PATCH v2 1/3] nfs: refactor "need_mount" code out of nfs_try_mount
Date: Wed, 26 Jun 2013 15:45:34 -0400
Message-Id: <1372275936-5360-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1372275936-5360-1-git-send-email-jlayton@redhat.com>
References: <1372275936-5360-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This looks like pointless refactoring for now, but we'll flesh out
the need_mount case a little more in a later patch.

Cc: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/super.c | 24 ++++++++++++++++--------
 1 file changed, 16 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 2d7525f..afeee81 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1759,21 +1759,29 @@ static int nfs_request_mount(struct nfs_parsed_mount_data *args,
 	return nfs_select_flavor(args, &request);
 }
 
+static struct nfs_server *nfs_try_mount_request(struct nfs_mount_info *mount_info,
+					struct nfs_subversion *nfs_mod)
+{
+	int status;
+
+	status = nfs_request_mount(mount_info->parsed, mount_info->mntfh);
+	if (status)
+		return ERR_PTR(status);
+
+	return nfs_mod->rpc_ops->create_server(mount_info, nfs_mod);
+}
+
 struct dentry *nfs_try_mount(int flags, const char *dev_name,
 			     struct nfs_mount_info *mount_info,
 			     struct nfs_subversion *nfs_mod)
 {
-	int status;
 	struct nfs_server *server;
 
-	if (mount_info->parsed->need_mount) {
-		status = nfs_request_mount(mount_info->parsed, mount_info->mntfh);
-		if (status)
-			return ERR_PTR(status);
-	}
+	if (mount_info->parsed->need_mount)
+		server = nfs_try_mount_request(mount_info, nfs_mod);
+	else
+		server = nfs_mod->rpc_ops->create_server(mount_info, nfs_mod);
 
-	/* Get a volume representation */
-	server = nfs_mod->rpc_ops->create_server(mount_info, nfs_mod);
 	if (IS_ERR(server))
 		return ERR_CAST(server);
 
-- 
1.8.1.4

