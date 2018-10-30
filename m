Return-Path: <SRS0=cX4g=NK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3269AC6786F
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 20:56:29 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DA39C2080A
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 20:56:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="PBO8fsG5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA39C2080A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726723AbeJaFvb (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 31 Oct 2018 01:51:31 -0400
Received: from mail-qt1-f195.google.com ([209.85.160.195]:40549 "EHLO
        mail-qt1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726005AbeJaFvb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Oct 2018 01:51:31 -0400
Received: by mail-qt1-f195.google.com with SMTP id k12so9401463qtf.7;
        Tue, 30 Oct 2018 13:56:26 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=xf4FnrHcgBJlod1T6CFfI+ZNKQfM2kBPZpTDX2oetmI=;
        b=PBO8fsG5ppvF19ITVtAjmqfP/q74WCFeYGtor7xr8Q0ViVIB7A8QhDz3QUstkg/lhP
         Z2ipS5B3z1vy18CUqnkCc+SqSy82/LtIYi23ESWrusN8BND3xR/xm99n83wgh54DxhIS
         xNwzAUyY+8jwxWzJX77we38hdYZ93eqTz+4AzAOmJQWJ8FlcOy3YppQPPSyXtNzu2S6G
         kZ+dNoxPi1cAPRaX0twRYqUatyz/5eZgSKRlmOrU5vHtpRlh9B1hJpQqzHiS1V07wwTe
         nYB5ySIFA6uW6w5Wp8R/ZCsgvhnvQa925EzNuPG4i2zJgUpaHfWs51se7BXuelxvWqQT
         UNIA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=xf4FnrHcgBJlod1T6CFfI+ZNKQfM2kBPZpTDX2oetmI=;
        b=tvuMe6QCDj4MHa6DJl/ktzf4Kb2/Rc4+q/MSdH0/OpCuV6ernp3Ubb988khOomFvUp
         WoegtPM4biEfbJyr5vQ3BTs3au4OKmsz6g6v6eLS4sbyBHKd2R2SJFE1Ayhi0LGB5FLp
         t864rsv2LKgBZ5mhvMw0uWoI+xGQMLHoDmNfxocMmGXn6HJtDmgDx587P3AUxzWJXoFw
         ElpK6b/DsZkCJZTNcEGFM9F1hjFYLsgZunpcGL9eiXVTTK91tTUfWHyWM5wkXaqgKnjh
         K+ZWFCOvfUwxg47i1iTetf9nR1J5TuRcbhK8sz0ii87DTiQ0vZIqMbyZDBxdU/fVl4US
         bTIA==
X-Gm-Message-State: AGRZ1gJ74ej8Vuaj5QuIlPPRfitabDSnVVcbUNJLtogeQY2Lg+vasSX3
        deCmMvt25RD6eSDYYTX0F2k=
X-Google-Smtp-Source: AJdET5e2MoRylB5NHdI+TG8Xl8qj7D74y7kmvJtjt5s4l3Z4abb5sdUAgiUP1fNTaFvICyMckYmZoA==
X-Received: by 2002:ac8:8ea:: with SMTP id y39-v6mr291841qth.3.1540932985853;
        Tue, 30 Oct 2018 13:56:25 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id i11-v6sm23478157qtc.96.2018.10.30.13.56.24
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 30 Oct 2018 13:56:25 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v7 01/11] VFS: move cross device copy_file_range() check into filesystems
Date:   Tue, 30 Oct 2018 16:56:03 -0400
Message-Id: <20181030205614.40754-2-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181030205614.40754-1-olga.kornievskaia@gmail.com>
References: <20181030205614.40754-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

This patch makes it the responsibility of individual filesystems to
allow or deny cross device copies.  Both NFS and CIFS have operations
for cross-server copies, and later patches will implement this feature.

Note that as of this patch, the copy_file_range() function might be passed
superblocks from different filesystem types. -EXDEV should be returned
if cross device copies aren't supported.

Reviewed-by: Amir Goldstein <amir73il@gmail.com>
Reviewed-by: Matthew Wilcox <willy@infradead.org>
Reviewed-by: Steve French <stfrench@microsoft.com>
Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 Documentation/filesystems/porting |  7 +++++++
 fs/cifs/cifsfs.c                  |  3 +++
 fs/nfs/nfs4file.c                 |  3 +++
 fs/overlayfs/file.c               |  3 +++
 fs/read_write.c                   | 12 +++++++-----
 5 files changed, 23 insertions(+), 5 deletions(-)

diff --git a/Documentation/filesystems/porting b/Documentation/filesystems/porting
index 7b7b845..897e1e7 100644
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
+	destination's copy_file_range() is the function which is called.
+	If it cannot copy ranges from the source, it should return -EXDEV.
diff --git a/fs/cifs/cifsfs.c b/fs/cifs/cifsfs.c
index 7065426..ca8fc87 100644
--- a/fs/cifs/cifsfs.c
+++ b/fs/cifs/cifsfs.c
@@ -1114,6 +1114,9 @@ static ssize_t cifs_copy_file_range(struct file *src_file, loff_t off,
 	unsigned int xid = get_xid();
 	ssize_t rc;
 
+	if (file_inode(src_file)->i_sb != file_inode(dst_file)->i_sb)
+		return -EXDEV;
+
 	rc = cifs_file_copychunk_range(xid, src_file, off, dst_file, destoff,
 					len, flags);
 	free_xid(xid);
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 4288a6e..5a73c90 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -135,6 +135,9 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
 {
 	ssize_t ret;
 
+	if (file_inode(file_in)->i_sb != file_inode(file_out)->i_sb)
+		return -EXDEV;
+
 	if (file_inode(file_in) == file_inode(file_out))
 		return -EINVAL;
 retry:
diff --git a/fs/overlayfs/file.c b/fs/overlayfs/file.c
index aeaefd2..0331e33 100644
--- a/fs/overlayfs/file.c
+++ b/fs/overlayfs/file.c
@@ -483,6 +483,9 @@ static ssize_t ovl_copy_file_range(struct file *file_in, loff_t pos_in,
 				   struct file *file_out, loff_t pos_out,
 				   size_t len, unsigned int flags)
 {
+	if (file_inode(file_in)->i_sb != file_inode(file_out)->i_sb)
+		return -EXDEV;
+
 	return ovl_copyfile(file_in, pos_in, file_out, pos_out, len, flags,
 			    OVL_COPY);
 }
diff --git a/fs/read_write.c b/fs/read_write.c
index 39b4a21..c5bed2e 100644
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
+	    file_in->f_op->clone_file_range) {
 		ret = file_in->f_op->clone_file_range(file_in, pos_in,
 				file_out, pos_out, len);
 		if (ret == 0) {
@@ -1604,6 +1601,11 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 			goto done;
 	}
 
+	if (inode_in->i_sb != inode_out->i_sb) {
+		ret = -EXDEV;
+		goto done;
+	}
+
 	ret = do_splice_direct(file_in, &pos_in, file_out, &pos_out,
 			len > MAX_RW_COUNT ? MAX_RW_COUNT : len, 0);
 
-- 
1.8.3.1

