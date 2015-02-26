Return-Path: linux-fsdevel-owner@vger.kernel.org
Subject: [PATCH 09/13] FS-Cache: Count the number of initialised operations
From: David Howells <dhowells@redhat.com>
To: linux-cachefs@redhat.com
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Thu, 26 Feb 2015 14:02:51 +0000
Message-ID: <20150226140251.2387.93288.stgit@warthog.procyon.org.uk>
In-Reply-To: <20150226140155.2387.70579.stgit@warthog.procyon.org.uk>
References: <20150226140155.2387.70579.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Count and display through /proc/fs/fscache/stats the number of initialised
operations.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 Documentation/filesystems/caching/fscache.txt |    3 ++-
 fs/fscache/internal.h                         |    1 +
 fs/fscache/operation.c                        |    1 +
 fs/fscache/stats.c                            |    4 +++-
 4 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/Documentation/filesystems/caching/fscache.txt b/Documentation/filesystems/caching/fscache.txt
index 66fa7fbccfa4..50f0a5757f48 100644
--- a/Documentation/filesystems/caching/fscache.txt
+++ b/Documentation/filesystems/caching/fscache.txt
@@ -284,8 +284,9 @@ proc files.
 		enq=N	Number of times async ops queued for processing
 		can=N	Number of async ops cancelled
 		rej=N	Number of async ops rejected due to object lookup/create failure
+		ini=N	Number of async ops initialised
 		dfr=N	Number of async ops queued for deferred release
-		rel=N	Number of async ops released
+		rel=N	Number of async ops released (should equal ini=N when idle)
 		gc=N	Number of deferred-release async ops garbage collected
 	CacheOp	alo=N	Number of in-progress alloc_object() cache ops
 		luo=N	Number of in-progress lookup_object() cache ops
diff --git a/fs/fscache/internal.h b/fs/fscache/internal.h
index 87c4544ec912..a63225116db6 100644
--- a/fs/fscache/internal.h
+++ b/fs/fscache/internal.h
@@ -165,6 +165,7 @@ extern atomic_t fscache_n_op_pend;
 extern atomic_t fscache_n_op_run;
 extern atomic_t fscache_n_op_enqueue;
 extern atomic_t fscache_n_op_deferred_release;
+extern atomic_t fscache_n_op_initialised;
 extern atomic_t fscache_n_op_release;
 extern atomic_t fscache_n_op_gc;
 extern atomic_t fscache_n_op_cancelled;
diff --git a/fs/fscache/operation.c b/fs/fscache/operation.c
index 61a6e78b85fa..9761df4fc2ab 100644
--- a/fs/fscache/operation.c
+++ b/fs/fscache/operation.c
@@ -39,6 +39,7 @@ void fscache_operation_init(struct fscache_operation *op,
 	op->processor = processor;
 	op->release = release;
 	INIT_LIST_HEAD(&op->pend_link);
+	fscache_stat(&fscache_n_op_initialised);
 }
 EXPORT_SYMBOL(fscache_operation_init);
 
diff --git a/fs/fscache/stats.c b/fs/fscache/stats.c
index 3a722e8f2307..7cfa0aacdf6d 100644
--- a/fs/fscache/stats.c
+++ b/fs/fscache/stats.c
@@ -23,6 +23,7 @@ atomic_t fscache_n_op_run;
 atomic_t fscache_n_op_enqueue;
 atomic_t fscache_n_op_requeue;
 atomic_t fscache_n_op_deferred_release;
+atomic_t fscache_n_op_initialised;
 atomic_t fscache_n_op_release;
 atomic_t fscache_n_op_gc;
 atomic_t fscache_n_op_cancelled;
@@ -251,7 +252,8 @@ static int fscache_stats_show(struct seq_file *m, void *v)
 		   atomic_read(&fscache_n_op_enqueue),
 		   atomic_read(&fscache_n_op_cancelled),
 		   atomic_read(&fscache_n_op_rejected));
-	seq_printf(m, "Ops    : dfr=%u rel=%u gc=%u\n",
+	seq_printf(m, "Ops    : ini=%u dfr=%u rel=%u gc=%u\n",
+		   atomic_read(&fscache_n_op_initialised),
 		   atomic_read(&fscache_n_op_deferred_release),
 		   atomic_read(&fscache_n_op_release),
 		   atomic_read(&fscache_n_op_gc));

