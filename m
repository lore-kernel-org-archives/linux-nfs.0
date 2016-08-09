Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35322 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752576AbcHIMtt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Aug 2016 08:49:49 -0400
Subject: [PATCH] cachefiles: Fix attempt to read i_blocks after deleting file
From: David Howells <dhowells@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@redhat.com>,
        linux-kernel@vger.kernel.org, Jianhong Yin <jiyin@redhat.com>,
        Steve Dickson <steved@redhat.com>, dhowells@redhat.com,
        linux-cachefs@redhat.com, stable@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Date: Tue, 09 Aug 2016 13:49:46 +0100
Message-ID: <147074698645.18102.17742162122820513623.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

An NULL-pointer dereference happens in cachefiles_mark_object_inactive()
when it tries to read i_blocks so that it can tell the cachefilesd daemon
how much space it's making available.

The problem is that cachefiles_drop_object() calls
cachefiles_mark_object_inactive() after calling cachefiles_delete_object()
because the object being marked active staves off attempts to (re-)use the
file at that filename until after it has been deleted.  This means that
d_inode is NULL by the time we come to try to access it.

To fix the problem, have the caller of cachefiles_mark_object_inactive()
supply the number of blocks freed up.

Without this, the following oops may occur:

BUG: unable to handle kernel NULL pointer dereference at 0000000000000098
IP: [<ffffffffa06c5cc1>] cachefiles_mark_object_inactive+0x61/0xb0 [cachefiles]
...
CPU: 11 PID: 527 Comm: kworker/u64:4 Tainted: G          I    ------------   3.10.0-470.el7.x86_64 #1
Hardware name: Hewlett-Packard HP Z600 Workstation/0B54h, BIOS 786G4 v03.19 03/11/2011
Workqueue: fscache_object fscache_object_work_func [fscache]
task: ffff880035edaf10 ti: ffff8800b77c0000 task.ti: ffff8800b77c0000
RIP: 0010:[<ffffffffa06c5cc1>] cachefiles_mark_object_inactive+0x61/0xb0 [cachefiles]
RSP: 0018:ffff8800b77c3d70  EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffff8800bf6cc400 RCX: 0000000000000034
RDX: 0000000000000000 RSI: ffff880090ffc710 RDI: ffff8800bf761ef8
RBP: ffff8800b77c3d88 R08: 2000000000000000 R09: 0090ffc710000000
R10: ff51005d2ff1c400 R11: 0000000000000000 R12: ffff880090ffc600
R13: ffff8800bf6cc520 R14: ffff8800bf6cc400 R15: ffff8800bf6cc498
FS:  0000000000000000(0000) GS:ffff8800bb8c0000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000098 CR3: 00000000019ba000 CR4: 00000000000007e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Stack:
 ffff880090ffc600 ffff8800bf6cc400 ffff8800867df140 ffff8800b77c3db0
 ffffffffa06c48cb ffff880090ffc600 ffff880090ffc180 ffff880090ffc658
 ffff8800b77c3df0 ffffffffa085d846 ffff8800a96b8150 ffff880090ffc600
Call Trace:
 [<ffffffffa06c48cb>] cachefiles_drop_object+0x6b/0xf0 [cachefiles]
 [<ffffffffa085d846>] fscache_drop_object+0xd6/0x1e0 [fscache]
 [<ffffffffa085d615>] fscache_object_work_func+0xa5/0x200 [fscache]
 [<ffffffff810a605b>] process_one_work+0x17b/0x470
 [<ffffffff810a6e96>] worker_thread+0x126/0x410
 [<ffffffff810a6d70>] ? rescuer_thread+0x460/0x460
 [<ffffffff810ae64f>] kthread+0xcf/0xe0
 [<ffffffff810ae580>] ? kthread_create_on_node+0x140/0x140
 [<ffffffff81695418>] ret_from_fork+0x58/0x90
 [<ffffffff810ae580>] ? kthread_create_on_node+0x140/0x140

The oopsing code shows:

	callq  0xffffffff810af6a0 <wake_up_bit>
	mov    0xf8(%r12),%rax
	mov    0x30(%rax),%rax
	mov    0x98(%rax),%rax   <---- oops here
	lock add %rax,0x130(%rbx)

where this is:

	d_backing_inode(object->dentry)->i_blocks

