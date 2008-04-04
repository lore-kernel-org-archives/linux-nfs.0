From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: reconnect_path() breaks NFS server causing occasional EACCES
Date: Fri, 4 Apr 2008 12:24:49 +0200
Message-ID: <20080404102449.GA10209@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([80.126.170.174]:37944 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752169AbYDDKYv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Apr 2008 06:24:51 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Occasionally we experience EACCES errors which are caused by the exportfs
reconnect_path() function called by the NFS server (NFSv3). The following
reproduces it reliably on the client.

Compile cd-droppriv.c and make it setuid root:
--------
#include <stdio.h>
#include <stdarg.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
#include <dirent.h>

void die(const char *fmt, ...) __attribute__((format(printf, 1, 2), noreturn));
void die(const char *fmt, ...)
{
	va_list ap;

	va_start(ap, fmt);
	fprintf(stderr, "cd-droppriv: ");
	vfprintf(stderr, fmt, ap);
	va_end(ap);
	exit(1);
}

int main(int argc, char **argv)
{
	if (chdir(argv[1]) == -1)
		die("chdir: %s\n", strerror(errno));
	if (setuid(getuid()) == -1)
		die("setuid: %s\n", strerror(errno));
	printf("Restart the NFS server then press <enter>.\n");
	getchar();
	if (opendir(".") == NULL)
		die("opendir: %s\n", strerror(errno));
	return 0;
}
--------

As root, create a directory tree on the client. The export options on
the server for /mnt include no_root_squash and no_subtree_check:

	mkdir -p /mnt/a/b
	chmod 700 /mnt/a
	chmod 777 /mnt/a/b

Run the program as non-root on the client:

	cd-droppriv /mnt/a/b

and press <enter>. When the server is restarted before pressing <enter>
opendir() fails with EACCES:

	cd-droppriv: opendir: Permission denied

This happens too when dentries are dropped on the server due to memory
pressure. The following seems to fix the problem (2.6.24.4):

--- ./fs/exportfs/expfs.c.orig	2008-02-04 14:24:21.000000000 +0100
+++ ./fs/exportfs/expfs.c	2008-04-03 18:00:20.000000000 +0200
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

-- 
Frank
