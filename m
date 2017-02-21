Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35250 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751925AbdBUPjU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 21 Feb 2017 10:39:20 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 3/4] locks: Set FL_CLOSE when removing flock locks on close()
Date: Tue, 21 Feb 2017 10:39:16 -0500
Message-Id: <c43ab767372bd73a60a4e1c97b39bb6fc0722590.1487691345.git.bcodding@redhat.com>
In-Reply-To: <cover.1487691345.git.bcodding@redhat.com>
References: <cover.1487691345.git.bcodding@redhat.com>
In-Reply-To: <cover.1487691345.git.bcodding@redhat.com>
References: <cover.1487691345.git.bcodding@redhat.com>
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

