Return-Path: linux-fsdevel-owner@vger.kernel.org
Subject: [PATCH 06/13] FS-Cache: fscache_object_is_dead() has wrong logic,
 kill it
From: David Howells <dhowells@redhat.com>
To: linux-cachefs@redhat.com
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Thu, 26 Feb 2015 14:02:33 +0000
Message-ID: <20150226140233.2387.40762.stgit@warthog.procyon.org.uk>
In-Reply-To: <20150226140155.2387.70579.stgit@warthog.procyon.org.uk>
References: <20150226140155.2387.70579.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

fscache_object_is_dead() returns true only if the object is marked dead and
the cache got an I/O error.  This should be a logical OR instead.  Since two
of the callers got split up into handling for separate subcases, expand the
other callers and kill the function.  This is probably the right thing to do
anyway since one of the subcases isn't about the object at all, but rather
about the cache.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/fscache/cookie.c           |    3 ++-
 fs/fscache/page.c             |    6 ++++--
 include/linux/fscache-cache.h |    6 ------
 3 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/fs/fscache/cookie.c b/fs/fscache/cookie.c
index 89acec742e0b..8de22164f5fb 100644
--- a/fs/fscache/cookie.c
+++ b/fs/fscache/cookie.c
@@ -327,7 +327,8 @@ static int fscache_alloc_object(struct fscache_cache *cache,
 
 object_already_extant:
 	ret = -ENOBUFS;
-	if (fscache_object_is_dead(object)) {
+	if (fscache_object_is_dying(object) ||
+	    fscache_cache_is_broken(object)) {
 		spin_unlock(&cookie->lock);
 		goto error;
 	}
diff --git a/fs/fscache/page.c b/fs/fscache/page.c
index de33b3fccca6..d0805e31361c 100644
--- a/fs/fscache/page.c
+++ b/fs/fscache/page.c
@@ -377,11 +377,13 @@ check_if_dead:
 		_leave(" = -ENOBUFS [cancelled]");
 		return -ENOBUFS;
 	}
-	if (unlikely(fscache_object_is_dead(object))) {
-		pr_err("%s() = -ENOBUFS [obj dead %d]\n", __func__, op->state);
+	if (unlikely(fscache_object_is_dying(object) ||
+		     fscache_cache_is_broken(object))) {
+		enum fscache_operation_state state = op->state;
 		fscache_cancel_op(op, do_cancel);
 		if (stat_object_dead)
 			fscache_stat(stat_object_dead);
+		_leave(" = -ENOBUFS [obj dead %d]", state);
 		return -ENOBUFS;
 	}
 	return 0;
diff --git a/include/linux/fscache-cache.h b/include/linux/fscache-cache.h
index 2e83a141e465..ca3d550da11e 100644
--- a/include/linux/fscache-cache.h
+++ b/include/linux/fscache-cache.h
@@ -423,12 +423,6 @@ static inline bool fscache_object_is_active(struct fscache_object *object)
 		!fscache_cache_is_broken(object);
 }
 
-static inline bool fscache_object_is_dead(struct fscache_object *object)
-{
-	return fscache_object_is_dying(object) &&
-		fscache_cache_is_broken(object);
-}
-
 /**
  * fscache_object_destroyed - Note destruction of an object in a cache
  * @cache: The cache from which the object came

