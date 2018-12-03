Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1128CC65BAE
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 08:34:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CD20520851
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 08:34:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD20520851
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725928AbeLCIea (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 Dec 2018 03:34:30 -0500
Received: from ipmailnode02.adl6.internode.on.net ([150.101.137.148]:60959
        "EHLO ipmailnode02.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1725913AbeLCIe3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Dec 2018 03:34:29 -0500
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail02.adl6.internode.on.net with ESMTP; 03 Dec 2018 19:04:19 +1030
Received: from discord.disaster.area ([192.168.1.111])
        by dastard with esmtp (Exim 4.80)
        (envelope-from <david@fromorbit.com>)
        id 1gTjgJ-0003PT-06; Mon, 03 Dec 2018 19:34:19 +1100
Received: from dave by discord.disaster.area with local (Exim 4.91)
        (envelope-from <david@fromorbit.com>)
        id 1gTjgI-000060-VF; Mon, 03 Dec 2018 19:34:18 +1100
From:   Dave Chinner <david@fromorbit.com>
To:     linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org
Cc:     olga.kornievskaia@gmail.com, linux-nfs@vger.kernel.org,
        linux-unionfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org
Subject: [PATCH 03/11] vfs: no fallback for ->copy_file_range
Date:   Mon,  3 Dec 2018 19:34:08 +1100
Message-Id: <20181203083416.28978-4-david@fromorbit.com>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20181203083416.28978-1-david@fromorbit.com>
References: <20181203083416.28978-1-david@fromorbit.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Dave Chinner <dchinner@redhat.com>

Now that we have generic_copy_file_range(), remove it as a fallback
case when offloads fail. This puts the responsibility for executing
fallbacks on the filesystems that implement ->copy_file_range and
allows us to add operational validity checks to
generic_copy_file_range().

Rework vfs_copy_file_range() to call a new do_copy_file_range()
helper to exceute the copying callout, and move calls to
generic_file_copy_range() into filesystem methods where they
currently return failures.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/ceph/file.c      | 17 ++++++++++++++++-
 fs/cifs/cifsfs.c    |  4 ++++
 fs/fuse/file.c      | 17 ++++++++++++++++-
 fs/nfs/nfs4file.c   |  4 ++++
 fs/overlayfs/file.c |  9 ++++++++-
 fs/read_write.c     | 24 +++++++++++++++---------
 6 files changed, 63 insertions(+), 12 deletions(-)

diff --git a/fs/ceph/file.c b/fs/ceph/file.c
index 189df668b6a0..cf29f0410dcb 100644
--- a/fs/ceph/file.c
+++ b/fs/ceph/file.c
@@ -1885,7 +1885,7 @@ static int is_file_size_ok(struct inode *src_inode, struct inode *dst_inode,
 	return 0;
 }
 
-static ssize_t ceph_copy_file_range(struct file *src_file, loff_t src_off,
+static ssize_t __ceph_copy_file_range(struct file *src_file, loff_t src_off,
 				    struct file *dst_file, loff_t dst_off,
 				    size_t len, unsigned int flags)
 {
@@ -2096,6 +2096,21 @@ static ssize_t ceph_copy_file_range(struct file *src_file, loff_t src_off,
 	return ret;
 }
 
+static ssize_t ceph_copy_file_range(struct file *src_file, loff_t src_off,
+				    struct file *dst_file, loff_t dst_off,
+				    size_t len, unsigned int flags)
+{
+	ssize_t ret;
+
+	ret = __ceph_copy_file_range(src_file, src_off, dst_file, dst_off,
+					len, flags);
+
+	if (ret == -EOPNOTSUPP)
+		ret = generic_copy_file_range(src_file, src_off, dst_file,
+					dst_off, len, flags);
+	return ret;
+}
+
 const struct file_operations ceph_file_fops = {
 	.open = ceph_open,
 	.release = ceph_release,
diff --git a/fs/cifs/cifsfs.c b/fs/cifs/cifsfs.c
index 865706edb307..5ef4baec6234 100644
--- a/fs/cifs/cifsfs.c
+++ b/fs/cifs/cifsfs.c
@@ -1141,6 +1141,10 @@ static ssize_t cifs_copy_file_range(struct file *src_file, loff_t off,
 	rc = cifs_file_copychunk_range(xid, src_file, off, dst_file, destoff,
 					len, flags);
 	free_xid(xid);
+
+	if (rc == -EOPNOTSUPP)
+		rc = generic_copy_file_range(src_file, off, dst_file,
+					destoff, len, flags);
 	return rc;
 }
 
diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index b52f9baaa3e7..b86fb0298739 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -3024,7 +3024,7 @@ static long fuse_file_fallocate(struct file *file, int mode, loff_t offset,
 	return err;
 }
 
-static ssize_t fuse_copy_file_range(struct file *file_in, loff_t pos_in,
+static ssize_t __fuse_copy_file_range(struct file *file_in, loff_t pos_in,
 				    struct file *file_out, loff_t pos_out,
 				    size_t len, unsigned int flags)
 {
@@ -3100,6 +3100,21 @@ static ssize_t fuse_copy_file_range(struct file *file_in, loff_t pos_in,
 	return err;
 }
 
+static ssize_t fuse_copy_file_range(struct file *src_file, loff_t src_off,
+				    struct file *dst_file, loff_t dst_off,
+				    size_t len, unsigned int flags)
+{
+	ssize_t ret;
+
+	ret = __fuse_copy_file_range(src_file, src_off, dst_file, dst_off,
+					len, flags);
+
+	if (ret == -EOPNOTSUPP)
+		ret = generic_copy_file_range(src_file, src_off, dst_file,
+					dst_off, len, flags);
+	return ret;
+}
+
 static const struct file_operations fuse_file_operations = {
 	.llseek		= fuse_file_llseek,
 	.read_iter	= fuse_file_read_iter,
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 46d691ba04bc..d7766a6eb0f4 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -141,6 +141,10 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
 	ret = nfs42_proc_copy(file_in, pos_in, file_out, pos_out, count);
 	if (ret == -EAGAIN)
 		goto retry;
+
+	if (ret == -EOPNOTSUPP)
+		ret = generic_copy_file_range(file_in, pos_in, file_out,
+					pos_out, count, flags);
 	return ret;
 }
 
diff --git a/fs/overlayfs/file.c b/fs/overlayfs/file.c
index 84dd957efa24..68736e5d6a56 100644
--- a/fs/overlayfs/file.c
+++ b/fs/overlayfs/file.c
@@ -486,8 +486,15 @@ static ssize_t ovl_copy_file_range(struct file *file_in, loff_t pos_in,
 				   struct file *file_out, loff_t pos_out,
 				   size_t len, unsigned int flags)
 {
-	return ovl_copyfile(file_in, pos_in, file_out, pos_out, len, flags,
+	ssize_t ret;
+
+	ret =  ovl_copyfile(file_in, pos_in, file_out, pos_out, len, flags,
 			    OVL_COPY);
+
+	if (ret == -EOPNOTSUPP)
+		ret = generic_copy_file_range(file_in, pos_in, file_out,
+					pos_out, len, flags);
+	return ret;
 }
 
 static loff_t ovl_remap_file_range(struct file *file_in, loff_t pos_in,
diff --git a/fs/read_write.c b/fs/read_write.c
index 50114694c98b..44339b44accc 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1570,6 +1570,18 @@ ssize_t generic_copy_file_range(struct file *file_in, loff_t pos_in,
 }
 EXPORT_SYMBOL(generic_copy_file_range);
 
+static ssize_t do_copy_file_range(struct file *file_in, loff_t pos_in,
+			    struct file *file_out, loff_t pos_out,
+			    size_t len, unsigned int flags)
+{
+	if (file_out->f_op->copy_file_range)
+		return file_out->f_op->copy_file_range(file_in, pos_in, file_out,
+						      pos_out, len, flags);
+
+	return generic_copy_file_range(file_in, &pos_in, file_out, &pos_out,
+					len, flags);
+}
+
 /*
  * copy_file_range() differs from regular file read and write in that it
  * specifically allows return partial success.  When it does so is up to
@@ -1634,15 +1646,9 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 		}
 	}
 
-	if (file_out->f_op->copy_file_range) {
-		ret = file_out->f_op->copy_file_range(file_in, pos_in, file_out,
-						      pos_out, len, flags);
-		if (ret != -EOPNOTSUPP)
-			goto done;
-	}
-
-	ret = generic_copy_file_range(file_in, &pos_in, file_out, &pos_out,
-					len, flags);
+	ret = do_copy_file_range(file_in, pos_in, file_out, pos_out, len,
+				flags);
+	WARN_ON_ONCE(ret == -EOPNOTSUPP);
 done:
 	if (ret > 0) {
 		fsnotify_access(file_in);
-- 
2.19.1

