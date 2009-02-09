From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] lockd: fix regression in lockd's handling of blocked locks
Date: Mon, 9 Feb 2009 13:24:25 -0500
Message-ID: <20090209182425.GJ10297@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	stable@kernel.org, Frank van Maarseveen <frankvm@frankvm.com>,
	Miklos Szeredi <mszeredi@suse.cz>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:42043 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754084AbZBISYT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Feb 2009 13:24:19 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

If a client requests a blocking lock, is denied, then requests it again,
then here in nlmsvc_lock() we will call vfs_lock_file() without FL_SLEEP
set, because we've already queued a block and don't need the locks code
to do it again.

But that means vfs_lock_file() will return -EAGAIN instead of
FILE_LOCK_DENIED.  So we still need to translate that -EAGAIN return
into a nlm_lck_blocked error in this case, and put ourselves back on
lockd's block list.

The bug was introduced by bde74e4bc64415b1 "locks: add special return
value for asynchronous locks".

Thanks to Frank van Maarseveen for the report; his original test
case was essentially

	for i in `seq 30`; do flock /nfsmount/foo sleep 10 & done

Tested-by: Frank van Maarseveen <frankvm@frankvm.com>
Reported-by: Frank van Maarseveen <frankvm@frankvm.com>
Cc: Miklos Szeredi <mszeredi@suse.cz>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/lockd/svclock.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

Also available from

	git://linux-nfs.org/~bfields/linux.git for-2.6.29

Also appropriate for stable.--b.

diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index 6063a8e..763b78a 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -427,7 +427,7 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
 			goto out;
 		case -EAGAIN:
 			ret = nlm_lck_denied;
-			goto out;
+			break;
 		case FILE_LOCK_DEFERRED:
 			if (wait)
 				break;
@@ -443,6 +443,10 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
 			goto out;
 	}
 
+	ret = nlm_lck_denied;
+	if (!wait)
+		goto out;
+
 	ret = nlm_lck_blocked;
 
 	/* Append to list of blocked */
-- 
1.5.6.3

