Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B0D6E381EA4
	for <linux-nfs@vger.kernel.org>; Wed, 22 Jul 2026 13:05:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784725510; cv=none; b=bCuX0tF/7dySi+0NOTPJ/cXwrJxKSma5fdkzXydZzfhfMR9/o/Ox4cwyfX2rBUgxBsyVFXDA6Ltk8PKDNvL5HmacdEt1B+uPa6wiZ6nZybXlmVbhuBoQ5sN/TRF70dTWZsg+ABnJsszFH3ht/YwWeMicN1b7q/L361H/LBGP0qs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784725510; c=relaxed/simple;
	bh=V/PEQe8TLTgny1TnXgBAgMdbQswucUkbnCClq4xKFpo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=LEPC0gjyyp4Gm+5sy4oEk7D8leX+DuJAoLPwRlqLIBl2rw9En8OAG7bOn/KUUdg038Vj/5y1g1GjmjnuI3qOosfAWYP58t8N1u+aB0WKIvz/5Hs+uD8FHFzizZ+yUPj9sfIds1gDjkEBm/+67LCAI+av4O4QJfX28NFGXvevAq0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=Z0Rsr5Hx; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="Z0Rsr5Hx"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1784725504;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=ZFIIu0bhK2T/7U1/V0mO7PoWxIaZ9WFyu7Hp7P52vBs=;
	b=Z0Rsr5HxFhejiO00DLg/qO/m/GYaSOLX1pdLLLVtyhszJ0TsEYSnnNYsT+hpbnhmbDSrt6
	U8S4bnTAX2IXYUx1VixkgyHzmimqBTFTn4U/i1qxD8CrsWXSaxMCplYnNfnuw39dimqANv
	yFcZqAb/k76UJoxUClsJ62jzVDB9QwU=
Received: from mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-222-7Lv_yJ6qPPO9NWMy6NKBrQ-1; Wed,
 22 Jul 2026 09:05:00 -0400
X-MC-Unique: 7Lv_yJ6qPPO9NWMy6NKBrQ-1
X-Mimecast-MFC-AGG-ID: 7Lv_yJ6qPPO9NWMy6NKBrQ_1784725497
Received: from mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.17])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 9A494180A238;
	Wed, 22 Jul 2026 13:04:57 +0000 (UTC)
Received: from warthog.procyon.org.com (unknown [10.44.33.159])
	by mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 163211955D88;
	Wed, 22 Jul 2026 13:04:50 +0000 (UTC)
From: David Howells <dhowells@redhat.com>
To: Christian Brauner <christian@brauner.io>,
	Matthew Wilcox <willy@infradead.org>,
	Christoph Hellwig <hch@infradead.org>
Cc: David Howells <dhowells@redhat.com>,
	Paulo Alcantara <pc@manguebit.org>,
	Jens Axboe <axboe@kernel.dk>,
	Leon Romanovsky <leon@kernel.org>,
	Steve French <sfrench@samba.org>,
	ChenXiaoSong <chenxiaosong@chenxiaosong.com>,
	Marc Dionne <marc.dionne@auristor.com>,
	Stefan Metzmacher <metze@samba.org>,
	Eric Van Hensbergen <ericvh@kernel.org>,
	Dominique Martinet <asmadeus@codewreck.org>,
	Ilya Dryomov <idryomov@gmail.com>,
	netfs@lists.linux.dev,
	linux-afs@lists.infradead.org,
	linux-cifs@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	ceph-devel@vger.kernel.org,
	v9fs@lists.linux.dev,
	linux-erofs@lists.ozlabs.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Gao Xiang <xiang@kernel.org>
Subject: [PATCH v7 18/29] cachefiles,netfs: sunset ondemand mode
Date: Wed, 22 Jul 2026 14:02:05 +0100
Message-ID: <20260722130218.78958-19-dhowells@redhat.com>
In-Reply-To: <20260722130218.78958-1-dhowells@redhat.com>
References: <20260722130218.78958-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.17

From: Gao Xiang <xiang@kernel.org>

It was an effort to enhance fscache as a kernel cache for lazy
pulling (at least according to previous Incremental FS discussion [1])
and EROFS over fscache was the in-tree user of this mode.

fscache has since evolved to be netfslib-oriented, serving network
filesystem inodes via the netfs library, but EROFS never acts as a
network filesystem and we need to cache golden filesystem images rather
than individual EROFS inodes.

Since EROFS over fscache is now removed, clean up netfs/fscache/
cachefiles upstream too.

[1] https://lore.kernel.org/r/CAOQ4uxi4dzxArY24YO=+kBCK2gGoq3Ptb8WkzCqSogPgU_R3dQ@mail.gmail.com

[dh] Fixed up comments on:
https://sashiko.dev/#/patchset/20260716103030.3065561-1-dhowells%40redhat.com

Signed-off-by: Gao Xiang <xiang@kernel.org>
Signed-off-by: David Howells <dhowells@redhat.com>
cc: Paulo Alcantara <pc@manguebit.org>
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
---
 .../filesystems/caching/cachefiles.rst        | 179 ----
 fs/cachefiles/Kconfig                         |  12 -
 fs/cachefiles/Makefile                        |   1 -
 fs/cachefiles/daemon.c                        |  76 +-
 fs/cachefiles/interface.c                     |   8 -
 fs/cachefiles/internal.h                      | 129 ---
 fs/cachefiles/io.c                            |  26 +-
 fs/cachefiles/namei.c                         |   8 -
 fs/cachefiles/ondemand.c                      | 761 ------------------
 include/linux/netfs.h                         |   9 -
 include/trace/events/cachefiles.h             | 178 ----
 11 files changed, 5 insertions(+), 1382 deletions(-)
 delete mode 100644 fs/cachefiles/ondemand.c

diff --git a/Documentation/filesystems/caching/cachefiles.rst b/Documentation/filesystems/caching/cachefiles.rst
index b3ccc782cb3b..adfb7d079027 100644
--- a/Documentation/filesystems/caching/cachefiles.rst
+++ b/Documentation/filesystems/caching/cachefiles.rst
@@ -28,8 +28,6 @@ Cache on Already Mounted Filesystem
 
  (*) Debugging.
 
- (*) On-demand Read.
-
 
 Overview
 ========
@@ -483,180 +481,3 @@ the control file.  For example::
 	echo $((1|4|8)) >/sys/module/cachefiles/parameters/debug
 
 will turn on all function entry debugging.
