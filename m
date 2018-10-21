Return-Path: <SRS0=BUwe=NB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F56FECDE43
	for <linux-nfs@archiver.kernel.org>; Sun, 21 Oct 2018 16:18:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id F18782083A
	for <linux-nfs@archiver.kernel.org>; Sun, 21 Oct 2018 16:18:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="ROd2ev+m"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F18782083A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728128AbeJVAdM (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 21 Oct 2018 20:33:12 -0400
Received: from aserp2120.oracle.com ([141.146.126.78]:43270 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728077AbeJVAdM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 21 Oct 2018 20:33:12 -0400
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
        by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w9LGDwbr154742;
        Sun, 21 Oct 2018 16:18:18 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : in-reply-to : references : mime-version :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=16P3zwKvrT99XdZtAWDX1lXYkN0QjMaraaBIuWhVyNg=;
 b=ROd2ev+mZxl75lWILLTzcCuKZO2mY+XCRSmQFqyFIc+2vbDpwWKKRUKXu4D97V1IJFVU
 FUFpejsn3vWbH6KC0DS2DNApwu66BCJPKo2rs+ZFg6A4QSA178l3kQOmqrAgPyOdBnE1
 FV2n0QP+Xz322smHUV49IWSUIz8mqp+3UT11NhJpcXbHbeYfwNpMKePT9AJveHL+hfxB
 R/qWRZOyPdPOG95Tiix8j4G3p8cnjB9p5FRnsQ2JvFuAy5QTgOg8K3SDj0CqAX6Vs2Gd
 CMMgbhmbbxNyly2RSGuFprZB1wAxwOqEWeUUjcQ5jnY/kYiPvDimrMwW1fiV5MStVi9J bg== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
        by aserp2120.oracle.com with ESMTP id 2n7vapjysu-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Sun, 21 Oct 2018 16:18:18 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w9LGICh8011342
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Sun, 21 Oct 2018 16:18:12 GMT
Received: from abhmp0013.oracle.com (abhmp0013.oracle.com [141.146.116.19])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w9LGICQU019126;
        Sun, 21 Oct 2018 16:18:12 GMT
Received: from localhost (/10.159.225.70)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Sun, 21 Oct 2018 09:18:12 -0700
Subject: [PATCH 27/28] xfs: remove xfs_reflink_remap_range
From:   "Darrick J. Wong" <darrick.wong@oracle.com>
To:     david@fromorbit.com, darrick.wong@oracle.com
Cc:     sandeen@redhat.com, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-xfs@vger.kernel.org, linux-mm@kvack.org,
        linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        ocfs2-devel@oss.oracle.com
Date:   Sun, 21 Oct 2018 09:18:11 -0700
Message-ID: <154013869100.29026.7543087084546497731.stgit@magnolia>
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

Since xfs_file_remap_range is a thin wrapper, move the contents of
xfs_reflink_remap_range into the shell.  This cuts down on the vfs
calls being made from internal xfs code.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 fs/xfs/xfs_file.c    |   65 ++++++++++++++++++++++++++++++++++++++++------
 fs/xfs/xfs_reflink.c |   70 +++-----------------------------------------------
 fs/xfs/xfs_reflink.h |   10 +++++++
 3 files changed, 70 insertions(+), 75 deletions(-)


diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 7d42ab8fe6e1..53c9ab8fb777 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -919,20 +919,67 @@ xfs_file_fallocate(
 	return error;
 }
 
-STATIC loff_t
+
+loff_t
 xfs_file_remap_range(
-	struct file	*file_in,
-	loff_t		pos_in,
-	struct file	*file_out,
-	loff_t		pos_out,
-	loff_t		len,
-	unsigned int	remap_flags)
+	struct file		*file_in,
+	loff_t			pos_in,
+	struct file		*file_out,
+	loff_t			pos_out,
+	loff_t			len,
+	unsigned int		remap_flags)
 {
+	struct inode		*inode_in = file_inode(file_in);
+	struct xfs_inode	*src = XFS_I(inode_in);
+	struct inode		*inode_out = file_inode(file_out);
+	struct xfs_inode	*dest = XFS_I(inode_out);
+	struct xfs_mount	*mp = src->i_mount;
+	loff_t			remapped = 0;
+	xfs_extlen_t		cowextsize;
+	int			ret;
+
 	if (remap_flags & ~(REMAP_FILE_DEDUP | REMAP_FILE_ADVISORY))
 		return -EINVAL;
 
-	return xfs_reflink_remap_range(file_in, pos_in, file_out, pos_out,
-			len, remap_flags);
+	if (!xfs_sb_version_hasreflink(&mp->m_sb))
+		return -EOPNOTSUPP;
+
+	if (XFS_FORCED_SHUTDOWN(mp))
+		return -EIO;
+
+	/* Prepare and then clone file data. */
+	ret = xfs_reflink_remap_prep(file_in, pos_in, file_out, pos_out,
+			&len, remap_flags);
+	if (ret < 0 || len == 0)
+		return ret;
+
+	trace_xfs_reflink_remap_range(src, pos_in, len, dest, pos_out);
+
+	ret = xfs_reflink_remap_blocks(src, pos_in, dest, pos_out, len,
+			&remapped);
+	if (ret)
+		goto out_unlock;
+
+	/*
+	 * Carry the cowextsize hint from src to dest if we're sharing the
+	 * entire source file to the entire destination file, the source file
+	 * has a cowextsize hint, and the destination file does not.
+	 */
+	cowextsize = 0;
+	if (pos_in == 0 && len == i_size_read(inode_in) &&
+	    (src->i_d.di_flags2 & XFS_DIFLAG2_COWEXTSIZE) &&
+	    pos_out == 0 && len >= i_size_read(inode_out) &&
+	    !(dest->i_d.di_flags2 & XFS_DIFLAG2_COWEXTSIZE))
+		cowextsize = src->i_d.di_cowextsize;
+
+	ret = xfs_reflink_update_dest(dest, pos_out + len, cowextsize,
+			remap_flags);
+
+out_unlock:
+	xfs_reflink_remap_unlock(file_in, file_out);
+	if (ret)
+		trace_xfs_reflink_remap_range_error(dest, ret, _RET_IP_);
+	return remapped > 0 ? remapped : ret;
 }
 
 STATIC int
diff --git a/fs/xfs/xfs_reflink.c b/fs/xfs/xfs_reflink.c
index bccc66316cc4..84f372f7ea04 100644
--- a/fs/xfs/xfs_reflink.c
+++ b/fs/xfs/xfs_reflink.c
@@ -916,7 +916,7 @@ xfs_reflink_set_inode_flag(
 /*
  * Update destination inode size & cowextsize hint, if necessary.
  */
-STATIC int
+int
 xfs_reflink_update_dest(
 	struct xfs_inode	*dest,
 	xfs_off_t		newlen,
@@ -1116,7 +1116,7 @@ xfs_reflink_remap_extent(
 /*
  * Iteratively remap one file's extents (and holes) to another's.
  */
-STATIC int
+int
 xfs_reflink_remap_blocks(
 	struct xfs_inode	*src,
 	loff_t			pos_in,
@@ -1232,7 +1232,7 @@ xfs_iolock_two_inodes_and_break_layout(
 }
 
 /* Unlock both inodes after they've been prepped for a range clone. */
-STATIC void
+void
 xfs_reflink_remap_unlock(
 	struct file		*file_in,
 	struct file		*file_out)
@@ -1300,7 +1300,7 @@ xfs_reflink_zero_posteof(
  * stale data in the destination file. Hence we reject these clone attempts with
  * -EINVAL in this case.
  */
-STATIC int
+int
 xfs_reflink_remap_prep(
 	struct file		*file_in,
 	loff_t			pos_in,
@@ -1370,68 +1370,6 @@ xfs_reflink_remap_prep(
 	return ret;
 }
 
-/*
- * Link a range of blocks from one file to another.
- */
-loff_t
-xfs_reflink_remap_range(
-	struct file		*file_in,
-	loff_t			pos_in,
-	struct file		*file_out,
-	loff_t			pos_out,
-	loff_t			len,
-	unsigned int		remap_flags)
-{
-	struct inode		*inode_in = file_inode(file_in);
-	struct xfs_inode	*src = XFS_I(inode_in);
-	struct inode		*inode_out = file_inode(file_out);
-	struct xfs_inode	*dest = XFS_I(inode_out);
-	struct xfs_mount	*mp = src->i_mount;
-	loff_t			remapped = 0;
-	xfs_extlen_t		cowextsize;
-	int			ret;
-
-	if (!xfs_sb_version_hasreflink(&mp->m_sb))
-		return -EOPNOTSUPP;
-
-	if (XFS_FORCED_SHUTDOWN(mp))
-		return -EIO;
-
-	/* Prepare and then clone file data. */
-	ret = xfs_reflink_remap_prep(file_in, pos_in, file_out, pos_out,
-			&len, remap_flags);
-	if (ret < 0 || len == 0)
-		return ret;
-
-	trace_xfs_reflink_remap_range(src, pos_in, len, dest, pos_out);
-
-	ret = xfs_reflink_remap_blocks(src, pos_in, dest, pos_out, len,
-			&remapped);
-	if (ret)
-		goto out_unlock;
-
-	/*
-	 * Carry the cowextsize hint from src to dest if we're sharing the
-	 * entire source file to the entire destination file, the source file
-	 * has a cowextsize hint, and the destination file does not.
-	 */
-	cowextsize = 0;
-	if (pos_in == 0 && len == i_size_read(inode_in) &&
-	    (src->i_d.di_flags2 & XFS_DIFLAG2_COWEXTSIZE) &&
-	    pos_out == 0 && len >= i_size_read(inode_out) &&
-	    !(dest->i_d.di_flags2 & XFS_DIFLAG2_COWEXTSIZE))
-		cowextsize = src->i_d.di_cowextsize;
-
-	ret = xfs_reflink_update_dest(dest, pos_out + len, cowextsize,
-			remap_flags);
-
-out_unlock:
-	xfs_reflink_remap_unlock(file_in, file_out);
-	if (ret)
-		trace_xfs_reflink_remap_range_error(dest, ret, _RET_IP_);
-	return remapped > 0 ? remapped : ret;
-}
-
 /*
  * The user wants to preemptively CoW all shared blocks in this file,
  * which enables us to turn off the reflink flag.  Iterate all
diff --git a/fs/xfs/xfs_reflink.h b/fs/xfs/xfs_reflink.h
index cbc26ff79a8f..28a84edda889 100644
--- a/fs/xfs/xfs_reflink.h
+++ b/fs/xfs/xfs_reflink.h
@@ -36,5 +36,15 @@ extern int xfs_reflink_clear_inode_flag(struct xfs_inode *ip,
 		struct xfs_trans **tpp);
 extern int xfs_reflink_unshare(struct xfs_inode *ip, xfs_off_t offset,
 		xfs_off_t len);
+extern int xfs_reflink_remap_prep(struct file *file_in, loff_t pos_in,
+		struct file *file_out, loff_t pos_out, loff_t *len,
+		unsigned int remap_flags);
+extern int xfs_reflink_remap_blocks(struct xfs_inode *src, loff_t pos_in,
+		struct xfs_inode *dest, loff_t pos_out, loff_t remap_len,
+		loff_t *remapped);
+extern int xfs_reflink_update_dest(struct xfs_inode *dest, xfs_off_t newlen,
+		xfs_extlen_t cowextsize, unsigned int remap_flags);
+extern void xfs_reflink_remap_unlock(struct file *file_in,
+		struct file *file_out);
 
 #endif /* __XFS_REFLINK_H */

