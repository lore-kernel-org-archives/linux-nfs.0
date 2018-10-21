Return-Path: <SRS0=BUwe=NB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 088BDECDE43
	for <linux-nfs@archiver.kernel.org>; Sun, 21 Oct 2018 16:17:53 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C4C882083E
	for <linux-nfs@archiver.kernel.org>; Sun, 21 Oct 2018 16:17:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="hMI/grNS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4C882083E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728091AbeJVAck (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 21 Oct 2018 20:32:40 -0400
Received: from userp2120.oracle.com ([156.151.31.85]:45478 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727408AbeJVAck (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 21 Oct 2018 20:32:40 -0400
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w9LGEViE106955;
        Sun, 21 Oct 2018 16:15:42 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : in-reply-to : references : mime-version :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=SHexZ7j4NahuPkzJw7xdjRTs2Ez8K2Od8tzKdBj+sBY=;
 b=hMI/grNS2O9UcylFxo7zNSIRyAyGodsx6RE06/3DCrd+aTxvroP7sa2CkXcbK/OdFYh7
 vwSxFAwjQWBKcod5Hun76y6wwtLB3Tz0WcCR4Gxde49GKFCJEGul6mmc9AVyXUKELfvT
 48Gm5JWoEAta77dJQRZi+3YILYHzDcdhIyFORlB+HUuLJdIhCZMCdx5nHjM7mPNh/UUI
 Pae2Bpw7MfRuLYJXQ7dwChEOmAECK3KKYoeC6Cazl77g2L1jexOXL79NoFos2EIMEoux
 KY0YrdB1kH0v92qV05waorrjRWAvExJMMb07b8mmPTW8iD2V2Q7juYZgpirQKWKdXPlA qg== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
        by userp2120.oracle.com with ESMTP id 2n7w0qaxhc-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Sun, 21 Oct 2018 16:15:42 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
        by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w9LGFerV008090
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Sun, 21 Oct 2018 16:15:41 GMT
Received: from abhmp0008.oracle.com (abhmp0008.oracle.com [141.146.116.14])
        by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w9LGFe89018874;
        Sun, 21 Oct 2018 16:15:40 GMT
Received: from localhost (/10.159.225.70)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Sun, 21 Oct 2018 09:15:39 -0700
Subject: [PATCH 05/28] vfs: avoid problematic remapping requests into
 partial EOF block
From:   "Darrick J. Wong" <darrick.wong@oracle.com>
To:     david@fromorbit.com, darrick.wong@oracle.com
Cc:     sandeen@redhat.com, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-xfs@vger.kernel.org, linux-mm@kvack.org,
        linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Christoph Hellwig <hch@lst.de>, ocfs2-devel@oss.oracle.com
Date:   Sun, 21 Oct 2018 09:15:37 -0700
Message-ID: <154013853780.29026.5441191187672186537.stgit@magnolia>
In-Reply-To: <154013850285.29026.16168387526580596209.stgit@magnolia>
References: <154013850285.29026.16168387526580596209.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9053 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=785
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1807170000 definitions=main-1810210151
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Darrick J. Wong <darrick.wong@oracle.com>

A deduplication data corruption is exposed in XFS and btrfs. It is
caused by extending the block match range to include the partial EOF
block, but then allowing unknown data beyond EOF to be considered a
"match" to data in the destination file because the comparison is only
made to the end of the source file. This corrupts the destination file
when the source extent is shared with it.

The VFS remapping prep functions  only support whole block dedupe, but
we still need to appear to support whole file dedupe correctly.  Hence
if the dedupe request includes the last block of the souce file, don't
include it in the actual dedupe operation. If the rest of the range
dedupes successfully, then reject the entire request.  A subsequent
patch will enable us to shorten dedupe requests correctly.

When reflinking sub-file ranges, a data corruption can occur when the
source file range includes a partial EOF block. This shares the unknown
data beyond EOF into the second file at a position inside EOF, exposing
stale data in the second file.

If the reflink request includes the last block of the souce file, only
proceed with the reflink operation if it lands at or past the
destination file's current EOF. If it lands within the destination file
EOF, reject the entire request with -EINVAL and make the caller go the
hard way.  A subsequent patch will enable us to shorten reflink requests
correctly.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/read_write.c |   33 +++++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)


diff --git a/fs/read_write.c b/fs/read_write.c
index 2456da3f8a41..0f0a6efdd502 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1708,6 +1708,34 @@ static int clone_verify_area(struct file *file, loff_t pos, u64 len, bool write)
 
 	return security_file_permission(file, write ? MAY_WRITE : MAY_READ);
 }
+/*
+ * Ensure that we don't remap a partial EOF block in the middle of something
+ * else.  Assume that the offsets have already been checked for block
+ * alignment.
+ *
+ * For deduplication we always scale down to the previous block because we
+ * can't meaningfully compare post-EOF contents.
+ *
+ * For clone we only link a partial EOF block above the destination file's EOF.
+ */
+static int generic_remap_check_len(struct inode *inode_in,
+				   struct inode *inode_out,
+				   loff_t pos_out,
+				   u64 *len,
+				   bool is_dedupe)
+{
+	u64 blkmask = i_blocksize(inode_in) - 1;
+
+	if ((*len & blkmask) == 0)
+		return 0;
+
+	if (is_dedupe)
+		*len &= ~blkmask;
+	else if (pos_out + *len < i_size_read(inode_out))
+		return -EINVAL;
+
+	return 0;
+}
 
 /*
  * Check that the two inodes are eligible for cloning, the ranges make
@@ -1787,6 +1815,11 @@ int vfs_clone_file_prep(struct file *file_in, loff_t pos_in,
 			return -EBADE;
 	}
 
+	ret = generic_remap_check_len(inode_in, inode_out, pos_out, len,
+			is_dedupe);
+	if (ret)
+		return ret;
+
 	return 1;
 }
 EXPORT_SYMBOL(vfs_clone_file_prep);

