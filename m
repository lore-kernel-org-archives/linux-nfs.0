Return-Path: <SRS0=BUwe=NB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5FD91ECDE45
	for <linux-nfs@archiver.kernel.org>; Sun, 21 Oct 2018 16:16:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 22F612083A
	for <linux-nfs@archiver.kernel.org>; Sun, 21 Oct 2018 16:16:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="NDxDrxgc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 22F612083A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728029AbeJVAbR (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 21 Oct 2018 20:31:17 -0400
Received: from aserp2120.oracle.com ([141.146.126.78]:41336 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727408AbeJVAbR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 21 Oct 2018 20:31:17 -0400
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
        by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w9LGFTEI155732;
        Sun, 21 Oct 2018 16:16:21 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : in-reply-to : references : mime-version :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=YES+b1E1OUbVKGgJYtK0FVRugzyHm2bJctiptn3YOO8=;
 b=NDxDrxgc8O8iv3G6KH0DvBNL2bnjf7lQwJXLV4KIIjLdkhblwr/ViGUoG01o69aMJFCs
 4c2v+NXaNx9AkI/LhGBN/84o/suRYEEd8g/0Eo3Cf1VsNarnhlax9PDdDSTFphePToGy
 CoPRhoWGZdqOaOd2+ecN1h0ZQNtZx+fXIxUXb6hpUhJtSL3PlH9gqSDgMCQR/Qf4z9/9
 jvuQHx5Krr5YrSERv3pp3Nj4Nk/HmAFvqovZBt3nFHBhzET3dP2eJWjIQOcF2MhEyVXe
 Pf1jnI5+SdTTqo5IyA0AJT1nF/8azq9JBoOC58ZEZnDrmMFoh1WT4EwABTERl3W+HfHM aA== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
        by aserp2120.oracle.com with ESMTP id 2n7vapjypy-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Sun, 21 Oct 2018 16:16:21 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
        by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w9LGGFPF008933
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Sun, 21 Oct 2018 16:16:16 GMT
Received: from abhmp0007.oracle.com (abhmp0007.oracle.com [141.146.116.13])
        by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w9LGGFfU021229;
        Sun, 21 Oct 2018 16:16:15 GMT
Received: from localhost (/10.159.225.70)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Sun, 21 Oct 2018 09:16:14 -0700
Subject: [PATCH 10/28] vfs: pass remap flags to generic_remap_file_range_prep
From:   "Darrick J. Wong" <darrick.wong@oracle.com>
To:     david@fromorbit.com, darrick.wong@oracle.com
Cc:     sandeen@redhat.com, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>,
        linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org,
        linux-mm@kvack.org, linux-btrfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>,
        ocfs2-devel@oss.oracle.com
Date:   Sun, 21 Oct 2018 09:16:13 -0700
Message-ID: <154013857305.29026.15904890974200543869.stgit@magnolia>
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

Plumb the remap flags through the filesystem from the vfs function
dispatcher all the way to the prep function to prepare for behavior
changes in subsequent patches.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
Reviewed-by: Amir Goldstein <amir73il@gmail.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/ocfs2/file.c         |    2 +-
 fs/ocfs2/refcounttree.c |    4 ++--
 fs/ocfs2/refcounttree.h |    2 +-
 fs/read_write.c         |   14 +++++++-------
 fs/xfs/xfs_file.c       |    2 +-
 fs/xfs/xfs_reflink.c    |   21 +++++++++++----------
 fs/xfs/xfs_reflink.h    |    3 ++-
 include/linux/fs.h      |    2 +-
 8 files changed, 26 insertions(+), 24 deletions(-)


diff --git a/fs/ocfs2/file.c b/fs/ocfs2/file.c
index 0b757a24567c..9809b0e5746f 100644
--- a/fs/ocfs2/file.c
+++ b/fs/ocfs2/file.c
@@ -2538,7 +2538,7 @@ static int ocfs2_remap_file_range(struct file *file_in,
 		return -EINVAL;
 
 	return ocfs2_reflink_remap_range(file_in, pos_in, file_out, pos_out,
-					 len, remap_flags & REMAP_FILE_DEDUP);
+					 len, remap_flags);
 }
 
 const struct inode_operations ocfs2_file_iops = {
diff --git a/fs/ocfs2/refcounttree.c b/fs/ocfs2/refcounttree.c
index 36c56dfbe485..df9781567ec0 100644
--- a/fs/ocfs2/refcounttree.c
+++ b/fs/ocfs2/refcounttree.c
@@ -4825,7 +4825,7 @@ int ocfs2_reflink_remap_range(struct file *file_in,
 			      struct file *file_out,
 			      loff_t pos_out,
 			      u64 len,
-			      bool is_dedupe)
+			      unsigned int remap_flags)
 {
 	struct inode *inode_in = file_inode(file_in);
 	struct inode *inode_out = file_inode(file_out);
@@ -4851,7 +4851,7 @@ int ocfs2_reflink_remap_range(struct file *file_in,
 		goto out_unlock;
 
 	ret = generic_remap_file_range_prep(file_in, pos_in, file_out, pos_out,
-			&len, is_dedupe);
+			&len, remap_flags);
 	if (ret <= 0)
 		goto out_unlock;
 
diff --git a/fs/ocfs2/refcounttree.h b/fs/ocfs2/refcounttree.h
index 4af55bf4b35b..d2c5f526edff 100644
--- a/fs/ocfs2/refcounttree.h
+++ b/fs/ocfs2/refcounttree.h
@@ -120,6 +120,6 @@ int ocfs2_reflink_remap_range(struct file *file_in,
 			      struct file *file_out,
 			      loff_t pos_out,
 			      u64 len,
-			      bool is_dedupe);
+			      unsigned int remap_flags);
 
 #endif /* OCFS2_REFCOUNTTREE_H */
