Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-da0-f46.google.com ([209.85.210.46]:48802 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753708Ab2JVABY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 21 Oct 2012 20:01:24 -0400
Date: Sun, 21 Oct 2012 17:01:20 -0700
From: Jonathan Nieder <jrnieder@gmail.com>
To: Ben Hutchings <ben@decadent.org.uk>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, 669314@bugs.debian.org,
        viro@zeniv.linux.org.uk, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, Micheal Waltz <mwaltz@qualcomm.com>,
        Gabriel Evanoff <gevanoff@salk.edu>, laurent+debian@u-picardie.fr
Subject: Re: [PATCH] nfs: Show original device name verbatim in
 /proc/*/mount{s,info}
Message-ID: <20121022000119.GB9057@elie.Belkin>
References: <7941E5E1-488D-4D0B-A21A-4E389EF6EBBA@salk.edu>
 <1350843832.22276.34.camel@deadeye.wl.decadent.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1350843832.22276.34.camel@deadeye.wl.decadent.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

(cc-ing Laurent in case he wants to test.  Laurent, a "git am"-ready
 patch is at [1])
Ben Hutchings wrote:

> Since commit c7f404b ('vfs: new superblock methods to override
> /proc/*/mount{s,info}'), nfs_path() is used to generate the mounted
> device name reported back to userland.
>
> nfs_path() always generates a trailing slash when the given dentry is
> the root of an NFS mount, but userland may expect the original device
> name to be returned verbatim (as it used to be).  Make this
> canonicalisation optional and change the callers accordingly.
>
> Reported-and-tested-by: Chris Hiestand <chiestand@salk.edu>
> Reference: http://bugs.debian.org/669314
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> Cc: <stable@vger.kernel.org> # v2.6.39+

Changing the content of /proc/mounts broke 

 user@hostname:/proc/self$ sudo umount.nfs nfsserver:/srv/ubuntu-32
 umount.nfs: nfsserver:/srv/ubuntu-32: not found

with nfs2 and nfs3 and this looks like the minimal change to get it
working again, so for what it's worth,
Reviewed-by: Jonathan Nieder <jrnieder@gmail.com>

How about something like the following on top?

-- >8 --
Subject: nfs: convert boolean nfs_path() argument to a flag word

If nfs_path() gains any other boolean settings, they can share the
flag argument, and this way call sites look like "nfs_path(&limit,
dentry, buffer, buflen, NFS_PATH_CANONICAL);" so the reader does not
need to guess the sense of true and false.  No functional change
intended.

Signed-off-by: Jonathan Nieder <jrnieder@gmail.com>
---
[1] http://download.gmane.org/gmane.linux.nfs/52755/52756

 fs/nfs/internal.h      |  5 +++--
 fs/nfs/namespace.c     | 14 +++++++++-----
 fs/nfs/nfs4namespace.c |  3 ++-
 fs/nfs/super.c         |  2 +-
 4 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 9c9603373d64..a54fe51c1dfb 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -353,8 +353,9 @@ extern void nfs_sb_active(struct super_block *sb);
 extern void nfs_sb_deactive(struct super_block *sb);
 
 /* namespace.c */
+#define NFS_PATH_CANONICAL 1
 extern char *nfs_path(char **p, struct dentry *dentry,
-		      char *buffer, ssize_t buflen, bool canonical);
+		      char *buffer, ssize_t buflen, unsigned flags);
 extern struct vfsmount *nfs_d_automount(struct path *path);
 struct vfsmount *nfs_submount(struct nfs_server *, struct dentry *,
 			      struct nfs_fh *, struct nfs_fattr *);
@@ -498,7 +499,7 @@ static inline char *nfs_devname(struct dentry *dentry,
 				char *buffer, ssize_t buflen)
 {
 	char *dummy;
-	return nfs_path(&dummy, dentry, buffer, buflen, true);
+	return nfs_path(&dummy, dentry, buffer, buflen, NFS_PATH_CANONICAL);
 }
 
 /*
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index 059975e492e1..dd057bc6b65b 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -33,8 +33,7 @@ int nfs_mountpoint_expiry_timeout = 500 * HZ;
  * @dentry - pointer to dentry
  * @buffer - result buffer
  * @buflen - length of buffer
- * @canonical - ensure there is exactly one slash after the original
- *		device (export) name; if false, return it verbatim
+ * @flags - options (see below)
  *
  * Helper function for constructing the server pathname
  * by arbitrary hashed dentry.
@@ -42,9 +41,14 @@ int nfs_mountpoint_expiry_timeout = 500 * HZ;
  * This is mainly for use in figuring out the path on the
  * server side when automounting on top of an existing partition
  * and in generating /proc/mounts and friends.
+ *
+ * Supported flags:
+ * NFS_PATH_CANONICAL: ensure there is exactly one slash after
+ *		       the original device (export) name
+ *		       (if unset, the original name is returned verbatim)
  */
 char *nfs_path(char **p, struct dentry *dentry, char *buffer, ssize_t buflen,
-	       bool canonical)
+	       unsigned flags)
 {
 	char *end;
 	int namelen;
@@ -77,7 +81,7 @@ rename_retry:
 		rcu_read_unlock();
 		goto rename_retry;
 	}
-	if (canonical && *end != '/') {
+	if ((flags & NFS_PATH_CANONICAL) && *end != '/') {
 		if (--buflen < 0) {
 			spin_unlock(&dentry->d_lock);
 			rcu_read_unlock();
@@ -94,7 +98,7 @@ rename_retry:
 		return end;
 	}
 	namelen = strlen(base);
-	if (canonical) {
+	if (flags & NFS_PATH_CANONICAL) {
 		/* Strip off excess slashes in base string */
 		while (namelen > 0 && base[namelen - 1] == '/')
 			namelen--;
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 2f6f16331769..1e09eb78543b 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -81,7 +81,8 @@ static char *nfs_path_component(const char *nfspath, const char *end)
 static char *nfs4_path(struct dentry *dentry, char *buffer, ssize_t buflen)
 {
 	char *limit;
-	char *path = nfs_path(&limit, dentry, buffer, buflen, true);
+	char *path = nfs_path(&limit, dentry, buffer, buflen,
+			      NFS_PATH_CANONICAL);
 	if (!IS_ERR(path)) {
 		char *path_component = nfs_path_component(path, limit);
 		if (path_component)
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index c89a73da13d9..13c2a5be4765 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -771,7 +771,7 @@ int nfs_show_devname(struct seq_file *m, struct dentry *root)
 	int err = 0;
 	if (!page)
 		return -ENOMEM;
-	devname = nfs_path(&dummy, root, page, PAGE_SIZE, false);
+	devname = nfs_path(&dummy, root, page, PAGE_SIZE, 0);
 	if (IS_ERR(devname))
 		err = PTR_ERR(devname);
 	else
-- 
1.8.0.rc3

