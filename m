Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:36567 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933704AbbHKJag (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Aug 2015 05:30:36 -0400
Received: by wicja10 with SMTP id ja10so67696818wic.1
        for <linux-nfs@vger.kernel.org>; Tue, 11 Aug 2015 02:30:35 -0700 (PDT)
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: Fix two typos in comments
Date: Tue, 11 Aug 2015 11:30:31 +0200
Message-Id: <1439285431-16215-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

(espect -> expect) and (no -> know)

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/nfsd/nfs4acl.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4acl.c b/fs/nfsd/nfs4acl.c
index eb5accf..9c17bcd7 100644
--- a/fs/nfsd/nfs4acl.c
+++ b/fs/nfsd/nfs4acl.c
@@ -100,7 +100,7 @@ deny_mask_from_posix(unsigned short perm, u32 flags)
 /* We only map from NFSv4 to POSIX ACLs when setting ACLs, when we err on the
  * side of being more restrictive, so the mode bit mapping below is
  * pessimistic.  An optimistic version would be needed to handle DENY's,
- * but we espect to coalesce all ALLOWs and DENYs before mapping to mode
+ * but we expect to coalesce all ALLOWs and DENYs before mapping to mode
  * bits. */
 
 static void
@@ -458,7 +458,7 @@ init_state(struct posix_acl_state *state, int cnt)
 	state->empty = 1;
 	/*
 	 * In the worst case, each individual acl could be for a distinct
-	 * named user or group, but we don't no which, so we allocate
+	 * named user or group, but we don't know which, so we allocate
 	 * enough space for either:
 	 */
 	alloc = sizeof(struct posix_ace_state_array)
-- 
2.4.2