-
-
-On-demand Read
-==============
-
-When working in its original mode, CacheFiles serves as a local cache for a
-remote networking fs - while in on-demand read mode, CacheFiles can boost the
-scenario where on-demand read semantics are needed, e.g. container image
-distribution.
-
-The essential difference between these two modes is seen when a cache miss
-occurs: In the original mode, the netfs will fetch the data from the remote
-server and then write it to the cache file; in on-demand read mode, fetching
-the data and writing it into the cache is delegated to a user daemon.
-
-``CONFIG_CACHEFILES_ONDEMAND`` should be enabled to support on-demand read mode.
-
-
-Protocol Communication
-----------------------
-
-The on-demand read mode uses a simple protocol for communication between kernel
-and user daemon. The protocol can be modeled as::
-
-	kernel --[request]--> user daemon --[reply]--> kernel
-
-CacheFiles will send requests to the user daemon when needed.  The user daemon
-should poll the devnode ('/dev/cachefiles') to check if there's a pending
-request to be processed.  A POLLIN event will be returned when there's a pending
-request.
-
-The user daemon then reads the devnode to fetch a request to process.  It should
-be noted that each read only gets one request. When it has finished processing
-the request, the user daemon should write the reply to the devnode.
-
-Each request starts with a message header of the form::
-
-	struct cachefiles_msg {
-		__u32 msg_id;
-		__u32 opcode;
-		__u32 len;
-		__u32 object_id;
-		__u8  data[];
-	};
-
-where:
-
-	* ``msg_id`` is a unique ID identifying this request among all pending
-	  requests.
-
-	* ``opcode`` indicates the type of this request.
-
-	* ``object_id`` is a unique ID identifying the cache file operated on.
-
-	* ``data`` indicates the payload of this request.
-
-	* ``len`` indicates the whole length of this request, including the
-	  header and following type-specific payload.
-
-
-Turning on On-demand Mode
--------------------------
-
-An optional parameter becomes available to the "bind" command::
-
-	bind [ondemand]
-
-When the "bind" command is given no argument, it defaults to the original mode.
-When it is given the "ondemand" argument, i.e. "bind ondemand", on-demand read
-mode will be enabled.
-
-
-The OPEN Request
-----------------
-
-When the netfs opens a cache file for the first time, a request with the
-CACHEFILES_OP_OPEN opcode, a.k.a an OPEN request will be sent to the user
-daemon.  The payload format is of the form::
-
-	struct cachefiles_open {
-		__u32 volume_key_size;
-		__u32 cookie_key_size;
-		__u32 fd;
-		__u32 flags;
-		__u8  data[];
-	};
-
-where:
-
-	* ``data`` contains the volume_key followed directly by the cookie_key.
-	  The volume key is a NUL-terminated string; the cookie key is binary
-	  data.
-
-	* ``volume_key_size`` indicates the size of the volume key in bytes.
-
-	* ``cookie_key_size`` indicates the size of the cookie key in bytes.
-
-	* ``fd`` indicates an anonymous fd referring to the cache file, through
-	  which the user daemon can perform write/llseek file operations on the
-	  cache file.
-
-
-The user daemon can use the given (volume_key, cookie_key) pair to distinguish
-the requested cache file.  With the given anonymous fd, the user daemon can
-fetch the data and write it to the cache file in the background, even when
-kernel has not triggered a cache miss yet.
-
-Be noted that each cache file has a unique object_id, while it may have multiple
-anonymous fds.  The user daemon may duplicate anonymous fds from the initial
-anonymous fd indicated by the @fd field through dup().  Thus each object_id can
-be mapped to multiple anonymous fds, while the usr daemon itself needs to
-maintain the mapping.
-
-When implementing a user daemon, please be careful of RLIMIT_NOFILE,
-``/proc/sys/fs/nr_open`` and ``/proc/sys/fs/file-max``.  Typically these needn't
-be huge since they're related to the number of open device blobs rather than
-open files of each individual filesystem.
-
-The user daemon should reply the OPEN request by issuing a "copen" (complete
-open) command on the devnode::
-
-	copen <msg_id>,<cache_size>
-
-where:
-
-	* ``msg_id`` must match the msg_id field of the OPEN request.
-
-	* When >= 0, ``cache_size`` indicates the size of the cache file;
-	  when < 0, ``cache_size`` indicates any error code encountered by the
-	  user daemon.
-
-
-The CLOSE Request
------------------
-
-When a cookie withdrawn, a CLOSE request (opcode CACHEFILES_OP_CLOSE) will be
-sent to the user daemon.  This tells the user daemon to close all anonymous fds
-associated with the given object_id.  The CLOSE request has no extra payload,
-and shouldn't be replied.
-
-
-The READ Request
-----------------
-
-When a cache miss is encountered in on-demand read mode, CacheFiles will send a
-READ request (opcode CACHEFILES_OP_READ) to the user daemon. This tells the user
-daemon to fetch the contents of the requested file range.  The payload is of the
-form::
-
-	struct cachefiles_read {
-		__u64 off;
-		__u64 len;
-	};
-
-where:
-
-	* ``off`` indicates the starting offset of the requested file range.
-
-	* ``len`` indicates the length of the requested file range.
-
-
-When it receives a READ request, the user daemon should fetch the requested data
-and write it to the cache file identified by object_id.
-
-When it has finished processing the READ request, the user daemon should reply
-by using the CACHEFILES_IOC_READ_COMPLETE ioctl on one of the anonymous fds
-associated with the object_id given in the READ request.  The ioctl is of the
-form::
-
-	ioctl(fd, CACHEFILES_IOC_READ_COMPLETE, msg_id);
-
-where:
-
-	* ``fd`` is one of the anonymous fds associated with the object_id
-	  given.
-
-	* ``msg_id`` must match the msg_id field of the READ request.
diff --git a/fs/cachefiles/Kconfig b/fs/cachefiles/Kconfig
index c5a070550ee3..afb25b6af5aa 100644
--- a/fs/cachefiles/Kconfig
+++ b/fs/cachefiles/Kconfig
@@ -26,15 +26,3 @@ config CACHEFILES_ERROR_INJECTION
 	help
 	  This permits error injection to be enabled in cachefiles whilst a
 	  cache is in service.
-
-config CACHEFILES_ONDEMAND
-	bool "Support for on-demand read"
-	depends on CACHEFILES
-	default n
-	help
-	  This permits userspace to enable the cachefiles on-demand read mode.
-	  In this mode, when a cache miss occurs, responsibility for fetching
-	  the data lies with the cachefiles backend instead of with the netfs
-	  and is delegated to userspace.
-
-	  If unsure, say N.
diff --git a/fs/cachefiles/Makefile b/fs/cachefiles/Makefile
index c37a7a9af10b..16d811f1a2fa 100644
--- a/fs/cachefiles/Makefile
+++ b/fs/cachefiles/Makefile
@@ -16,6 +16,5 @@ cachefiles-y := \
 	xattr.o
 
 cachefiles-$(CONFIG_CACHEFILES_ERROR_INJECTION) += error_inject.o
-cachefiles-$(CONFIG_CACHEFILES_ONDEMAND) += ondemand.o
 
 obj-$(CONFIG_CACHEFILES) := cachefiles.o
diff --git a/fs/cachefiles/daemon.c b/fs/cachefiles/daemon.c
index 4117b145ac94..6e0248a62c13 100644
--- a/fs/cachefiles/daemon.c
+++ b/fs/cachefiles/daemon.c
@@ -76,10 +76,6 @@ static const struct cachefiles_daemon_cmd cachefiles_daemon_cmds[] = {
 	{ "inuse",	cachefiles_daemon_inuse		},
 	{ "secctx",	cachefiles_daemon_secctx	},
 	{ "tag",	cachefiles_daemon_tag		},
-#ifdef CONFIG_CACHEFILES_ONDEMAND
-	{ "copen",	cachefiles_ondemand_copen	},
-	{ "restore",	cachefiles_ondemand_restore	},
-#endif
 	{ "",		NULL				}
 };
 
@@ -114,8 +110,6 @@ static int cachefiles_daemon_open(struct inode *inode, struct file *file)
 	INIT_LIST_HEAD(&cache->object_list);
 	spin_lock_init(&cache->object_list_lock);
 	refcount_set(&cache->unbind_pincount, 1);
