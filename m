From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH] nfsd: Change error handling in _get_posix_acl and it's callers
Date: Wed, 22 Oct 2008 14:48:48 +0530
Message-ID: <20081022091848.22100.80769.sendpatchset@localhost.localdomain>
References: <20081022091836.22100.57827.sendpatchset@localhost.localdomain>
Cc: Krishna Kumar <krkumar2@in.ibm.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:57722 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752290AbYJVJSx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Oct 2008 05:18:53 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id m9M9IKL1025401
	for <linux-nfs@vger.kernel.org>; Wed, 22 Oct 2008 03:18:20 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9M9IqcR058642
	for <linux-nfs@vger.kernel.org>; Wed, 22 Oct 2008 03:18:52 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9M9Ipn0015054
	for <linux-nfs@vger.kernel.org>; Wed, 22 Oct 2008 03:18:51 -0600
In-Reply-To: <20081022091836.22100.57827.sendpatchset-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>

Change _get_posix_acl to return NULL on buflen == 0, and change users of
	this function to handle error cases.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 fs/nfsd/vfs.c |   12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff -ruNp 2.6.27-org/fs/nfsd/vfs.c 2.6.27-new/fs/nfsd/vfs.c
--- 2.6.27-org/fs/nfsd/vfs.c	2008-10-22 14:19:15.000000000 +0530
+++ 2.6.27-new/fs/nfsd/vfs.c	2008-10-22 14:35:16.000000000 +0530
@@ -503,13 +503,11 @@ static struct posix_acl *
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
@@ -526,7 +524,7 @@ nfsd4_get_nfs4_acl(struct svc_rqst *rqst
 	unsigned int flags = 0;
 
 	pacl = _get_posix_acl(dentry, POSIX_ACL_XATTR_ACCESS);
-	if (IS_ERR(pacl) && PTR_ERR(pacl) == -ENODATA)
+	if (!pacl)
 		pacl = posix_acl_from_mode(inode->i_mode, GFP_KERNEL);
 	if (IS_ERR(pacl)) {
 		error = PTR_ERR(pacl);
@@ -536,9 +534,7 @@ nfsd4_get_nfs4_acl(struct svc_rqst *rqst
 
 	if (S_ISDIR(inode->i_mode)) {
 		dpacl = _get_posix_acl(dentry, POSIX_ACL_XATTR_DEFAULT);
-		if (IS_ERR(dpacl) && PTR_ERR(dpacl) == -ENODATA)
-			dpacl = NULL;
-		else if (IS_ERR(dpacl)) {
+		if (IS_ERR(dpacl)) {
 			error = PTR_ERR(dpacl);
 			dpacl = NULL;
 			goto out;
