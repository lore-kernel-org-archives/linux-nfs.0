Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E72B3C47082
	for <linux-nfs@archiver.kernel.org>; Tue,  8 Jun 2021 17:10:20 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id C4A2861354
	for <linux-nfs@archiver.kernel.org>; Tue,  8 Jun 2021 17:10:20 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231493AbhFHRMM (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 8 Jun 2021 13:12:12 -0400
Received: from mail.kernel.org ([198.145.29.99]:49494 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S231261AbhFHRMM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 8 Jun 2021 13:12:12 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id A1A8361351;
        Tue,  8 Jun 2021 17:10:18 +0000 (UTC)
Subject: [PATCH] nfs(5): Fix missing mentions of "rdma6" netid
From:   Chuck Lever <chuck.lever@oracle.com>
To:     SteveD@redhat.com
Cc:     linux-nfs@vger.kernel.org
Date:   Tue, 08 Jun 2021 13:10:17 -0400
Message-ID: <162317221773.1999.16160807270651134948.stgit@oracle-100.nfsv4.dev>
User-Agent: StGit/1.1
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 utils/mount/nfs.man |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index 5682b5592a66..f98cb47dbf99 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -564,7 +564,7 @@ The
 .I netid
 determines the transport that is used to communicate with the NFS
 server.  Available options are
-.BR udp ", " udp6 ", "tcp ", " tcp6 ", and " rdma .
+.BR udp ", " udp6 ", "tcp ", " tcp6 ", " rdma ", and " rdma6 .
 Those which end in
 .B 6
 use IPv6 addresses and are only available if support for TI-RPC is
@@ -812,7 +812,7 @@ The
 .I netid
 determines the transport that is used to communicate with the NFS
 server.  Supported options are
-.BR tcp ", " tcp6 ", and " rdma .
+.BR tcp ", " tcp6 ", " rdma ", and " rdma6 .
 .B tcp6
 use IPv6 addresses and is only available if support for TI-RPC is
 built in. Both others use IPv4 addresses.


