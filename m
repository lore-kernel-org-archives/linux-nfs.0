Return-Path: <SRS0=BUwe=NB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4F4DCECDE44
	for <linux-nfs@archiver.kernel.org>; Sun, 21 Oct 2018 16:17:47 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 082CF2083A
	for <linux-nfs@archiver.kernel.org>; Sun, 21 Oct 2018 16:17:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="yagSBMWY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 082CF2083A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728084AbeJVAcf (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 21 Oct 2018 20:32:35 -0400
Received: from userp2130.oracle.com ([156.151.31.86]:41154 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727408AbeJVAce (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 21 Oct 2018 20:32:34 -0400
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
        by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w9LGEsJO154505;
        Sun, 21 Oct 2018 16:17:39 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : in-reply-to : references : mime-version :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=yAZ/1PPkeVRlAU93kCg6O9O78UCd/8KO5hoqJKQC2Ek=;
 b=yagSBMWYuvghMIqDYBJYaE6H6wiVG1maa0ILSahktUrXCAVGFzF7z3Nqu++roa+fCV5j
 hGZ+Ydqx6YJT9iohkXp+Ecco4aEAH5AorPqg3NRg6p9h0GCXba4vOM6BVt3GfQ1bwPuU
 KEiUfs8aveaXFDwmLUSeaO1av1gTy+rbDAuGXP32Mfw5RgLixtdYzGZAfzsN47y0V1fy
 vhJVrFSiB/ld1+rj1gxRGdpjSqHrjECvMi064pjwYfBDusiegL7SxJKIOhKEaKh1jP+q
 aIWcT0cZTk0tF8xPBg4094KAdh7NpdqXWDSiPRRvGU7si0kPT0xn2B8vqJ5aJdQXRo75 UQ== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
        by userp2130.oracle.com with ESMTP id 2n7ustu1v6-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Sun, 21 Oct 2018 16:17:39 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
        by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w9LGHckK014091
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Sun, 21 Oct 2018 16:17:38 GMT
Received: from abhmp0013.oracle.com (abhmp0013.oracle.com [141.146.116.19])
        by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w9LGHc1Z024863;
        Sun, 21 Oct 2018 16:17:38 GMT
Received: from localhost (/10.159.225.70)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Sun, 21 Oct 2018 09:17:38 -0700
Subject: [PATCH 22/28] ocfs2: remove ocfs2_reflink_remap_range
From:   "Darrick J. Wong" <darrick.wong@oracle.com>
To:     david@fromorbit.com, darrick.wong@oracle.com
Cc:     sandeen@redhat.com, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-xfs@vger.kernel.org, linux-mm@kvack.org,
        linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        ocfs2-devel@oss.oracle.com
Date:   Sun, 21 Oct 2018 09:17:36 -0700
Message-ID: <154013865665.29026.16826908431108353571.stgit@magnolia>
In-Reply-To: <154013850285.29026.16168387526580596209.stgit@magnolia>
References: <154013850285.29026.16168387526580596209.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9053 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1807170000 definitions=main-1810210151
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Darrick J. Wong <darrick.wong@oracle.com>

Since ocfs2_remap_file_range is a thin shell around
ocfs2_remap_remap_range, move everything from the latter into the
former.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 fs/ocfs2/file.c         |   68 +++++++++++++++++++++++++++-
 fs/ocfs2/refcounttree.c |  113 +++++++----------------------------------------
 fs/ocfs2/refcounttree.h |   24 +++++++---
 3 files changed, 102 insertions(+), 103 deletions(-)


diff --git a/fs/ocfs2/file.c b/fs/ocfs2/file.c
index 8125c5ccf821..fe570824b991 100644
--- a/fs/ocfs2/file.c
+++ b/fs/ocfs2/file.c
@@ -2531,11 +2531,75 @@ static loff_t ocfs2_remap_file_range(struct file *file_in, loff_t pos_in,
 				     struct file *file_out, loff_t pos_out,
 				     loff_t len, unsigned int remap_flags)
 {
+	struct inode *inode_in = file_inode(file_in);
+	struct inode *inode_out = file_inode(file_out);
+	struct ocfs2_super *osb = OCFS2_SB(inode_in->i_sb);
+	struct buffer_head *in_bh = NULL, *out_bh = NULL;
+	bool same_inode = (inode_in == inode_out);
+	loff_t remapped = 0;
+	ssize_t ret;
+
 	if (remap_flags & ~(REMAP_FILE_DEDUP | REMAP_FILE_ADVISORY))
 		return -EINVAL;
+	if (!ocfs2_refcount_tree(osb))
+		return -EOPNOTSUPP;
+	if (ocfs2_is_hard_readonly(osb) || ocfs2_is_soft_readonly(osb))
+		return -EROFS;
 
-	return ocfs2_reflink_remap_range(file_in, pos_in, file_out, pos_out,
-			len, remap_flags);
+	/* Lock both files against IO */
+	ret = ocfs2_reflink_inodes_lock(inode_in, &in_bh, inode_out, &out_bh);
+	if (ret)
+		return ret;
+
+	/* Check file eligibility and prepare for block sharing. */
+	ret = -EINVAL;
+	if ((OCFS2_I(inode_in)->ip_flags & OCFS2_INODE_SYSTEM_FILE) ||
+	    (OCFS2_I(inode_out)->ip_flags & OCFS2_INODE_SYSTEM_FILE))
+		goto out_unlock;
+
+	ret = generic_remap_file_range_prep(file_in, pos_in, file_out, pos_out,
+			&len, remap_flags);
+	if (ret < 0 || len == 0)
+		goto out_unlock;
+
+	/* Lock out changes to the allocation maps and remap. */
+	down_write(&OCFS2_I(inode_in)->ip_alloc_sem);
+	if (!same_inode)
+		down_write_nested(&OCFS2_I(inode_out)->ip_alloc_sem,
+				  SINGLE_DEPTH_NESTING);
+
+	/* Zap any page cache for the destination file's range. */
+	truncate_inode_pages_range(&inode_out->i_data,
+				   round_down(pos_out, PAGE_SIZE),
+				   round_up(pos_out + len, PAGE_SIZE) - 1);
+
+	remapped = ocfs2_reflink_remap_blocks(inode_in, in_bh, pos_in,
+			inode_out, out_bh, pos_out, len);
+	up_write(&OCFS2_I(inode_in)->ip_alloc_sem);
+	if (!same_inode)
+		up_write(&OCFS2_I(inode_out)->ip_alloc_sem);
+	if (remapped < 0) {
+		ret = remapped;
+		mlog_errno(ret);
+		goto out_unlock;
+	}
+
+	/*
+	 * Empty the extent map so that we may get the right extent
+	 * record from the disk.
+	 */
+	ocfs2_extent_map_trunc(inode_in, 0);
+	ocfs2_extent_map_trunc(inode_out, 0);
+
+	ret = ocfs2_reflink_update_dest(inode_out, out_bh, pos_out + len);
+	if (ret) {
+		mlog_errno(ret);
+		goto out_unlock;
+	}
+
+out_unlock:
+	ocfs2_reflink_inodes_unlock(inode_in, in_bh, inode_out, out_bh);
+	return remapped > 0 ? remapped : ret;
 }
 
 const struct inode_operations ocfs2_file_iops = {
diff --git a/fs/ocfs2/refcounttree.c b/fs/ocfs2/refcounttree.c
index c7409578657b..dc66b80585ec 100644
--- a/fs/ocfs2/refcounttree.c
+++ b/fs/ocfs2/refcounttree.c
@@ -4468,9 +4468,9 @@ int ocfs2_reflink_ioctl(struct inode *inode,
 }
 
 /* Update destination inode size, if necessary. */
-static int ocfs2_reflink_update_dest(struct inode *dest,
-				     struct buffer_head *d_bh,
-				     loff_t newlen)
+int ocfs2_reflink_update_dest(struct inode *dest,
+			      struct buffer_head *d_bh,
+			      loff_t newlen)
 {
 	handle_t *handle;
 	int ret;
@@ -4621,13 +4621,13 @@ static loff_t ocfs2_reflink_remap_extent(struct inode *s_inode,
 }
 
 /* Set up refcount tree and remap s_inode to t_inode. */
-static loff_t ocfs2_reflink_remap_blocks(struct inode *s_inode,
-					 struct buffer_head *s_bh,
-					 loff_t pos_in,
-					 struct inode *t_inode,
-					 struct buffer_head *t_bh,
-					 loff_t pos_out,
-					 loff_t len)
+loff_t ocfs2_reflink_remap_blocks(struct inode *s_inode,
+				  struct buffer_head *s_bh,
+				  loff_t pos_in,
+				  struct inode *t_inode,
+				  struct buffer_head *t_bh,
+				  loff_t pos_out,
+				  loff_t len)
 {
 	struct ocfs2_cached_dealloc_ctxt dealloc;
 	struct ocfs2_super *osb;
@@ -4720,10 +4720,10 @@ static loff_t ocfs2_reflink_remap_blocks(struct inode *s_inode,
 }
 
 /* Lock an inode and grab a bh pointing to the inode. */
-static int ocfs2_reflink_inodes_lock(struct inode *s_inode,
-				     struct buffer_head **bh1,
-				     struct inode *t_inode,
-				     struct buffer_head **bh2)
+int ocfs2_reflink_inodes_lock(struct inode *s_inode,
+			      struct buffer_head **bh1,
+			      struct inode *t_inode,
+			      struct buffer_head **bh2)
 {
 	struct inode *inode1;
 	struct inode *inode2;
@@ -4808,10 +4808,10 @@ static int ocfs2_reflink_inodes_lock(struct inode *s_inode,
 }
 
 /* Unlock both inodes and release buffers. */
-static void ocfs2_reflink_inodes_unlock(struct inode *s_inode,
-					struct buffer_head *s_bh,
-					struct inode *t_inode,
-					struct buffer_head *t_bh)
+void ocfs2_reflink_inodes_unlock(struct inode *s_inode,
+				 struct buffer_head *s_bh,
+				 struct inode *t_inode,
+				 struct buffer_head *t_bh)
 {
 	ocfs2_inode_unlock(s_inode, 1);
 	ocfs2_rw_unlock(s_inode, 1);
@@ -4823,80 +4823,3 @@ static void ocfs2_reflink_inodes_unlock(struct inode *s_inode,
 	}
 	unlock_two_nondirectories(s_inode, t_inode);
 }
-
-/* Link a range of blocks from one file to another. */
-loff_t ocfs2_reflink_remap_range(struct file *file_in,
-				 loff_t pos_in,
-				 struct file *file_out,
-				 loff_t pos_out,
-				 loff_t len,
-				 unsigned int remap_flags)
-{
-	struct inode *inode_in = file_inode(file_in);
-	struct inode *inode_out = file_inode(file_out);
-	struct ocfs2_super *osb = OCFS2_SB(inode_in->i_sb);
-	struct buffer_head *in_bh = NULL, *out_bh = NULL;
-	bool same_inode = (inode_in == inode_out);
-	loff_t remapped = 0;
-	ssize_t ret;
-
-	if (!ocfs2_refcount_tree(osb))
-		return -EOPNOTSUPP;
-	if (ocfs2_is_hard_readonly(osb) || ocfs2_is_soft_readonly(osb))
-		return -EROFS;
-
-	/* Lock both files against IO */
-	ret = ocfs2_reflink_inodes_lock(inode_in, &in_bh, inode_out, &out_bh);
-	if (ret)
-		return ret;
-
-	/* Check file eligibility and prepare for block sharing. */
-	ret = -EINVAL;
-	if ((OCFS2_I(inode_in)->ip_flags & OCFS2_INODE_SYSTEM_FILE) ||
-	    (OCFS2_I(inode_out)->ip_flags & OCFS2_INODE_SYSTEM_FILE))
-		goto out_unlock;
-
-	ret = generic_remap_file_range_prep(file_in, pos_in, file_out, pos_out,
-			&len, remap_flags);
-	if (ret < 0 || len == 0)
-		goto out_unlock;
-
-	/* Lock out changes to the allocation maps and remap. */
-	down_write(&OCFS2_I(inode_in)->ip_alloc_sem);
-	if (!same_inode)
-		down_write_nested(&OCFS2_I(inode_out)->ip_alloc_sem,
-				  SINGLE_DEPTH_NESTING);
-
-	/* Zap any page cache for the destination file's range. */
-	truncate_inode_pages_range(&inode_out->i_data,
-				   round_down(pos_out, PAGE_SIZE),
-				   round_up(pos_out + len, PAGE_SIZE) - 1);
-
-	remapped = ocfs2_reflink_remap_blocks(inode_in, in_bh, pos_in,
-			inode_out, out_bh, pos_out, len);
-	up_write(&OCFS2_I(inode_in)->ip_alloc_sem);
-	if (!same_inode)
-		up_write(&OCFS2_I(inode_out)->ip_alloc_sem);
-	if (remapped < 0) {
-		ret = remapped;
-		mlog_errno(ret);
-		goto out_unlock;
-	}
-
-	/*
-	 * Empty the extent map so that we may get the right extent
-	 * record from the disk.
-	 */
-	ocfs2_extent_map_trunc(inode_in, 0);
-	ocfs2_extent_map_trunc(inode_out, 0);
-
-	ret = ocfs2_reflink_update_dest(inode_out, out_bh, pos_out + len);
-	if (ret) {
-		mlog_errno(ret);
-		goto out_unlock;
-	}
-
-out_unlock:
-	ocfs2_reflink_inodes_unlock(inode_in, in_bh, inode_out, out_bh);
-	return remapped > 0 ? remapped : ret;
-}
diff --git a/fs/ocfs2/refcounttree.h b/fs/ocfs2/refcounttree.h
index 9e64daba395d..e9e862be4a1e 100644
--- a/fs/ocfs2/refcounttree.h
+++ b/fs/ocfs2/refcounttree.h
@@ -115,11 +115,23 @@ int ocfs2_reflink_ioctl(struct inode *inode,
 			const char __user *oldname,
 			const char __user *newname,
 			bool preserve);
-loff_t ocfs2_reflink_remap_range(struct file *file_in,
-				 loff_t pos_in,
-				 struct file *file_out,
-				 loff_t pos_out,
-				 loff_t len,
-				 unsigned int remap_flags);
+loff_t ocfs2_reflink_remap_blocks(struct inode *s_inode,
+				  struct buffer_head *s_bh,
+				  loff_t pos_in,
+				  struct inode *t_inode,
+				  struct buffer_head *t_bh,
+				  loff_t pos_out,
+				  loff_t len);
+int ocfs2_reflink_inodes_lock(struct inode *s_inode,
+			      struct buffer_head **bh1,
+			      struct inode *t_inode,
+			      struct buffer_head **bh2);
+void ocfs2_reflink_inodes_unlock(struct inode *s_inode,
+				 struct buffer_head *s_bh,
+				 struct inode *t_inode,
+				 struct buffer_head *t_bh);
+int ocfs2_reflink_update_dest(struct inode *dest,
+			      struct buffer_head *d_bh,
+			      loff_t newlen);
 
 #endif /* OCFS2_REFCOUNTTREE_H */

