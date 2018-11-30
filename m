Return-Path: <SRS0=T1LL=OJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 285BBC04EB8
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 20:03:55 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DA55D2082F
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 20:03:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Q7wVQwPf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA55D2082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726245AbeLAHOR (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 1 Dec 2018 02:14:17 -0500
Received: from mail-oi1-f194.google.com ([209.85.167.194]:45306 "EHLO
        mail-oi1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725790AbeLAHOR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 1 Dec 2018 02:14:17 -0500
Received: by mail-oi1-f194.google.com with SMTP id b141so5749750oii.12;
        Fri, 30 Nov 2018 12:03:53 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=S2oPgo+TaTI6N0xr3S6Ve1tH4nozGA1RfIUTKrPc69I=;
        b=Q7wVQwPfN4tsjWN7wM81C4tzDe1wmgVDai0EYel9s41bCaU7iqCJlUWwHxcPRDvvWN
         jCb3F9x2xEo1qZIPZCmIVkGsnT/TBOYPb8NHUpm7e30cU+E+4KjKMxt2WHFlhOF0QMc8
         ptTMEfvRNsHXPgW6XAaDtp9xAkGB4TdGZpZwXGJtJRFX9b1jH16E938kQZjIaDe7+maY
         7DLAla41JUPC8iTZ4YLnsfvV6ArKR9Yl5u6XFXBxBF+xGxuhS2zX3BHZWzSe3I6akDRp
         UM9fW/xslgpoColH3IvRO15495GDv4ZSkZvZnwwpS7MHOvNQQqYhoy/FSVQnrXInoLKe
         yZew==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=S2oPgo+TaTI6N0xr3S6Ve1tH4nozGA1RfIUTKrPc69I=;
        b=dG5yuPNFQ+AmzCtVg59ZMHe9JczOYD3M4ny7jspLA+jdRK5yfurbk/yppVzFpHYb25
         xu5+zTKD9FQcuEucyS2/CyH9WNuRAcrQRevAUcGaU1myEa2DCtblOKCtn+CUquHsVriD
         cVieXtibSVy0t/EAdmM7liWS3wzDpegjufBu3zPT1bd3N0MQlOmAOV15hdGRqXN23UF8
         3SEo8rEHSeerhhlk4Sx6VP4ViBYA/+f+/LVTEeAKZNeqPV9CsN750aVlIeTChoPtux1c
         jGslUHkJdz2PfLlyy5uM3MYTPtIhT2Gn2GE2htZ5tEJUBKRTqvx1yweOBrrCTbq44CAj
         xPDg==
X-Gm-Message-State: AA+aEWYFzJlaVvEHa34XASU9+PendMNuDmBr+o3UwgVGwkg4VX8q1WA4
        mAPrygsCS8+SiCm5Ta0+7Ks=
X-Google-Smtp-Source: AFSGD/XpmDtMeLLAHDBIWy/Y0aXS51anUt/00yS5LBHETeMPBgcwxgX7Oyiyhot/uxrrqOMOCQv7ZQ==
X-Received: by 2002:a54:4581:: with SMTP id z1mr4304054oib.192.1543608232580;
        Fri, 30 Nov 2018 12:03:52 -0800 (PST)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id q10sm2065289otl.15.2018.11.30.12.03.50
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 30 Nov 2018 12:03:50 -0800 (PST)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     bfields@redhat.com
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: [PATCH v2 01/10] VFS generic copy_file_range() support
Date:   Fri, 30 Nov 2018 15:03:39 -0500
Message-Id: <20181130200348.59524-2-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181130200348.59524-1-olga.kornievskaia@gmail.com>
References: <20181130200348.59524-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Relax the condition that input files must be from the same
file systems.

Add checks that input parameters adhere semantics.

If no copy_file_range() support is found, then do generic
checks for the unsupported page cache ranges, LFS, limits,
and clear setuid/setgid if not running as root before calling
do_splice_direct(). Update atime,ctime,mtime afterwards.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/read_write.c    | 66 ++++++++++++++++++++++++++++++++++++++++++------------
 include/linux/fs.h |  7 ++++++
 mm/filemap.c       |  6 ++---
 3 files changed, 61 insertions(+), 18 deletions(-)

diff --git a/fs/read_write.c b/fs/read_write.c
index 7b9e59d..2d309b0 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1540,6 +1540,44 @@ static ssize_t do_sendfile(int out_fd, int in_fd, loff_t *ppos,
 }
 #endif
 
+ssize_t generic_copy_file_range(struct file *file_in, loff_t pos_in,
+				struct file *file_out, loff_t pos_out,
+				loff_t len, unsigned int flags)
+{
+	ssize_t ret;
+	loff_t size_in = i_size_read(file_inode(file_in)), count;
+
+	/* preform generic checks for unsupported page cache ranges, LFS
+	 * limits. If pos exceeds the limit, returns EFBIG
+	 */
+	count = min(len, size_in - pos_in);
+	ret = generic_access_check_limits(file_in, pos_in, &count);
+	if (ret)
+		goto done;
+	ret = generic_write_check_limits(file_out, pos_out, &count);
+	if (ret)
+		goto done;
+	/* If not running as root, clear setuid/setgid bits. This keeps
+	 * people from modifying setuid and setgid binaries.
+	 */
+	if (!IS_NOSEC(file_inode(file_out))) {
+		ret = file_remove_privs(file_out);
+		if (ret)
+			goto done;
+	}
+
+	ret = do_splice_direct(file_in, &pos_in, file_out, &pos_out,
+			count > MAX_RW_COUNT ? MAX_RW_COUNT : count, 0);
+
+	file_accessed(file_in);
+	if (!(file_out->f_mode & FMODE_NOCMTIME))
+		file_update_time(file_out);
+
+done:
+	return ret;
+}
+EXPORT_SYMBOL(generic_copy_file_range);
+
 /*
  * copy_file_range() differs from regular file read and write in that it
  * specifically allows return partial success.  When it does so is up to
@@ -1552,6 +1590,7 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 	struct inode *inode_in = file_inode(file_in);
 	struct inode *inode_out = file_inode(file_out);
 	ssize_t ret;
+	loff_t size_in;
 
 	if (flags != 0)
 		return -EINVAL;
@@ -1577,6 +1616,15 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 	if (len == 0)
 		return 0;
 
+	/* Ensure offsets don't wrap. */
+	if (pos_in + len < pos_in || pos_out + len < pos_out)
+		return -EINVAL;
+
+	size_in = i_size_read(inode_in);
+	/* Ensure that source range is within EOF. */
+	if (pos_in >= size_in || pos_in + len > size_in)
+		return -EINVAL;
+
 	file_start_write(file_out);
 
 	/*
@@ -1597,22 +1645,12 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 		}
 	}
 
-	if (file_out->f_op->copy_file_range) {
+	if (file_out->f_op->copy_file_range)
 		ret = file_out->f_op->copy_file_range(file_in, pos_in, file_out,
 						      pos_out, len, flags);
-		if (ret != -EOPNOTSUPP)
-			goto done;
-	}
-
-	/* this could be relaxed once generic cross fs support is added */
-	if (inode_in->i_sb != inode_out->i_sb) {
-		ret = -EXDEV;
-		goto done;
-	}
-
-	ret = do_splice_direct(file_in, &pos_in, file_out, &pos_out,
-			len > MAX_RW_COUNT ? MAX_RW_COUNT : len, 0);
-
+	else
+		ret = generic_copy_file_range(file_in, pos_in, file_out,
+					      pos_out, len, flags);
 done:
 	if (ret > 0) {
 		fsnotify_access(file_in);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index c95c080..c88ad09 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1874,6 +1874,9 @@ extern ssize_t vfs_readv(struct file *, const struct iovec __user *,
 		unsigned long, loff_t *, rwf_t);
 extern ssize_t vfs_copy_file_range(struct file *, loff_t , struct file *,
 				   loff_t, size_t, unsigned int);
+extern ssize_t generic_copy_file_range(struct file *file_int, loff_t pos_in,
+				       struct file *file_out, loff_t pos_out,
+				       loff_t len, unsigned int flags);
 extern int generic_remap_file_range_prep(struct file *file_in, loff_t pos_in,
 					 struct file *file_out, loff_t pos_out,
 					 loff_t *count,
@@ -3016,6 +3019,10 @@ static inline void remove_inode_hash(struct inode *inode)
 extern int generic_file_mmap(struct file *, struct vm_area_struct *);
 extern int generic_file_readonly_mmap(struct file *, struct vm_area_struct *);
 extern ssize_t generic_write_checks(struct kiocb *, struct iov_iter *);
+extern int generic_access_check_limits(struct file *file, loff_t pos,
+				       loff_t *count);
+extern int generic_write_check_limits(struct file *file, loff_t pos,
+				      loff_t *count);
 extern int generic_remap_checks(struct file *file_in, loff_t pos_in,
 				struct file *file_out, loff_t pos_out,
 				loff_t *count, unsigned int remap_flags);
diff --git a/mm/filemap.c b/mm/filemap.c
index 81adec8..894f3ae 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2829,8 +2829,7 @@ struct page *read_cache_page_gfp(struct address_space *mapping,
  * LFS limits.  If pos is under the limit it becomes a short access.  If it
  * exceeds the limit we return -EFBIG.
  */
-static int generic_access_check_limits(struct file *file, loff_t pos,
-				       loff_t *count)
+int generic_access_check_limits(struct file *file, loff_t pos, loff_t *count)
 {
 	struct inode *inode = file->f_mapping->host;
 	loff_t max_size = inode->i_sb->s_maxbytes;
@@ -2844,8 +2843,7 @@ static int generic_access_check_limits(struct file *file, loff_t pos,
 	return 0;
 }
 
-static int generic_write_check_limits(struct file *file, loff_t pos,
-				      loff_t *count)
+int generic_write_check_limits(struct file *file, loff_t pos, loff_t *count)
 {
 	loff_t limit = rlimit(RLIMIT_FSIZE);
 
-- 
1.8.3.1

