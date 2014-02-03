Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f169.google.com ([209.85.213.169]:38397 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750789AbaBCUWS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Feb 2014 15:22:18 -0500
Received: by mail-ig0-f169.google.com with SMTP id uq10so6468652igb.0
        for <linux-nfs@vger.kernel.org>; Mon, 03 Feb 2014 12:22:17 -0800 (PST)
Message-ID: <1391458935.17089.1.camel@leira.trondhjem.org>
Subject: Re: NFS client broken in Linus' tip
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
        linuxnfs <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Viro Alexander <viro@zeniv.linux.org.uk>,
        Christoph Hellwig <hch@lst.de>, linux-arm-kernel@lists.infradead.org
Date: Mon, 03 Feb 2014 15:22:15 -0500
In-Reply-To: <3003D7E5-93F8-4B32-ACDB-07ED3F6CE70D@primarydata.com>
References: <20140130140834.GW15937@n2100.arm.linux.org.uk>
	 <20140130141405.GA23985@infradead.org>
	 <20140130142752.GX15937@n2100.arm.linux.org.uk>
	 <20140130143208.GB9573@infradead.org>
	 <20140130153812.GA15937@n2100.arm.linux.org.uk>
	 <1391201970.6978.1.camel@leira.trondhjem.org>
	 <20140203080325.GB806@infradead.org>
	 <85AAFCF5-60EE-42E5-B103-37A4613C5947@primarydata.com>
	 <20140203145759.GA30263@infradead.org>
	 <3003D7E5-93F8-4B32-ACDB-07ED3F6CE70D@primarydata.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2014-02-03 at 10:45 -0500, Trond Myklebust wrote:
> On Feb 3, 2014, at 9:57, Christoph Hellwig <hch@infradead.org> wrote:
> 
> > On Mon, Feb 03, 2014 at 09:17:30AM -0500, Trond Myklebust wrote:
> >> As I said above, that causes posix_acl_xattr_get() to return the wrong answer (ENODATA instead of EOPNOTSUPP).
> > 
> > Is it really the wrong answer?  How does userspace care wether this
> > server doesn't support ACLs at all or none is set?  The resulting
> > behavior is the same.
> 
> It will certainly cause acl_get_file() to behave differently than previously. I’ve no idea how that will affect applications, though.
> 
> > If there's a good reason to care we might have to go with your patch,
> > but if we can avoid it I'd prefer to keep things simple.
> 
> One alternative is to simply wrap posix_acl_xattr_get() in fs/nfs/nfs3acl.c, and have it check the value of nfs_server_capable(inode, NFS_CAP_ACLS) before returning ENODATA. That’s rather ugly too...

FWIW, here is the alternative patch. I've tested it, and it seems to
work.
8<---------------------------------------------------------------------
>From 2e527b12169a67e9cfcf43898ae4d15bcfa1ede9 Mon Sep 17 00:00:00 2001
From: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Mon, 3 Feb 2014 13:07:05 -0500
Subject: [PATCH] NFSv3: Fix return values for get_acl()

Ensure that nfs3_get_acl() returns NULL when the server doesn't support
POSIX acls. This ensures that posix_acl_create() does the right thing,
and applies the current_umask() to the mode before returning.

Add a wrapper around posix_acl_xattr_get() so that we continue to
return EOPNOTSUPP when the server doesn't support POSIX acls. Otherwise,
the NULL return from nfs3_get_acl() will cause ENODATA to be returned.

Also add the appropriate exports to posix_acl_xattr_get, posix_acl_xattr_set
and posix_acl_xattr_list to enable their use in the wrapper.

Reported-by: Russell King <linux@arm.linux.org.uk>
Link: http://lkml.kernel.org/r/20140130140834.GW15937@n2100.arm.linux.org.uk
Cc: Christoph Hellwig <hch@lst.de>
Cc: Al Viro viro@zeniv.linux.org.uk>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs3acl.c                | 42 ++++++++++++++++++++++++++++++++++++-----
 fs/posix_acl.c                  |  9 ++++++---
 include/linux/posix_acl_xattr.h |  8 ++++++++
 3 files changed, 51 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs3acl.c b/fs/nfs/nfs3acl.c
index 871d6eda8dba..d1bc84f22f64 100644
--- a/fs/nfs/nfs3acl.c
+++ b/fs/nfs/nfs3acl.c
@@ -28,8 +28,10 @@ struct posix_acl *nfs3_get_acl(struct inode *inode, int type)
 	};
 	int status, count;
 
-	if (!nfs_server_capable(inode, NFS_CAP_ACLS))
-		return ERR_PTR(-EOPNOTSUPP);
+	if (!nfs_server_capable(inode, NFS_CAP_ACLS)) {
+		cache_no_acl(inode);
+		return NULL;
+	}
 
 	status = nfs_revalidate_inode(server, inode);
 	if (status < 0)
