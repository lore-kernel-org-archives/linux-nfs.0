Return-Path: <SRS0=HHNt=NF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F284DC46475
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 21:51:55 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9A6D12082E
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 21:51:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RcMOsC95"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A6D12082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727582AbeJZG0R (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 26 Oct 2018 02:26:17 -0400
Received: from mail-qt1-f194.google.com ([209.85.160.194]:39016 "EHLO
        mail-qt1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727574AbeJZG0Q (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Oct 2018 02:26:16 -0400
Received: by mail-qt1-f194.google.com with SMTP id g10-v6so11789778qtq.6;
        Thu, 25 Oct 2018 14:51:52 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=VUF9SbP5j5MpasRdnLxwtcRSj5YNOPAQj4lFP7eSQgg=;
        b=RcMOsC95NnLniS7kKSyLYJNHcY+Hc6CqvEsQ5rHByi1ZdtVCAaDfm5q8rsacDDh1P+
         fmuue+mYDpGwrhyqB7z/5cJp1hC2/Yj2nIEanNxZtoerx1A5qJZGbsGQMwWxE+Hi7xge
         nyX06KHCwg06ZIgUjS8RAaBL3FKoXjhxFvpxZ/dG+zSJ963TryEkvpU/kxdhPmycWsyY
         tCaMhQ4Oq7X2TTbIzz3nQufKG0JgFdaegRoq+xTDNUW0jAew+mxBWczbcyjGVhBY2IIw
         s/ZBvTW1b9TyGwxo07MND8mf/t2wEinBDcGWy/4mdWLoYDLn1iC6tHC7lo4UAEwcCBW7
         LxqQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=VUF9SbP5j5MpasRdnLxwtcRSj5YNOPAQj4lFP7eSQgg=;
        b=MAqaK1RlwPDS5ZZK2/Y0DeRdXR3fyVkyrSoIlHqon70DzOg++pOttBGkRTvoQ0e/VV
         Eqd1J4QjVJHTHRyi82v3K1lE8P7a5fBZ2Dc4EoxBRmTeXVTwMF1wkk7JMnqU0CFQzFOC
         lM583PF3WngWtNzPIcwk3Ks+4NjbriPFkFQMDKp+tkBLcVFyDCmx9fxCCvo2wz28t9+T
         VIjJZRPmjnpiyuWN5Kku82rqGAKrLdI0VTUi5b0mRAiuL67cWwC0b0au7iVageEoghyJ
         pdEEVFvi7D5CSsjtIir5DjthZZNEwgUg7Vix4jRl8Q0vgtms9Ap9/GivjPwheus5+Y1a
         ejoQ==
X-Gm-Message-State: AGRZ1gJgOfsKG6G1yMPOeOxlI6LnTRIgOomwpmnf0qHocKpGDEIVfDfr
        EPKef40MwbLfLkUoE1Jt0bQ=
X-Google-Smtp-Source: AJdET5dhCcULyPXNLOEb9SW5n/cdApv9BAmnFMxihyVCcictyq/2ykCkzvlPp53evHt3pVPOypsPeg==
X-Received: by 2002:ac8:4541:: with SMTP id z1-v6mr923665qtn.79.1540504311615;
        Thu, 25 Oct 2018 14:51:51 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id p64-v6sm5895927qkc.96.2018.10.25.14.51.50
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 Oct 2018 14:51:51 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v3 01/11] VFS move cross device copy_file_range() check into filesystems
Date:   Thu, 25 Oct 2018 17:51:36 -0400
Message-Id: <20181025215147.36248-2-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181025215147.36248-1-olga.kornievskaia@gmail.com>
References: <20181025215147.36248-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

This patch removes the check for source and destination files to
come from the same superblock. This feature was of interest to
NFS as well as CIFS communities.

Specifically, this feature is needed to allow for NFSv4.2 copy offload
to be done between different NFSv4.2 servers. SMBv3 copy offload between
different servers would be able to use this as well.

Removal of the check implies that passed in source and destination
files can come from different superblocks of the same file system
type or different. It is upto each individual copy_file_range()
file system implementation to decide what type of copy it is
capable of doing and return -EXDEV in cases support is lacking.

There are 3 known implementator of copy_file_range() f_op: NFS,
CIFS, OverlayFS. Adding appropriate checks to each of those file systems.
When appropriate each file system will remove/replace those checks.

If the copy_file_range() errors with EXDEV, the code would fallback
on doing do_splice_direct() copying which in itself is beneficial.

Adding wording to the vfs.txt and porting documentation about the
new support for cross-device copy offload.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 Documentation/filesystems/porting | 7 +++++++
 Documentation/filesystems/vfs.txt | 6 +++++-
 fs/cifs/cifsfs.c                  | 2 ++
 fs/nfs/nfs4file.c                 | 3 +++
 fs/overlayfs/file.c               | 3 +++
 fs/read_write.c                   | 9 +++------
 6 files changed, 23 insertions(+), 7 deletions(-)

diff --git a/Documentation/filesystems/porting b/Documentation/filesystems/porting
index 7b7b845..ebb4954 100644
--- a/Documentation/filesystems/porting
+++ b/Documentation/filesystems/porting
@@ -622,3 +622,10 @@ in your dentry operations instead.
 	alloc_file_clone(file, flags, ops) does not affect any caller's references.
 	On success you get a new struct file sharing the mount/dentry with the
 	original, on failure - ERR_PTR().
+--
+[mandatory]
+	->copy_file_range() may now be passed files which belong to two
+	different superblocks of the same file system type or which belong
+	to two different filesystems types all together. As before, the
+        destination's copy_file_range() is the function which is called.
+	If it cannot copy ranges from the source, it should return -EXDEV.
diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
index a6c6a8a..34c0e8c 100644
--- a/Documentation/filesystems/vfs.txt
+++ b/Documentation/filesystems/vfs.txt
@@ -1,5 +1,6 @@
 
 	      Overview of the Linux Virtual File System
+- [fs] nfs: Don't let readdirplus revalidate an inode that was marked as stale (Benjamin Coddington) [1429514 1416532]
 
 	Original author: Richard Gooch <rgooch@atnf.csiro.au>
 
@@ -958,7 +959,10 @@ otherwise noted.
 
   fallocate: called by the VFS to preallocate blocks or punch a hole.
 
-  copy_file_range: called by the copy_file_range(2) system call.
+  copy_file_range: called by copy_file_range(2) system call. This method
+		   works on two file descriptors that might reside on
+		   different superblocks which might belong to file systems
+		   of different types.
 
   clone_file_range: called by the ioctl(2) system call for FICLONERANGE and
 	FICLONE commands.
diff --git a/fs/cifs/cifsfs.c b/fs/cifs/cifsfs.c
index 7065426..1f41e74 100644
--- a/fs/cifs/cifsfs.c
+++ b/fs/cifs/cifsfs.c
@@ -1114,6 +1114,8 @@ static ssize_t cifs_copy_file_range(struct file *src_file, loff_t off,
 	unsigned int xid = get_xid();
 	ssize_t rc;
 
+	if (src_file->f_inode->i_sb != dst_file->f_inode->i_sb)
+		return -EXDEV;
 	rc = cifs_file_copychunk_range(xid, src_file, off, dst_file, destoff,
 					len, flags);
 	free_xid(xid);
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 4288a6e..09df688 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -135,6 +135,9 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
 {
 	ssize_t ret;
 
+	if (file_in->f_inode->i_sb != file_out->f_inode->i_sb)
+		return -EXDEV;
+
 	if (file_inode(file_in) == file_inode(file_out))
 		return -EINVAL;
 retry:
diff --git a/fs/overlayfs/file.c b/fs/overlayfs/file.c
index aeaefd2..5282853 100644
--- a/fs/overlayfs/file.c
+++ b/fs/overlayfs/file.c
@@ -483,6 +483,9 @@ static ssize_t ovl_copy_file_range(struct file *file_in, loff_t pos_in,
 				   struct file *file_out, loff_t pos_out,
 				   size_t len, unsigned int flags)
 {
+	if (file_in->f_inode->i_sb != file_out->f_inode->i_sb)
+		return -EXDEV;
+
 	return ovl_copyfile(file_in, pos_in, file_out, pos_out, len, flags,
 			    OVL_COPY);
 }
diff --git a/fs/read_write.c b/fs/read_write.c
index 39b4a21..fb4ffca 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1575,10 +1575,6 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 	    (file_out->f_flags & O_APPEND))
 		return -EBADF;
 
-	/* this could be relaxed once a method supports cross-fs copies */
-	if (inode_in->i_sb != inode_out->i_sb)
-		return -EXDEV;
-
 	if (len == 0)
 		return 0;
 
@@ -1588,7 +1584,8 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 	 * Try cloning first, this is supported by more file systems, and
 	 * more efficient if both clone and copy are supported (e.g. NFS).
 	 */
-	if (file_in->f_op->clone_file_range) {
+	if (inode_in->i_sb == inode_out->i_sb &&
+			file_in->f_op->clone_file_range) {
 		ret = file_in->f_op->clone_file_range(file_in, pos_in,
 				file_out, pos_out, len);
 		if (ret == 0) {
@@ -1600,7 +1597,7 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 	if (file_out->f_op->copy_file_range) {
 		ret = file_out->f_op->copy_file_range(file_in, pos_in, file_out,
 						      pos_out, len, flags);
-		if (ret != -EOPNOTSUPP)
+		if (ret != -EOPNOTSUPP && ret != -EXDEV)
 			goto done;
 	}
 
-- 
1.8.3.1

