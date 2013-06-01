Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:23794 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755677Ab3FADIL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 31 May 2013 23:08:11 -0400
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk, matthew@wil.cx, bfields@fieldses.org
Cc: dhowells@redhat.com, sage@inktank.com, smfrench@gmail.com,
        swhiteho@redhat.com, Trond.Myklebust@netapp.com,
        akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        linux-afs@lists.infradead.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        cluster-devel@redhat.com, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, piastryyy@gmail.com
Subject: [PATCH v1 04/11] locks: make "added" in __posix_lock_file a bool
Date: Fri, 31 May 2013 23:07:27 -0400
Message-Id: <1370056054-25449-5-git-send-email-jlayton@redhat.com>
In-Reply-To: <1370056054-25449-1-git-send-email-jlayton@redhat.com>
References: <1370056054-25449-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...save 3 bytes of stack space.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/locks.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index a7d2253..cef0e04 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -800,7 +800,8 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
 	struct file_lock *left = NULL;
 	struct file_lock *right = NULL;
 	struct file_lock **before;
-	int error, added = 0;
+	int error;
+	bool added = false;
 
 	/*
 	 * We may need two file_lock structures for this operation,
@@ -894,7 +895,7 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
 				continue;
 			}
 			request = fl;
-			added = 1;
+			added = true;
 		}
 		else {
 			/* Processing for different lock types is a bit
@@ -905,7 +906,7 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
 			if (fl->fl_start > request->fl_end)
 				break;
 			if (request->fl_type == F_UNLCK)
-				added = 1;
+				added = true;
 			if (fl->fl_start < request->fl_start)
 				left = fl;
 			/* If the next lock in the list has a higher end
@@ -935,7 +936,7 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
 				locks_release_private(fl);
 				locks_copy_private(fl, request);
 				request = fl;
-				added = 1;
+				added = true;
 			}
 		}
 		/* Go on to next lock.
-- 
1.7.1

