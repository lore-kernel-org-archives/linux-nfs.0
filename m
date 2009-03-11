From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 4/4] NFS: Correct the NFS mount path when following a
 referral
Date: Wed, 11 Mar 2009 15:50:46 -0400
Message-ID: <864a633c69dde0b4c1da42b65fe5b5563b5d4d02.1238525532.git.Trond.Myklebust@netapp.com>
References: <cover.1238525532.git.Trond.Myklebust@netapp.com>
Mime-Version: 1.0
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk,
	hch@infradead.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:25082 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756701AbZCaVKb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Mar 2009 17:10:31 -0400
In-Reply-To: <cover.1238525532.git.Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/super.c |   24 ++++++++++++++++++++++++
 1 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 1da36bf..f0f88a5 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2496,6 +2496,27 @@ static struct vfsmount *nfs_do_root_mount(struct file_system_type *fs_type,
 	return root_mnt;
 }
 
+static void nfs_fix_devname(const struct path *path, struct vfsmount *mnt)
+{
+	char *page = (char *) __get_free_page(GFP_KERNEL);
+	char *devname, *tmp;
+
+	if (page == NULL)
+		return;
+	devname = nfs_path(path->mnt->mnt_devname,
+			path->mnt->mnt_root, path->dentry,
+			page, PAGE_SIZE);
+	if (devname == NULL)
+		goto out_freepage;
+	tmp = kstrdup(devname, GFP_KERNEL);
+	if (tmp == NULL)
+		goto out_freepage;
+	kfree(mnt->mnt_devname);
+	mnt->mnt_devname = tmp;
+out_freepage:
+	free_page((unsigned long)page);
+}
+
 static int nfs_follow_remote_path(struct vfsmount *root_mnt,
 		const char *export_path, struct vfsmount *mnt_target)
 {
@@ -2513,6 +2534,9 @@ static int nfs_follow_remote_path(struct vfsmount *root_mnt,
 	mnt_target->mnt_sb = s;
 	mnt_target->mnt_root = dget(nd.path.dentry);
 
+	/* Correct the device pathname */
+	nfs_fix_devname(&nd.path, mnt_target);
+
 	path_put(&nd.path);
 	mntput(root_mnt);
 	down_write(&s->s_umount);
-- 
1.6.0.4