-	xa_init_flags(&cache->reqs, XA_FLAGS_ALLOC);
-	xa_init_flags(&cache->ondemand_ids, XA_FLAGS_ALLOC1);
 
 	/* set default caching limits
 	 * - limit at 1% free space and/or free files
@@ -134,40 +128,6 @@ static int cachefiles_daemon_open(struct inode *inode, struct file *file)
 	return 0;
 }
 
-void cachefiles_flush_reqs(struct cachefiles_cache *cache)
-{
-	struct xarray *xa = &cache->reqs;
-	struct cachefiles_req *req;
-	unsigned long index;
-
-	/*
-	 * Make sure the following two operations won't be reordered.
-	 *   1) set CACHEFILES_DEAD bit
-	 *   2) flush requests in the xarray
-	 * Otherwise the request may be enqueued after xarray has been
-	 * flushed, leaving the orphan request never being completed.
-	 *
-	 * CPU 1			CPU 2
-	 * =====			=====
-	 * flush requests in the xarray
-	 *				test CACHEFILES_DEAD bit
-	 *				enqueue the request
-	 * set CACHEFILES_DEAD bit
-	 */
-	smp_mb();
-
-	xa_lock(xa);
-	xa_for_each(xa, index, req) {
-		req->error = -EIO;
-		complete(&req->done);
-		__xa_erase(xa, index);
-	}
-	xa_unlock(xa);
-
-	xa_destroy(&cache->reqs);
-	xa_destroy(&cache->ondemand_ids);
-}
-
 void cachefiles_put_unbind_pincount(struct cachefiles_cache *cache)
 {
 	if (refcount_dec_and_test(&cache->unbind_pincount)) {
@@ -195,9 +155,6 @@ static int cachefiles_daemon_release(struct inode *inode, struct file *file)
 
 	set_bit(CACHEFILES_DEAD, &cache->flags);
 
-	if (cachefiles_in_ondemand_mode(cache))
-		cachefiles_flush_reqs(cache);
-
 	/* clean up the control file interface */
 	cache->cachefilesd = NULL;
 	file->private_data = NULL;
@@ -266,10 +223,7 @@ static ssize_t cachefiles_daemon_read(struct file *file, char __user *_buffer,
 	if (!test_bit(CACHEFILES_READY, &cache->flags))
 		return 0;
 
-	if (cachefiles_in_ondemand_mode(cache))
-		return cachefiles_ondemand_daemon_read(cache, _buffer, buflen);
-	else
-		return cachefiles_do_daemon_read(cache, _buffer, buflen);
+	return cachefiles_do_daemon_read(cache, _buffer, buflen);
 }
 
 /*
@@ -358,28 +312,13 @@ static __poll_t cachefiles_daemon_poll(struct file *file,
 					   struct poll_table_struct *poll)
 {
 	struct cachefiles_cache *cache = file->private_data;
-	XA_STATE(xas, &cache->reqs, 0);
-	struct cachefiles_req *req;
 	__poll_t mask;
 
 	poll_wait(file, &cache->daemon_pollwq, poll);
 	mask = 0;
 
-	if (cachefiles_in_ondemand_mode(cache)) {
-		if (!xa_empty(&cache->reqs)) {
-			xas_lock(&xas);
-			xas_for_each_marked(&xas, req, ULONG_MAX, CACHEFILES_REQ_NEW) {
-				if (!cachefiles_ondemand_is_reopening_read(req)) {
-					mask |= EPOLLIN;
-					break;
-				}
-			}
-			xas_unlock(&xas);
-		}
-	} else {
-		if (test_bit(CACHEFILES_STATE_CHANGED, &cache->flags))
-			mask |= EPOLLIN;
-	}
+	if (test_bit(CACHEFILES_STATE_CHANGED, &cache->flags))
+		mask |= EPOLLIN;
 
 	if (test_bit(CACHEFILES_CULLING, &cache->flags))
 		mask |= EPOLLOUT;
@@ -779,14 +718,7 @@ static int cachefiles_daemon_bind(struct cachefiles_cache *cache, char *args)
 		return -EBUSY;
 	}
 
-	if (IS_ENABLED(CONFIG_CACHEFILES_ONDEMAND)) {
-		if (!strcmp(args, "ondemand")) {
-			set_bit(CACHEFILES_ONDEMAND_MODE, &cache->flags);
-		} else if (*args) {
-			pr_err("Invalid argument to the 'bind' command\n");
-			return -EINVAL;
-		}
-	} else if (*args) {
+	if (*args) {
 		pr_err("'bind' command doesn't take an argument\n");
 		return -EINVAL;
 	}
diff --git a/fs/cachefiles/interface.c b/fs/cachefiles/interface.c
index a08250d244ea..50a000310a8c 100644
--- a/fs/cachefiles/interface.c
+++ b/fs/cachefiles/interface.c
@@ -32,11 +32,6 @@ struct cachefiles_object *cachefiles_alloc_object(struct fscache_cookie *cookie)
 	if (!object)
 		return NULL;
 
-	if (cachefiles_ondemand_init_obj_info(object, volume)) {
-		kmem_cache_free(cachefiles_object_jar, object);
-		return NULL;
-	}
-
 	refcount_set(&object->ref, 1);
 
 	spin_lock_init(&object->lock);
@@ -94,7 +89,6 @@ void cachefiles_put_object(struct cachefiles_object *object,
 		ASSERTCMP(object->file, ==, NULL);
 
 		kfree(object->d_name);
-		cachefiles_ondemand_deinit_obj_info(object);
 		cache = object->volume->cache->cache;
 		fscache_put_cookie(object->cookie, fscache_cookie_put_object);
 		object->cookie = NULL;
@@ -374,8 +368,6 @@ static void cachefiles_withdraw_cookie(struct fscache_cookie *cookie)
 		spin_unlock(&cache->object_list_lock);
 	}
 
-	cachefiles_ondemand_clean_object(object);
-
 	if (object->file) {
 		cachefiles_begin_secure(cache, &saved_cred);
 		cachefiles_clean_up_object(object, cache);
diff --git a/fs/cachefiles/internal.h b/fs/cachefiles/internal.h
index b62cd3e9a18e..39300d61f419 100644
--- a/fs/cachefiles/internal.h
+++ b/fs/cachefiles/internal.h
@@ -15,7 +15,6 @@
 #include <linux/fscache-cache.h>
 #include <linux/cred.h>
 #include <linux/security.h>
-#include <linux/xarray.h>
 #include <linux/cachefiles.h>
 
 #define CACHEFILES_DIO_BLOCK_SIZE 4096
@@ -44,21 +43,6 @@ struct cachefiles_volume {
 	struct dentry			*fanout[256];	/* Fanout subdirs */
 };
 
-enum cachefiles_object_state {
-	CACHEFILES_ONDEMAND_OBJSTATE_CLOSE, /* Anonymous fd closed by daemon or initial state */
-	CACHEFILES_ONDEMAND_OBJSTATE_OPEN, /* Anonymous fd associated with object is available */
-	CACHEFILES_ONDEMAND_OBJSTATE_REOPENING, /* Object that was closed and is being reopened. */
-	CACHEFILES_ONDEMAND_OBJSTATE_DROPPING, /* Object is being dropped. */
-};
-
-struct cachefiles_ondemand_info {
-	struct work_struct		ondemand_work;
-	int				ondemand_id;
-	enum cachefiles_object_state	state;
-	struct cachefiles_object	*object;
-	spinlock_t			lock;
-};
-
 /*
  * Backing file state.
  */
@@ -74,13 +58,8 @@ struct cachefiles_object {
 	enum cachefiles_content		content_info:8;	/* Info about content presence */
 	unsigned long			flags;
 #define CACHEFILES_OBJECT_USING_TMPFILE	0		/* Have an unlinked tmpfile */
-#ifdef CONFIG_CACHEFILES_ONDEMAND
-	struct cachefiles_ondemand_info	*ondemand;
-#endif
 };
 
-#define CACHEFILES_ONDEMAND_ID_CLOSED	-1
-
 /*
  * Cache files cache definition
  */
@@ -119,35 +98,13 @@ struct cachefiles_cache {
 #define CACHEFILES_DEAD			1	/* T if cache dead */
 #define CACHEFILES_CULLING		2	/* T if cull engaged */
 #define CACHEFILES_STATE_CHANGED	3	/* T if state changed (poll trigger) */
-#define CACHEFILES_ONDEMAND_MODE	4	/* T if in on-demand read mode */
 	char				*rootdirname;	/* name of cache root directory */
 	char				*tag;		/* cache binding tag */
 	refcount_t			unbind_pincount;/* refcount to do daemon unbind */
-	struct xarray			reqs;		/* xarray of pending on-demand requests */
-	unsigned long			req_id_next;
-	struct xarray			ondemand_ids;	/* xarray for ondemand_id allocation */
-	u32				ondemand_id_next;
-	u32				msg_id_next;
 	u32				secid;		/* LSM security id */
 	bool				have_secid;	/* whether "secid" was set */
 };
 
-static inline bool cachefiles_in_ondemand_mode(struct cachefiles_cache *cache)
-{
-	return IS_ENABLED(CONFIG_CACHEFILES_ONDEMAND) &&
-		test_bit(CACHEFILES_ONDEMAND_MODE, &cache->flags);
-}
-
-struct cachefiles_req {
-	struct cachefiles_object *object;
-	struct completion done;
-	refcount_t ref;
-	int error;
-	struct cachefiles_msg msg;
-};
-
-#define CACHEFILES_REQ_NEW	XA_MARK_1
-
 #include <trace/events/cachefiles.h>
 
 static inline
@@ -298,90 +255,6 @@ extern struct file *cachefiles_create_tmpfile(struct cachefiles_object *object);
 extern bool cachefiles_commit_tmpfile(struct cachefiles_cache *cache,
 				      struct cachefiles_object *object);
 
-/*
- * ondemand.c
- */
-#ifdef CONFIG_CACHEFILES_ONDEMAND
-extern ssize_t cachefiles_ondemand_daemon_read(struct cachefiles_cache *cache,
-					char __user *_buffer, size_t buflen);
-
-extern int cachefiles_ondemand_copen(struct cachefiles_cache *cache,
-				     char *args);
-
-extern int cachefiles_ondemand_restore(struct cachefiles_cache *cache,
-					char *args);
-
-extern int cachefiles_ondemand_init_object(struct cachefiles_object *object);
-extern void cachefiles_ondemand_clean_object(struct cachefiles_object *object);
-
-extern int cachefiles_ondemand_read(struct cachefiles_object *object,
-				    loff_t pos, size_t len);
-
-extern int cachefiles_ondemand_init_obj_info(struct cachefiles_object *obj,
-					struct cachefiles_volume *volume);
-extern void cachefiles_ondemand_deinit_obj_info(struct cachefiles_object *obj);
-
-#define CACHEFILES_OBJECT_STATE_FUNCS(_state, _STATE)	\
-static inline bool								\
-cachefiles_ondemand_object_is_##_state(const struct cachefiles_object *object) \
-{												\
-	return object->ondemand->state == CACHEFILES_ONDEMAND_OBJSTATE_##_STATE; \
-}												\
-												\
-static inline void								\
-cachefiles_ondemand_set_object_##_state(struct cachefiles_object *object) \
-{												\
-	object->ondemand->state = CACHEFILES_ONDEMAND_OBJSTATE_##_STATE; \
-}
-
-CACHEFILES_OBJECT_STATE_FUNCS(open, OPEN);
-CACHEFILES_OBJECT_STATE_FUNCS(close, CLOSE);
-CACHEFILES_OBJECT_STATE_FUNCS(reopening, REOPENING);
-CACHEFILES_OBJECT_STATE_FUNCS(dropping, DROPPING);
-
-static inline bool cachefiles_ondemand_is_reopening_read(struct cachefiles_req *req)
-{
-	return cachefiles_ondemand_object_is_reopening(req->object) &&
-			req->msg.opcode == CACHEFILES_OP_READ;
-}
-
-#else
-static inline ssize_t cachefiles_ondemand_daemon_read(struct cachefiles_cache *cache,
-					char __user *_buffer, size_t buflen)
-{
-	return -EOPNOTSUPP;
-}
-
-static inline int cachefiles_ondemand_init_object(struct cachefiles_object *object)
-{
-	return 0;
-}
-
-static inline void cachefiles_ondemand_clean_object(struct cachefiles_object *object)
-{
-}
-
-static inline int cachefiles_ondemand_read(struct cachefiles_object *object,
-					   loff_t pos, size_t len)
-{
-	return -EOPNOTSUPP;
-}
-
-static inline int cachefiles_ondemand_init_obj_info(struct cachefiles_object *obj,
-						struct cachefiles_volume *volume)
-{
-	return 0;
-}
-static inline void cachefiles_ondemand_deinit_obj_info(struct cachefiles_object *obj)
-{
-}
-
-static inline bool cachefiles_ondemand_is_reopening_read(struct cachefiles_req *req)
-{
-	return false;
-}
-#endif
-
 /*
  * security.c
  */
@@ -430,8 +303,6 @@ do {							\
 	pr_err("I/O Error: " FMT"\n", ##__VA_ARGS__);	\
 	fscache_io_error((___cache)->cache);		\
 	set_bit(CACHEFILES_DEAD, &(___cache)->flags);	\
-	if (cachefiles_in_ondemand_mode(___cache))	\
-		cachefiles_flush_reqs(___cache);	\
 } while (0)
 
 #define cachefiles_io_error_obj(object, FMT, ...)			\
diff --git a/fs/cachefiles/io.c b/fs/cachefiles/io.c
index d879b80a0bed..9540ec25b3cb 100644
--- a/fs/cachefiles/io.c
+++ b/fs/cachefiles/io.c
@@ -390,7 +390,6 @@ cachefiles_do_prepare_read(struct netfs_cache_resources *cres,
 	size_t len = *_len;
 	loff_t off, to;
 	ino_t ino = file ? file_inode(file)->i_ino : 0;
-	int rc;
 
 	_enter("%zx @%llx/%llx", len, start, i_size);
 
@@ -403,8 +402,7 @@ cachefiles_do_prepare_read(struct netfs_cache_resources *cres,
 	if (test_bit(FSCACHE_COOKIE_NO_DATA_TO_READ, &cookie->flags)) {
 		__set_bit(NETFS_SREQ_COPY_TO_CACHE, _flags);
 		why = cachefiles_trace_read_no_data;
-		if (!test_bit(NETFS_SREQ_ONDEMAND, _flags))
-			goto out_no_object;
+		goto out_no_object;
 	}
 
 	/* The object and the file may be being created in the background. */
@@ -421,7 +419,6 @@ cachefiles_do_prepare_read(struct netfs_cache_resources *cres,
 	object = cachefiles_cres_object(cres);
 	cache = object->volume->cache;
 	cachefiles_begin_secure(cache, &saved_cred);
-retry:
 	off = cachefiles_inject_read_error();
 	if (off == 0)
 		off = vfs_llseek(file, start, SEEK_DATA);
@@ -474,14 +471,6 @@ cachefiles_do_prepare_read(struct netfs_cache_resources *cres,
 
 download_and_store:
 	__set_bit(NETFS_SREQ_COPY_TO_CACHE, _flags);
-	if (test_bit(NETFS_SREQ_ONDEMAND, _flags)) {
-		rc = cachefiles_ondemand_read(object, start, len);
-		if (!rc) {
-			__clear_bit(NETFS_SREQ_ONDEMAND, _flags);
-			goto retry;
-		}
-		ret = NETFS_INVALID_READ;
-	}
 out:
 	cachefiles_end_secure(cache, saved_cred);
 out_no_object:
@@ -501,18 +490,6 @@ static enum netfs_io_source cachefiles_prepare_read(struct netfs_io_subrequest *
 					  &subreq->flags, subreq->rreq->inode->i_ino);
 }
 
-/*
- * Prepare an on-demand read operation, shortening it to a cached/uncached
- * boundary as appropriate.
- */
-static enum netfs_io_source
-cachefiles_prepare_ondemand_read(struct netfs_cache_resources *cres,
-				 loff_t start, size_t *_len, loff_t i_size,
-				 unsigned long *_flags, ino_t ino)
-{
-	return cachefiles_do_prepare_read(cres, start, _len, i_size, _flags, ino);
-}
-
 /*
  * Prepare for a write to occur.
  */
@@ -731,7 +708,6 @@ static const struct netfs_cache_ops cachefiles_netfs_cache_ops = {
 	.prepare_read		= cachefiles_prepare_read,
 	.prepare_write		= cachefiles_prepare_write,
 	.prepare_write_subreq	= cachefiles_prepare_write_subreq,
-	.prepare_ondemand_read	= cachefiles_prepare_ondemand_read,
 	.query_occupancy	= cachefiles_query_occupancy,
 };
 
diff --git a/fs/cachefiles/namei.c b/fs/cachefiles/namei.c
index 8a9f6be15828..88955249a1a6 100644
--- a/fs/cachefiles/namei.c
+++ b/fs/cachefiles/namei.c
@@ -442,10 +442,6 @@ struct file *cachefiles_create_tmpfile(struct cachefiles_object *object)
 	if (!cachefiles_mark_inode_in_use(object, file_inode(file)))
 		WARN_ON(1);
 
-	ret = cachefiles_ondemand_init_object(object);
-	if (ret < 0)
-		goto err_unuse;
-
 	ni_size = object->cookie->object_size;
 	ni_size = round_up(ni_size, CACHEFILES_DIO_BLOCK_SIZE);
 
@@ -546,10 +542,6 @@ static bool cachefiles_open_file(struct cachefiles_object *object,
 	}
 	_debug("file -> %pd positive", dentry);
 
-	ret = cachefiles_ondemand_init_object(object);
-	if (ret < 0)
-		goto error_fput;
-
 	ret = cachefiles_check_auxdata(object, file);
 	if (ret < 0)
 		goto check_failed;
diff --git a/fs/cachefiles/ondemand.c b/fs/cachefiles/ondemand.c
deleted file mode 100644
index 0849eaf583cd..000000000000
--- a/fs/cachefiles/ondemand.c
+++ /dev/null
@@ -1,761 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0-or-later
-#include <linux/anon_inodes.h>
-#include <linux/uio.h>
-#include "internal.h"
-
-struct ondemand_anon_file {
-	struct file *file;
-	int fd;
-};
-
-static inline void cachefiles_req_put(struct cachefiles_req *req)
-{
-	if (refcount_dec_and_test(&req->ref))
-		kfree(req);
-}
-
-static int cachefiles_ondemand_fd_release(struct inode *inode,
-					  struct file *file)
-{
-	struct cachefiles_object *object = file->private_data;
-	struct cachefiles_cache *cache;
-	struct cachefiles_ondemand_info *info;
-	int object_id;
-	struct cachefiles_req *req;
-	XA_STATE(xas, NULL, 0);
-
-	if (!object)
-		return 0;
-
-	info = object->ondemand;
-	cache = object->volume->cache;
-	xas.xa = &cache->reqs;
-
-	xa_lock(&cache->reqs);
-	spin_lock(&info->lock);
-	object_id = info->ondemand_id;
-	info->ondemand_id = CACHEFILES_ONDEMAND_ID_CLOSED;
-	cachefiles_ondemand_set_object_close(object);
-	spin_unlock(&info->lock);
-
-	/* Only flush CACHEFILES_REQ_NEW marked req to avoid race with daemon_read */
-	xas_for_each_marked(&xas, req, ULONG_MAX, CACHEFILES_REQ_NEW) {
-		if (req->msg.object_id == object_id &&
-		    req->msg.opcode == CACHEFILES_OP_CLOSE) {
-			complete(&req->done);
-			xas_store(&xas, NULL);
-		}
-	}
-	xa_unlock(&cache->reqs);
-
-	xa_erase(&cache->ondemand_ids, object_id);
-	trace_cachefiles_ondemand_fd_release(object, object_id);
-	cachefiles_put_object(object, cachefiles_obj_put_ondemand_fd);
-	cachefiles_put_unbind_pincount(cache);
-	return 0;
-}
-
-static ssize_t cachefiles_ondemand_fd_write_iter(struct kiocb *kiocb,
-						 struct iov_iter *iter)
-{
-	struct cachefiles_object *object = kiocb->ki_filp->private_data;
-	struct cachefiles_cache *cache = object->volume->cache;
-	struct file *file;
-	size_t len = iter->count, aligned_len = len;
-	loff_t pos = kiocb->ki_pos;
-	const struct cred *saved_cred;
-	int ret;
-
-	spin_lock(&object->lock);
-	file = object->file;
-	if (!file) {
-		spin_unlock(&object->lock);
-		return -ENOBUFS;
-	}
-	get_file(file);
-	spin_unlock(&object->lock);
-
-	cachefiles_begin_secure(cache, &saved_cred);
-	ret = __cachefiles_prepare_write(object, file, &pos, &aligned_len, len, true);
-	cachefiles_end_secure(cache, saved_cred);
-	if (ret < 0)
-		goto out;
-
-	trace_cachefiles_ondemand_fd_write(object, file_inode(file), pos, len);
-	ret = __cachefiles_write(object, file, pos, iter, NULL, NULL);
-	if (ret > 0)
-		kiocb->ki_pos += ret;
-
-out:
-	fput(file);
-	return ret;
-}
-
-static loff_t cachefiles_ondemand_fd_llseek(struct file *filp, loff_t pos,
-					    int whence)
-{
-	struct cachefiles_object *object = filp->private_data;
-	struct file *file;
-	loff_t ret;
-
-	spin_lock(&object->lock);
-	file = object->file;
-	if (!file) {
-		spin_unlock(&object->lock);
-		return -ENOBUFS;
-	}
-	get_file(file);
-	spin_unlock(&object->lock);
-
-	ret = vfs_llseek(file, pos, whence);
-	fput(file);
-
-	return ret;
-}
-
-static long cachefiles_ondemand_fd_ioctl(struct file *filp, unsigned int ioctl,
-					 unsigned long id)
-{
-	struct cachefiles_object *object = filp->private_data;
-	struct cachefiles_cache *cache = object->volume->cache;
-	struct cachefiles_req *req;
-	XA_STATE(xas, &cache->reqs, id);
-
-	if (ioctl != CACHEFILES_IOC_READ_COMPLETE)
-		return -EINVAL;
-
-	if (!test_bit(CACHEFILES_ONDEMAND_MODE, &cache->flags))
-		return -EOPNOTSUPP;
-
-	xa_lock(&cache->reqs);
-	req = xas_load(&xas);
-	if (!req || req->msg.opcode != CACHEFILES_OP_READ ||
-	    req->object != object) {
-		xa_unlock(&cache->reqs);
-		return -EINVAL;
-	}
-	xas_store(&xas, NULL);
-	xa_unlock(&cache->reqs);
-
-	trace_cachefiles_ondemand_cread(object, id);
-	complete(&req->done);
-	return 0;
-}
-
-static const struct file_operations cachefiles_ondemand_fd_fops = {
-	.owner		= THIS_MODULE,
-	.release	= cachefiles_ondemand_fd_release,
-	.write_iter	= cachefiles_ondemand_fd_write_iter,
-	.llseek		= cachefiles_ondemand_fd_llseek,
-	.unlocked_ioctl	= cachefiles_ondemand_fd_ioctl,
-};
-
-/*
- * OPEN request Completion (copen)
- * - command: "copen <id>,<cache_size>"
- *   <cache_size> indicates the object size if >=0, error code if negative
- */
-int cachefiles_ondemand_copen(struct cachefiles_cache *cache, char *args)
-{
-	struct cachefiles_req *req;
-	struct fscache_cookie *cookie;
-	struct cachefiles_ondemand_info *info;
-	char *pid, *psize;
-	unsigned long id;
-	long size;
-	int ret;
-	XA_STATE(xas, &cache->reqs, 0);
-
-	if (!test_bit(CACHEFILES_ONDEMAND_MODE, &cache->flags))
-		return -EOPNOTSUPP;
-
-	if (!*args) {
-		pr_err("Empty id specified\n");
-		return -EINVAL;
-	}
-
-	pid = args;
-	psize = strchr(args, ',');
-	if (!psize) {
-		pr_err("Cache size is not specified\n");
-		return -EINVAL;
-	}
-
-	*psize = 0;
-	psize++;
-
-	ret = kstrtoul(pid, 0, &id);
-	if (ret)
-		return ret;
-
-	xa_lock(&cache->reqs);
-	xas.xa_index = id;
-	req = xas_load(&xas);
-	if (!req || req->msg.opcode != CACHEFILES_OP_OPEN ||
-	    !req->object->ondemand->ondemand_id) {
-		xa_unlock(&cache->reqs);
-		return -EINVAL;
-	}
-	xas_store(&xas, NULL);
-	xa_unlock(&cache->reqs);
-
-	info = req->object->ondemand;
-	/* fail OPEN request if copen format is invalid */
-	ret = kstrtol(psize, 0, &size);
-	if (ret) {
-		req->error = ret;
-		goto out;
-	}
-
-	/* fail OPEN request if daemon reports an error */
-	if (size < 0) {
-		if (!IS_ERR_VALUE(size)) {
-			req->error = -EINVAL;
-			ret = -EINVAL;
-		} else {
-			req->error = size;
-			ret = 0;
-		}
-		goto out;
-	}
-
-	spin_lock(&info->lock);
-	/*
-	 * The anonymous fd was closed before copen ? Fail the request.
-	 *
-	 *             t1             |             t2
-	 * ---------------------------------------------------------
-	 *                             cachefiles_ondemand_copen
-	 *                             req = xa_erase(&cache->reqs, id)
-	 * // Anon fd is maliciously closed.
-	 * cachefiles_ondemand_fd_release
-	 * xa_lock(&cache->reqs)
-	 * cachefiles_ondemand_set_object_close(object)
-	 * xa_unlock(&cache->reqs)
-	 *                             cachefiles_ondemand_set_object_open
-	 *                             // No one will ever close it again.
-	 * cachefiles_ondemand_daemon_read
-	 * cachefiles_ondemand_select_req
-	 *
-	 * Get a read req but its fd is already closed. The daemon can't
-	 * issue a cread ioctl with an closed fd, then hung.
-	 */
-	if (info->ondemand_id == CACHEFILES_ONDEMAND_ID_CLOSED) {
-		spin_unlock(&info->lock);
-		req->error = -EBADFD;
-		goto out;
-	}
-	cookie = req->object->cookie;
-	cookie->object_size = size;
-	if (size)
-		clear_bit(FSCACHE_COOKIE_NO_DATA_TO_READ, &cookie->flags);
-	else
-		set_bit(FSCACHE_COOKIE_NO_DATA_TO_READ, &cookie->flags);
-	trace_cachefiles_ondemand_copen(req->object, id, size);
-
-	cachefiles_ondemand_set_object_open(req->object);
-	spin_unlock(&info->lock);
-	wake_up_all(&cache->daemon_pollwq);
-
-out:
-	spin_lock(&info->lock);
-	/* Need to set object close to avoid reopen status continuing */
-	if (info->ondemand_id == CACHEFILES_ONDEMAND_ID_CLOSED)
-		cachefiles_ondemand_set_object_close(req->object);
-	spin_unlock(&info->lock);
-	complete(&req->done);
-	return ret;
-}
-
-int cachefiles_ondemand_restore(struct cachefiles_cache *cache, char *args)
-{
-	struct cachefiles_req *req;
-
-	XA_STATE(xas, &cache->reqs, 0);
-
-	if (!test_bit(CACHEFILES_ONDEMAND_MODE, &cache->flags))
-		return -EOPNOTSUPP;
-
-	/*
-	 * Reset the requests to CACHEFILES_REQ_NEW state, so that the
-	 * requests have been processed halfway before the crash of the
-	 * user daemon could be reprocessed after the recovery.
-	 */
-	xas_lock(&xas);
-	xas_for_each(&xas, req, ULONG_MAX)
-		xas_set_mark(&xas, CACHEFILES_REQ_NEW);
-	xas_unlock(&xas);
-
-	wake_up_all(&cache->daemon_pollwq);
-	return 0;
-}
-
-static int cachefiles_ondemand_get_fd(struct cachefiles_req *req,
-				      struct ondemand_anon_file *anon_file)
-{
-	struct cachefiles_object *object;
-	struct cachefiles_cache *cache;
-	struct cachefiles_open *load;
-	u32 object_id;
-	int ret;
-
-	object = cachefiles_grab_object(req->object,
-			cachefiles_obj_get_ondemand_fd);
-	cache = object->volume->cache;
-
-	ret = xa_alloc_cyclic(&cache->ondemand_ids, &object_id, NULL,
-			      XA_LIMIT(1, INT_MAX),
-			      &cache->ondemand_id_next, GFP_KERNEL);
-	if (ret < 0)
-		goto err;
-
-	anon_file->fd = get_unused_fd_flags(O_WRONLY);
-	if (anon_file->fd < 0) {
-		ret = anon_file->fd;
-		goto err_free_id;
-	}
-
-	anon_file->file = anon_inode_getfile_fmode("[cachefiles]",
-				&cachefiles_ondemand_fd_fops, object,
-				O_WRONLY, FMODE_PWRITE | FMODE_LSEEK);
-	if (IS_ERR(anon_file->file)) {
-		ret = PTR_ERR(anon_file->file);
-		goto err_put_fd;
-	}
-
-	spin_lock(&object->ondemand->lock);
-	if (object->ondemand->ondemand_id > 0) {
-		spin_unlock(&object->ondemand->lock);
-		/* Pair with check in cachefiles_ondemand_fd_release(). */
-		anon_file->file->private_data = NULL;
-		ret = -EEXIST;
-		goto err_put_file;
-	}
-
-	load = (void *)req->msg.data;
-	load->fd = anon_file->fd;
-	object->ondemand->ondemand_id = object_id;
-	spin_unlock(&object->ondemand->lock);
-
-	cachefiles_get_unbind_pincount(cache);
-	trace_cachefiles_ondemand_open(object, &req->msg, load);
-	return 0;
-
-err_put_file:
-	fput(anon_file->file);
-	anon_file->file = NULL;
-err_put_fd:
-	put_unused_fd(anon_file->fd);
-	anon_file->fd = ret;
-err_free_id:
-	xa_erase(&cache->ondemand_ids, object_id);
-err:
-	spin_lock(&object->ondemand->lock);
-	/* Avoid marking an opened object as closed. */
-	if (object->ondemand->ondemand_id <= 0)
-		cachefiles_ondemand_set_object_close(object);
-	spin_unlock(&object->ondemand->lock);
-	cachefiles_put_object(object, cachefiles_obj_put_ondemand_fd);
-	return ret;
-}
-
-static void ondemand_object_worker(struct work_struct *work)
-{
-	struct cachefiles_ondemand_info *info =
-		container_of(work, struct cachefiles_ondemand_info, ondemand_work);
-
-	cachefiles_ondemand_init_object(info->object);
-}
-
-/*
- * If there are any inflight or subsequent READ requests on the
- * closed object, reopen it.
- * Skip read requests whose related object is reopening.
- */
-static struct cachefiles_req *cachefiles_ondemand_select_req(struct xa_state *xas,
-							      unsigned long xa_max)
-{
-	struct cachefiles_req *req;
-	struct cachefiles_object *object;
-	struct cachefiles_ondemand_info *info;
-
-	xas_for_each_marked(xas, req, xa_max, CACHEFILES_REQ_NEW) {
-		if (req->msg.opcode != CACHEFILES_OP_READ)
-			return req;
-		object = req->object;
-		info = object->ondemand;
-		if (cachefiles_ondemand_object_is_close(object)) {
-			cachefiles_ondemand_set_object_reopening(object);
-			queue_work(fscache_wq, &info->ondemand_work);
-			continue;
-		}
-		if (cachefiles_ondemand_object_is_reopening(object))
-			continue;
-		return req;
-	}
-	return NULL;
-}
-
-static inline bool cachefiles_ondemand_finish_req(struct cachefiles_req *req,
-						  struct xa_state *xas, int err)
-{
-	if (unlikely(!xas || !req))
-		return false;
-
-	if (xa_cmpxchg(xas->xa, xas->xa_index, req, NULL, 0) != req)
-		return false;
-
-	req->error = err;
-	complete(&req->done);
-	return true;
-}
-
-ssize_t cachefiles_ondemand_daemon_read(struct cachefiles_cache *cache,
-					char __user *_buffer, size_t buflen)
-{
-	struct cachefiles_req *req;
-	struct cachefiles_msg *msg;
-	size_t n;
-	int ret = 0;
-	struct ondemand_anon_file anon_file;
-	XA_STATE(xas, &cache->reqs, cache->req_id_next);
-
-	xa_lock(&cache->reqs);
-	/*
-	 * Cyclically search for a request that has not ever been processed,
-	 * to prevent requests from being processed repeatedly, and make
-	 * request distribution fair.
-	 */
-	req = cachefiles_ondemand_select_req(&xas, ULONG_MAX);
-	if (!req && cache->req_id_next > 0) {
-		xas_set(&xas, 0);
-		req = cachefiles_ondemand_select_req(&xas, cache->req_id_next - 1);
-	}
-	if (!req) {
-		xa_unlock(&cache->reqs);
-		return 0;
-	}
-
-	msg = &req->msg;
-	n = msg->len;
-
-	if (n > buflen) {
-		xa_unlock(&cache->reqs);
-		return -EMSGSIZE;
-	}
-
-	xas_clear_mark(&xas, CACHEFILES_REQ_NEW);
-	cache->req_id_next = xas.xa_index + 1;
-	refcount_inc(&req->ref);
-	cachefiles_grab_object(req->object, cachefiles_obj_get_read_req);
-	xa_unlock(&cache->reqs);
-
-	if (msg->opcode == CACHEFILES_OP_OPEN) {
-		ret = cachefiles_ondemand_get_fd(req, &anon_file);
-		if (ret)
-			goto out;
-	}
-
-	msg->msg_id = xas.xa_index;
-	msg->object_id = req->object->ondemand->ondemand_id;
-
-	if (copy_to_user(_buffer, msg, n) != 0)
-		ret = -EFAULT;
-
-	if (msg->opcode == CACHEFILES_OP_OPEN) {
-		if (ret < 0) {
-			fput(anon_file.file);
-			put_unused_fd(anon_file.fd);
-			goto out;
-		}
-		fd_install(anon_file.fd, anon_file.file);
-	}
-out:
-	cachefiles_put_object(req->object, cachefiles_obj_put_read_req);
-	/* Remove error request and CLOSE request has no reply */
-	if (ret || msg->opcode == CACHEFILES_OP_CLOSE)
-		cachefiles_ondemand_finish_req(req, &xas, ret);
-	cachefiles_req_put(req);
-	return ret ? ret : n;
-}
-
-typedef int (*init_req_fn)(struct cachefiles_req *req, void *private);
-
-static int cachefiles_ondemand_send_req(struct cachefiles_object *object,
-					enum cachefiles_opcode opcode,
-					size_t data_len,
-					init_req_fn init_req,
-					void *private)
-{
-	struct cachefiles_cache *cache = object->volume->cache;
-	struct cachefiles_req *req = NULL;
-	XA_STATE(xas, &cache->reqs, 0);
-	int ret;
-
-	if (!test_bit(CACHEFILES_ONDEMAND_MODE, &cache->flags))
-		return 0;
-
-	if (test_bit(CACHEFILES_DEAD, &cache->flags)) {
-		ret = -EIO;
-		goto out;
-	}
-
-	req = kzalloc(sizeof(*req) + data_len, GFP_KERNEL);
-	if (!req) {
-		ret = -ENOMEM;
-		goto out;
-	}
-
-	refcount_set(&req->ref, 1);
-	req->object = object;
-	init_completion(&req->done);
-	req->msg.opcode = opcode;
-	req->msg.len = sizeof(struct cachefiles_msg) + data_len;
-
-	ret = init_req(req, private);
-	if (ret)
-		goto out;
-
-	do {
-		/*
-		 * Stop enqueuing the request when daemon is dying. The
-		 * following two operations need to be atomic as a whole.
-		 *   1) check cache state, and
-		 *   2) enqueue request if cache is alive.
-		 * Otherwise the request may be enqueued after xarray has been
-		 * flushed, leaving the orphan request never being completed.
-		 *
-		 * CPU 1			CPU 2
-		 * =====			=====
-		 *				test CACHEFILES_DEAD bit
-		 * set CACHEFILES_DEAD bit
-		 * flush requests in the xarray
-		 *				enqueue the request
-		 */
-		xas_lock(&xas);
-
-		if (test_bit(CACHEFILES_DEAD, &cache->flags) ||
-		    cachefiles_ondemand_object_is_dropping(object)) {
-			xas_unlock(&xas);
-			ret = -EIO;
-			goto out;
-		}
-
-		/* coupled with the barrier in cachefiles_flush_reqs() */
-		smp_mb();
-
-		if (opcode == CACHEFILES_OP_CLOSE &&
-		    !cachefiles_ondemand_object_is_open(object)) {
-			WARN_ON_ONCE(object->ondemand->ondemand_id == 0);
-			xas_unlock(&xas);
-			ret = -EIO;
-			goto out;
-		}
-
-		/*
-		 * Cyclically find a free xas to avoid msg_id reuse that would
-		 * cause the daemon to successfully copen a stale msg_id.
-		 */
-		xas.xa_index = cache->msg_id_next;
-		xas_find_marked(&xas, UINT_MAX, XA_FREE_MARK);
-		if (xas.xa_node == XAS_RESTART) {
-			xas.xa_index = 0;
-			xas_find_marked(&xas, cache->msg_id_next - 1, XA_FREE_MARK);
-		}
-		if (xas.xa_node == XAS_RESTART)
-			xas_set_err(&xas, -EBUSY);
-
-		xas_store(&xas, req);
-		if (xas_valid(&xas)) {
-			cache->msg_id_next = xas.xa_index + 1;
-			xas_clear_mark(&xas, XA_FREE_MARK);
-			xas_set_mark(&xas, CACHEFILES_REQ_NEW);
-		}
-		xas_unlock(&xas);
-	} while (xas_nomem(&xas, GFP_KERNEL));
-
-	ret = xas_error(&xas);
-	if (ret)
-		goto out;
-
-	wake_up_all(&cache->daemon_pollwq);
-wait:
-	ret = wait_for_completion_killable(&req->done);
-	if (!ret) {
-		ret = req->error;
-	} else {
-		ret = -EINTR;
-		if (!cachefiles_ondemand_finish_req(req, &xas, ret)) {
-			/* Someone will complete it soon. */
-			cpu_relax();
-			goto wait;
-		}
-	}
-	cachefiles_req_put(req);
-	return ret;
-out:
-	/* Reset the object to close state in error handling path.
-	 * If error occurs after creating the anonymous fd,
-	 * cachefiles_ondemand_fd_release() will set object to close.
-	 */
-	if (opcode == CACHEFILES_OP_OPEN &&
-	    !cachefiles_ondemand_object_is_dropping(object))
-		cachefiles_ondemand_set_object_close(object);
-	kfree(req);
-	return ret;
-}
-
-static int cachefiles_ondemand_init_open_req(struct cachefiles_req *req,
-					     void *private)
-{
-	struct cachefiles_object *object = req->object;
-	struct fscache_cookie *cookie = object->cookie;
-	struct fscache_volume *volume = object->volume->vcookie;
-	struct cachefiles_open *load = (void *)req->msg.data;
-	size_t volume_key_size, cookie_key_size;
-	void *volume_key, *cookie_key;
-
-	/*
-	 * Volume key is a NUL-terminated string. key[0] stores strlen() of the
-	 * string, followed by the content of the string (excluding '\0').
-	 */
-	volume_key_size = volume->key[0] + 1;
-	volume_key = volume->key + 1;
-
-	/* Cookie key is binary data, which is netfs specific. */
-	cookie_key_size = cookie->key_len;
-	cookie_key = fscache_get_key(cookie);
-
-	if (!(object->cookie->advice & FSCACHE_ADV_WANT_CACHE_SIZE)) {
-		pr_err("WANT_CACHE_SIZE is needed for on-demand mode\n");
-		return -EINVAL;
-	}
-
-	load->volume_key_size = volume_key_size;
-	load->cookie_key_size = cookie_key_size;
-	memcpy(load->data, volume_key, volume_key_size);
-	memcpy(load->data + volume_key_size, cookie_key, cookie_key_size);
-
-	return 0;
-}
-
-static int cachefiles_ondemand_init_close_req(struct cachefiles_req *req,
-					      void *private)
-{
-	struct cachefiles_object *object = req->object;
-
-	if (!cachefiles_ondemand_object_is_open(object))
-		return -ENOENT;
-
-	trace_cachefiles_ondemand_close(object, &req->msg);
-	return 0;
-}
-
-struct cachefiles_read_ctx {
-	loff_t off;
-	size_t len;
-};
-
-static int cachefiles_ondemand_init_read_req(struct cachefiles_req *req,
-					     void *private)
-{
-	struct cachefiles_object *object = req->object;
-	struct cachefiles_read *load = (void *)req->msg.data;
-	struct cachefiles_read_ctx *read_ctx = private;
-
-	load->off = read_ctx->off;
-	load->len = read_ctx->len;
-	trace_cachefiles_ondemand_read(object, &req->msg, load);
-	return 0;
-}
-
-int cachefiles_ondemand_init_object(struct cachefiles_object *object)
-{
-	struct fscache_cookie *cookie = object->cookie;
-	struct fscache_volume *volume = object->volume->vcookie;
-	size_t volume_key_size, cookie_key_size, data_len;
-
-	if (!object->ondemand)
-		return 0;
-
-	/*
-	 * CacheFiles will firstly check the cache file under the root cache
-	 * directory. If the coherency check failed, it will fallback to
-	 * creating a new tmpfile as the cache file. Reuse the previously
-	 * allocated object ID if any.
-	 */
-	if (cachefiles_ondemand_object_is_open(object))
-		return 0;
-
-	volume_key_size = volume->key[0] + 1;
-	cookie_key_size = cookie->key_len;
-	data_len = sizeof(struct cachefiles_open) +
-		   volume_key_size + cookie_key_size;
-
-	return cachefiles_ondemand_send_req(object, CACHEFILES_OP_OPEN,
-			data_len, cachefiles_ondemand_init_open_req, NULL);
-}
-
-void cachefiles_ondemand_clean_object(struct cachefiles_object *object)
-{
-	unsigned long index;
-	struct cachefiles_req *req;
-	struct cachefiles_cache *cache;
-
-	if (!object->ondemand)
-		return;
-
-	cachefiles_ondemand_send_req(object, CACHEFILES_OP_CLOSE, 0,
-			cachefiles_ondemand_init_close_req, NULL);
-
-	if (!object->ondemand->ondemand_id)
-		return;
-
-	/* Cancel all requests for the object that is being dropped. */
-	cache = object->volume->cache;
-	xa_lock(&cache->reqs);
-	cachefiles_ondemand_set_object_dropping(object);
-	xa_for_each(&cache->reqs, index, req) {
-		if (req->object == object) {
-			req->error = -EIO;
-			complete(&req->done);
-			__xa_erase(&cache->reqs, index);
-		}
-	}
-	xa_unlock(&cache->reqs);
-
-	/* Wait for ondemand_object_worker() to finish to avoid UAF. */
-	cancel_work_sync(&object->ondemand->ondemand_work);
-}
-
-int cachefiles_ondemand_init_obj_info(struct cachefiles_object *object,
-				struct cachefiles_volume *volume)
-{
-	if (!cachefiles_in_ondemand_mode(volume->cache))
-		return 0;
-
-	object->ondemand = kzalloc_obj(struct cachefiles_ondemand_info);
-	if (!object->ondemand)
-		return -ENOMEM;
-
-	object->ondemand->object = object;
-	spin_lock_init(&object->ondemand->lock);
-	INIT_WORK(&object->ondemand->ondemand_work, ondemand_object_worker);
-	return 0;
-}
-
-void cachefiles_ondemand_deinit_obj_info(struct cachefiles_object *object)
-{
-	kfree(object->ondemand);
-	object->ondemand = NULL;
-}
-
-int cachefiles_ondemand_read(struct cachefiles_object *object,
-			     loff_t pos, size_t len)
-{
-	struct cachefiles_read_ctx read_ctx = {pos, len};
-
-	return cachefiles_ondemand_send_req(object, CACHEFILES_OP_READ,
-			sizeof(struct cachefiles_read),
-			cachefiles_ondemand_init_read_req, &read_ctx);
-}
diff --git a/include/linux/netfs.h b/include/linux/netfs.h
index c724a68c2e20..e12d8f393354 100644
--- a/include/linux/netfs.h
+++ b/include/linux/netfs.h
@@ -192,7 +192,6 @@ struct netfs_io_subrequest {
 #define NETFS_SREQ_COPY_TO_CACHE	0	/* Set if should copy the data to the cache */
 #define NETFS_SREQ_CLEAR_TAIL		1	/* Set if the rest of the read should be cleared */
 #define NETFS_SREQ_MADE_PROGRESS	4	/* Set if we transferred at least some data */
-#define NETFS_SREQ_ONDEMAND		5	/* Set if it's from on-demand read mode */
 #define NETFS_SREQ_BOUNDARY		6	/* Set if ends on hard boundary (eg. ceph object) */
 #define NETFS_SREQ_HIT_EOF		7	/* Set if short due to EOF */
 #define NETFS_SREQ_IN_PROGRESS		8	/* Unlocked when the subrequest completes */
@@ -374,14 +373,6 @@ struct netfs_cache_ops {
 			     loff_t *_start, size_t *_len, size_t upper_len,
 			     loff_t i_size, bool no_space_allocated_yet);
 
-	/* Prepare an on-demand read operation, shortening it to a cached/uncached
-	 * boundary as appropriate.
-	 */
-	enum netfs_io_source (*prepare_ondemand_read)(struct netfs_cache_resources *cres,
-						      loff_t start, size_t *_len,
-						      loff_t i_size,
-						      unsigned long *_flags, ino_t ino);
-
 	/* Query the occupancy of the cache in a region, returning where the
 	 * next chunk of data starts and how long it is.
 	 */
diff --git a/include/trace/events/cachefiles.h b/include/trace/events/cachefiles.h
index 6e3b1424eea4..f1631bb02454 100644
--- a/include/trace/events/cachefiles.h
+++ b/include/trace/events/cachefiles.h
@@ -31,8 +31,6 @@ enum cachefiles_obj_ref_trace {
 	cachefiles_obj_see_lookup_failed,
 	cachefiles_obj_see_withdraw_cookie,
 	cachefiles_obj_see_withdrawal,
-	cachefiles_obj_get_ondemand_fd,
-	cachefiles_obj_put_ondemand_fd,
 	cachefiles_obj_get_read_req,
 	cachefiles_obj_put_read_req,
 };
@@ -130,8 +128,6 @@ enum cachefiles_error_trace {
 	EM(cachefiles_obj_see_lookup_failed,	"SEE lookup_failed")	\
 	EM(cachefiles_obj_see_withdraw_cookie,	"SEE withdraw_cookie")	\
 	EM(cachefiles_obj_see_withdrawal,	"SEE withdrawal")	\
-	EM(cachefiles_obj_get_ondemand_fd,      "GET ondemand_fd")	\
-	EM(cachefiles_obj_put_ondemand_fd,      "PUT ondemand_fd")	\
 	EM(cachefiles_obj_get_read_req,		"GET read_req")		\
 	E_(cachefiles_obj_put_read_req,		"PUT read_req")
 
@@ -687,180 +683,6 @@ TRACE_EVENT(cachefiles_io_error,
 		      __entry->error)
 	    );
 
-TRACE_EVENT(cachefiles_ondemand_open,
-	    TP_PROTO(struct cachefiles_object *obj, struct cachefiles_msg *msg,
-		     struct cachefiles_open *load),
-
-	    TP_ARGS(obj, msg, load),
-
-	    TP_STRUCT__entry(
-		    __field(unsigned int,	obj)
-		    __field(unsigned int,	msg_id)
-		    __field(unsigned int,	object_id)
-		    __field(unsigned int,	fd)
-		    __field(unsigned int,	flags)
-			     ),
-
-	    TP_fast_assign(
-		    __entry->obj	= obj ? obj->debug_id : 0;
-		    __entry->msg_id	= msg->msg_id;
-		    __entry->object_id	= msg->object_id;
-		    __entry->fd		= load->fd;
-		    __entry->flags	= load->flags;
-			   ),
-
-	    TP_printk("o=%08x mid=%x oid=%x fd=%d f=%x",
-		      __entry->obj,
-		      __entry->msg_id,
-		      __entry->object_id,
-		      __entry->fd,
-		      __entry->flags)
-	    );
-
-TRACE_EVENT(cachefiles_ondemand_copen,
-	    TP_PROTO(struct cachefiles_object *obj, unsigned int msg_id,
-		     long len),
-
-	    TP_ARGS(obj, msg_id, len),
-
-	    TP_STRUCT__entry(
-		    __field(unsigned int,	obj)
-		    __field(unsigned int,	msg_id)
-		    __field(long,		len)
-			     ),
-
-	    TP_fast_assign(
-		    __entry->obj	= obj ? obj->debug_id : 0;
-		    __entry->msg_id	= msg_id;
-		    __entry->len	= len;
-			   ),
-
-	    TP_printk("o=%08x mid=%x l=%lx",
-		      __entry->obj,
-		      __entry->msg_id,
-		      __entry->len)
-	    );
-
-TRACE_EVENT(cachefiles_ondemand_close,
-	    TP_PROTO(struct cachefiles_object *obj, struct cachefiles_msg *msg),
-
-	    TP_ARGS(obj, msg),
-
-	    TP_STRUCT__entry(
-		    __field(unsigned int,	obj)
-		    __field(unsigned int,	msg_id)
-		    __field(unsigned int,	object_id)
-			     ),
-
-	    TP_fast_assign(
-		    __entry->obj	= obj ? obj->debug_id : 0;
-		    __entry->msg_id	= msg->msg_id;
-		    __entry->object_id	= msg->object_id;
-			   ),
-
-	    TP_printk("o=%08x mid=%x oid=%x",
-		      __entry->obj,
-		      __entry->msg_id,
-		      __entry->object_id)
-	    );
-
-TRACE_EVENT(cachefiles_ondemand_read,
-	    TP_PROTO(struct cachefiles_object *obj, struct cachefiles_msg *msg,
-		     struct cachefiles_read *load),
-
-	    TP_ARGS(obj, msg, load),
-
-	    TP_STRUCT__entry(
-		    __field(unsigned int,	obj)
-		    __field(unsigned int,	msg_id)
-		    __field(unsigned int,	object_id)
-		    __field(loff_t,		start)
-		    __field(size_t,		len)
-			     ),
-
-	    TP_fast_assign(
-		    __entry->obj	= obj ? obj->debug_id : 0;
-		    __entry->msg_id	= msg->msg_id;
-		    __entry->object_id	= msg->object_id;
-		    __entry->start	= load->off;
-		    __entry->len	= load->len;
-			   ),
-
-	    TP_printk("o=%08x mid=%x oid=%x s=%llx l=%zx",
-		      __entry->obj,
-		      __entry->msg_id,
-		      __entry->object_id,
-		      __entry->start,
-		      __entry->len)
-	    );
-
-TRACE_EVENT(cachefiles_ondemand_cread,
-	    TP_PROTO(struct cachefiles_object *obj, unsigned int msg_id),
-
-	    TP_ARGS(obj, msg_id),
-
-	    TP_STRUCT__entry(
-		    __field(unsigned int,	obj)
-		    __field(unsigned int,	msg_id)
-			     ),
-
-	    TP_fast_assign(
-		    __entry->obj	= obj ? obj->debug_id : 0;
-		    __entry->msg_id	= msg_id;
-			   ),
-
-	    TP_printk("o=%08x mid=%x",
-		      __entry->obj,
-		      __entry->msg_id)
-	    );
-
-TRACE_EVENT(cachefiles_ondemand_fd_write,
-	    TP_PROTO(struct cachefiles_object *obj, struct inode *backer,
-		     loff_t start, size_t len),
-
-	    TP_ARGS(obj, backer, start, len),
-
-	    TP_STRUCT__entry(
-		    __field(unsigned int,	obj)
-		    __field(unsigned int,	backer)
-		    __field(loff_t,		start)
-		    __field(size_t,		len)
-			     ),
-
-	    TP_fast_assign(
-		    __entry->obj	= obj ? obj->debug_id : 0;
-		    __entry->backer	= backer->i_ino;
-		    __entry->start	= start;
-		    __entry->len	= len;
-			   ),
-
-	    TP_printk("o=%08x iB=%x s=%llx l=%zx",
-		      __entry->obj,
-		      __entry->backer,
-		      __entry->start,
-		      __entry->len)
-	    );
-
-TRACE_EVENT(cachefiles_ondemand_fd_release,
-	    TP_PROTO(struct cachefiles_object *obj, int object_id),
-
-	    TP_ARGS(obj, object_id),
-
-	    TP_STRUCT__entry(
-		    __field(unsigned int,	obj)
-		    __field(unsigned int,	object_id)
-			     ),
-
-	    TP_fast_assign(
-		    __entry->obj	= obj ? obj->debug_id : 0;
-		    __entry->object_id	= object_id;
-			   ),
-
-	    TP_printk("o=%08x oid=%x",
-		      __entry->obj,
-		      __entry->object_id)
-	    );
-
 #endif /* _TRACE_CACHEFILES_H */
 
 /* This part must be outside protection */

