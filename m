From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [RFC:PATCH] How best to handle implicit clearing of
 setuid/setgid bits on NFS?
Date: Wed, 27 Jun 2007 22:13:54 -0400
Message-ID: <20070627221354.02233c58.jlayton@redhat.com>
References: <20070529124705.a1e70735.jlayton@redhat.com>
	<1182982555.5311.67.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-fsdevel@vger.kernel.org, aviro@redhat.com
To: nfs@lists.sourceforge.net
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1182982555.5311.67.camel@heimdal.trondhjem.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Wed, 27 Jun 2007 18:15:55 -0400
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> On Tue, 2007-05-29 at 12:47 -0400, Jeff Layton wrote:
> > I've been looking at issue of clearing setuid/setgid bits when a file
> > is written to on NFS. Here's the problem in a nutshell:
> > 
> > We have 2 users. test1 and test2. Both are members of the group
> > "testgrp":
> > 
> > test2@host$ ls -l f1
> > -rwxrwsr-x 1 test1 testgrp 2 2007-05-29 12:23 f1
> > test2@host$ echo foo > f1
> > -bash: f1: Permission denied
> > 
> > ...and f1 is unchanged. The problem is that the VFS calls remove_suid
> > to wipe the setgid bit. This ends up causing a SETATTR call, which
> > fails on NFS because we're attempting to remove these bits as user
> > "test2".
> > 
> > Until recently, the situation here was worse. The VFS would truncate
> > the file first and then try to clear the setgid bit. The truncate would
> > succeed, but the perm change would fail. You'd end up with a zero-length
> > file. This was fixed my making the size change and bit-clearing go via
> > the same setattr call, so the whole operation just errors out now.
> > 
> > My question is -- Is there anything we can do to make this work as it
> > does on a local filesystem? Ideally there would be some way to tell the
> > server "clear the setuid/gid bits", without actually modifying the
> > contents of the file. Is there a NFS call we can use that would do this?
> > 
> > The only thing I can think of is to read the first byte of the file and
> > then overwrite it with the same data, but that seems racy and may have
> > other problems (and what do you do with a zero-length, setuid file?).
> > 
> > Any suggestions appreciated...
> 
> The answer should be simple: leave it to the server. All servers I know
> (except possibly Hummingbird) will clear the setuid/setgid bit whenever
> the file is modified. Anything else would be _extremely_ racy anyway:
> Consider the scenario where you are preparing to write to the file, when
> suddenly a user on another client makes the file setuid after you have
> open()ed the file, but before you actually issue the write().
> 
> IOW: calling remove_suid() on the client is completely redundant, and
> should be suppressed.
> 
> Trond
> 

Ok. This is a bit more complex now since we remove suid bits on
truncate, but don't set ATTR_FORCE.

Here's a patch that should do this. I know there's a general
aversion to adding new flags to vfs structures, but I couldn't think of
a way to cleanly do this without adding one.

Note that I've not tested this patch at all so this is just a RFC.

CC'ing Al here since he's expressed interest in this problem as well.

Thoughts?

Signed-off-by: Jeff Layton <jlayton@redhat.com>

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index ca20d3c..afdd82e 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -71,7 +71,7 @@ static struct file_system_type nfs_fs_type = {
 	.name		= "nfs",
 	.get_sb		= nfs_get_sb,
 	.kill_sb	= nfs_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
+	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA|FS_DONT_REMOVE_SUID,
 };
 
 struct file_system_type nfs_xdev_fs_type = {
@@ -79,7 +79,7 @@ struct file_system_type nfs_xdev_fs_type = {
 	.name		= "nfs",
 	.get_sb		= nfs_xdev_get_sb,
 	.kill_sb	= nfs_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
+	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA|FS_DONT_REMOVE_SUID,
 };
 
 static const struct super_operations nfs_sops = {
@@ -107,7 +107,7 @@ static struct file_system_type nfs4_fs_type = {
 	.name		= "nfs4",
 	.get_sb		= nfs4_get_sb,
 	.kill_sb	= nfs4_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
+	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA|FS_DONT_REMOVE_SUID,
 };
 
 struct file_system_type nfs4_xdev_fs_type = {
@@ -115,7 +115,7 @@ struct file_system_type nfs4_xdev_fs_type = {
 	.name		= "nfs4",
 	.get_sb		= nfs4_xdev_get_sb,
 	.kill_sb	= nfs4_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
+	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA|FS_DONT_REMOVE_SUID,
 };
 
 struct file_system_type nfs4_referral_fs_type = {
@@ -123,7 +123,7 @@ struct file_system_type nfs4_referral_fs_type = {
 	.name		= "nfs4",
 	.get_sb		= nfs4_referral_get_sb,
 	.kill_sb	= nfs4_kill_super,
-	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
+	.fs_flags	= FS_RENAME_DOES_D_MOVE|FS_REVAL_DOT|FS_BINARY_MOUNTDATA|FS_DONT_REMOVE_SUID,
 };
 
 static const struct super_operations nfs4_sops = {
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 6a41f4c..e6e18dd 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -93,6 +93,7 @@ extern int dir_notify_enable;
 #define FS_REQUIRES_DEV 1 
 #define FS_BINARY_MOUNTDATA 2
 #define FS_HAS_SUBTYPE 4
+#define FS_DONT_REMOVE_SUID 8	/* don't try to remove_suid */
 #define FS_REVAL_DOT	16384	/* Check the paths ".", ".." for staleness */
 #define FS_RENAME_DOES_D_MOVE	32768	/* FS will handle d_move()
 					 * during rename() internally.
diff --git a/mm/filemap.c b/mm/filemap.c
index edb1b0b..27febc8 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1888,6 +1888,14 @@ int should_remove_suid(struct dentry *dentry)
 	mode_t mode = dentry->d_inode->i_mode;
 	int kill = 0;
 
+	/*
+	 * We want to supress this on some filesystems -- particularly NFS
+	 * as we expect the server to handle it, and we may not have
+	 * permission to remove these bits.
+	 */
+	if (dentry->d_sb->s_type->fs_flags & FS_DONT_REMOVE_SUID)
+		return 0;
+
 	/* suid always must be killed */
 	if (unlikely(mode & S_ISUID))
 		kill = ATTR_KILL_SUID;
