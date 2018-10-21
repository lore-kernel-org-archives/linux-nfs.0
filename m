Return-Path: <SRS0=BUwe=NB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69B73ECDE44
	for <linux-nfs@archiver.kernel.org>; Sun, 21 Oct 2018 16:17:00 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 307DE2083A
	for <linux-nfs@archiver.kernel.org>; Sun, 21 Oct 2018 16:17:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="N5YLm8oA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 307DE2083A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727712AbeJVAbr (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 21 Oct 2018 20:31:47 -0400
Received: from aserp2120.oracle.com ([141.146.126.78]:42174 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727408AbeJVAbq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 21 Oct 2018 20:31:46 -0400
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
        by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w9LGF4D4155377;
        Sun, 21 Oct 2018 16:16:52 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : in-reply-to : references : mime-version :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=pC8nJW77l6kqdRNb3rj5XcaGF3voO6grLSxCXMDgfF0=;
 b=N5YLm8oAdXTZUxPUhI2dgJs4g8oK1tP34saHlI7ZcL6zBFzTUrs9szXJIertH4aNlA8P
 2nmvGtFEHHZQ11I8F1VwNccpBMAYITG++vHBT+Gy62K8Y01QNJX4xEF8cAgJVhtp1/g0
 OIbMJLlrys3owlVvcUYBJ9EvBGJYb+YsBRcVwJ/y+BgvuCUHCcdHURmiUtO9uuG8Xugn
 LrMgzitbsHUazyytJjMuoLFgoMMIeyQOAo24WiEPs6b9t16nY4vKhGaQIHIqsTij2S2c
 lTLZacJgG5vVDU8Yx1RPT5imPriW2ZtFaWPGB0Vk7iFxycFaQ7USfgbqlDMhXyT+C5Kk jg== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
        by aserp2120.oracle.com with ESMTP id 2n7vapjyrb-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Sun, 21 Oct 2018 16:16:52 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
        by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w9LGGpBq026699
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Sun, 21 Oct 2018 16:16:51 GMT
Received: from abhmp0009.oracle.com (abhmp0009.oracle.com [141.146.116.15])
        by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w9LGGo0A019171;
        Sun, 21 Oct 2018 16:16:51 GMT
Received: from localhost (/10.159.225.70)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Sun, 21 Oct 2018 09:16:50 -0700
Subject: [PATCH 15/28] vfs: plumb remap flags through the vfs dedupe
 functions
From:   "Darrick J. Wong" <darrick.wong@oracle.com>
To:     david@fromorbit.com, darrick.wong@oracle.com
Cc:     sandeen@redhat.com, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>,
        linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org,
        linux-mm@kvack.org, linux-btrfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com
Date:   Sun, 21 Oct 2018 09:16:49 -0700
Message-ID: <154013860893.29026.11185987776641893367.stgit@magnolia>
In-Reply-To: <154013850285.29026.16168387526580596209.stgit@magnolia>
References: <154013850285.29026.16168387526580596209.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9053 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=522
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1807170000 definitions=main-1810210151
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Darrick J. Wong <darrick.wong@oracle.com>

Plumb a remap_flags argument through the vfs_dedupe_file_range_one
functions so that dedupe can take advantage of it.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
Reviewed-by: Amir Goldstein <amir73il@gmail.com>
---
 fs/overlayfs/file.c |    3 ++-
 fs/read_write.c     |    9 ++++++---
 include/linux/fs.h  |    2 +-
 3 files changed, 9 insertions(+), 5 deletions(-)


diff --git a/fs/overlayfs/file.c b/fs/overlayfs/file.c
index 0393815c8971..84dd957efa24 100644
--- a/fs/overlayfs/file.c
+++ b/fs/overlayfs/file.c
@@ -467,7 +467,8 @@ static loff_t ovl_copyfile(struct file *file_in, loff_t pos_in,
 
 	case OVL_DEDUPE:
 		ret = vfs_dedupe_file_range_one(real_in.file, pos_in,
-						real_out.file, pos_out, len);
+						real_out.file, pos_out, len,
+						flags);
 		break;
 	}
 	revert_creds(old_cred);
diff --git a/fs/read_write.c b/fs/read_write.c
index 0d1ac1b9bc22..ea30666013b0 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -2010,10 +2010,12 @@ EXPORT_SYMBOL(vfs_dedupe_file_range_compare);
 
 loff_t vfs_dedupe_file_range_one(struct file *src_file, loff_t src_pos,
 				 struct file *dst_file, loff_t dst_pos,
-				 loff_t len)
+				 loff_t len, unsigned int remap_flags)
 {
 	loff_t ret;
 
+	WARN_ON_ONCE(remap_flags & ~(REMAP_FILE_DEDUP));
+
 	ret = mnt_want_write_file(dst_file);
 	if (ret)
 		return ret;
@@ -2044,7 +2046,7 @@ loff_t vfs_dedupe_file_range_one(struct file *src_file, loff_t src_pos,
 	}
 
 	ret = dst_file->f_op->remap_file_range(src_file, src_pos, dst_file,
-			dst_pos, len, REMAP_FILE_DEDUP);
+			dst_pos, len, remap_flags | REMAP_FILE_DEDUP);
 out_drop_write:
 	mnt_drop_write_file(dst_file);
 
@@ -2112,7 +2114,8 @@ int vfs_dedupe_file_range(struct file *file, struct file_dedupe_range *same)
 		}
 
 		deduped = vfs_dedupe_file_range_one(file, off, dst_file,
-						    info->dest_offset, len);
+						    info->dest_offset, len,
+						    0);
 		if (deduped == -EBADE)
 			info->status = FILE_DEDUPE_RANGE_DIFFERS;
 		else if (deduped < 0)
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 1c5e55d2a67d..544ab5083b48 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1859,7 +1859,7 @@ extern int vfs_dedupe_file_range(struct file *file,
 				 struct file_dedupe_range *same);
 extern loff_t vfs_dedupe_file_range_one(struct file *src_file, loff_t src_pos,
 					struct file *dst_file, loff_t dst_pos,
-					loff_t len);
+					loff_t len, unsigned int remap_flags);
 
 
 struct super_operations {

