Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:54879 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753731Ab3FENwE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Jun 2013 09:52:04 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r55Dq3jd032306
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 5 Jun 2013 09:52:03 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: jlayton@redhat.com
Subject: [PATCH RFC 2/2] NFS: Make nfs_readdir revalidate less often
Date: Wed,  5 Jun 2013 09:52:01 -0400
Message-Id: <1370440321-56488-3-git-send-email-smayhew@redhat.com>
In-Reply-To: <1370440321-56488-1-git-send-email-smayhew@redhat.com>
References: <1370440321-56488-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make nfs_readdir revalidate only when we're at the beginning of the directory or
if the cached attributes have expired.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 fs/nfs/dir.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index f23f455..8b83fa9 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -807,7 +807,7 @@ static int nfs_readdir(struct file *filp, void *dirent, filldir_t filldir)
 	nfs_readdir_descriptor_t my_desc,
 			*desc = &my_desc;
 	struct nfs_open_dir_context *dir_ctx = filp->private_data;
-	int res;
+	int res = 0;
 
 	dfprintk(FILE, "NFS: readdir(%s/%s) starting at cookie %llu\n",
 			dentry->d_parent->d_name.name, dentry->d_name.name,
@@ -828,7 +828,8 @@ static int nfs_readdir(struct file *filp, void *dirent, filldir_t filldir)
 	desc->plus = nfs_use_readdirplus(inode, filp) ? 1 : 0;
 
 	nfs_block_sillyrename(dentry);
-	res = nfs_revalidate_mapping(inode, filp->f_mapping);
+	if (filp->f_pos == 0 || nfs_attribute_cache_expired(inode))
+		res = nfs_revalidate_mapping(inode, filp->f_mapping);
 	if (res < 0)
 		goto out;
 
-- 
1.7.11.7

