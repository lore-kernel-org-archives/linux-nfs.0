Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f174.google.com ([209.85.160.174]:34557 "EHLO
	mail-yk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753295AbbG3Nwd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jul 2015 09:52:33 -0400
Received: by ykax123 with SMTP id x123so34370641yka.1
        for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2015 06:52:32 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/9] nfsd: include linux/nfs4.h in export.h
Date: Thu, 30 Jul 2015 09:52:13 -0400
Message-Id: <1438264341-18048-3-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1438264341-18048-1-git-send-email-jeff.layton@primarydata.com>
References: <1438264341-18048-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

export.h refers to the pnfs_layouttype enum, which is defined there.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/export.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfsd/export.h b/fs/nfsd/export.h
index 1f52bfcc436f..2e315072bf3f 100644
--- a/fs/nfsd/export.h
+++ b/fs/nfsd/export.h
@@ -6,6 +6,7 @@
 
 #include <linux/sunrpc/cache.h>
 #include <uapi/linux/nfsd/export.h>
+#include <linux/nfs4.h>
 
 struct knfsd_fh;
 struct svc_fh;
-- 
2.4.3

