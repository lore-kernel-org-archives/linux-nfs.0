Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:34062 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932501Ab3ECAdq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 May 2013 20:33:46 -0400
Subject: [PATCH 6/8] Add wait_on_atomic_t() and wake_up_atomic_t()
To: linux-cachefs@redhat.com
From: David Howells <dhowells@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        hjayasur@redhat.com, jlayton@redhat.com, linux-kernel@vger.kernel.org
Date: Fri, 03 May 2013 01:33:44 +0100
Message-ID: <20130503003344.14952.62121.stgit@warthog.procyon.org.uk>
In-Reply-To: <20130503003316.14952.51791.stgit@warthog.procyon.org.uk>
References: <20130503003316.14952.51791.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add wait_on_atomic_t() and wake_up_atomic_t() to indicate became-zero events
on atomic_t types.  This uses the bit-wake waitqueue table.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/linux/wait.h |   29 ++++++++++++++++-
 kernel/wait.c        |   85 ++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 113 insertions(+), 1 deletion(-)

diff --git a/include/linux/wait.h b/include/linux/wait.h
index 7cb64d4..1379562 100644
--- a/include/linux/wait.h
+++ b/include/linux/wait.h
@@ -21,8 +21,12 @@ struct __wait_queue {
 };
 
 struct wait_bit_key {
-	void *flags;
+	union {
+		void *flags;
+		atomic_t *atomic_val;
+	};
 	int bit_nr;
+#define WAIT_ATOMIC_T_BIT_NR -1
 };
 
 struct wait_bit_queue {
@@ -60,6 +64,9 @@ struct task_struct;
 #define __WAIT_BIT_KEY_INITIALIZER(word, bit)				\
 	{ .flags = word, .bit_nr = bit, }
 
+#define __WAIT_ATOMIC_T_KEY_INITIALIZER(p)				\
+	{ .atomic_val = p, .bit_nr = WAIT_ATOMIC_T_BIT_NR, }
+
 extern void __init_waitqueue_head(wait_queue_head_t *q, const char *name, struct lock_class_key *);
 
 #define init_waitqueue_head(q)				\
@@ -146,8 +153,10 @@ void __wake_up_bit(wait_queue_head_t *, void *, int);
 int __wait_on_bit(wait_queue_head_t *, struct wait_bit_queue *, int (*)(void *), unsigned);
 int __wait_on_bit_lock(wait_queue_head_t *, struct wait_bit_queue *, int (*)(void *), unsigned);
 void wake_up_bit(void *, int);
+void wake_up_atomic_t(atomic_t *);
 int out_of_line_wait_on_bit(void *, int, int (*)(void *), unsigned);
 int out_of_line_wait_on_bit_lock(void *, int, int (*)(void *), unsigned);
+int out_of_line_wait_on_atomic_t(atomic_t *, int (*)(atomic_t *), unsigned);
 wait_queue_head_t *bit_waitqueue(void *, int);
 
 #define wake_up(x)			__wake_up(x, TASK_NORMAL, 1, NULL)
@@ -810,5 +819,23 @@ static inline int wait_on_bit_lock(void *word, int bit,
 		return 0;
 	return out_of_line_wait_on_bit_lock(word, bit, action, mode);
 }
+
+/**
+ * wait_on_atomic_t - Wait for an atomic_t to become 0
+ * @val: The atomic value being waited on, a kernel virtual address
+ * @action: the function used to sleep, which may take special actions
+ * @mode: the task state to sleep in
+ *
+ * Wait for an atomic_t to become 0.  We abuse the bit-wait waitqueue table for
+ * the purpose of getting a waitqueue, but we set the key to a bit number
+ * outside of the target 'word'.
+ */
+static inline
+int wait_on_atomic_t(atomic_t *val, int (*action)(atomic_t *), unsigned mode)
+{
+	if (atomic_read(val) == 0)
+		return 0;
+	return out_of_line_wait_on_atomic_t(val, action, mode);
+}
 	
 #endif
diff --git a/kernel/wait.c b/kernel/wait.c
index 6698e0c..ec5b23c 100644
--- a/kernel/wait.c
+++ b/kernel/wait.c
@@ -287,3 +287,88 @@ wait_queue_head_t *bit_waitqueue(void *word, int bit)
 	return &zone->wait_table[hash_long(val, zone->wait_table_bits)];
 }
 EXPORT_SYMBOL(bit_waitqueue);
