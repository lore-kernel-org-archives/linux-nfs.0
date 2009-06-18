From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 4/4] NFS: Correct the NFS mount path when following a
 referral
Date: Thu, 18 Jun 2009 12:25:01 -0700
Message-ID: <20090618192501.19433.58138.stgit@heimdal.trondhjem.org>
References: <20090618192500.19433.16770.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35431 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753610AbZFRTev (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Jun 2009 15:34:51 -0400
In-Reply-To: <20090618192500.19433.16770.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/super.c |   24 ++++++++++++++++++++++++
 1 files changed, 24 insertions(+), 0 deletions(-)


diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 8da7e59..daecbad 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2548,6 +2548,27 @@ static struct vfsmount *nfs_do_root_mount(struct file_system_type *fs_type,
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
@@ -2574,6 +2595,9 @@ static int nfs_follow_remote_path(struct vfsmount *root_mnt,
 	mnt_target->mnt_sb = s;
 	mnt_target->mnt_root = dget(nd.path.dentry);
 
+	/* Correct the device pathname */
+	nfs_fix_devname(&nd.path, mnt_target);
+
 	path_put(&nd.path);
 	down_write(&s->s_umount);
 	return 0;

