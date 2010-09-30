Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24788 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755737Ab0I3SQs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Sep 2010 14:16:48 -0400
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 16/17] autofs4 - add v4 pseudo direct mount support
To: viro@ftp.linux.org.uk, jmoyer@redhat.com
Cc: linux-fs@vger.kernel.org, autofs@linux.kernel.org,
        linux-kernel@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        Ian Kent <raven@themaw.net>, David Howells <dhowells@redhat.com>
Date: Thu, 30 Sep 2010 19:16:17 +0100
Message-ID: <20100930181617.30939.37248.stgit@warthog.procyon.org.uk>
In-Reply-To: <20100930181455.30939.53914.stgit@warthog.procyon.org.uk>
References: <20100930181455.30939.53914.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Ian Kent <raven@themaw.net>

Version 4 of autofs provides a pseudo direct mount implementation
that relies on directories at the leaves of a directory tree under
an indirect mount to trigger mounts.

This patch adds support for that functionality.

Signed-off-by: Ian Kent <raven@themaw.net>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/autofs4/root.c |   60 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 60 insertions(+), 0 deletions(-)

diff --git a/fs/autofs4/root.c b/fs/autofs4/root.c
index 3b38794..135d713 100644
--- a/fs/autofs4/root.c
+++ b/fs/autofs4/root.c
@@ -629,6 +629,60 @@ static int autofs4_dir_unlink(struct inode *dir, struct dentry *dentry)
 	return 0;
 }
 
+/*
+ * Version 4 of autofs provides a pseudo direct mount implementation
+ * that relies on directories at the leaves of a directory tree under
+ * an indirect mount to trigger mounts. To allow for this we need to
+ * set the DMANAGED_AUTOMOUNT and DMANAGED_TRANSIT flags on the leaves
+ * of the directory tree. There is no need to clear the automount flag
+ * following a mount or restore it after an expire because these mounts
+ * are always covered. However, it is neccessary to ensure that these
+ * flags are clear on non-empty directories to avoid unnecessary calls
+ * during path walks.
+ */
+static void autofs_set_leaf_automount_flags(struct dentry *dentry)
+{
+	struct dentry *parent;
+
+	/* root and dentrys in the root are already handled */
+	if (IS_ROOT(dentry->d_parent))
+		return;
+
+	managed_dentry_set_managed(dentry);
+
+	parent = dentry->d_parent;
+	/* only consider parents below dentrys in the root */
+	if (IS_ROOT(parent->d_parent))
+		return;
+	managed_dentry_clear_managed(parent);
+	return;
+}
+
+static void autofs_clear_leaf_automount_flags(struct dentry *dentry)
+{
+	struct list_head *d_child;
+	struct dentry *parent;
+
+	/* flags for dentrys in the root are handled elsewhere */
+	if (IS_ROOT(dentry->d_parent))
+		return;
+
+	managed_dentry_clear_managed(dentry);
+
+	parent = dentry->d_parent;
+	/* only consider parents below dentrys in the root */
+	if (IS_ROOT(parent->d_parent))
+		return;
+	d_child = &dentry->d_u.d_child;
+	spin_lock(&dcache_lock);
+	/* Set parent managed if it's becoming empty */
+	if (d_child->next == &parent->d_subdirs &&
+	    d_child->prev == &parent->d_subdirs)
+		managed_dentry_set_managed(parent);
+	spin_unlock(&dcache_lock);
+	return;
+}
+
 static int autofs4_dir_rmdir(struct inode *dir, struct dentry *dentry)
 {
 	struct autofs_sb_info *sbi = autofs4_sbi(dir->i_sb);
@@ -652,6 +706,9 @@ static int autofs4_dir_rmdir(struct inode *dir, struct dentry *dentry)
 	spin_unlock(&dentry->d_lock);
 	spin_unlock(&dcache_lock);
 
+	if (sbi->version < 5)
+		autofs_clear_leaf_automount_flags(dentry);
+
 	if (atomic_dec_and_test(&ino->count)) {
 		p_ino = autofs4_dentry_ino(dentry->d_parent);
 		if (p_ino && dentry->d_parent != dentry)
@@ -694,6 +751,9 @@ static int autofs4_dir_mkdir(struct inode *dir, struct dentry *dentry, int mode)
 	}
 	d_add(dentry, inode);
 
+	if (sbi->version < 5)
+		autofs_set_leaf_automount_flags(dentry);
+
 	dentry->d_fsdata = ino;
 	ino->dentry = dget(dentry);
 	atomic_inc(&ino->count);