diff --git a/fs/read_write.c b/fs/read_write.c
index 766bdcb381f3..201381689284 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1722,14 +1722,14 @@ static int generic_remap_check_len(struct inode *inode_in,
 				   struct inode *inode_out,
 				   loff_t pos_out,
 				   u64 *len,
-				   bool is_dedupe)
+				   unsigned int remap_flags)
 {
 	u64 blkmask = i_blocksize(inode_in) - 1;
 
 	if ((*len & blkmask) == 0)
 		return 0;
 
-	if (is_dedupe)
+	if (remap_flags & REMAP_FILE_DEDUP)
 		*len &= ~blkmask;
 	else if (pos_out + *len < i_size_read(inode_out))
 		return -EINVAL;
@@ -1747,7 +1747,7 @@ static int generic_remap_check_len(struct inode *inode_in,
  */
 int generic_remap_file_range_prep(struct file *file_in, loff_t pos_in,
 				  struct file *file_out, loff_t pos_out,
-				  u64 *len, bool is_dedupe)
+				  u64 *len, unsigned int remap_flags)
 {
 	struct inode *inode_in = file_inode(file_in);
 	struct inode *inode_out = file_inode(file_out);
@@ -1771,7 +1771,7 @@ int generic_remap_file_range_prep(struct file *file_in, loff_t pos_in,
 	if (*len == 0) {
 		loff_t isize = i_size_read(inode_in);
 
-		if (is_dedupe || pos_in == isize)
+		if ((remap_flags & REMAP_FILE_DEDUP) || pos_in == isize)
 			return 0;
 		if (pos_in > isize)
 			return -EINVAL;
@@ -1782,7 +1782,7 @@ int generic_remap_file_range_prep(struct file *file_in, loff_t pos_in,
 
 	/* Check that we don't violate system file offset limits. */
 	ret = generic_remap_checks(file_in, pos_in, file_out, pos_out, len,
-			is_dedupe);
+			(remap_flags & REMAP_FILE_DEDUP));
 	if (ret)
 		return ret;
 
@@ -1804,7 +1804,7 @@ int generic_remap_file_range_prep(struct file *file_in, loff_t pos_in,
 	/*
 	 * Check that the extents are the same.
 	 */
-	if (is_dedupe) {
+	if (remap_flags & REMAP_FILE_DEDUP) {
 		bool		is_same = false;
 
 		ret = vfs_dedupe_file_range_compare(inode_in, pos_in,
@@ -1816,7 +1816,7 @@ int generic_remap_file_range_prep(struct file *file_in, loff_t pos_in,
 	}
 
 	ret = generic_remap_check_len(inode_in, inode_out, pos_out, len,
-			is_dedupe);
+			remap_flags);
 	if (ret)
 		return ret;
 
diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 2ad94d508f80..20314eb4677a 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -932,7 +932,7 @@ xfs_file_remap_range(
 		return -EINVAL;
 
 	return xfs_reflink_remap_range(file_in, pos_in, file_out, pos_out,
-			len, remap_flags & REMAP_FILE_DEDUP);
+			len, remap_flags);
 }
 
 STATIC int
diff --git a/fs/xfs/xfs_reflink.c b/fs/xfs/xfs_reflink.c
index a7757a128a78..29aab196ce7e 100644
--- a/fs/xfs/xfs_reflink.c
+++ b/fs/xfs/xfs_reflink.c
@@ -921,13 +921,14 @@ xfs_reflink_update_dest(
 	struct xfs_inode	*dest,
 	xfs_off_t		newlen,
 	xfs_extlen_t		cowextsize,
-	bool			is_dedupe)
+	unsigned int		remap_flags)
 {
 	struct xfs_mount	*mp = dest->i_mount;
 	struct xfs_trans	*tp;
 	int			error;
 
-	if (is_dedupe && newlen <= i_size_read(VFS_I(dest)) && cowextsize == 0)
+	if ((remap_flags & REMAP_FILE_DEDUP) &&
+	    newlen <= i_size_read(VFS_I(dest)) && cowextsize == 0)
 		return 0;
 
 	error = xfs_trans_alloc(mp, &M_RES(mp)->tr_ichange, 0, 0, 0, &tp);
@@ -948,7 +949,7 @@ xfs_reflink_update_dest(
 		dest->i_d.di_flags2 |= XFS_DIFLAG2_COWEXTSIZE;
 	}
 
-	if (!is_dedupe) {
+	if (!(remap_flags & REMAP_FILE_DEDUP)) {
 		xfs_trans_ichgtime(tp, dest,
 				   XFS_ICHGTIME_MOD | XFS_ICHGTIME_CHG);
 	}
@@ -1296,7 +1297,7 @@ xfs_reflink_remap_prep(
 	struct file		*file_out,
 	loff_t			pos_out,
 	u64			*len,
-	bool			is_dedupe)
+	unsigned int		remap_flags)
 {
 	struct inode		*inode_in = file_inode(file_in);
 	struct xfs_inode	*src = XFS_I(inode_in);
@@ -1327,7 +1328,7 @@ xfs_reflink_remap_prep(
 		goto out_unlock;
 
 	ret = generic_remap_file_range_prep(file_in, pos_in, file_out, pos_out,
-			len, is_dedupe);
+			len, remap_flags);
 	if (ret <= 0)
 		goto out_unlock;
 
@@ -1336,7 +1337,7 @@ xfs_reflink_remap_prep(
 	 * from the source file so we don't try to dedupe the partial
 	 * EOF block.
 	 */
-	if (is_dedupe) {
+	if (remap_flags & REMAP_FILE_DEDUP) {
 		*len &= ~blkmask;
 	} else if (*len & blkmask) {
 		/*
@@ -1372,7 +1373,7 @@ xfs_reflink_remap_prep(
 				   PAGE_ALIGN(pos_out + *len) - 1);
 
 	/* If we're altering the file contents... */
-	if (!is_dedupe) {
+	if (!(remap_flags & REMAP_FILE_DEDUP)) {
 		/*
 		 * ...update the timestamps (which will grab the ilock again
 		 * from xfs_fs_dirty_inode, so we have to call it before we
@@ -1410,7 +1411,7 @@ xfs_reflink_remap_range(
 	struct file		*file_out,
 	loff_t			pos_out,
 	u64			len,
-	bool			is_dedupe)
+	unsigned int		remap_flags)
 {
 	struct inode		*inode_in = file_inode(file_in);
 	struct xfs_inode	*src = XFS_I(inode_in);
@@ -1430,7 +1431,7 @@ xfs_reflink_remap_range(
 
 	/* Prepare and then clone file data. */
 	ret = xfs_reflink_remap_prep(file_in, pos_in, file_out, pos_out,
-			&len, is_dedupe);
+			&len, remap_flags);
 	if (ret <= 0)
 		return ret;
 
@@ -1457,7 +1458,7 @@ xfs_reflink_remap_range(
 		cowextsize = src->i_d.di_cowextsize;
 
 	ret = xfs_reflink_update_dest(dest, pos_out + len, cowextsize,
-			is_dedupe);
+			remap_flags);
 
 out_unlock:
 	xfs_reflink_remap_unlock(file_in, file_out);
diff --git a/fs/xfs/xfs_reflink.h b/fs/xfs/xfs_reflink.h
index c585ad9552b2..6f82d628bf17 100644
--- a/fs/xfs/xfs_reflink.h
+++ b/fs/xfs/xfs_reflink.h
@@ -28,7 +28,8 @@ extern int xfs_reflink_end_cow(struct xfs_inode *ip, xfs_off_t offset,
 		xfs_off_t count);
 extern int xfs_reflink_recover_cow(struct xfs_mount *mp);
 extern int xfs_reflink_remap_range(struct file *file_in, loff_t pos_in,
-		struct file *file_out, loff_t pos_out, u64 len, bool is_dedupe);
+		struct file *file_out, loff_t pos_out, u64 len,
+		unsigned int remap_flags);
 extern int xfs_reflink_inode_has_shared_extents(struct xfs_trans *tp,
 		struct xfs_inode *ip, bool *has_shared);
 extern int xfs_reflink_clear_inode_flag(struct xfs_inode *ip,
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 888cef35c7d7..631c28ce1436 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1844,7 +1844,7 @@ extern ssize_t vfs_copy_file_range(struct file *, loff_t , struct file *,
 				   loff_t, size_t, unsigned int);
 extern int generic_remap_file_range_prep(struct file *file_in, loff_t pos_in,
 					 struct file *file_out, loff_t pos_out,
-					 u64 *count, bool is_dedupe);
+					 u64 *count, unsigned int remap_flags);
 extern int do_clone_file_range(struct file *file_in, loff_t pos_in,
 			       struct file *file_out, loff_t pos_out, u64 len);
 extern int vfs_clone_file_range(struct file *file_in, loff_t pos_in,

