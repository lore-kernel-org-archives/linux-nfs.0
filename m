Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40832 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932906AbbLGQ0L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Dec 2015 11:26:11 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, hch@infradead.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 08/10] locks: Set FL_CLOSE when removing flock locks on close()
Date: Mon,  7 Dec 2015 11:26:07 -0500
Message-Id: <065c82364ff6bcecdbbb05550ff7b61f02469428.1449503713.git.bcodding@redhat.com>
In-Reply-To: <cover.1449503713.git.bcodding@redhat.com>
References: <cover.1449503713.git.bcodding@redhat.com>
In-Reply-To: <cover.1449503713.git.bcodding@redhat.com>
References: <cover.1449503713.git.bcodding@redhat.com>
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

