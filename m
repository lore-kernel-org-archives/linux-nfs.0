From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 1/2] vfs: force reval of dentries for LAST_BIND symlinks on open
Date: Tue, 10 Nov 2009 11:27:35 -0500
Message-ID: <1257870456-31188-2-git-send-email-jlayton@redhat.com>
References: <1257870456-31188-1-git-send-email-jlayton@redhat.com>
Cc: ebiederm@xmission.com, adobriyan@gmail.com,
	viro@ZenIV.linux.org.uk, jamie@shareable.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1257870456-31188-1-git-send-email-jlayton@redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

procfs-style symlinks return a last_type of LAST_BIND without an actual
path string. This causes __follow_link to skip calling __vfs_follow_link
and so the dentry isn't revalidated.

This is a problem when the link target sits on NFSv4 as it depends on
the VFS to revalidate the dentry before using it on an open call. Ensure
that this occurs by forcing a revalidation of the target dentry of
LAST_BIND symlinks.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c |   41 +++++++++++++++++++++++++++++++++++++++++
 1 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 3374917..5c8ef80 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -414,6 +414,45 @@ do_revalidate(struct dentry *dentry, struct nameidata *nd)
 }
 
 /*
+ * open_reval_path - force revalidation of a dentry for file opens
+ *
+ * in some situations the path walking code will trust dentries without
+ * revalidating them. This causes problems for filesystems that depend on
+ * d_revalidate to handle the actual file open (e.g. NFSv4). When LOOKUP_OPEN
+ * is set, force a revalidation if the dentry appears to be valid and a
+ * d_revalidate routine exists.
+ *
+ * Returns 0 if the revalidation was successful. If the revalidation fails,
+ * either return the error returned by d_revalidate or -ESTALE if the
+ * revalidation indicates an invalid dentry. On error, references to the dentry
+ * and vfsmount in the path are put.
+ */
+static int
+open_reval_path(struct path *path, struct nameidata *nd)
+{
+	struct dentry *dentry = path->dentry;
+
+	/* only bother with this for opens */
+	if (!(nd->flags & LOOKUP_OPEN))
+		return 0;
+
+	/* no reval routine, just return */
+	if (!dentry->d_op || !dentry->d_op->d_revalidate)
+		return 0;
+
+	dentry = do_revalidate(dentry, nd);
+	if (dentry && !IS_ERR(dentry))
+		return 0;
+
+	mntput(path->mnt);
+
+	if (!dentry)
+		return -ESTALE;
+
+	return PTR_ERR(dentry);
+}
+
+/*
  * Internal lookup() using the new generic dcache.
  * SMP-safe
  */
@@ -641,6 +680,8 @@ static __always_inline int __do_follow_link(struct path *path, struct nameidata
 		error = 0;
 		if (s)
 			error = __vfs_follow_link(nd, s);
+		else if (nd->last_type == LAST_BIND)
+			error = open_reval_path(&nd->path, nd);
 		if (dentry->d_inode->i_op->put_link)
 			dentry->d_inode->i_op->put_link(dentry, nd, cookie);
 	}
-- 
1.5.5.6

