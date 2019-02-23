Return-Path: <SRS0=i0gF=Q6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA92FC10F0B
	for <linux-nfs@archiver.kernel.org>; Sat, 23 Feb 2019 21:14:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8D7DA20675
	for <linux-nfs@archiver.kernel.org>; Sat, 23 Feb 2019 21:14:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1550956464;
	bh=p4kan2IM2IrDaDDB9W42ixbh+nU1EN9A4HLzGAW2Xmg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=O1uwsy1/mQjIDkEBnerfmvvRjWU/WPzfoXlALev9myXeLOjeXQrRG3yplgXX7mUkg
	 Jrq9MOdXKJ7fXx5dP/s9KT0bUCu4vL6zYuowt72yEBFRV3mWQ0QXu+PLF+XVjmaj2e
	 rO+TGjJ9mzJy6/Va5mI/BBpwLDF57cjgUaurwQfM=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728522AbfBWVOS (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 23 Feb 2019 16:14:18 -0500
Received: from mail.kernel.org ([198.145.29.99]:47634 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729935AbfBWVLO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 23 Feb 2019 16:11:14 -0500
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 74B972086A;
        Sat, 23 Feb 2019 21:11:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1550956274;
        bh=p4kan2IM2IrDaDDB9W42ixbh+nU1EN9A4HLzGAW2Xmg=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=yAyQssjI3Lm/Q8DOenaerrm0rvi/0DeKxTNkt1Inj6cwIn9EPaLi1Uidp88Y4nXGJ
         wcisz2txkrNaDC3dvV44kTjulfa6k4hH6qAxMTIXAgokFypHFGMU1zjsiGhC50gZb9
         wSavd+SHQzc1EHCisF90WwwqbjYbbOElSlMPHoko=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Yao Liu <yotta.liu@ucloud.cn>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 4.4 16/26] nfs: Fix NULL pointer dereference of dev_name
Date:   Sat, 23 Feb 2019 16:10:37 -0500
Message-Id: <20190223211047.202725-16-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190223211047.202725-1-sashal@kernel.org>
References: <20190223211047.202725-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Yao Liu <yotta.liu@ucloud.cn>

[ Upstream commit 80ff00172407e0aad4b10b94ef0816fc3e7813cb ]

There is a NULL pointer dereference of dev_name in nfs_parse_devname()

The oops looks something like:

  BUG: unable to handle kernel NULL pointer dereference at 0000000000000000
  ...
  RIP: 0010:nfs_fs_mount+0x3b6/0xc20 [nfs]
  ...
  Call Trace:
   ? ida_alloc_range+0x34b/0x3d0
   ? nfs_clone_super+0x80/0x80 [nfs]
   ? nfs_free_parsed_mount_data+0x60/0x60 [nfs]
   mount_fs+0x52/0x170
   ? __init_waitqueue_head+0x3b/0x50
   vfs_kern_mount+0x6b/0x170
   do_mount+0x216/0xdc0
   ksys_mount+0x83/0xd0
   __x64_sys_mount+0x25/0x30
   do_syscall_64+0x65/0x220
   entry_SYSCALL_64_after_hwframe+0x49/0xbe

Fix this by adding a NULL check on dev_name

Signed-off-by: Yao Liu <yotta.liu@ucloud.cn>
Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/nfs/super.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 62f358f677646..322efac79cc71 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1877,6 +1877,11 @@ static int nfs_parse_devname(const char *dev_name,
 	size_t len;
 	char *end;
 
+	if (unlikely(!dev_name || !*dev_name)) {
+		dfprintk(MOUNT, "NFS: device name not specified\n");
+		return -EINVAL;
+	}
+
 	/* Is the host name protected with square brakcets? */
 	if (*dev_name == '[') {
 		end = strchr(++dev_name, ']');
-- 
2.19.1

