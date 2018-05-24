Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:40426 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755082AbeEXN0z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 24 May 2018 09:26:55 -0400
From: Waiman Long <longman@redhat.com>
To: Ingo Molnar <mingo@redhat.com>,
        Peter Zijlstra <peterz@infradead.org>,
        Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>,
        Dan Williams <dan.j.williams@intel.com>,
        Arnd Bergmann <arnd@arndb.de>, linux-nfs@vger.kernel.org,
        Waiman Long <longman@redhat.com>
Subject: [PATCH] locking/rwsem: Fix up_read_non_owner() warning with DEBUG_RWSEMS
Date: Thu, 24 May 2018 09:26:38 -0400
Message-Id: <1527168398-4291-1-git-send-email-longman@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It was found that the use of up_read_non_owner() in NFS was causing
the following warning when DEBUG_RWSEMS was configured.

  DEBUG_LOCKS_WARN_ON(sem->owner != ((struct task_struct *)(1UL << 0)))

Looking into the rwsem.c file, it was discovered that the corresponding
down_read_non_owner() function was not setting the owner field properly.
This is fixed now, and the warning should be gone.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 kernel/locking/rwsem.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/kernel/locking/rwsem.c b/kernel/locking/rwsem.c
index bc1e507..776308d 100644
--- a/kernel/locking/rwsem.c
+++ b/kernel/locking/rwsem.c
@@ -181,6 +181,7 @@ void down_read_non_owner(struct rw_semaphore *sem)
 	might_sleep();
 
 	__down_read(sem);
+	rwsem_set_reader_owned(sem);
 }
 
 EXPORT_SYMBOL(down_read_non_owner);
-- 
1.8.3.1

