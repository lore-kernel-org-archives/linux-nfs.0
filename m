Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C3CEC47082
	for <linux-nfs@archiver.kernel.org>; Tue,  8 Jun 2021 17:03:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 5F20F61285
	for <linux-nfs@archiver.kernel.org>; Tue,  8 Jun 2021 17:03:46 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S233200AbhFHRFi (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 8 Jun 2021 13:05:38 -0400
Received: from mail.kernel.org ([198.145.29.99]:45818 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S231278AbhFHRFh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 8 Jun 2021 13:05:37 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id 1BA786127A;
        Tue,  8 Jun 2021 17:03:44 +0000 (UTC)
Subject: [PATCH] nfs(5): Correct the spelling of "kernel_source"
From:   Chuck Lever <chuck.lever@oracle.com>
To:     SteveD@redhat.com
Cc:     linux-nfs@vger.kernel.org
Date:   Tue, 08 Jun 2021 13:03:42 -0400
Message-ID: <162317182289.1639.2985340972351210574.stgit@oracle-100.nfsv4.dev>
User-Agent: StGit/1.1
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 utils/mount/nfs.man |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index 19fe22fb5411..5682b5592a66 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -552,7 +552,7 @@ detailed discussion of these trade-offs.
 .BR fsc " / " nofsc
 Enable/Disables the cache of (read-only) data pages to the local disk 
 using the FS-Cache facility. See cachefilesd(8) 
-and <kernel_soruce>/Documentation/filesystems/caching
+and <kernel_source>/Documentation/filesystems/caching
 for detail on how to configure the FS-Cache facility.
 Default value is nofsc.
 .SS "Options for NFS versions 2 and 3 only"


