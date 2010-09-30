Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7868 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755546Ab0I3SQl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Sep 2010 14:16:41 -0400
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 14/17] autofs4: cleanup autofs4_free_ino()
To: viro@ftp.linux.org.uk, jmoyer@redhat.com
Cc: linux-fs@vger.kernel.org, autofs@linux.kernel.org,
        linux-kernel@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        Ian Kent <raven@themaw.net>, David Howells <dhowells@redhat.com>
Date: Thu, 30 Sep 2010 19:16:07 +0100
Message-ID: <20100930181607.30939.4558.stgit@warthog.procyon.org.uk>
In-Reply-To: <20100930181455.30939.53914.stgit@warthog.procyon.org.uk>
References: <20100930181455.30939.53914.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Ian Kent <raven@themaw.net>

When this function is called the local reference count does't need to
be updated since the dentry is going away and dput definitely must
not be called here.

Also the autofs info struct field inode isn't used so remove it.

Signed-off-by: Ian Kent <raven@themaw.net>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/autofs4/inode.c |   13 -------------
 fs/autofs4/root.c  |    9 ---------
 2 files changed, 0 insertions(+), 22 deletions(-)

diff --git a/fs/autofs4/inode.c b/fs/autofs4/inode.c
index 8eaa723..ebc6354 100644
--- a/fs/autofs4/inode.c
+++ b/fs/autofs4/inode.c
@@ -45,7 +45,6 @@ struct autofs_info *autofs4_init_ino(struct autofs_info *ino,
 
 	if (!reinit) {
 		ino->flags = 0;
-		ino->inode = NULL;
 		ino->dentry = NULL;
 		ino->size = 0;
 		INIT_LIST_HEAD(&ino->active);
@@ -76,19 +75,8 @@ struct autofs_info *autofs4_init_ino(struct autofs_info *ino,
 
 void autofs4_free_ino(struct autofs_info *ino)
 {
-	struct autofs_info *p_ino;
-
 	if (ino->dentry) {
 		ino->dentry->d_fsdata = NULL;
-		if (ino->dentry->d_inode) {
-			struct dentry *parent = ino->dentry->d_parent;
-			if (atomic_dec_and_test(&ino->count)) {
-				p_ino = autofs4_dentry_ino(parent);
-				if (p_ino && parent != ino->dentry)
-					atomic_dec(&p_ino->count);
-			}
-			dput(ino->dentry);
-		}
 		ino->dentry = NULL;
 	}
 	if (ino->free)
@@ -390,7 +378,6 @@ struct inode *autofs4_get_inode(struct super_block *sb,
 	if (inode == NULL)
 		return NULL;
 
-	inf->inode = inode;
 	inode->i_mode = inf->mode;
 	if (sb->s_root) {
 		inode->i_uid = sb->s_root->d_inode->i_uid;
diff --git a/fs/autofs4/root.c b/fs/autofs4/root.c
index cb168ba..3b38794 100644
--- a/fs/autofs4/root.c
+++ b/fs/autofs4/root.c
@@ -144,11 +144,8 @@ void autofs4_dentry_release(struct dentry *de)
 	DPRINTK("releasing %p", de);
 
 	inf = autofs4_dentry_ino(de);
-	de->d_fsdata = NULL;
-
 	if (inf) {
 		struct autofs_sb_info *sbi = autofs4_sbi(de->d_sb);
-
 		if (sbi) {
 			spin_lock(&sbi->lookup_lock);
 			if (!list_empty(&inf->active))
@@ -157,10 +154,6 @@ void autofs4_dentry_release(struct dentry *de)
 				list_del(&inf->expiring);
 			spin_unlock(&sbi->lookup_lock);
 		}
-
-		inf->dentry = NULL;
-		inf->inode = NULL;
-
 		autofs4_free_ino(inf);
 	}
 }
@@ -582,7 +575,6 @@ static int autofs4_dir_symlink(struct inode *dir,
 	p_ino = autofs4_dentry_ino(dentry->d_parent);
 	if (p_ino && dentry->d_parent != dentry)
 		atomic_inc(&p_ino->count);
-	ino->inode = inode;
 
 	ino->u.symlink = cp;
 	dir->i_mtime = CURRENT_TIME;
@@ -708,7 +700,6 @@ static int autofs4_dir_mkdir(struct inode *dir, struct dentry *dentry, int mode)
 	p_ino = autofs4_dentry_ino(dentry->d_parent);
 	if (p_ino && dentry->d_parent != dentry)
 		atomic_inc(&p_ino->count);
-	ino->inode = inode;
 	inc_nlink(dir);
 	dir->i_mtime = CURRENT_TIME;
 

