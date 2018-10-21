Return-Path: <SRS0=BUwe=NB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE4F7ECDE44
	for <linux-nfs@archiver.kernel.org>; Sun, 21 Oct 2018 16:16:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 94FB62083A
	for <linux-nfs@archiver.kernel.org>; Sun, 21 Oct 2018 16:16:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="n6L7avtx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 94FB62083A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728013AbeJVAa5 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 21 Oct 2018 20:30:57 -0400
Received: from aserp2120.oracle.com ([141.146.126.78]:41090 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727641AbeJVAa4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 21 Oct 2018 20:30:56 -0400
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
        by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w9LGE650154818;
        Sun, 21 Oct 2018 16:16:02 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : in-reply-to : references : mime-version :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=lbgR3wOuOLZGLL8/c8R4UCc54EWHiKBjm/iFOf5M+sk=;
 b=n6L7avtxPHSrZRUnsbJm+xUBs9dbvUZW8h8rDvfvIbXNC+YAJJimK8Lc+4n2NdxoaD6X
 a5de+M4HczsI+FTbTY8ADlMmmFf9LBfsJ47PVUBxqGl7wt42x/N7+cWibXLLpZN1ZHw0
 EEyKV83b/5/ip2rtFyHNZmzKSf3jv3JYegQcMPSI2u5RqE6fJvW0cA4HZEu0S5eOFMbN
 1khxwhvPjHoKFAkPdQZ4kNy5wZ+/TeCJwST+MuxBZ7MXSik3bVvc4jwCX+sjjpHO2Len
 vU36WlKLepmSUQr7Ai/dKlFocBQVXAwGu4VtpRa0o6CBG9TfWoPpSwZavJ6V4ZqwqWfW Mg== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
        by aserp2120.oracle.com with ESMTP id 2n7vapjypd-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Sun, 21 Oct 2018 16:16:02 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
        by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w9LGG1ri025777
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Sun, 21 Oct 2018 16:16:01 GMT
Received: from abhmp0020.oracle.com (abhmp0020.oracle.com [141.146.116.26])
        by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w9LGG0oR018910;
        Sun, 21 Oct 2018 16:16:00 GMT
Received: from localhost (/10.159.225.70)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Sun, 21 Oct 2018 09:16:00 -0700
Subject: [PATCH 08/28] vfs: rename clone_verify_area to remap_verify_area
From:   "Darrick J. Wong" <darrick.wong@oracle.com>
To:     david@fromorbit.com, darrick.wong@oracle.com
Cc:     sandeen@redhat.com, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>,
        linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org,
        linux-mm@kvack.org, linux-btrfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com
Date:   Sun, 21 Oct 2018 09:15:58 -0700
Message-ID: <154013855860.29026.18117400241937143769.stgit@magnolia>
In-Reply-To: <154013850285.29026.16168387526580596209.stgit@magnolia>
References: <154013850285.29026.16168387526580596209.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9053 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=706
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1807170000 definitions=main-1810210151
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Darrick J. Wong <darrick.wong@oracle.com>

Since we use clone_verify_area for both clone and dedupe range checks,
rename the function to make it clear that it's for both.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
Reviewed-by: Amir Goldstein <amir73il@gmail.com>
---
 fs/read_write.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)


diff --git a/fs/read_write.c b/fs/read_write.c
index aca75a97a695..734c5661fb69 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1686,7 +1686,7 @@ SYSCALL_DEFINE6(copy_file_range, int, fd_in, loff_t __user *, off_in,
 	return ret;
 }
 
-static int clone_verify_area(struct file *file, loff_t pos, u64 len, bool write)
+static int remap_verify_area(struct file *file, loff_t pos, u64 len, bool write)
 {
 	struct inode *inode = file_inode(file);
 
@@ -1852,11 +1852,11 @@ int do_clone_file_range(struct file *file_in, loff_t pos_in,
 	if (!file_in->f_op->clone_file_range)
 		return -EOPNOTSUPP;
 
-	ret = clone_verify_area(file_in, pos_in, len, false);
+	ret = remap_verify_area(file_in, pos_in, len, false);
 	if (ret)
 		return ret;
 
-	ret = clone_verify_area(file_out, pos_out, len, true);
+	ret = remap_verify_area(file_out, pos_out, len, true);
 	if (ret)
 		return ret;
 
@@ -1989,7 +1989,7 @@ int vfs_dedupe_file_range_one(struct file *src_file, loff_t src_pos,
 	if (ret)
 		return ret;
 
-	ret = clone_verify_area(dst_file, dst_pos, len, true);
+	ret = remap_verify_area(dst_file, dst_pos, len, true);
 	if (ret < 0)
 		goto out_drop_write;
 
@@ -2051,7 +2051,7 @@ int vfs_dedupe_file_range(struct file *file, struct file_dedupe_range *same)
 	if (!S_ISREG(src->i_mode))
 		goto out;
 
-	ret = clone_verify_area(file, off, len, false);
+	ret = remap_verify_area(file, off, len, false);
 	if (ret < 0)
 		goto out;
 	ret = 0;

