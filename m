Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60126 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750803AbbL1Q2I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Dec 2015 11:28:08 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 08/10] locks: Set FL_CLOSE when removing flock locks on close()
Date: Mon, 28 Dec 2015 11:28:04 -0500
Message-Id: <999b2265fc3122b43f4da46b577f53f5555db2ab.1451319354.git.bcodding@redhat.com>
In-Reply-To: <cover.1451319354.git.bcodding@redhat.com>
References: <cover.1451319354.git.bcodding@redhat.com>
In-Reply-To: <cover.1451319354.git.bcodding@redhat.com>
References: <cover.1451319354.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use FL_CLOSE in fl_flags as in locks_remove_posix() when clearing locks.
NFS will depend on this flag to properly defer an unlock until IO under the
current lock has completed.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/locks.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 0d2b326..9aea07a 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -2423,7 +2423,7 @@ locks_remove_flock(struct file *filp, struct file_lock_context *flctx)
 		.fl_owner = filp,
 		.fl_pid = current->tgid,
 		.fl_file = filp,
-		.fl_flags = FL_FLOCK,
+		.fl_flags = FL_FLOCK | FL_CLOSE,
 		.fl_type = F_UNLCK,
 		.fl_end = OFFSET_MAX,
 	};
-- 
1.7.1

