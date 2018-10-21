Return-Path: <SRS0=BUwe=NB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65D6DECDE44
	for <linux-nfs@archiver.kernel.org>; Sun, 21 Oct 2018 16:18:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2E4F12083A
	for <linux-nfs@archiver.kernel.org>; Sun, 21 Oct 2018 16:18:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="FkLUpJ5Z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E4F12083A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728102AbeJVAcs (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 21 Oct 2018 20:32:48 -0400
Received: from aserp2120.oracle.com ([141.146.126.78]:43060 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727408AbeJVAcr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 21 Oct 2018 20:32:47 -0400
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
        by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w9LGGCQA155864;
        Sun, 21 Oct 2018 16:17:54 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : in-reply-to : references : mime-version :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=LiozndoqC/TzvqN9AZSX3PUuVQc7boe5NscE8EdW/X4=;
 b=FkLUpJ5ZlHSQVxxriZvK5EtLw4/gvEgBpaitc1X1xmPGI9EhRSD9If1RF/PctUGEhoOt
 NK5VYcUjYJJbGvNozecBfeyKs2qFkdH6BxFXhYLln/kgEKniPKm3WEsauLhsuyOGt1t0
 Dz1w0BZd/FE2Kfd0QNynAg9LbOlxaDmMCZe8BnVWnSkN8TJ1UuebDj1n7cpzDE/zdj0S
 0gvRJ/c6ibSQ+kb1BshomwVeOsQYlUUsSbW4ALSyRDHlhOXW7FFjP5TAMV8S167D7yiG
 fXZfQ6a+GEN8mBsX2gRkK7MgeUOwlHlYbEhllMxEs1U24hGWpfmaqADE/F+2UCDz9CgA OQ== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
        by aserp2120.oracle.com with ESMTP id 2n7vapjysd-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Sun, 21 Oct 2018 16:17:53 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w9LGHqq4006984
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Sun, 21 Oct 2018 16:17:52 GMT
Received: from abhmp0001.oracle.com (abhmp0001.oracle.com [141.146.116.7])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w9LGHqw3018953;
        Sun, 21 Oct 2018 16:17:52 GMT
Received: from localhost (/10.159.225.70)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Sun, 21 Oct 2018 09:17:52 -0700
Subject: [PATCH 24/28] xfs: clean up xfs_reflink_remap_blocks call site
From:   "Darrick J. Wong" <darrick.wong@oracle.com>
To:     david@fromorbit.com, darrick.wong@oracle.com
Cc:     sandeen@redhat.com, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-xfs@vger.kernel.org, linux-mm@kvack.org,
        linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        ocfs2-devel@oss.oracle.com
Date:   Sun, 21 Oct 2018 09:17:50 -0700
Message-ID: <154013867045.29026.12266020817835171751.stgit@magnolia>
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

Move the offset <-> blocks unit conversions into
xfs_reflink_remap_blocks to make the call site less ugly.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 fs/xfs/xfs_reflink.c |   37 ++++++++++++++++++-------------------
 1 file changed, 18 insertions(+), 19 deletions(-)


diff --git a/fs/xfs/xfs_reflink.c b/fs/xfs/xfs_reflink.c
index e8e86646bb4b..79dec457f7fb 100644
--- a/fs/xfs/xfs_reflink.c
+++ b/fs/xfs/xfs_reflink.c
@@ -1119,16 +1119,23 @@ xfs_reflink_remap_extent(
 STATIC int
 xfs_reflink_remap_blocks(
 	struct xfs_inode	*src,
-	xfs_fileoff_t		srcoff,
+	loff_t			pos_in,
 	struct xfs_inode	*dest,
-	xfs_fileoff_t		destoff,
-	xfs_filblks_t		len,
-	xfs_off_t		new_isize)
+	loff_t			pos_out,
+	loff_t			remap_len)
 {
 	struct xfs_bmbt_irec	imap;
+	xfs_fileoff_t		srcoff;
+	xfs_fileoff_t		destoff;
+	xfs_filblks_t		len;
+	xfs_filblks_t		range_len;
+	xfs_off_t		new_isize = pos_out + remap_len;
 	int			nimaps;
 	int			error = 0;
-	xfs_filblks_t		range_len;
+
+	destoff = XFS_B_TO_FSBT(src->i_mount, pos_out);
+	srcoff = XFS_B_TO_FSBT(src->i_mount, pos_in);
+	len = XFS_B_TO_FSB(src->i_mount, remap_len);
 
 	/* drange = (destoff, destoff + len); srange = (srcoff, srcoff + len) */
 	while (len) {
@@ -1143,7 +1150,7 @@ xfs_reflink_remap_blocks(
 		error = xfs_bmapi_read(src, srcoff, len, &imap, &nimaps, 0);
 		xfs_iunlock(src, lock_mode);
 		if (error)
-			goto err;
+			break;
 		ASSERT(nimaps == 1);
 
 		trace_xfs_reflink_remap_imap(src, srcoff, len, XFS_IO_OVERWRITE,
@@ -1157,11 +1164,11 @@ xfs_reflink_remap_blocks(
 		error = xfs_reflink_remap_extent(dest, &imap, destoff,
 				new_isize);
 		if (error)
-			goto err;
+			break;
 
 		if (fatal_signal_pending(current)) {
 			error = -EINTR;
-			goto err;
+			break;
 		}
 
 		/* Advance drange/srange */
@@ -1170,10 +1177,8 @@ xfs_reflink_remap_blocks(
 		len -= range_len;
 	}
 
-	return 0;
-
-err:
-	trace_xfs_reflink_remap_blocks_error(dest, error, _RET_IP_);
+	if (error)
+		trace_xfs_reflink_remap_blocks_error(dest, error, _RET_IP_);
 	return error;
 }
 
@@ -1396,8 +1401,6 @@ xfs_reflink_remap_range(
 	struct inode		*inode_out = file_inode(file_out);
 	struct xfs_inode	*dest = XFS_I(inode_out);
 	struct xfs_mount	*mp = src->i_mount;
-	xfs_fileoff_t		sfsbno, dfsbno;
-	xfs_filblks_t		fsblen;
 	xfs_extlen_t		cowextsize;
 	ssize_t			ret;
 
@@ -1415,11 +1418,7 @@ xfs_reflink_remap_range(
 
 	trace_xfs_reflink_remap_range(src, pos_in, len, dest, pos_out);
 
-	dfsbno = XFS_B_TO_FSBT(mp, pos_out);
-	sfsbno = XFS_B_TO_FSBT(mp, pos_in);
-	fsblen = XFS_B_TO_FSB(mp, len);
-	ret = xfs_reflink_remap_blocks(src, sfsbno, dest, dfsbno, fsblen,
-			pos_out + len);
+	ret = xfs_reflink_remap_blocks(src, pos_in, dest, pos_out, len);
 	if (ret)
 		goto out_unlock;
 

