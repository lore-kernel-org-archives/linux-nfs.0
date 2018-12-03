Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6200C65BAE
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 08:34:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A8C3B20851
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 08:34:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A8C3B20851
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725855AbeLCIeY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 Dec 2018 03:34:24 -0500
Received: from ipmailnode02.adl6.internode.on.net ([150.101.137.148]:60959
        "EHLO ipmailnode02.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1725830AbeLCIeY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Dec 2018 03:34:24 -0500
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail02.adl6.internode.on.net with ESMTP; 03 Dec 2018 19:04:19 +1030
Received: from discord.disaster.area ([192.168.1.111])
        by dastard with esmtp (Exim 4.80)
        (envelope-from <david@fromorbit.com>)
        id 1gTjgI-0003PR-UQ; Mon, 03 Dec 2018 19:34:19 +1100
Received: from dave by discord.disaster.area with local (Exim 4.91)
        (envelope-from <david@fromorbit.com>)
        id 1gTjgI-00005u-TN; Mon, 03 Dec 2018 19:34:18 +1100
From:   Dave Chinner <david@fromorbit.com>
To:     linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org
Cc:     olga.kornievskaia@gmail.com, linux-nfs@vger.kernel.org,
        linux-unionfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org
Subject: [PATCH 01/11] vfs: copy_file_range source range over EOF should fail
Date:   Mon,  3 Dec 2018 19:34:06 +1100
Message-Id: <20181203083416.28978-2-david@fromorbit.com>
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

The man page says:

EINVAL Requested range extends beyond the end of the source file

But the current behaviour is that copy_file_range does a short
copy up to the source file EOF. Fix the kernel behaviour to match
the behaviour described in the man page.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/read_write.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/read_write.c b/fs/read_write.c
index 4dae0399c75a..09d1816cf3cf 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1581,6 +1581,10 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 	if (len == 0)
 		return 0;
 
+	/* If the source range crosses EOF, fail the copy */
+	if (pos_in >= i_size(inode_in) || pos_in + len > i_size(inode_in))
+		return -EINVAL;
+
 	file_start_write(file_out);
 
 	/*
-- 
2.19.1

