Return-Path: <SRS0=f+aV=XG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57C3AC49ED6
	for <linux-nfs@archiver.kernel.org>; Wed, 11 Sep 2019 16:18:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 37D4D20863
	for <linux-nfs@archiver.kernel.org>; Wed, 11 Sep 2019 16:18:03 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728995AbfIKQQX (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 11 Sep 2019 12:16:23 -0400
Received: from mx1.redhat.com ([209.132.183.28]:47258 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728959AbfIKQQX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 11 Sep 2019 12:16:23 -0400
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id AC104C057E9A;
        Wed, 11 Sep 2019 16:16:22 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-122-52.rdu2.redhat.com [10.10.122.52])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 7C9E060C18;
        Wed, 11 Sep 2019 16:16:22 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id 11DD420ACC; Wed, 11 Sep 2019 12:16:22 -0400 (EDT)
From:   Scott Mayhew <smayhew@redhat.com>
To:     anna.schumaker@netapp.com, trond.myklebust@hammerspace.com
Cc:     dhowells@redhat.com, viro@zeniv.linux.org.uk,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH v3 04/26] nfs: fold nfs4_remote_fs_type and nfs4_remote_referral_fs_type
Date:   Wed, 11 Sep 2019 12:15:59 -0400
Message-Id: <20190911161621.19832-5-smayhew@redhat.com>
In-Reply-To: <20190911161621.19832-1-smayhew@redhat.com>
References: <20190911161621.19832-1-smayhew@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Wed, 11 Sep 2019 16:16:22 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Al Viro <viro@zeniv.linux.org.uk>

They are identical now.

Reviewed-by: David Howells <dhowells@redhat.com>
Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 fs/nfs/nfs4super.c | 26 ++++----------------------
 1 file changed, 4 insertions(+), 22 deletions(-)

diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index 773c347df3ab..d0237d8ffa2b 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -22,8 +22,6 @@ static struct dentry *nfs4_remote_mount(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *raw_data);
 static struct dentry *nfs4_referral_mount(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *raw_data);
-static struct dentry *nfs4_remote_referral_mount(struct file_system_type *fs_type,
-	int flags, const char *dev_name, void *raw_data);
 
 static struct file_system_type nfs4_remote_fs_type = {
 	.owner		= THIS_MODULE,
@@ -33,14 +31,6 @@ static struct file_system_type nfs4_remote_fs_type = {
 	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_BINARY_MOUNTDATA,
 };
 
-static struct file_system_type nfs4_remote_referral_fs_type = {
-	.owner		= THIS_MODULE,
-	.name		= "nfs4",
-	.mount		= nfs4_remote_referral_mount,
-	.kill_sb	= nfs_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_BINARY_MOUNTDATA,
-};
-
 struct file_system_type nfs4_referral_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "nfs4",
@@ -111,8 +101,7 @@ nfs4_remote_mount(struct file_system_type *fs_type, int flags,
 	return nfs_fs_mount_common(flags, dev_name, info, &nfs_v4);
 }
 
-static struct vfsmount *nfs_do_root_mount(struct file_system_type *fs_type,
-					  struct nfs_server *server, int flags,
+static struct vfsmount *nfs_do_root_mount(struct nfs_server *server, int flags,
 					  struct nfs_mount_info *info,
 					  const char *hostname)
 {
@@ -135,7 +124,7 @@ static struct vfsmount *nfs_do_root_mount(struct file_system_type *fs_type,
 	else
 		snprintf(root_devname, len, "%s:/", hostname);
 	info->server = server;
-	root_mnt = vfs_kern_mount(fs_type, flags, root_devname, info);
+	root_mnt = vfs_kern_mount(&nfs4_remote_fs_type, flags, root_devname, info);
 	if (info->server)
 		nfs_free_server(info->server);
 	info->server = NULL;
@@ -245,7 +234,7 @@ struct dentry *nfs4_try_mount(int flags, const char *dev_name,
 
 	export_path = data->nfs_server.export_path;
 	data->nfs_server.export_path = "/";
-	root_mnt = nfs_do_root_mount(&nfs4_remote_fs_type,
+	root_mnt = nfs_do_root_mount(
 			nfs4_create_server(mount_info, &nfs_v4),
 			flags, mount_info,
 			data->nfs_server.hostname);
@@ -259,13 +248,6 @@ struct dentry *nfs4_try_mount(int flags, const char *dev_name,
 	return res;
 }
 
-static struct dentry *
-nfs4_remote_referral_mount(struct file_system_type *fs_type, int flags,
-			   const char *dev_name, void *raw_data)
-{
-	return nfs_fs_mount_common(flags, dev_name, raw_data, &nfs_v4);
-}
-
 /*
  * Create an NFS4 server record on referral traversal
  */
@@ -290,7 +272,7 @@ static struct dentry *nfs4_referral_mount(struct file_system_type *fs_type,
 
 	export_path = data->mnt_path;
 	data->mnt_path = "/";
-	root_mnt = nfs_do_root_mount(&nfs4_remote_referral_fs_type,
+	root_mnt = nfs_do_root_mount(
 			nfs4_create_referral_server(mount_info.cloned,
 						    mount_info.mntfh),
 			flags, &mount_info, data->hostname);
-- 
2.17.2

