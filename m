From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] proc: revalidate dentry returned by proc_pid_follow_link
Date: Fri,  6 Nov 2009 08:19:54 -0500
Message-ID: <1257513594-31071-1-git-send-email-jlayton@redhat.com>
Cc: adobriyan@gmail.com, viro@ZenIV.linux.org.uk
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33089 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752423AbZKFNTv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 Nov 2009 08:19:51 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The procfs follow_link operation doesn't provide an actual pathname
string.  Instead, it returns a struct path in the nameidata and sets the
last_type field in the nameidata to LAST_BIND. This makes the open path
walking routine (do_filp_open) skip doing a lookup against the path
string and has it just trust the info in the struct path.

The problem here is that this makes that code shortcut any lookup or
revalidation of the dentry. In general, this isn't a problem -- in most
cases the dentry is known to be good. It is a problem however for NFSv4.
If this symlink is followed on an open operation no actual open call
occurs and the open state isn't properly established. This causes
problems when we later try to use this file descriptor for actual
operations.

This patch takes a minimalist approach to fixing this by making the
/proc/pid follow_link routine revalidate the dentry before returning it.
It seems to fix the reproducer I have for this, but I wonder whether it
might be better to do this at a higher level, maybe in __do_follow_link
in case there are other filesystems in the future that return a
last_type of LAST_BIND. Also, should this dentry be d_invalidated if
it d_revalidate returns 0?

Comments welcome.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/proc/base.c |   14 +++++++++++++-
 1 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 837469a..1bd994c 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -1343,7 +1343,7 @@ static int proc_exe_link(struct inode *inode, struct path *exe_path)
 static void *proc_pid_follow_link(struct dentry *dentry, struct nameidata *nd)
 {
 	struct inode *inode = dentry->d_inode;
-	int error = -EACCES;
+	int valid = 1, error = -EACCES;
 
 	/* We don't need a base pointer in the /proc filesystem */
 	path_put(&nd->path);
@@ -1354,6 +1354,18 @@ static void *proc_pid_follow_link(struct dentry *dentry, struct nameidata *nd)
 
 	error = PROC_I(inode)->op.proc_get_link(inode, &nd->path);
 	nd->last_type = LAST_BIND;
+
+	if (error)
+		goto out;
+
+	dentry = nd->path.dentry;
+	if (dentry->d_op && dentry->d_op->d_revalidate)
+		valid = dentry->d_op->d_revalidate(dentry, nd);
+
+	if (valid <= 0) {
+		path_put(&nd->path);
+		error = -ESTALE;
+	}
 out:
 	return ERR_PTR(error);
 }
-- 
1.5.5.6

