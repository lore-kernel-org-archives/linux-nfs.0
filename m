Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ye0-f176.google.com ([209.85.213.176]:49338 "EHLO
	mail-ye0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750906Ab3A1TsC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jan 2013 14:48:02 -0500
Received: by mail-ye0-f176.google.com with SMTP id m1so469952yen.35
        for <linux-nfs@vger.kernel.org>; Mon, 28 Jan 2013 11:48:01 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 03/16] nfsd: get rid of RC_INTR
Date: Mon, 28 Jan 2013 14:41:09 -0500
Message-Id: <1359402082-29195-4-git-send-email-jlayton@redhat.com>
In-Reply-To: <1359402082-29195-1-git-send-email-jlayton@redhat.com>
References: <1359402082-29195-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The reply cache code never returns this status.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/cache.h  | 3 +--
 fs/nfsd/nfssvc.c | 1 -
 2 files changed, 1 insertion(+), 3 deletions(-)

diff --git a/fs/nfsd/cache.h b/fs/nfsd/cache.h
index 2cac76c..f8c6df8 100644
--- a/fs/nfsd/cache.h
+++ b/fs/nfsd/cache.h
@@ -50,8 +50,7 @@ enum {
 enum {
 	RC_DROPIT,
 	RC_REPLY,
-	RC_DOIT,
-	RC_INTR
+	RC_DOIT
 };
 
 /*
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index cee62ab..40cb1cb 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -652,7 +652,6 @@ nfsd_dispatch(struct svc_rqst *rqstp, __be32 *statp)
 
 	/* Check whether we have this call in the cache. */
 	switch (nfsd_cache_lookup(rqstp)) {
-	case RC_INTR:
 	case RC_DROPIT:
 		return 0;
 	case RC_REPLY:
-- 
1.7.11.7

