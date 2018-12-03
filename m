Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2CCF3C65BAE
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 08:34:37 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E5D8A20851
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 08:34:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E5D8A20851
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725951AbeLCIee (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 Dec 2018 03:34:34 -0500
Received: from ipmailnode02.adl6.internode.on.net ([150.101.137.148]:39077
        "EHLO ipmailnode02.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1725930AbeLCIee (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Dec 2018 03:34:34 -0500
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail02.adl6.internode.on.net with ESMTP; 03 Dec 2018 19:04:19 +1030
Received: from discord.disaster.area ([192.168.1.111])
        by dastard with esmtp (Exim 4.80)
        (envelope-from <david@fromorbit.com>)
        id 1gTjgJ-0003PY-4o; Mon, 03 Dec 2018 19:34:19 +1100
Received: from dave by discord.disaster.area with local (Exim 4.91)
        (envelope-from <david@fromorbit.com>)
        id 1gTjgJ-00006G-3l; Mon, 03 Dec 2018 19:34:19 +1100
From:   Dave Chinner <david@fromorbit.com>
To:     linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org
Cc:     olga.kornievskaia@gmail.com, linux-nfs@vger.kernel.org,
        linux-unionfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org
Subject: [PATCH 08/11] vfs: push EXDEV check down into ->remap_file_range
Date:   Mon,  3 Dec 2018 19:34:13 +1100
Message-Id: <20181203083416.28978-9-david@fromorbit.com>
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

before we can enable cross-device copies into copy_file_range(),
we have to ensure that ->remap_file_range() implemenations will
correctly reject attempts to do cross filesystem clones. Currently
these checks are done above calls to ->remap_file_range(), but
we need to drive them inwards so that we get EXDEV protection for all
callers of ->remap_file_range().

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/read_write.c | 21 +++++++++++++--------
 1 file changed, 13 insertions(+), 8 deletions(-)

diff --git a/fs/read_write.c b/fs/read_write.c
index 3288db1d5f21..174cf92eea1d 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1909,6 +1909,19 @@ int generic_remap_file_range_prep(struct file *file_in, loff_t pos_in,
 	bool same_inode = (inode_in == inode_out);
 	int ret;
 
+	/*
+	 * FICLONE/FICLONERANGE ioctls enforce that src and dest files are on
+	 * the same mount. Practically, they only need to be on the same file
+	 * system. We check this here rather than at the ioctl layers because
+	 * this is effectively a limitation of the fielsystem implementations,
+	 * not so much the API itself. Further, ->remap_file_range() can be
+	 * called from syscalls that don't have cross device copy restrictions
+	 * (such as copy_file_range()) and so we need to catch them before we
+	 * do any damage.
+	 */
+	if (inode_in->i_sb != inode_out->i_sb)
+		return -EXDEV;
+
 	/* Don't touch certain kinds of inodes */
 	if (IS_IMMUTABLE(inode_out))
 		return -EPERM;
@@ -2013,14 +2026,6 @@ loff_t do_clone_file_range(struct file *file_in, loff_t pos_in,
 	if (!S_ISREG(inode_in->i_mode) || !S_ISREG(inode_out->i_mode))
 		return -EINVAL;
 
-	/*
-	 * FICLONE/FICLONERANGE ioctls enforce that src and dest files are on
-	 * the same mount. Practically, they only need to be on the same file
-	 * system.
-	 */
-	if (inode_in->i_sb != inode_out->i_sb)
-		return -EXDEV;
-
 	if (!(file_in->f_mode & FMODE_READ) ||
 	    !(file_out->f_mode & FMODE_WRITE) ||
 	    (file_out->f_flags & O_APPEND))
-- 
2.19.1

