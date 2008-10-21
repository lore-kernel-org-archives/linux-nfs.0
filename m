From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH] nfsd: Fix memory leak in nfsd_getxattr (& usage in _get_posix_acl)
Date: Tue, 21 Oct 2008 16:21:39 +0530
Message-ID: <20081021105139.13512.67162.sendpatchset@localhost.localdomain>
Cc: Krishna Kumar <krkumar2@in.ibm.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:57707 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752797AbYJUKvp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Oct 2008 06:51:45 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m9LApi0W005387
	for <linux-nfs@vger.kernel.org>; Tue, 21 Oct 2008 06:51:44 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9LApiJP128706
	for <linux-nfs@vger.kernel.org>; Tue, 21 Oct 2008 06:51:44 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9LApgNl021974
	for <linux-nfs@vger.kernel.org>; Tue, 21 Oct 2008 06:51:42 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"J. Bruce Fields" <bfields@fieldses.org> wrote on 10/21/2008 02:32:59 AM:

> Is the current code really a problem?
> 
> Possibly more interesting to look into:
> 
>    - Can nfsd_getxattr actually return NULL?

You are right. I think it can return 0, eg any of the filesystem getxattr's.

>    - Why do we need to return ENODATA in that case?
>      (nfsd_get_posix_acl, for example, seems to just end up
>      returning -EINVAL in that case.)

Did you mean NULL rather than EINVAL (posix_acl_from_xattr returns NULL before
EINVAL)?

Another thing that seems slightly wrong. Both of the following functions:
nfsd_get_posix_acl()
{
	...
	size = nfsd_getxattr(fhp->fh_dentry, name, &value);
	if (size < 0)
		return ERR_PTR(size);
	...
}
_get_posix_acl(struct dentry *dentry, char *key)
{
	...
	buflen = nfsd_getxattr(dentry, key, &buf);
	if (!buflen)
		buflen = -ENODATA;
	if (buflen <= 0)
		return ERR_PTR(buflen);
	...
}
call nfsd_getxattr which can allocate memory but still return < 0. Function
allocates buf and calls vfs_getxattr() which fails and leaks memory. The best
place to fix this is in nfsd_getxattr in case vfs_getxattr() returns < 0

Does that sound correct? Patch for this follows...

thanks,

- KK

From: Krishna Kumar <krkumar2@in.ibm.com>

1. Fix a memory leak in nfsd_getxattr. nfsd_getxattr should free up memory
	that it allocated if vfs_getxattr fails.

2. Change _get_posix_acl to return NULL on buflen == 0.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---

 fs/nfsd/vfs.c |   12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff -ruNp org/fs/nfsd/vfs.c new/fs/nfsd/vfs.c
--- org/fs/nfsd/vfs.c	2008-10-21 16:05:41.000000000 +0530
+++ new/fs/nfsd/vfs.c	2008-10-21 15:57:30.000000000 +0530
@@ -411,6 +411,7 @@ out_nfserr:
 static ssize_t nfsd_getxattr(struct dentry *dentry, char *key, void **buf)
 {
 	ssize_t buflen;
+	ssize_t ret;
 
 	buflen = vfs_getxattr(dentry, key, NULL, 0);
 	if (buflen <= 0)
@@ -420,7 +421,10 @@ static ssize_t nfsd_getxattr(struct dent
 	if (!*buf)
 		return -ENOMEM;
 
-	return vfs_getxattr(dentry, key, *buf, buflen);
+	ret = vfs_getxattr(dentry, key, *buf, buflen);
+	if (ret < 0)
+		kfree(*buf);
+	return ret;
 }
 #endif
 
@@ -499,13 +503,11 @@ static struct posix_acl *
 _get_posix_acl(struct dentry *dentry, char *key)
 {
 	void *buf = NULL;
-	struct posix_acl *pacl = NULL;
+	struct posix_acl *pacl;
 	int buflen;
 
 	buflen = nfsd_getxattr(dentry, key, &buf);
-	if (!buflen)
-		buflen = -ENODATA;
-	if (buflen <= 0)
+	if (buflen < 0)
 		return ERR_PTR(buflen);
 
 	pacl = posix_acl_from_xattr(buf, buflen);
