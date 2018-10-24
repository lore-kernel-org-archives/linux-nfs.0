Return-Path: <SRS0=9d91=NE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7867ECDE46
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Oct 2018 19:59:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A907920832
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Oct 2018 19:59:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UfClAvfD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A907920832
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727167AbeJYE2J (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Oct 2018 00:28:09 -0400
Received: from mail-qt1-f196.google.com ([209.85.160.196]:37674 "EHLO
        mail-qt1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726264AbeJYE2I (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Oct 2018 00:28:08 -0400
Received: by mail-qt1-f196.google.com with SMTP id d14-v6so7108031qto.4;
        Wed, 24 Oct 2018 12:58:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=dlFL4npXT0g1RppdgdYI/CystWwtpVfsVcBHdAcJOKA=;
        b=UfClAvfD/Z/UQ27zoXkMd0a+JVVxVwpSCS3DYNx99Z3z31ieNt38rx/PFl6IO0VD5z
         10sXnoM7l38C13ZIBcypmMoFFDozSwVub7y2rvCBYxs98pVWbf7uyA3PXTkevhVTtrwJ
         efhXiCLBFrnw6R8sdmQjA1MXkpLu37SWMQPYgVGjCV+4jNa+kM9Hi+14O+l3mp2TJGQR
         oekdDBfJhAdYxeaPHxnxNHgV7XC081FA0cqnJ8iGrBBezzQeivVcCruYCNCptYelYGnS
         lmpUbDs0j4CvveDnhvaP6oil7uuoMsj1AdB/umQ/JM/Ywez1KVSsaiovcHwVIJK5EeIW
         5reQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=dlFL4npXT0g1RppdgdYI/CystWwtpVfsVcBHdAcJOKA=;
        b=nHRUbn/nDEQCwh/n8iY/lYIIkEiyrtdtw+gmROxf9v8ThmYad3B4Ii34Yl3iRBIfTR
         BRVXKYdWGO104z8/qQD8HpoOZgoMLe7Y9SaEH69NyGi/vDuGUwcBxkgo3LK3yRRAwiJ2
         MAOdhkDyaRehRg+cuyjkdQhHaYr369K7A8pMiz54E5UkZyOUMb9lKH2OMfe18J4+3IJc
         hMF2Joc8wmj8EquZdCGHvTWH4np+DDE2g26OhZZkuRDS49nzlCZgb//wS1GJBLfBqhFj
         0bglobUdjgV4v8ULZKCb3N8Ca4Mn4o5pfuz7fn7Xx8L8JkiY+B75imUGOt2+plPfGL38
         lQaA==
X-Gm-Message-State: AGRZ1gK22QcXjdqD9/oCcnUelySKqc+R8phdY8IcIq4aR9AKoSU80NL8
        HY4TTvTJZNVpnRsCp9nvvUg=
X-Google-Smtp-Source: AJdET5dnc7L3vszQz8CSbJWRBJw6F09QZz3ZTHPuXHl09N/H8drGK6gbNvwS88jbf53sIhanhZLp8A==
X-Received: by 2002:a0c:b211:: with SMTP id x17mr3758304qvd.153.1540411121739;
        Wed, 24 Oct 2018 12:58:41 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id d124-v6sm3872380qkf.85.2018.10.24.12.58.40
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 Oct 2018 12:58:41 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v2 01/13] VFS permit cross device vfs_copy_file_range
Date:   Wed, 24 Oct 2018 15:58:24 -0400
Message-Id: <20181024195837.35532-2-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181024195837.35532-1-olga.kornievskaia@gmail.com>
References: <20181024195837.35532-1-olga.kornievskaia@gmail.com>
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
CIFS, OverlayFS. NFS and CIFS are interested to support cross-device
copy offload but do not support cross file system types copy offload.
Following patches will add appropriate checks in each of the drivers.

If the copy_file_range() errors with EXDEV, the code would fallback
on doing do_splice_direct() copying which in itself is beneficial.

Adding wording to the vfs.txt and porting documentation about the
new support for cross-device copy offload.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 Documentation/filesystems/porting | 7 +++++++
 Documentation/filesystems/vfs.txt | 6 +++++-
 fs/read_write.c                   | 9 +++------
 3 files changed, 15 insertions(+), 7 deletions(-)

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

