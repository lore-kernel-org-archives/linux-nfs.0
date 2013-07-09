Return-Path: linux-nfs-owner@vger.kernel.org
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:11483 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752442Ab3GIBRu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Jul 2013 21:17:50 -0400
From: Waiman Long <Waiman.Long@hp.com>
Cc: Waiman Long <Waiman.Long@hp.com>, linux-fsdevel@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Peter Zijlstra <peterz@infradead.org>,
        Steven Rostedt <rostedt@goodmis.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Andi Kleen <andi@firstfloor.org>,
        "Chandramouleeswaran, Aswin" <aswin@hp.com>,
        "Norton, Scott J" <scott.norton@hp.com>
Subject: [PATCH v6 10/14] nfs: replace direct access of d_count with the d_count() helper
Date: Mon,  8 Jul 2013 21:10:00 -0400
Message-Id: <1373332204-10379-11-git-send-email-Waiman.Long@hp.com>
In-Reply-To: <1373332204-10379-1-git-send-email-Waiman.Long@hp.com>
References: <1373332204-10379-1-git-send-email-Waiman.Long@hp.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Jeff Layton <jlayton@redhat.com>,
        Miklos Szeredi <mszeredi@suse.cz>, Ingo Molnar <mingo@redhat.com>,
        Thomas Gleixner <tglx@linutronix.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

All readonly references to d_count outside of the core dcache code
should be changed to use the new d_count() helper as they shouldn't
access its value directly.  There is no change in logic and everything
should just work.

Signed-off-by: Waiman Long <Waiman.Long@hp.com>
---
 fs/nfs/dir.c    |    6 +++---
 fs/nfs/unlink.c |    2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index d7ed697..c933bdf 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1721,7 +1721,7 @@ int nfs_unlink(struct inode *dir, struct dentry *dentry)
 		dir->i_ino, dentry->d_name.name);
 
 	spin_lock(&dentry->d_lock);
-	if (dentry->d_count > 1) {
+	if (d_count(dentry) > 1) {
 		spin_unlock(&dentry->d_lock);
 		/* Start asynchronous writeout of the inode */
 		write_inode_now(dentry->d_inode, 0);
@@ -1866,7 +1866,7 @@ int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 	dfprintk(VFS, "NFS: rename(%s/%s -> %s/%s, ct=%d)\n",
 		 old_dentry->d_parent->d_name.name, old_dentry->d_name.name,
 		 new_dentry->d_parent->d_name.name, new_dentry->d_name.name,
-		 new_dentry->d_count);
+		 d_count(new_dentry));
 
 	/*
 	 * For non-directories, check whether the target is busy and if so,
@@ -1884,7 +1884,7 @@ int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 			rehash = new_dentry;
 		}
 
-		if (new_dentry->d_count > 2) {
+		if (d_count(new_dentry) > 2) {
 			int err;
 
 			/* copy the target dentry's name */
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 1f1f38f..60395ad 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -479,7 +479,7 @@ nfs_sillyrename(struct inode *dir, struct dentry *dentry)
 
 	dfprintk(VFS, "NFS: silly-rename(%s/%s, ct=%d)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name,
-		dentry->d_count);
+		d_count(dentry));
 	nfs_inc_stats(dir, NFSIOS_SILLYRENAME);
 
 	/*
-- 
1.7.1

