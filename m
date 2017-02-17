Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50050 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934889AbdBQSq0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 17 Feb 2017 13:46:26 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 3/4] locks: Set FL_CLOSE when removing flock locks on close()
Date: Fri, 17 Feb 2017 13:46:19 -0500
Message-Id: <a9494275523dd233b3c5fd94d37ec0ee8e7f4934.1487356965.git.bcodding@redhat.com>
In-Reply-To: <cover.1487356965.git.bcodding@redhat.com>
References: <cover.1487356965.git.bcodding@redhat.com>
In-Reply-To: <cover.1487356965.git.bcodding@redhat.com>
References: <cover.1487356965.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Set FL_CLOSE in fl_flags as in locks_remove_posix() when clearing locks.
NFS will check for this flag to ensure an unlock is sent in a following
patch.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/locks.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/locks.c b/fs/locks.c
index 26811321d39b..af2031a1fcff 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -2504,7 +2504,7 @@ locks_remove_flock(struct file *filp, struct file_lock_context *flctx)
 		.fl_owner = filp,
 		.fl_pid = current->tgid,
 		.fl_file = filp,
-		.fl_flags = FL_FLOCK,
+		.fl_flags = FL_FLOCK | FL_CLOSE,
 		.fl_type = F_UNLCK,
 		.fl_end = OFFSET_MAX,
 	};
-- 
2.9.3

