Return-Path: <SRS0=9F0h=R2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E63A3C43381
	for <linux-nfs@archiver.kernel.org>; Sat, 23 Mar 2019 13:46:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BFB1E2183E
	for <linux-nfs@archiver.kernel.org>; Sat, 23 Mar 2019 13:46:56 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727482AbfCWNq4 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 23 Mar 2019 09:46:56 -0400
Received: from out20-39.mail.aliyun.com ([115.124.20.39]:32954 "EHLO
        out20-39.mail.aliyun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726909AbfCWNq4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 23 Mar 2019 09:46:56 -0400
X-Alimail-AntiSpam: AC=CONTINUE;BC=0.07455182|-1;CH=green;DM=CONTINUE|CONTINUE|true|0.302902-0.0232141-0.673883;FP=0|0|0|0|0|-1|-1|-1;HT=e01a16378;MF=liupeifeng@horiscale.com;NM=1;PH=DS;RN=2;RT=2;SR=0;TI=SMTPD_---.EBmQpiQ_1553348797;
Received: from LIU.OPENFS.NET.OPENFS.NET(mailfrom:liupeifeng@horiscale.com fp:SMTPD_---.EBmQpiQ_1553348797)
          by smtp.aliyun-inc.com(10.194.99.21);
          Sat, 23 Mar 2019 21:46:50 +0800
From:   Pei-Feng liu <liupeifeng@horiscale.com>
To:     linux-nfs@vger.kernel.org
Cc:     Pei-Feng liu <liupeifeng@horiscale.com>
Subject: [PATCH] fs/exportfs: Decoding FH with a larger memory to cache the filename.
Date:   Sat, 23 Mar 2019 21:46:34 +0800
Message-Id: <1553348794-4505-2-git-send-email-liupeifeng@horiscale.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1553348794-4505-1-git-send-email-liupeifeng@horiscale.com>
References: <1553348794-4505-1-git-send-email-liupeifeng@horiscale.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

It uses 'NAME_MAX+1' memory to cache a filename string when decoding a FH
to a connected 'dentry' object. As a matter of fact, the correct method
is using 'f_namelen' that returned by 'vfs_statfs()'.

More details: I have a proprietary filesystem driver, which looks like
XFS or EXT4 and is going to be exported its namespace with a special
NFS/CIFS server. The filename's maxlen (in bytes) of it is larger than
'NAME_MAX'.  And 'dentry' object doesn't contraint that the name string
within 'NAME_MAX'. So, this piece of code in 'exportfs_decode_fh' in
'fs/exportfs/expfs.c' doesn't work when the exported namespace is from
my proprietary filesystem.

This patch is filed to get this resolved. The max length of a filesystem
is probed firstly with 'vfs_statfs()', then malloc a large enough memory
to cache the filename string when decoding a 'FH'.

Signed-off-by: Pei-Feng liu <liupeifeng@horiscale.com>
---
 fs/exportfs/expfs.c | 30 +++++++++++++++++++++++++++++-
 1 file changed, 29 insertions(+), 1 deletion(-)

diff --git a/fs/exportfs/expfs.c b/fs/exportfs/expfs.c
index c69927be..8738868 100644
--- a/fs/exportfs/expfs.c
+++ b/fs/exportfs/expfs.c
@@ -16,6 +16,8 @@
 #include <linux/namei.h>
 #include <linux/sched.h>
 #include <linux/cred.h>
+#include <linux/slab.h>
+#include <linux/statfs.h>
 
 #define dprintk(fmt, args...) do{}while(0)
 
@@ -422,7 +424,7 @@ struct dentry *exportfs_decode_fh(struct vfsmount *mnt, struct fid *fid,
 {
 	const struct export_operations *nop = mnt->mnt_sb->s_export_op;
 	struct dentry *result, *alias;
-	char nbuf[NAME_MAX+1];
+	int nbuf_max = NAME_MAX+1;
 	int err;
 
 	/*
@@ -445,6 +447,15 @@ struct dentry *exportfs_decode_fh(struct vfsmount *mnt, struct fid *fid,
 	if (!acceptable)
 		return result;
 
+	if (NULL!=mnt->mnt_sb->s_op && NULL!=mnt->mnt_sb->s_op->statfs) {
+		struct kstatfs stfs;
+
+		if ((0 == mnt->mnt_sb->s_op->statfs(mnt->mnt_root, &stfs)) &&	\
+				(stfs.f_namelen > 0) && (stfs.f_namelen < INT_MAX)) {
+			nbuf_max = (uint32_t)stfs.f_namelen + 1;
+		}
+	}
+
 	if (d_is_dir(result)) {
 		/*
 		 * This request is for a directory.
@@ -455,7 +466,14 @@ struct dentry *exportfs_decode_fh(struct vfsmount *mnt, struct fid *fid,
 		 * filesystem root.
 		 */
 		if (result->d_flags & DCACHE_DISCONNECTED) {
+			char *nbuf = (char *)kzalloc(nbuf_max, GFP_KERNEL);
+			if (NULL == nbuf) {
+				err = -ENOMEM;
+				goto err_result;
+			}
+
 			err = reconnect_path(mnt, result, nbuf);
+			kfree(nbuf);
 			if (err)
 				goto err_result;
 		}
@@ -471,6 +489,7 @@ struct dentry *exportfs_decode_fh(struct vfsmount *mnt, struct fid *fid,
 		 * It's not a directory.  Life is a little more complicated.
 		 */
 		struct dentry *target_dir, *nresult;
+		char *nbuf = NULL;
 
 		/*
 		 * See if either the dentry we just got from the filesystem
@@ -501,6 +520,12 @@ struct dentry *exportfs_decode_fh(struct vfsmount *mnt, struct fid *fid,
 		if (IS_ERR(target_dir))
 			goto err_result;
 
+		nbuf = (char *)kzalloc(nbuf_max, GFP_KERNEL);
+		if (NULL == nbuf) {
+			err = -ENOMEM;
+			goto err_result;
+		}
+
 		/*
 		 * And as usual we need to make sure the parent directory is
 		 * connected to the filesystem root.  The VFS really doesn't
@@ -509,6 +534,7 @@ struct dentry *exportfs_decode_fh(struct vfsmount *mnt, struct fid *fid,
 		err = reconnect_path(mnt, target_dir, nbuf);
 		if (err) {
 			dput(target_dir);
+			kfree(nbuf);
 			goto err_result;
 		}
 
@@ -532,6 +558,8 @@ struct dentry *exportfs_decode_fh(struct vfsmount *mnt, struct fid *fid,
 			}
 		}
 
+		kfree(nbuf);
+
 		/*
 		 * At this point we are done with the parent, but it's pinned
 		 * by the child dentry anyway.
-- 
1.8.3.1

