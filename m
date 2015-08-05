Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f176.google.com ([209.85.160.176]:34934 "EHLO
	mail-yk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752265AbbHEVNo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Aug 2015 17:13:44 -0400
Received: by ykcq64 with SMTP id q64so41663949ykc.2
        for <linux-nfs@vger.kernel.org>; Wed, 05 Aug 2015 14:13:43 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 01/18] nfsd: include linux/nfs4.h in export.h
Date: Wed,  5 Aug 2015 17:13:19 -0400
Message-Id: <1438809216-4846-2-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1438809216-4846-1-git-send-email-jeff.layton@primarydata.com>
References: <1438264341-18048-1-git-send-email-jeff.layton@primarydata.com>
 <1438809216-4846-1-git-send-email-jeff.layton@primarydata.com>
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

