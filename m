Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C82ADC65BAE
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 08:34:35 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8F74820851
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 08:34:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8F74820851
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725956AbeLCIee (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 Dec 2018 03:34:34 -0500
Received: from ipmailnode02.adl6.internode.on.net ([150.101.137.148]:60959
        "EHLO ipmailnode02.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1725937AbeLCIee (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Dec 2018 03:34:34 -0500
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail02.adl6.internode.on.net with ESMTP; 03 Dec 2018 19:04:20 +1030
Received: from discord.disaster.area ([192.168.1.111])
        by dastard with esmtp (Exim 4.80)
        (envelope-from <david@fromorbit.com>)
        id 1gTjgJ-0003Pl-7y; Mon, 03 Dec 2018 19:34:19 +1100
Received: from dave by discord.disaster.area with local (Exim 4.91)
        (envelope-from <david@fromorbit.com>)
        id 1gTjgJ-00006Q-6Y; Mon, 03 Dec 2018 19:34:19 +1100
From:   Dave Chinner <david@fromorbit.com>
To:     linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org
Cc:     olga.kornievskaia@gmail.com, linux-nfs@vger.kernel.org,
        linux-unionfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org
Subject: [PATCH 11/11] ovl: allow cross-device copy_file_range calls
Date:   Mon,  3 Dec 2018 19:34:16 +1100
Message-Id: <20181203083416.28978-12-david@fromorbit.com>
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

Restrictions on cross-device copy_file_range() only affect the
vfs_copy_file_range() call to the lower filesystems. They will
handle the copy appropriately, so OVL will never see a EXDEV error
from them. Hence we can remove the EXDEV checks and error handling
from the ovl_copy_file_range() implementation.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/overlayfs/file.c | 11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

diff --git a/fs/overlayfs/file.c b/fs/overlayfs/file.c
index 34fb0398d016..146901d204df 100644
--- a/fs/overlayfs/file.c
+++ b/fs/overlayfs/file.c
@@ -443,14 +443,6 @@ static loff_t ovl_copyfile(struct file *file_in, loff_t pos_in,
 	const struct cred *old_cred;
 	loff_t ret;
 
-	/*
-	 * Temporary. Cross device copy checks should be left to the copy file
-	 * call on the real inodes, but existing behaviour checks the upper
-	 * files only.
-	 */
-	if (file_inode(file_in)->i_sb != file_inode(file_out)->i_sb)
-		return -EXDEV;
-
 	ret = ovl_real_fdget(file_out, &real_out);
 	if (ret)
 		return ret;
@@ -499,7 +491,8 @@ static ssize_t ovl_copy_file_range(struct file *file_in, loff_t pos_in,
 	ret =  ovl_copyfile(file_in, pos_in, file_out, pos_out, len, flags,
 			    OVL_COPY);
 
-	if (ret == -EOPNOTSUPP || ret == -EXDEV)
+	WARN_ON_ONCE(ret == -EXDEV);
+	if (ret == -EOPNOTSUPP)
 		ret = generic_copy_file_range(file_in, pos_in, file_out,
 					pos_out, len, flags);
 	return ret;
-- 
2.19.1