@@ -70,7 +72,7 @@ struct posix_acl *nfs3_get_acl(struct inode *inode, int type)
 			dprintk("NFS_V3_ACL extension not supported; disabling\n");
 			server->caps &= ~NFS_CAP_ACLS;
 		case -ENOTSUPP:
-			status = -EOPNOTSUPP;
+			status = 0;
 		default:
 			goto getout;
 	}
@@ -242,8 +244,38 @@ fail:
 	return PTR_ERR(alloc);
 }
 
+static int
+nfs_posix_acl_xattr_get(struct dentry *dentry, const char *name,
+		void *value, size_t size, int type)
+{
+	int ret;
+
+	ret = posix_acl_xattr_get(dentry, name, value, size, type);
+	/*
+	 * This check is needed to override the ENODATA error that
+	 * posix_acl_xattr_get will return if the acl probe fails.
+	 */
+	if (!nfs_server_capable(dentry->d_inode, NFS_CAP_ACLS))
+		ret = -EOPNOTSUPP;
+	return ret;
+}
+
+static const struct xattr_handler nfs_posix_acl_access_xattr_handler = {
+	.prefix = POSIX_ACL_XATTR_ACCESS,
+	.flags = ACL_TYPE_ACCESS,
+	.get = nfs_posix_acl_xattr_get,
+	.set = posix_acl_xattr_set,
+};
+
+static const struct xattr_handler nfs_posix_acl_default_xattr_handler = {
+	.prefix = POSIX_ACL_XATTR_DEFAULT,
+	.flags = ACL_TYPE_DEFAULT,
+	.get = nfs_posix_acl_xattr_get,
+	.set = posix_acl_xattr_set,
+};
+
 const struct xattr_handler *nfs3_xattr_handlers[] = {
-	&posix_acl_access_xattr_handler,
-	&posix_acl_default_xattr_handler,
+	&nfs_posix_acl_access_xattr_handler,
+	&nfs_posix_acl_default_xattr_handler,
 	NULL,
 };
diff --git a/fs/posix_acl.c b/fs/posix_acl.c
index 38bae5a0ea25..835167f92952 100644
--- a/fs/posix_acl.c
+++ b/fs/posix_acl.c
@@ -750,7 +750,7 @@ posix_acl_to_xattr(struct user_namespace *user_ns, const struct posix_acl *acl,
 }
 EXPORT_SYMBOL (posix_acl_to_xattr);
 
-static int
+int
 posix_acl_xattr_get(struct dentry *dentry, const char *name,
 		void *value, size_t size, int type)
 {
@@ -773,8 +773,9 @@ posix_acl_xattr_get(struct dentry *dentry, const char *name,
 
 	return error;
 }
+EXPORT_SYMBOL_GPL(posix_acl_xattr_get);
 
-static int
+int
 posix_acl_xattr_set(struct dentry *dentry, const char *name,
 		const void *value, size_t size, int flags, int type)
 {
@@ -809,8 +810,9 @@ out:
 	posix_acl_release(acl);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(posix_acl_xattr_set);
 
-static size_t
+size_t
 posix_acl_xattr_list(struct dentry *dentry, char *list, size_t list_size,
 		const char *name, size_t name_len, int type)
 {
@@ -832,6 +834,7 @@ posix_acl_xattr_list(struct dentry *dentry, char *list, size_t list_size,
 		memcpy(list, xname, size);
 	return size;
 }
+EXPORT_SYMBOL_GPL(posix_acl_xattr_list);
 
 const struct xattr_handler posix_acl_access_xattr_handler = {
 	.prefix = POSIX_ACL_XATTR_ACCESS,
diff --git a/include/linux/posix_acl_xattr.h b/include/linux/posix_acl_xattr.h
index 6f14ee295822..fc062003a456 100644
--- a/include/linux/posix_acl_xattr.h
+++ b/include/linux/posix_acl_xattr.h
@@ -69,6 +69,14 @@ struct posix_acl *posix_acl_from_xattr(struct user_namespace *user_ns,
 int posix_acl_to_xattr(struct user_namespace *user_ns,
 		       const struct posix_acl *acl, void *buffer, size_t size);
 
+int posix_acl_xattr_get(struct dentry *dentry, const char *name,
+			void *value, size_t size, int type);
+int posix_acl_xattr_set(struct dentry *dentry, const char *name,
+			const void *value, size_t size, int flags, int type);
+size_t posix_acl_xattr_list(struct dentry *dentry, char *list,
+			    size_t list_size, const char *name,
+			    size_t name_len, int type);
+
 extern const struct xattr_handler posix_acl_access_xattr_handler;
 extern const struct xattr_handler posix_acl_default_xattr_handler;
 
-- 
1.8.5.3


-- 
Trond Myklebust
Linux NFS client maintainer

