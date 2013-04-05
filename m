Return-Path: linux-nfs-owner@vger.kernel.org
Received: from g4t0016.houston.hp.com ([15.201.24.19]:16468 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1162246Ab3DEQ6P (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Apr 2013 12:58:15 -0400
From: Waiman Long <Waiman.Long@hp.com>
Cc: Waiman Long <Waiman.Long@hp.com>, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, autofs@vger.kernel.org,
        ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-nfs@vger.kernel.org,
        "Chandramouleeswaran, Aswin" <aswin@hp.com>,
        "Norton, Scott J" <scott.norton@hp.com>,
        Andi Kleen <andi@firstfloor.org>, Dave Chinner <david@fromorbit.com>
Subject: [PATCH RFC v2 2/4] dcache: introduce a new sequence read/write lock type
Date: Fri,  5 Apr 2013 12:57:39 -0400
Message-Id: <1365181061-30787-3-git-send-email-Waiman.Long@hp.com>
In-Reply-To: <1365181061-30787-1-git-send-email-Waiman.Long@hp.com>
References: <1365181061-30787-1-git-send-email-Waiman.Long@hp.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Jeff Layton <jlayton@redhat.com>,
        Miklos Szeredi <mszeredi@suse.cz>, Ian Kent <raven@themaw.net>,
        Sage Weil <sage@inktank.com>, Steve French <sfrench@samba.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Eric Paris <eparis@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The current sequence lock supports 2 types of lock users:

1. A reader who wants a consistent set of information and is willing
   to retry if the information changes. The information that the
   reader needs cannot contain pointers, because any writer could
   invalidate a pointer that a reader was following. This reader
   will never block but they may have to retry if a writer is in
   progress.
2. A writer who may need to modify content of a data structure. Writer
   blocks only if another writer is in progress.

This type of lock is suitable for cases where there are a large number
of readers and much less writers. However, it has a limitation that
reader who may want to follow pointer or cannot tolerate unexpected
changes in the protected data structure must take the writer lock
even if it doesn't need to make any changes.

To more efficiently support this type of readers, a new lock type is
introduced by this patch: sequence read/write lock. Two types of readers
are supported by this new lock:

1. Reader who has the same behavior as a sequence lock reader.
2. Reader who may need to follow pointers. This reader will block if
   a writer is in progress. In turn, it blocks a writer if it is in
   progress. Multiple readers of this type can proceed concurrently.
   Taking this reader lock won't update the sequence number.

This new lock type is a combination of the sequence lock and read/write
lock. Hence it will have the same limitation of a read/write lock that
writers may be starved if there is a lot of contention.

Signed-off-by: Waiman Long <Waiman.Long@hp.com>
---
 include/linux/seqrwlock.h |  137 +++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 137 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/seqrwlock.h

diff --git a/include/linux/seqrwlock.h b/include/linux/seqrwlock.h
new file mode 100644
index 0000000..c6145ff
--- /dev/null
+++ b/include/linux/seqrwlock.h
@@ -0,0 +1,137 @@
+#ifndef __LINUX_SEQRWLOCK_H
+#define __LINUX_SEQRWLOCK_H
+/*
+ * Sequence Read/Write Lock
+ * ------------------------
+ * This new lock type is a combination of the sequence lock and read/write
+ * lock. Three types of lock users are supported:
+ * 1. Reader who wants a consistent set of information and is willing to
+ *    retry if the information changes. The information that the reader
+ *    need cannot contain pointers, because any writer could invalidate
+ *    a pointer that a reader was following. This reader never block but
+ *    they may have to retry if a writer is in progress.
+ * 2. Reader who may need to follow pointers. This reader will block if
+ *    a writer is in progress.
+ * 3. Writer who may need to modify content of a data structure. Writer
+ *    blocks if another writer or the 2nd type of reader is in progress.
+ *
+ * The current implementation layered on top of the regular read/write
+ * lock. There is a chance that the writers may be starved by the readers.
+ * So be careful when you decided to use this lock.
+ *
+ * Expected 1st type reader usage:
+ * 	do {
+ *	    seq = read_seqrwbegin(&foo);
+ * 	...
+ *      } while (read_seqrwretry(&foo, seq));
+ *
+ * Expected 2nd type reader usage:
+ * 	read_seqrwlock(&foo)
+ * 	...
+ * 	read_seqrwunlock(&foo)
+ *
+ * Expected writer usage:
+ * 	write_seqrwlock(&foo)
+ * 	...
+ * 	write_seqrwunlock(&foo)
+ *
+ * Based on the seqlock.h file
+ * by Waiman Long
+ */
+
+#include <linux/rwlock.h>
+#include <linux/preempt.h>
+#include <asm/processor.h>
+
+typedef struct {
+	unsigned sequence;
+	rwlock_t lock;
+} seqrwlock_t;
+
+#define __SEQRWLOCK_UNLOCKED(lockname) \
+		 { 0, __RW_LOCK_UNLOCKED(lockname) }
+
+#define seqrwlock_init(x)				\
+	do {						\
+		(x)->sequence = 0;			\
+		rwlock_init(&(x)->lock);		\
+	} while (0)
+
+#define DEFINE_SEQRWLOCK(x) \
+		seqrwlock_t x = __SEQRWLOCK_UNLOCKED(x)
+
+/* For writer:
+ * Lock out other writers and 2nd type of readers and update the sequence
+ * number. Don't need preempt_disable() because that is in the read_lock and
+ * write_lock already.
+ */
+static inline void write_seqrwlock(seqrwlock_t *sl)
+{
+	write_lock(&sl->lock);
+	++sl->sequence;
+	smp_wmb();
+}
+
+static inline void write_seqrwunlock(seqrwlock_t *sl)
+{
+	smp_wmb();
+	sl->sequence++;
+	write_unlock(&sl->lock);
+}
+
+static inline int write_tryseqrwlock(seqrwlock_t *sl)
+{
+	int ret = write_trylock(&sl->lock);
+
+	if (ret) {
+		++sl->sequence;
+		smp_wmb();
+	}
+	return ret;
+}
+
+/* For 2nd type of reader:
+ * Lock out other writers, but don't update the sequence number
+ */
+static inline void read_seqrwlock(seqrwlock_t *sl)
+{
+	read_lock(&sl->lock);
+}
+
+static inline void read_seqrwunlock(seqrwlock_t *sl)
+{
+	read_unlock(&sl->lock);
+}
+
+static inline int read_tryseqrwlock(seqrwlock_t *sl)
+{
+	return read_trylock(&sl->lock);
+}
+
+/* Start of read calculation -- fetch last complete writer token */
+static __always_inline unsigned read_seqrwbegin(const seqrwlock_t *sl)
+{
+	unsigned ret;
+
+repeat:
+	ret = ACCESS_ONCE(sl->sequence);
+	if (unlikely(ret & 1)) {
+		cpu_relax();
+		goto repeat;
+	}
+	smp_rmb();
+	return ret;
+}
+
+/*
+ * Test if reader processed invalid data.
+ *
+ * If sequence value changed then writer changed data while in section.
+ */
+static __always_inline int read_seqrwretry(const seqrwlock_t *sl, unsigned start)
+{
+	smp_rmb();
+	return unlikely(sl->sequence != start);
+}
+
+#endif /* __LINUX_SEQLOCK_H */
-- 
1.7.1

