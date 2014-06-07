Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:59508 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752642AbaFGOEQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 7 Jun 2014 10:04:16 -0400
Date: Sat, 7 Jun 2014 07:04:14 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Philippe Troin <phil@coldcreektech.com>,
        Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>
Subject: Re: Phantom ACL-related xattrs on 3.14.4 NFS client
Message-ID: <20140607140414.GA26534@infradead.org>
References: <1402082953.28220.7.camel@ceramic.home.fifi.org>
 <CAHQdGtS2BL9u4DV=FZ0HaXO-iTNPU4hTGVR--HubNa4A_6UNog@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtS2BL9u4DV=FZ0HaXO-iTNPU4hTGVR--HubNa4A_6UNog@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 06, 2014 at 04:37:03PM -0400, Trond Myklebust wrote:
> Christoph, what is the intended interface for telling
> posix_acl_xattr_list() that there are no acls on a particular file?
> Should there perhaps be a call to get_acl()?

The interface is to not call posix_acl_xattr_list unless you have ACLs.
Every implementation does this, except for generic_listxattr which is
only used by NFS.

Philippe, can you test the patch below?


diff --git a/fs/nfs/nfs3acl.c b/fs/nfs/nfs3acl.c
index 871d6ed..e083827 100644
--- a/fs/nfs/nfs3acl.c
+++ b/fs/nfs/nfs3acl.c
@@ -247,3 +247,45 @@ const struct xattr_handler *nfs3_xattr_handlers[] = {
 	&posix_acl_default_xattr_handler,
 	NULL,
 };
+
+static int
+nfs3_list_one_acl(struct inode *inode, int type, const char *name, void *data,
+		size_t size, ssize_t *result)
+{
+	struct posix_acl *acl;
+	char *p = data + *result;
+
+	acl = get_acl(inode, type);
+	if (!acl)
+		return 0;
+
+	posix_acl_release(acl);
+
+	*result += strlen(name);
+	if (!size)
+		return 0;
+	if (*result > size)
+		return -ERANGE;
+
+	strcpy(p, name);
+	return 0;
+}
+
+ssize_t
+nfs3_listxattr(struct dentry *dentry, char *data, size_t size)
+{
+	struct inode *inode = dentry->d_inode;
+	ssize_t result = 0;
+	int error;
+
+	error = nfs3_list_one_acl(inode, ACL_TYPE_ACCESS,
+			POSIX_ACL_XATTR_ACCESS, data, size, &result);
+	if (error)
+		return error;
+
+	error = nfs3_list_one_acl(inode, ACL_TYPE_DEFAULT,
+			POSIX_ACL_XATTR_DEFAULT, data, size, &result);
+	if (error)
+		return error;
+	return result;
+}
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index db60149..0e2bb26 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -891,7 +891,7 @@ static const struct inode_operations nfs3_dir_inode_operations = {
 	.getattr	= nfs_getattr,
 	.setattr	= nfs_setattr,
 #ifdef CONFIG_NFS_V3_ACL
-	.listxattr	= generic_listxattr,
+	.listxattr	= nfs3_listxattr,
 	.getxattr	= generic_getxattr,
 	.setxattr	= generic_setxattr,
 	.removexattr	= generic_removexattr,
@@ -905,7 +905,7 @@ static const struct inode_operations nfs3_file_inode_operations = {
 	.getattr	= nfs_getattr,
 	.setattr	= nfs_setattr,
 #ifdef CONFIG_NFS_V3_ACL
-	.listxattr	= generic_listxattr,
+	.listxattr	= nfs3_listxattr,
 	.getxattr	= generic_getxattr,
 	.setxattr	= generic_setxattr,
 	.removexattr	= generic_removexattr,
