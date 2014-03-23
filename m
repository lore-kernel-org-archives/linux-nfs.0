Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47910 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752225AbaCWBMb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 22 Mar 2014 21:12:31 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 36/50] nfsd4: allow larger 4.1 session drc slots
Date: Sat, 22 Mar 2014 21:12:07 -0400
Message-Id: <1395537141-10389-37-git-send-email-bfields@redhat.com>
In-Reply-To: <1395537141-10389-1-git-send-email-bfields@redhat.com>
References: <1395537141-10389-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

The client is actually asking for 2532 bytes.  I suspect that's a
mistake.  But maybe we can allow some more.  In theory lock needs more
if it might return a maximum-length lockowner in the denied case.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/state.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 424d8f5..66db998 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -123,7 +123,7 @@ static inline struct nfs4_delegation *delegstateid(struct nfs4_stid *s)
 /* Maximum number of operations per session compound */
 #define NFSD_MAX_OPS_PER_COMPOUND	16
 /* Maximum  session per slot cache size */
-#define NFSD_SLOT_CACHE_SIZE		1024
+#define NFSD_SLOT_CACHE_SIZE		2048
 /* Maximum number of NFSD_SLOT_CACHE_SIZE slots per session */
 #define NFSD_CACHE_SIZE_SLOTS_PER_SESSION	32
 #define NFSD_MAX_MEM_PER_SESSION  \
-- 
1.8.5.3

