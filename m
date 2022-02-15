Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27052C433F5
	for <linux-nfs@archiver.kernel.org>; Tue, 15 Feb 2022 10:25:09 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S235404AbiBOKZQ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 15 Feb 2022 05:25:16 -0500
Received: from mxb-00190b01.gslb.pphosted.com ([23.128.96.19]:41710 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231349AbiBOKZP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Feb 2022 05:25:15 -0500
X-Greylist: delayed 458 seconds by postgrey-1.37 at lindbergh.monkeyblade.net; Tue, 15 Feb 2022 02:25:05 PST
Received: from mail.ispras.ru (mail.ispras.ru [83.149.199.84])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id CCFEB22B3D
        for <linux-nfs@vger.kernel.org>; Tue, 15 Feb 2022 02:25:05 -0800 (PST)
Received: from hednb3.intra.ispras.ru (unknown [10.10.2.52])
        by mail.ispras.ru (Postfix) with ESMTPSA id 3E0114076B21;
        Tue, 15 Feb 2022 10:17:26 +0000 (UTC)
From:   Alexey Khoroshilov <khoroshilov@ispras.ru>
To:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna@kernel.org>
Cc:     Alexey Khoroshilov <khoroshilov@ispras.ru>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        ldv-project@linuxtesting.org
Subject: [PATCH] NFS: remove unneeded check in decode_devicenotify_args()
Date:   Tue, 15 Feb 2022 13:17:04 +0300
Message-Id: <1644920224-24966-1-git-send-email-khoroshilov@ispras.ru>
X-Mailer: git-send-email 2.7.4
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Overflow check in not needed anymore after we switch to kmalloc_array().

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
Fixes: a4f743a6bb20 ("NFSv4.1: Convert open-coded array allocation calls to kmalloc_array()")
---
 fs/nfs/callback_xdr.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index f90de8043b0f..8dcb08e1a885 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -271,10 +271,6 @@ __be32 decode_devicenotify_args(struct svc_rqst *rqstp,
 	n = ntohl(*p++);
 	if (n == 0)
 		goto out;
-	if (n > ULONG_MAX / sizeof(*args->devs)) {
-		status = htonl(NFS4ERR_BADXDR);
-		goto out;
-	}
 
 	args->devs = kmalloc_array(n, sizeof(*args->devs), GFP_KERNEL);
 	if (!args->devs) {
-- 
2.7.4

