From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH attempt=3 5/5] NFS: Correct the NFS mount path when
 following a referral
Date: Sat, 20 Jun 2009 15:33:45 -0400
Message-ID: <20090620193345.14142.10415.stgit@heimdal.trondhjem.org>
References: <20090620193344.14142.22774.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20090620193344.14142.22774.stgit@heimdal.trondhjem.org>
Sender: linux-fsdevel-owner@vger.kernel.org
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

