From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: [PATCH] exportfs: fix incorrect EACCES in reconnect_path()
Date: Fri, 2 May 2008 17:16:46 +0200
Message-ID: <20080502151646.GA5515@janus>
References: <20080404102449.GA10209@janus> <20080407184346.GF3305@fieldses.org> <20080409133639.GA9588@lst.de> <18454.45086.254692.412079@notabene.brown> <20080429163554.GE20420@fieldses.org> <20080429174004.GA28719@janus> <20080430174736.GB20377@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Frank van Maarseveen <frankvm@frankvm.com>,
	Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@lst.de>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([80.126.170.174]:46923 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S935700AbYEBPQt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 May 2008 11:16:49 -0400
In-Reply-To: <20080430174736.GB20377@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A privileged process on an NFS client which drops privileges after using
them to change the current working directory, will experience incorrect
EACCES after an NFS server reboot. This problem can also occur after
memory pressure on the server, particularly when the client side is
quiet for some time.

This patch removes the x-bit check during dentry tree reconstruction at
the server by exportfs on behalf of nfsd.

Signed-off-by: Frank van Maarseveen <frankvm@frankvm.com>
---

Here's the patch including a comment change for lookup_one_noperm().

diff -urp a/fs/exportfs/expfs.c b/fs/exportfs/expfs.c
--- a/fs/exportfs/expfs.c	2008-02-04 14:24:21.000000000 +0100
+++ b/fs/exportfs/expfs.c	2008-05-02 14:40:13.000000000 +0200
@@ -170,7 +170,7 @@ reconnect_path(struct vfsmount *mnt, str
 			}
 			dprintk("%s: found name: %s\n", __FUNCTION__, nbuf);
 			mutex_lock(&ppd->d_inode->i_mutex);
-			npd = lookup_one_len(nbuf, ppd, strlen(nbuf));
+			npd = lookup_one_noperm(nbuf, ppd);
 			mutex_unlock(&ppd->d_inode->i_mutex);
 			if (IS_ERR(npd)) {
 				err = PTR_ERR(npd);
@@ -447,8 +447,7 @@ struct dentry *exportfs_decode_fh(struct
 		err = exportfs_get_name(mnt, target_dir, nbuf, result);
 		if (!err) {
 			mutex_lock(&target_dir->d_inode->i_mutex);
-			nresult = lookup_one_len(nbuf, target_dir,
-						 strlen(nbuf));
+			nresult = lookup_one_noperm(nbuf, target_dir);
 			mutex_unlock(&target_dir->d_inode->i_mutex);
 			if (!IS_ERR(nresult)) {
 				if (nresult->d_inode) {
diff -urp a/fs/namei.c b/fs/namei.c
--- a/fs/namei.c	2008-04-29 09:30:55.000000000 +0200
+++ b/fs/namei.c	2008-05-02 17:04:32.000000000 +0200
@@ -1391,15 +1391,15 @@ struct dentry *lookup_one_len(const char
 }
 
 /**
- * lookup_one_noperm - bad hack for sysfs
  * @name:	pathname component to lookup
  * @base:	base directory to lookup from
  *
  * This is a variant of lookup_one_len that doesn't perform any permission
- * checks.   It's a horrible hack to work around the braindead sysfs
- * architecture and should not be used anywhere else.
+ * checks. nfsd needs it via exportfs to reconstruct the dentry tree for
+ * directory handles (e.g. after a server reboot).
  *
- * DON'T USE THIS FUNCTION EVER, thanks.
+ * Originally this function was a horrible hack to work around the braindead
+ * sysfs architecture and it is still being used there.
  */
 struct dentry *lookup_one_noperm(const char *name, struct dentry *base)
 {

-- 
Frank