+
+/*
+ * Manipulate the atomic_t address to produce a better bit waitqueue table hash
+ * index (we're keying off bit -1, but that would produce a horrible hash
+ * value).
+ */
+static inline wait_queue_head_t *atomic_t_waitqueue(atomic_t *p)
+{
+	if (BITS_PER_LONG == 64) {
+		unsigned long q = (unsigned long)p;
+		return bit_waitqueue((void *)(q & ~1), q & 1);
+	}
+	return bit_waitqueue(p, 0);
+}
+
+static int wake_atomic_t_function(wait_queue_t *wait, unsigned mode, int sync,
+				  void *arg)
+{
+	struct wait_bit_key *key = arg;
+	struct wait_bit_queue *wait_bit
+		= container_of(wait, struct wait_bit_queue, wait);
+
+	if (wait_bit->key.atomic_val != key->atomic_val ||
+	    wait_bit->key.bit_nr != key->bit_nr ||
+	    atomic_read(key->atomic_val) != 0)
+		return 0;
+	return autoremove_wake_function(wait, mode, sync, key);
+}
+
+/*
+ * To allow interruptible waiting and asynchronous (i.e. nonblocking) waiting,
+ * the actions of __wait_on_atomic_t() are permitted return codes.  Nonzero
+ * return codes halt waiting and return.
+ */
+static __sched
+int __wait_on_atomic_t(wait_queue_head_t *wq, struct wait_bit_queue *q,
+		       int (*action)(atomic_t *), unsigned mode)
+{
+	int ret = 0;
+
+	do {
+		prepare_to_wait(wq, &q->wait, mode);
+		if (atomic_read(q->key.atomic_val) == 0)
+			ret = (*action)(q->key.atomic_val);
+	} while (!ret && atomic_read(q->key.atomic_val) != 0);
+	finish_wait(wq, &q->wait);
+	return ret;
+}
+
+#define DEFINE_WAIT_ATOMIC_T(name, p)					\
+	struct wait_bit_queue name = {					\
+		.key = __WAIT_ATOMIC_T_KEY_INITIALIZER(p),		\
+		.wait	= {						\
+			.private	= current,			\
+			.func		= wake_atomic_t_function,	\
+			.task_list	=				\
+				LIST_HEAD_INIT((name).wait.task_list),	\
+		},							\
+	}
+
+__sched int out_of_line_wait_on_atomic_t(atomic_t *p, int (*action)(atomic_t *),
+					 unsigned mode)
+{
+	wait_queue_head_t *wq = atomic_t_waitqueue(p);
+	DEFINE_WAIT_ATOMIC_T(wait, p);
+
+	return __wait_on_atomic_t(wq, &wait, action, mode);
+}
+EXPORT_SYMBOL(out_of_line_wait_on_atomic_t);
+
+/**
+ * wake_up_atomic_t - Wake up a waiter on a atomic_t
+ * @word: The word being waited on, a kernel virtual address
+ * @bit: The bit of the word being waited on
+ *
+ * Wake up anyone waiting for the atomic_t to go to zero.
+ *
+ * Abuse the bit-waker function and its waitqueue hash table set (the atomic_t
+ * check is done by the waiter's wake function, not the by the waker itself).
+ */
+void wake_up_atomic_t(atomic_t *p)
+{
+	__wake_up_bit(atomic_t_waitqueue(p), p, WAIT_ATOMIC_T_BIT_NR);
+}
+EXPORT_SYMBOL(wake_up_atomic_t);