Fixes: a5b3a80b899bda0f456f1246c4c5a1191ea01519 (CacheFiles: Provide read-and-reset release counters for cachefilesd)
Reported-by: Jianhong Yin <jiyin@redhat.com>
Signed-off-by: David Howells <dhowells@redhat.com>
Reviewed-by: Jeff Layton <jlayton@redhat.com>
Reviewed-by: Steve Dickson <steved@redhat.com>
cc: stable@vger.kernel.org
---

 fs/cachefiles/interface.c |    8 +++++++-
 fs/cachefiles/internal.h  |    3 ++-
 fs/cachefiles/namei.c     |   11 ++++++++---
 3 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/fs/cachefiles/interface.c b/fs/cachefiles/interface.c
index ce5f345d70f5..e7f16a77a22a 100644
--- a/fs/cachefiles/interface.c
+++ b/fs/cachefiles/interface.c
@@ -253,6 +253,8 @@ static void cachefiles_drop_object(struct fscache_object *_object)
 	struct cachefiles_object *object;
 	struct cachefiles_cache *cache;
 	const struct cred *saved_cred;
+	struct inode *inode;
+	blkcnt_t i_blocks = 0;
 
 	ASSERT(_object);
 
@@ -279,6 +281,10 @@ static void cachefiles_drop_object(struct fscache_object *_object)
 		    _object != cache->cache.fsdef
 		    ) {
 			_debug("- retire object OBJ%x", object->fscache.debug_id);
+			inode = d_backing_inode(object->dentry);
+			if (inode)
+				i_blocks = inode->i_blocks;
+
 			cachefiles_begin_secure(cache, &saved_cred);
 			cachefiles_delete_object(cache, object);
 			cachefiles_end_secure(cache, saved_cred);
@@ -292,7 +298,7 @@ static void cachefiles_drop_object(struct fscache_object *_object)
 
 	/* note that the object is now inactive */
 	if (test_bit(CACHEFILES_OBJECT_ACTIVE, &object->flags))
-		cachefiles_mark_object_inactive(cache, object);
+		cachefiles_mark_object_inactive(cache, object, i_blocks);
 
 	dput(object->dentry);
 	object->dentry = NULL;
diff --git a/fs/cachefiles/internal.h b/fs/cachefiles/internal.h
index 2fcde1a34b7c..cd1effee8a49 100644
--- a/fs/cachefiles/internal.h
+++ b/fs/cachefiles/internal.h
@@ -160,7 +160,8 @@ extern char *cachefiles_cook_key(const u8 *raw, int keylen, uint8_t type);
  * namei.c
  */
 extern void cachefiles_mark_object_inactive(struct cachefiles_cache *cache,
-					    struct cachefiles_object *object);
+					    struct cachefiles_object *object,
+					    blkcnt_t i_blocks);
 extern int cachefiles_delete_object(struct cachefiles_cache *cache,
 				    struct cachefiles_object *object);
 extern int cachefiles_walk_to_object(struct cachefiles_object *parent,
diff --git a/fs/cachefiles/namei.c b/fs/cachefiles/namei.c
index 3f7c2cd41f8f..f9d2226689d1 100644
--- a/fs/cachefiles/namei.c
+++ b/fs/cachefiles/namei.c
@@ -261,10 +261,14 @@ requeue:
  * Mark an object as being inactive.
  */
 void cachefiles_mark_object_inactive(struct cachefiles_cache *cache,
-				     struct cachefiles_object *object)
+				     struct cachefiles_object *object,
+				     blkcnt_t i_blocks)
 {
-	blkcnt_t i_blocks = d_backing_inode(object->dentry)->i_blocks;
+	struct dentry *dentry = object->dentry;
 
+	trace_cachefiles_mark_inactive(object, dentry,
+				       d_backing_inode(dentry));
+	
 	write_lock(&cache->active_lock);
 	rb_erase(&object->active_node, &cache->active_nodes);
 	clear_bit(CACHEFILES_OBJECT_ACTIVE, &object->flags);
@@ -707,7 +711,8 @@ mark_active_timed_out:
 
 check_error:
 	_debug("check error %d", ret);
-	cachefiles_mark_object_inactive(cache, object);
+	cachefiles_mark_object_inactive(
+		cache, object, d_backing_inode(object->dentry)->i_blocks);
 release_dentry:
 	dput(object->dentry);
 	object->dentry = NULL;

