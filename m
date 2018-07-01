Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:37602 "EHLO
        mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1031929AbeGAQmS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 1 Jul 2018 12:42:18 -0400
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        stable@vger.kernel.org, Waiman Long <longman@redhat.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        "Peter Zijlstra (Intel)" <peterz@infradead.org>,
        Gavin Schenk <g.schenk@eckelmann.de>,
        Davidlohr Bueso <dave@stgolabs.net>,
        Dan Williams <dan.j.williams@intel.com>,
        Arnd Bergmann <arnd@arndb.de>, linux-nfs@vger.kernel.org
Subject: [PATCH 4.17 126/220] locking/rwsem: Fix up_read_non_owner() warning with DEBUG_RWSEMS
Date: Sun,  1 Jul 2018 18:22:30 +0200
Message-Id: <20180701160913.605670833@linuxfoundation.org>
In-Reply-To: <20180701160908.272447118@linuxfoundation.org>
References: <20180701160908.272447118@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

4.17-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Waiman Long <longman@redhat.com>

commit 03eeafdd9ab06a770d42c2b264d50dff7e2f4eee upstream.

It was found that the use of up_read_non_owner() in NFS was causing
the following warning when DEBUG_RWSEMS was configured.

  DEBUG_LOCKS_WARN_ON(sem->owner != ((struct task_struct *)(1UL << 0)))

Looking into the rwsem.c file, it was discovered that the corresponding
down_read_non_owner() function was not setting the owner field properly.
This is fixed now, and the warning should be gone.

Fixes: 5149cbac4235 ("locking/rwsem: Add DEBUG_RWSEMS to look for lock/unlock mismatches")
Signed-off-by: Waiman Long <longman@redhat.com>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Tested-by: Gavin Schenk <g.schenk@eckelmann.de>
Cc: Davidlohr Bueso <dave@stgolabs.net>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: linux-nfs@vger.kernel.org
Cc: stable@vger.kernel.org
Link: https://lkml.kernel.org/r/1527168398-4291-1-git-send-email-longman@redhat.com
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 kernel/locking/rwsem.c |    1 +
 1 file changed, 1 insertion(+)

--- a/kernel/locking/rwsem.c
+++ b/kernel/locking/rwsem.c
@@ -181,6 +181,7 @@ void down_read_non_owner(struct rw_semap
 	might_sleep();
 
 	__down_read(sem);
+	rwsem_set_reader_owned(sem);
 }
 
 EXPORT_SYMBOL(down_read_non_owner);


