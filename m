Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36734 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751966AbdLVQdw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 22 Dec 2017 11:33:52 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] lockd: fix uninitialized fl_pid in NLMSVC
Date: Fri, 22 Dec 2017 11:33:51 -0500
Message-Id: <6c2c80f9d939dfb8081156db5bf1f85a837c8eb1.1513959252.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In commit 9d5b86ac13c5 "fs/locks: Remove fl_nspid and use fs-specific l_pid
for remote locks" the fl_pid number is translated into the namespace of the
viewer when the viewer looks at the lock, and if a lock's fl_pid does not
belong to the viewer's pid namespace then that lock is not displayed in
/proc/locks or /proc/<pid>/fdinfo/<fd>.

That change made it easy to notice that NLM has been using an uninitialized
value for fl_pid when NLM locks would only show up in the listings if their
fl_pid values happened to collide with existing pids.  Fix this by
correctly initializing fl_pid.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/lockd/svc4proc.c | 1 +
 fs/lockd/svcproc.c  | 1 +
 2 files changed, 2 insertions(+)

diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index 1bddf70d9656..21980440114d 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -47,6 +47,7 @@ nlm4svc_retrieve_args(struct svc_rqst *rqstp, struct nlm_args *argp,
 		/* Set up the missing parts of the file_lock structure */
 		lock->fl.fl_file  = file->f_file;
 		lock->fl.fl_owner = (fl_owner_t) host;
+		lock->fl.fl_pid = current->tgid;
 		lock->fl.fl_lmops = &nlmsvc_lock_operations;
 	}
 
diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
index 0d670c5c378f..9b03719574c3 100644
--- a/fs/lockd/svcproc.c
+++ b/fs/lockd/svcproc.c
@@ -77,6 +77,7 @@ nlmsvc_retrieve_args(struct svc_rqst *rqstp, struct nlm_args *argp,
 		/* Set up the missing parts of the file_lock structure */
 		lock->fl.fl_file  = file->f_file;
 		lock->fl.fl_owner = (fl_owner_t) host;
+		lock->fl.fl_pid = current->tgid;
 		lock->fl.fl_lmops = &nlmsvc_lock_operations;
 	}
 
-- 
2.9.3

