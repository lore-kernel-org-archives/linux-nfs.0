Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35894 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S969474AbdAEOqh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Jan 2017 09:46:37 -0500
Received: by mail-pg0-f68.google.com with SMTP id 75so2696725pgf.3
        for <linux-nfs@vger.kernel.org>; Thu, 05 Jan 2017 06:46:36 -0800 (PST)
Subject: [PATCH v2] NFSD: Only support readonly export for !fsync and readonly
 filesystem
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
References: <960d206f-3cb5-b60e-5245-d7282dabf664@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Steve Dickson <SteveD@redhat.com>, kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <d34d688a-cd83-960e-ae2b-32671a6af1dd@gmail.com>
Date: Thu, 5 Jan 2017 22:46:24 +0800
MIME-Version: 1.0
In-Reply-To: <960d206f-3cb5-b60e-5245-d7282dabf664@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit fae5096ad217
"nfsd: assume writeable exportabled filesystems have f_sync"
have remove the checking of f_sync.

Christoph Hellwig suggests, "Warn and refuse the writable export."
I think just covert to a readonly export for !fsync filesystem and
readonly filesystem is reasonable.

For example,
A test directory may be mounted many underlay filesystem (contain
 ISO9660, f2fs, etc) frequently. If refuse the writeable export,
for ISO9660 the exports entry must be *(ro,...), but for f2fs
may be *(rw,...). I don't think someone wants change it every time.

Also, I let the message as a dprintk for, an export entry cache will
be dropped without any use in some times, and created in the next use.
If let the message as a warning, there will be many messages that
users maybe think that's a noise or bug.

v2, update the notice message advice from Bruce
    just pass svc_exoprt to check_export instead many parameters
    a path string for exporting entry is simply than d_path

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/export.c | 25 ++++++++++++++++++++-----
 1 file changed, 20 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 43e109c..5b9527b 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -339,8 +339,10 @@ static struct svc_export *svc_export_update(struct svc_export *new,
 					    struct svc_export *old);
 static struct svc_export *svc_export_lookup(struct svc_export *);
 
-static int check_export(struct inode *inode, int *flags, unsigned char *uuid)
+static int check_export(struct svc_export *exp, char *path_str)
 {
+	struct inode *inode = d_inode(exp->ex_path.dentry);
+	int *flags = &exp->ex_flags;
 
 	/*
 	 * We currently export only dirs, regular files, and (for v4
@@ -358,6 +360,18 @@ static int check_export(struct inode *inode, int *flags, unsigned char *uuid)
 	if (*flags & NFSEXP_V4ROOT)
 		*flags |= NFSEXP_READONLY;
 
+	/*
+	 * Convert to a readonly export for that,
+	 * 1. not supported fsync filesystem,
+	 * 2. readonly filesystem.
+	 */
+	if ((!inode->i_fop->fsync || IS_RDONLY(inode))
+	    && !(*flags & NFSEXP_READONLY)) {
+		dprintk("%s %s: exporting read-only.\n", path_str,
+			IS_RDONLY(inode) ? "is read-only" : "has no fsync method");
+		*flags |= NFSEXP_READONLY;
+	}
+
 	/* There are two requirements on a filesystem to be exportable.
 	 * 1:  We must be able to identify the filesystem from a number.
 	 *       either a device number (so FS_REQUIRES_DEV needed)
@@ -367,7 +381,7 @@ static int check_export(struct inode *inode, int *flags, unsigned char *uuid)
 	 */
 	if (!(inode->i_sb->s_type->fs_flags & FS_REQUIRES_DEV) &&
 	    !(*flags & NFSEXP_FSID) &&
-	    uuid == NULL) {
+	    exp->ex_uuid == NULL) {
 		dprintk("exp_export: export of non-dev fs without fsid\n");
 		return -EINVAL;
 	}
@@ -509,7 +523,7 @@ uuid_parse(char **mesg, char *buf, unsigned char **puuid)
 static int svc_export_parse(struct cache_detail *cd, char *mesg, int mlen)
 {
 	/* client path expiry [flags anonuid anongid fsid] */
-	char *buf;
+	char *buf, *path_str = NULL;
 	int len;
 	int err;
 	struct auth_domain *dom = NULL;
@@ -544,6 +558,7 @@ static int svc_export_parse(struct cache_detail *cd, char *mesg, int mlen)
 	if (err)
 		goto out1;
 
+	path_str = kstrdup(buf, GFP_KERNEL);
 	exp.ex_client = dom;
 	exp.cd = cd;
 	exp.ex_devid_map = NULL;
@@ -599,8 +614,7 @@ static int svc_export_parse(struct cache_detail *cd, char *mesg, int mlen)
 				goto out4;
 		}
 
-		err = check_export(d_inode(exp.ex_path.dentry), &exp.ex_flags,
-				   exp.ex_uuid);
+		err = check_export(&exp, path_str);
 		if (err)
 			goto out4;
 		/*
@@ -645,6 +659,7 @@ static int svc_export_parse(struct cache_detail *cd, char *mesg, int mlen)
 out1:
 	auth_domain_put(dom);
 out:
+	kfree(path_str);
 	kfree(buf);
 	return err;
 }
-- 
2.9.3


