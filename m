Return-Path: <SRS0=I+ZC=IE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B54EFC433E0
	for <linux-nfs@archiver.kernel.org>; Sat,  6 Mar 2021 22:34:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 7E6FA64DFF
	for <linux-nfs@archiver.kernel.org>; Sat,  6 Mar 2021 22:34:25 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229839AbhCFWdy (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 6 Mar 2021 17:33:54 -0500
Received: from mail.kernel.org ([198.145.29.99]:34872 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S229854AbhCFWdc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 6 Mar 2021 17:33:32 -0500
Received: by mail.kernel.org (Postfix) with ESMTPSA id 8F06C650D7
        for <linux-nfs@vger.kernel.org>; Sat,  6 Mar 2021 22:33:32 +0000 (UTC)
Subject: [PATCH v2 43/43] NFSD: Clean up NFSDDBG_FACILITY macro
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Sat, 06 Mar 2021 17:33:31 -0500
Message-ID: <161507001183.4312.11812982100710038964.stgit@klimt.1015granger.net>
In-Reply-To: <161506956174.4312.17478383686779759287.stgit@klimt.1015granger.net>
References: <161506956174.4312.17478383686779759287.stgit@klimt.1015granger.net>
User-Agent: StGit/1.0-5-g755c
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

These are no longer needed because there are no dprintk() call sites
in these files.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/nfs3xdr.c |    3 ---
 fs/nfsd/nfsxdr.c  |    2 --
 2 files changed, 5 deletions(-)

diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index fcfa0d611b93..0a5ebc52e6a9 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -14,9 +14,6 @@
 #include "netns.h"
 #include "vfs.h"
 
-#define NFSDDBG_FACILITY		NFSDDBG_XDR
-
-
 /*
  * Force construction of an empty post-op attr
  */
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index b800cfefcab7..a06c05fe3b42 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -9,8 +9,6 @@
 #include "xdr.h"
 #include "auth.h"
 
-#define NFSDDBG_FACILITY		NFSDDBG_XDR
-
 /*
  * Mapping of S_IF* types to NFS file types
  */


