Return-Path: <SRS0=Ohau=NM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2FD98ECDE46
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 16:45:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id EB103205F4
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 16:45:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="nJnSADWt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB103205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726306AbeKBBtO (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 1 Nov 2018 21:49:14 -0400
Received: from mail-oi1-f196.google.com ([209.85.167.196]:41602 "EHLO
        mail-oi1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725959AbeKBBtN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Nov 2018 21:49:13 -0400
Received: by mail-oi1-f196.google.com with SMTP id y192-v6so1171741oie.8;
        Thu, 01 Nov 2018 09:45:28 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=D3mPgmHbHiAVGsyI4bEkuzcTi5NVNKrpZPNiRWNG42w=;
        b=nJnSADWtHaea4xdoEqPiHKDdKo+UwFyowPrZA14q84oVjCZXeo/Kk4gqGp9ZWYUsQL
         GPuoU20WdlYpbms4x7+XP2KUDKu+pweyzTdldRXjCm0iRDiEurBhtpmbWbXud9gfx5+n
         X2s34I0Y1moM01PfNNR6a/PbP9Y6Iv6BZ1dZssLoNBSiXEBy7uItZnujMAq0FUEnuADj
         DVY6ezV9N8OWgWHGh3VHxFtM7vTijNQhvpoDO5Z/tj+eVRlA3E+dkTES8wtBerU9lkr+
         hpwPwrBshQ+XeeA2BsXMZhJylSmUR/l3YLFsbnbJ1aFCyTaT/oIH4NsSNoExPUKGpsjQ
         A0Rw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=D3mPgmHbHiAVGsyI4bEkuzcTi5NVNKrpZPNiRWNG42w=;
        b=Cmf9CFfh6yh/sN5NouejtevK197q+7riYAgDw1JtMaMt7x37SUvo9x+cOqu75AkbLV
         FCCayf8AUMwkDIr7+QZFBPl0FefmqusHB1xCwPp9DL+O98PUKUGa7iYIf+jIwVrmWR/v
         gJ2zQFJQtdjfoiri8TI+YkjrgESah0B/hHhASgbpmS8gmwmxxD/F/w+E5vJdC6WTXZVL
         eoNYFHmjTcselrb8FftJtpxhMglm1rPhzaGYGYyirNcKwmsXKCyU+jccHSwks22HkBwM
         7R/NdNHqIw6cJjGdXEaGVVZXpO8mFRsGLfnpVAhQuU9JhiE7wJQr/8buvKrMDsKmT4PX
         QyhQ==
X-Gm-Message-State: AGRZ1gJrLh7Szq6UQCZh3Bs2kyYaVZ+jLiUufwoeEsFJFGKYO7B6aNNa
        LM38JjwDbeyjLjdJVGKGQL8=
X-Google-Smtp-Source: AJdET5flcJQYypKlGae0AXgLWqygjhBxsndGUO1dcmJN3R8Zz+/hXNcB6LN9jQeJFuvWIAQj0pHubg==
X-Received: by 2002:aca:ac90:: with SMTP id v138-v6mr1498862oie.70.1541090728444;
        Thu, 01 Nov 2018 09:45:28 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id r62-v6sm1834301oig.14.2018.11.01.09.45.27
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Nov 2018 09:45:27 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org
Subject: [PATCH v8 01/11] VFS: move cross device copy_file_range() check into filesystems
Date:   Thu,  1 Nov 2018 12:45:13 -0400
Message-Id: <20181101164523.41812-2-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181101164523.41812-1-olga.kornievskaia@gmail.com>
References: <20181101164523.41812-1-olga.kornievskaia@gmail.com>
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
 fs/read_write.c                   | 13 ++++++++-----
 5 files changed, 24 insertions(+), 5 deletions(-)

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
index 39b4a21..cfb1d10 100644
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
@@ -1604,6 +1601,12 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 			goto done;
 	}
 
+	/* this could be relaxed once generic cross fs support is added */
+	if (inode_in->i_sb != inode_out->i_sb) {
+		ret = -EXDEV;
+		goto done;
+	}
+
 	ret = do_splice_direct(file_in, &pos_in, file_out, &pos_out,
 			len > MAX_RW_COUNT ? MAX_RW_COUNT : len, 0);
 
-- 
1.8.3.1

