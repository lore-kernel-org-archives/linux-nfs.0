From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 1/2] locks: allow lockd to process blocked locks during grace period
Date: Tue, 19 Aug 2008 18:12:42 -0400
Message-ID: <1219183963-17476-1-git-send-email-bfields@citi.umich.edu>
References: <20080819221209.GF8331@fieldses.org>
Cc: linux-kernel@vger.kernel.org, neilb@suse.de,
	Trond.Myklebust@netapp.com,
	NAKANO Hiroaki <nakano.hiroaki-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>,
	=?utf-8?q?Fernando=20Luis=20V=C3=A1zquez=20Cao?=
	<fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:60898 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752810AbYHSWMo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Aug 2008 18:12:44 -0400
In-Reply-To: <20080819221209.GF8331@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The check here is currently harmless but unnecessary, since, as the
comment notes, there aren't any blocked-lock callbacks to process
during the grace period anyway.

And eventually we want to allow multiple grace periods that come and go
for different filesystems over the course of the lifetime of lockd, at
which point this check is just going to get in the way.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/lockd/svc.c |   12 +++---------
 1 files changed, 3 insertions(+), 9 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 1553fec..bdc607b 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -158,15 +158,9 @@ lockd(void *vrqstp)
 			continue;
 		}
 
-		/*
-		 * Retry any blocked locks that have been notified by
-		 * the VFS. Don't do this during grace period.
-		 * (Theoretically, there shouldn't even be blocked locks
-		 * during grace period).
-		 */
-		if (!nlmsvc_grace_period) {
-			timeout = nlmsvc_retry_blocked();
-		} else if (time_before(grace_period_expire, jiffies))
+		timeout = nlmsvc_retry_blocked();
+
+		if (time_before(grace_period_expire, jiffies))
 			clear_grace_period();
 
 		/*
-- 
1.5.5.rc1

