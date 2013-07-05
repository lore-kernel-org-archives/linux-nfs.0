Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:33618 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751019Ab3GEVtd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Jul 2013 17:49:33 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r65LnX8R020023
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 5 Jul 2013 17:49:33 -0400
Received: from tonberry.usersys.redhat.com (dhcp145-64.rdu.redhat.com [10.13.145.64])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r65LnW8M029832
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Fri, 5 Jul 2013 17:49:33 -0400
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.5/8.14.5) with ESMTP id r65LnWgX012303
	for <linux-nfs@vger.kernel.org>; Fri, 5 Jul 2013 17:49:32 -0400
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.5/8.14.5/Submit) id r65LnWtN012302
	for linux-nfs@vger.kernel.org; Fri, 5 Jul 2013 17:49:32 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFS: Make nfs_readdir revalidate less often
Date: Fri,  5 Jul 2013 17:49:31 -0400
Message-Id: <1373060971-12260-3-git-send-email-smayhew@redhat.com>
In-Reply-To: <1373060971-12260-1-git-send-email-smayhew@redhat.com>
References: <1373060971-12260-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make nfs_readdir revalidate only when we're at the beginning of the directory or
if the cached attributes have expired.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 fs/nfs/dir.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index d7ed697..e57703c 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -806,7 +806,7 @@ static int nfs_readdir(struct file *file, struct dir_context *ctx)
 	nfs_readdir_descriptor_t my_desc,
 			*desc = &my_desc;
 	struct nfs_open_dir_context *dir_ctx = file->private_data;
-	int res;
+	int res = 0;
 
 	dfprintk(FILE, "NFS: readdir(%s/%s) starting at cookie %llu\n",
 			dentry->d_parent->d_name.name, dentry->d_name.name,
@@ -828,7 +828,8 @@ static int nfs_readdir(struct file *file, struct dir_context *ctx)
 	desc->plus = nfs_use_readdirplus(inode, ctx) ? 1 : 0;
 
 	nfs_block_sillyrename(dentry);
-	res = nfs_revalidate_mapping(inode, file->f_mapping);
+	if (ctx->pos == 0 || nfs_attribute_cache_expired(inode))
+		res = nfs_revalidate_mapping(inode, file->f_mapping);
 	if (res < 0)
 		goto out;
 
-- 
1.7.11.7

