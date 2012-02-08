Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:59999 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757559Ab2BHVTO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Feb 2012 16:19:14 -0500
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 14/17] FS-Cache: Don't mask off the object event mask when
 printing it
To: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-cachefs@redhat.com,
        linux-nfs@vger.kernel.org
Date: Wed, 08 Feb 2012 21:19:03 +0000
Message-ID: <20120208211903.15607.54140.stgit@warthog.procyon.org.uk>
In-Reply-To: <20120208211640.15607.58537.stgit@warthog.procyon.org.uk>
References: <20120208211640.15607.58537.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Don't mask off the object event mask when printing it.  That way it can be seen
if threre are bits set that shouldn't be.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/cachefiles/namei.c    |    3 +--
 fs/fscache/object-list.c |    2 +-
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/cachefiles/namei.c b/fs/cachefiles/namei.c
index a0358c2..0fd9b6d 100644
--- a/fs/cachefiles/namei.c
+++ b/fs/cachefiles/namei.c
@@ -40,8 +40,7 @@ void __cachefiles_printk_object(struct cachefiles_object *object,
 	printk(KERN_ERR "%sobjstate=%s fl=%lx wbusy=%x ev=%lx[%lx]\n",
 	       prefix, fscache_object_states[object->fscache.state],
 	       object->fscache.flags, work_busy(&object->fscache.work),
-	       object->fscache.events,
-	       object->fscache.event_mask & FSCACHE_OBJECT_EVENTS_MASK);
+	       object->fscache.events, object->fscache.event_mask);
 	printk(KERN_ERR "%sops=%u inp=%u exc=%u\n",
 	       prefix, object->fscache.n_ops, object->fscache.n_in_progress,
 	       object->fscache.n_exclusive);
diff --git a/fs/fscache/object-list.c b/fs/fscache/object-list.c
index ebe29c5..f27c89d 100644
--- a/fs/fscache/object-list.c
+++ b/fs/fscache/object-list.c
@@ -245,7 +245,7 @@ static int fscache_objlist_show(struct seq_file *m, void *v)
 		   obj->n_in_progress,
 		   obj->n_exclusive,
 		   atomic_read(&obj->n_reads),
-		   obj->event_mask & FSCACHE_OBJECT_EVENTS_MASK,
+		   obj->event_mask,
 		   obj->events,
 		   obj->flags,
 		   work_busy(&obj->work));

