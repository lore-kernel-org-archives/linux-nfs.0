Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:38839 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756104Ab3BAL1n (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Feb 2013 06:27:43 -0500
Subject: [PATCH 1/2] per-cpu semaphores: export symbols to modules
To: bfields@fieldses.org, akpm@linux-foundation.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Fri, 01 Feb 2013 14:28:30 +0300
Message-ID: <20130201112830.24066.48656.stgit@localhost.localdomain>
In-Reply-To: <20130201111046.24066.72836.stgit@localhost.localdomain>
References: <20130201111046.24066.72836.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Per-cpu semaphores are desired to be used by NFS kernel server.
As Bruce Fields suggested:

	"The server rpc code goes to some care not to write to any global
	structure, to prevent server threads running on multiple cores from
	bouncing cache lines between them.

	But my understanding is that even down_read() does modify the semaphore.
	So we might want something like the percpu semaphore describe in
	Documentation/percpu-rw-semaphore.txt."


So add EXPORT_SYMBOL_GPL() for all publically accessible per-cpu rw semaphores
and move to obj-y so that modules may use this library.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 lib/Makefile       |    2 +-
 lib/percpu-rwsem.c |    6 ++++++
 2 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/lib/Makefile b/lib/Makefile
index 02ed6c0..22e0c03 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -40,7 +40,7 @@ obj-$(CONFIG_DEBUG_LOCKING_API_SELFTESTS) += locking-selftest.o
 obj-$(CONFIG_DEBUG_SPINLOCK) += spinlock_debug.o
 lib-$(CONFIG_RWSEM_GENERIC_SPINLOCK) += rwsem-spinlock.o
 lib-$(CONFIG_RWSEM_XCHGADD_ALGORITHM) += rwsem.o
-lib-$(CONFIG_PERCPU_RWSEM) += percpu-rwsem.o
+obj-$(CONFIG_PERCPU_RWSEM) += percpu-rwsem.o
 
 CFLAGS_hweight.o = $(subst $(quote),,$(CONFIG_ARCH_HWEIGHT_CFLAGS))
 obj-$(CONFIG_GENERIC_HWEIGHT) += hweight.o
diff --git a/lib/percpu-rwsem.c b/lib/percpu-rwsem.c
index 652a8ee..7f6aa71 100644
--- a/lib/percpu-rwsem.c
+++ b/lib/percpu-rwsem.c
@@ -7,6 +7,7 @@
 #include <linux/rcupdate.h>
 #include <linux/sched.h>
 #include <linux/errno.h>
+#include <linux/export.h>
 
 int __percpu_init_rwsem(struct percpu_rw_semaphore *brw,
 			const char *name, struct lock_class_key *rwsem_key)
@@ -22,6 +23,7 @@ int __percpu_init_rwsem(struct percpu_rw_semaphore *brw,
 	init_waitqueue_head(&brw->write_waitq);
 	return 0;
 }
+EXPORT_SYMBOL_GPL(__percpu_init_rwsem);
 
 void percpu_free_rwsem(struct percpu_rw_semaphore *brw)
 {
@@ -87,6 +89,7 @@ void percpu_down_read(struct percpu_rw_semaphore *brw)
 	/* avoid up_read()->rwsem_release() */
 	__up_read(&brw->rw_sem);
 }
+EXPORT_SYMBOL_GPL(percpu_down_read);
 
 void percpu_up_read(struct percpu_rw_semaphore *brw)
 {
@@ -99,6 +102,7 @@ void percpu_up_read(struct percpu_rw_semaphore *brw)
 	if (atomic_dec_and_test(&brw->slow_read_ctr))
 		wake_up_all(&brw->write_waitq);
 }
+EXPORT_SYMBOL_GPL(percpu_up_read);
 
 static int clear_fast_ctr(struct percpu_rw_semaphore *brw)
 {
@@ -150,6 +154,7 @@ void percpu_down_write(struct percpu_rw_semaphore *brw)
 	/* wait for all readers to complete their percpu_up_read() */
 	wait_event(brw->write_waitq, !atomic_read(&brw->slow_read_ctr));
 }
+EXPORT_SYMBOL_GPL(percpu_down_write);
 
 void percpu_up_write(struct percpu_rw_semaphore *brw)
 {
@@ -163,3 +168,4 @@ void percpu_up_write(struct percpu_rw_semaphore *brw)
 	/* the last writer unblocks update_fast_ctr() */
 	atomic_dec(&brw->write_ctr);
 }
+EXPORT_SYMBOL_GPL(percpu_up_write);

