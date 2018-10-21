Return-Path: <SRS0=BUwe=NB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88A1AECDE44
	for <linux-nfs@archiver.kernel.org>; Sun, 21 Oct 2018 16:17:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4EB9D2083A
	for <linux-nfs@archiver.kernel.org>; Sun, 21 Oct 2018 16:17:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Q98qxZ3n"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4EB9D2083A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728000AbeJVAby (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 21 Oct 2018 20:31:54 -0400
Received: from aserp2120.oracle.com ([141.146.126.78]:42358 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727408AbeJVAby (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 21 Oct 2018 20:31:54 -0400
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
        by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w9LGE276154815;
        Sun, 21 Oct 2018 16:17:00 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : in-reply-to : references : mime-version :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=Tr6EshQsxOzbBBn5mCvIhaKvT953YPy/0dHgMvFh9q4=;
 b=Q98qxZ3neieJv3J3cs2XPbWOvcXhLJKXeNpgZCBxOx22q770V7OVZ54D45h6X2ZPDwbz
 WgvZ/30zQurCheMHXr8w0EfyLjtO/oAl/9ZfcVPzus+aMn2H4qvI3vJXbjW+4nbTAC1v
 QqXgW0E6Fo4sMTzDZZ4UvvNpVMBm7bBcHGmAzap9WAnUaQO+STEEVvcfXD+vXrmzMKAS
 aq0GSTpRm7tLbYqIH2kGU+cbSRdZdzX26jvtWFMTGJzo7FEFMP5JkwIZh4C1vOwXtGyX
 yveqz7oQ/QE6j08TtBLTffc/ZnlSENeaL9xS06Llth1zq5u7HsxfhsxbOTPcziAaf6Ck Sw== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
        by aserp2120.oracle.com with ESMTP id 2n7vapjyrk-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Sun, 21 Oct 2018 16:17:00 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
        by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w9LGGwYJ005994
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Sun, 21 Oct 2018 16:16:58 GMT
Received: from abhmp0006.oracle.com (abhmp0006.oracle.com [141.146.116.12])
        by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w9LGGvO0021301;
        Sun, 21 Oct 2018 16:16:57 GMT
Received: from localhost (/10.159.225.70)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Sun, 21 Oct 2018 09:16:57 -0700
Subject: [PATCH 16/28] vfs: enable remap callers that can handle short
 operations
From:   "Darrick J. Wong" <darrick.wong@oracle.com>
To:     david@fromorbit.com, darrick.wong@oracle.com
Cc:     sandeen@redhat.com, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>,
        linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org,
        linux-mm@kvack.org, linux-btrfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com
Date:   Sun, 21 Oct 2018 09:16:55 -0700
Message-ID: <154013861584.29026.5158930020192209258.stgit@magnolia>
In-Reply-To: <154013850285.29026.16168387526580596209.stgit@magnolia>
References: <154013850285.29026.16168387526580596209.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9053 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=759
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1807170000 definitions=main-1810210151
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Darrick J. Wong <darrick.wong@oracle.com>

Plumb in a remap flag that enables the filesystem remap handler to
shorten remapping requests for callers that can handle it.  Now
copy_file_range can report partial success (in case we run up against
alignment problems, resource limits, etc.).

We also enable CAN_SHORTEN for fideduperange to maintain existing
userspace-visible behavior where xfs/btrfs shorten the dedupe range to
avoid stale post-eof data exposure.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
Reviewed-by: Amir Goldstein <amir73il@gmail.com>
---
 Documentation/filesystems/vfs.txt |    4 +++-
 fs/read_write.c                   |   28 ++++++++++++++++++++--------
 include/linux/fs.h                |    5 +++--
 mm/filemap.c                      |   11 +++++++----
 4 files changed, 33 insertions(+), 15 deletions(-)


diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
index 1bd2919deaca..5f71a252e2e0 100644
--- a/Documentation/filesystems/vfs.txt
+++ b/Documentation/filesystems/vfs.txt
@@ -970,7 +970,9 @@ otherwise noted.
 	negative error code if errors occurred before any bytes were remapped.
 	The remap_flags parameter accepts REMAP_FILE_* flags.  If
 	REMAP_FILE_DEDUP is set then the implementation must only remap if the
-	requested file ranges have identical contents.
+	requested file ranges have identical contents.  If REMAP_CAN_SHORTEN is
+	set, the caller is ok with the implementation shortening the request
+	length to satisfy alignment or EOF requirements (or any other reason).
 
   fadvise: possibly called by the fadvise64() system call.
 
diff --git a/fs/read_write.c b/fs/read_write.c
index ea30666013b0..c0bcc1a20650 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1593,7 +1593,8 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 
 		cloned = file_in->f_op->remap_file_range(file_in, pos_in,
 				file_out, pos_out,
-				min_t(loff_t, MAX_RW_COUNT, len), 0);
+				min_t(loff_t, MAX_RW_COUNT, len),
+				REMAP_FILE_CAN_SHORTEN);
 		if (cloned > 0) {
 			ret = cloned;
 			goto done;
@@ -1721,6 +1722,8 @@ static int remap_verify_area(struct file *file, loff_t pos, loff_t len,
  * can't meaningfully compare post-EOF contents.
  *
  * For clone we only link a partial EOF block above the destination file's EOF.
+ *
+ * Shorten the request if possible.
  */
 static int generic_remap_check_len(struct inode *inode_in,
 				   struct inode *inode_out,
@@ -1729,16 +1732,24 @@ static int generic_remap_check_len(struct inode *inode_in,
 				   unsigned int remap_flags)
 {
 	u64 blkmask = i_blocksize(inode_in) - 1;
+	loff_t new_len = *len;
 
 	if ((*len & blkmask) == 0)
 		return 0;
 
-	if (remap_flags & REMAP_FILE_DEDUP)
-		*len &= ~blkmask;
-	else if (pos_out + *len < i_size_read(inode_out))
-		return -EINVAL;
+	if ((remap_flags & REMAP_FILE_DEDUP) ||
+	    pos_out + *len < i_size_read(inode_out))
+		new_len &= ~blkmask;
 
-	return 0;
+	if (new_len == *len)
+		return 0;
+
+	if (remap_flags & REMAP_FILE_CAN_SHORTEN) {
+		*len = new_len;
+		return 0;
+	}
+
+	return (remap_flags & REMAP_FILE_DEDUP) ? -EBADE : -EINVAL;
 }
 
 /*
@@ -2014,7 +2025,8 @@ loff_t vfs_dedupe_file_range_one(struct file *src_file, loff_t src_pos,
 {
 	loff_t ret;
 
-	WARN_ON_ONCE(remap_flags & ~(REMAP_FILE_DEDUP));
+	WARN_ON_ONCE(remap_flags & ~(REMAP_FILE_DEDUP |
+				     REMAP_FILE_CAN_SHORTEN));
 
 	ret = mnt_want_write_file(dst_file);
 	if (ret)
@@ -2115,7 +2127,7 @@ int vfs_dedupe_file_range(struct file *file, struct file_dedupe_range *same)
 
 		deduped = vfs_dedupe_file_range_one(file, off, dst_file,
 						    info->dest_offset, len,
-						    0);
+						    REMAP_FILE_CAN_SHORTEN);
 		if (deduped == -EBADE)
 			info->status = FILE_DEDUPE_RANGE_DIFFERS;
 		else if (deduped < 0)
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 544ab5083b48..34c22d695011 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1727,8 +1727,10 @@ struct block_device_operations;
  * See Documentation/filesystems/vfs.txt for more details about this call.
  *
  * REMAP_FILE_DEDUP: only remap if contents identical (i.e. deduplicate)
+ * REMAP_FILE_CAN_SHORTEN: caller can handle a shortened request
  */
 #define REMAP_FILE_DEDUP		(1 << 0)
+#define REMAP_FILE_CAN_SHORTEN		(1 << 1)
 
 /*
  * These flags signal that the caller is ok with altering various aspects of
@@ -1736,9 +1738,8 @@ struct block_device_operations;
  * implementation; the vfs remap helper functions can take advantage of them.
  * Flags in this category exist to preserve the quirky behavior of the hoisted
  * btrfs clone/dedupe ioctls.
- * There are no flags yet, but subsequent commits will add some.
  */
-#define REMAP_FILE_ADVISORY		(0)
+#define REMAP_FILE_ADVISORY		(REMAP_FILE_CAN_SHORTEN)
 
 struct iov_iter;
 
diff --git a/mm/filemap.c b/mm/filemap.c
index e9091d731f84..1775d4ad3317 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -3045,8 +3045,7 @@ int generic_remap_checks(struct file *file_in, loff_t pos_in,
 		bcount = ALIGN(size_in, bs) - pos_in;
 	} else {
 		if (!IS_ALIGNED(count, bs))
-			return -EINVAL;
-
+			count = ALIGN_DOWN(count, bs);
 		bcount = count;
 	}
 
@@ -3056,10 +3055,14 @@ int generic_remap_checks(struct file *file_in, loff_t pos_in,
 	    pos_out < pos_in + bcount)
 		return -EINVAL;
 
-	/* For now we don't support changing the length. */
-	if (*req_count != count)
+	/*
+	 * We shortened the request but the caller can't deal with that, so
+	 * bounce the request back to userspace.
+	 */
+	if (*req_count != count && !(remap_flags & REMAP_FILE_CAN_SHORTEN))
 		return -EINVAL;
 
+	*req_count = count;
 	return 0;
 }
 

