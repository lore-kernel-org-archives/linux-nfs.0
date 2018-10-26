Return-Path: <SRS0=VOvP=NG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 674D0ECDE46
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 20:11:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 29E0420824
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 20:11:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="my/jK8gJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 29E0420824
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727764AbeJ0EtZ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 27 Oct 2018 00:49:25 -0400
Received: from mail-qt1-f195.google.com ([209.85.160.195]:35992 "EHLO
        mail-qt1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726672AbeJ0EtZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Oct 2018 00:49:25 -0400
Received: by mail-qt1-f195.google.com with SMTP id u34-v6so2692925qth.3;
        Fri, 26 Oct 2018 13:11:01 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=JiUuu4yV/pzkBhnLczriTu4tikK4WzXAeZJ8xxEpL8g=;
        b=my/jK8gJVzFOreePzdy4OreKCrhiChiOz66gsfNz8oxl5SIWB6CpCH1vfXQliAw3K5
         bD+Bs2lZK0U5rnJYOctQZIelkM9/iyl0ETrrHAcmw64XwJMgK8MTBFuBY3fabrXBHaAN
         i3uNH/UHjMpR29c83YcYKYO8Ko0oOJRhRmG0X+tZVlKuwIcEcoTghY5NxB7chM8cqyLD
         UCwHnUjaCeTHJmQHar5xMAFPpGyTnqnEuGj2G/a0PKNhiDZ+SJtXy9KSyeGCG59sKiS8
         tE2RKysasXZLnuqbUOyt6lg18t7sM3fQylGLo5wZ6RoP+y/aek+ABB7xf/HoUAjG7dy2
         kQ5A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=JiUuu4yV/pzkBhnLczriTu4tikK4WzXAeZJ8xxEpL8g=;
        b=n+VaJlaq/uvnyGILSzKWhLNTgqtZQqcHkG9oSZW99vL4bjmezM7BiPexCgYTEJYYsi
         yGL0IGe84eixzzoWMR6u5Xf51QQawRqvKHcO9W16HeEiFsmVgRp2wMivySXZSsU2kfJ2
         EIzgwVZapL56hRKHLUtNCRijAKcg2S3Wvr5HOjgGV7HHqL/Q+j5VoAmSyYn2seX+FMbL
         IDkRumskmPu8c+9JyE5zwDNILSXiZZi29zrj5yIDN6y6ugrpFwEbFPs4VC9lxGsiRMFj
         5AbIF+c0DT5JVVdKS+3/BVYrIzxmAMYUS+4dGSrYIB/M0eFIJx6AO7Tax0F/6zmVa52p
         LiLg==
X-Gm-Message-State: AGRZ1gII1N9zRd2waZgA5mWWBgv+1JE9xxJJL6mm9Rci8IxIChE2OPN0
        XPXN6GgyXW4UUAPivNhbbac=
X-Google-Smtp-Source: AJdET5fGTm8fnzoPFzfvks69JjfaNTtIAkguJTrU277z3z/4MfkafZCktGrQ0ufb+jiKzsXKGqeOXA==
X-Received: by 2002:a0c:98d1:: with SMTP id g17-v6mr4606124qvd.13.1540584660961;
        Fri, 26 Oct 2018 13:11:00 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id p64-v6sm8037667qkc.96.2018.10.26.13.10.59
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 26 Oct 2018 13:11:00 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v4 01/11] VFS: move cross device copy_file_range() check into filesystems
Date:   Fri, 26 Oct 2018 16:10:46 -0400
Message-Id: <20181026201057.36899-2-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181026201057.36899-1-olga.kornievskaia@gmail.com>
References: <20181026201057.36899-1-olga.kornievskaia@gmail.com>
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
if cross device copies aren't supported, causing the VFS to fall back
on using do_splice_direct().

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 Documentation/filesystems/porting | 7 +++++++
 fs/cifs/cifsfs.c                  | 3 +++
 fs/nfs/nfs4file.c                 | 3 +++
 fs/overlayfs/file.c               | 3 +++
 fs/read_write.c                   | 9 +++------
 5 files changed, 19 insertions(+), 6 deletions(-)

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
index 7065426..f2d7f4f 100644
--- a/fs/cifs/cifsfs.c
+++ b/fs/cifs/cifsfs.c
@@ -1114,6 +1114,9 @@ static ssize_t cifs_copy_file_range(struct file *src_file, loff_t off,
 	unsigned int xid = get_xid();
 	ssize_t rc;
 
+	if (src_file->f_inode->i_sb != dst_file->f_inode->i_sb)
+		return -EXDEV;
+
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

