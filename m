Return-Path: linux-fsdevel-owner@vger.kernel.org
Subject: [PATCH 10/13] FS-Cache: Fix cancellation of in-progress operation
From: David Howells <dhowells@redhat.com>
To: linux-cachefs@redhat.com
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Thu, 26 Feb 2015 14:02:58 +0000
Message-ID: <20150226140258.2387.23616.stgit@warthog.procyon.org.uk>
In-Reply-To: <20150226140155.2387.70579.stgit@warthog.procyon.org.uk>
References: <20150226140155.2387.70579.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Cancellation of an in-progress operation needs to update the relevant counters
and start any operations that are pending waiting on this one.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/fscache/operation.c |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/fs/fscache/operation.c b/fs/fscache/operation.c
index 9761df4fc2ab..b6bf5f399d70 100644
--- a/fs/fscache/operation.c
+++ b/fs/fscache/operation.c
@@ -365,6 +365,13 @@ int fscache_cancel_op(struct fscache_operation *op,
 			wake_up_bit(&op->flags, FSCACHE_OP_WAITING);
 		ret = 0;
 	} else if (op->state == FSCACHE_OP_ST_IN_PROGRESS && cancel_in_progress_op) {
+		ASSERTCMP(object->n_in_progress, >, 0);
+		if (test_bit(FSCACHE_OP_EXCLUSIVE, &op->flags))
+			object->n_exclusive--;
+		object->n_in_progress--;
+		if (object->n_in_progress == 0)
+			fscache_start_operations(object);
+
 		fscache_stat(&fscache_n_op_cancelled);
 		if (do_cancel)
 			do_cancel(op);

