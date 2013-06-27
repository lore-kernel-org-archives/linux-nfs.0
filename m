Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f50.google.com ([209.85.213.50]:46815 "EHLO
	mail-yh0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752806Ab3F0PuP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Jun 2013 11:50:15 -0400
Received: by mail-yh0-f50.google.com with SMTP id i72so493308yha.37
        for <linux-nfs@vger.kernel.org>; Thu, 27 Jun 2013 08:50:15 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, chuck.lever@oracle.com,
        Weston.Adamson@netapp.com
Subject: [PATCH v3 1/3] nfs: refactor "need_mount" code out of nfs_try_mount
Date: Thu, 27 Jun 2013 11:50:05 -0400
Message-Id: <1372348207-26388-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1372348207-26388-1-git-send-email-jlayton@redhat.com>
References: <1372348207-26388-1-git-send-email-jlayton@redhat.com>
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

