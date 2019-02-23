Return-Path: <SRS0=i0gF=Q6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94469C10F0B
	for <linux-nfs@archiver.kernel.org>; Sat, 23 Feb 2019 21:31:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5982020661
	for <linux-nfs@archiver.kernel.org>; Sat, 23 Feb 2019 21:31:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1550957501;
	bh=HnbKnRWz+OUBOlMk6fo+ms7MyuxIXy5k3djy9votkRo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=wnbMJ1f1kPHs3KalZFuQYKEixQfr2W6C8fNzYRVjFa32+rvrk0GsqqAGXMsLblFXF
	 8YDHlAqezZr7apE/YycPVNVZzTTaU+0T+lscKXvMug+QXKOGVpJeXmVuBUCkP1+qRU
	 bsBPR7MUT6obu34DHXYdSqKnVgedE0NhKqcUdkjo=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728185AbfBWVbf (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 23 Feb 2019 16:31:35 -0500
Received: from mail.kernel.org ([198.145.29.99]:40710 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728400AbfBWVFe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 23 Feb 2019 16:05:34 -0500
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 8BA9C206B6;
        Sat, 23 Feb 2019 21:05:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1550955933;
        bh=HnbKnRWz+OUBOlMk6fo+ms7MyuxIXy5k3djy9votkRo=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=ZbzIHl2y5H/ogzca502CPBiVz92qYnKPTMDG+CHuE04EIehI1NR1lciyd2MpY/KtO
         4qrtt/N+D3CUezXuO/cDGNQg4bhTmqBi2CMNca7jCS7M0xVc1OXplzcfX03b9sQjUU
         mzcyWy6KI7bjH+JjG47bnwQleS3sKWYMzHADSctQ=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Yao Liu <yotta.liu@ucloud.cn>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 4.20 42/72] nfs: Fix NULL pointer dereference of dev_name
Date:   Sat, 23 Feb 2019 16:03:52 -0500
Message-Id: <20190223210422.199966-42-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190223210422.199966-1-sashal@kernel.org>
References: <20190223210422.199966-1-sashal@kernel.org>
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
index ac4b2f005778c..25bd29176053f 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1906,6 +1906,11 @@ static int nfs_parse_devname(const char *dev_name,
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

