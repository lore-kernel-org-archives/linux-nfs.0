Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:30434 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752055Ab3GBO1n (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Jul 2013 10:27:43 -0400
From: David Howells <dhowells@redhat.com>
To: torvalds@linux-foundation.org
cc: dhowells@redhat.com, linux-cachefs@redhat.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, milosz@adfin.com
Subject: [GIT PULL] Fix assorted FS-Cache issues
Date: Tue, 02 Jul 2013 15:27:36 +0100
Message-ID: <6302.1372775256@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi Linus,

Can you please pull this GIT branch?  It contains a number of fixes for
various FS-Cache issues plus some cleanups.  The commits are, in order:

 (1) Provide a system wait_on_atomic_t() and wake_up_atomic_t() sharing the
     bit-wait table (enhancement for #8).

 (2) Don't put spin_lock() in a while-condition as spin_lock() may have a
     do {} while(0) wrapper (cleanup).

 (3) Symbolically name i_mutex lock classes rather than using numbers in
     CacheFiles (cleanup).

 (4) Don't sleep in page release if __GFP_FS is not set (deadlock vs ext4).

 (5) Uninline fscache_object_init() (cleanup for #7).

 (6) Wrap checks on object state (cleanup for #7).

 (7) Simplify the object state machine by separating work states from wait
     states.

 (8) Simplify cookie retention by objects (NULL pointer deref fix).

 (9) Remove unused list_to_page() macro (cleanup).

(10) Make the remaining-pages counter in the retrieval op atomic (assertion
     failure fix).

(11) Don't use spin_is_locked() in assertions (assertion failure fix).

This is tagged with fscache-20130702.  This is the same as fscache-20130619
but with added acks.

Thanks,
David
---
The following changes since commit b973425cbb51e08301b34fecdfd476a44507d8cf:

  Merge tag 'ext4_for_linus_stable' of git://git.kernel.org/pub/scm/linux/kernel/git/tytso/ext4 (2013-05-14 09:30:54 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git tags/fscache-20130702

for you to fetch changes up to dcfae32f892f03dee9896b19d1960c1ecd3f0583:

  FS-Cache: Don't use spin_is_locked() in assertions (2013-06-19 14:16:47 +0100)

----------------------------------------------------------------
(from the branch description for fscache local branch)

clone of "master"
FS-Cache patches 2013-07-02

----------------------------------------------------------------
David Howells (8):
      Add wait_on_atomic_t() and wake_up_atomic_t()
      FS-Cache: Don't sleep in page release if __GFP_FS is not set
      FS-Cache: Uninline fscache_object_init()
      FS-Cache: Wrap checks on object state
      FS-Cache: Fix object state machine to have separate work and wait states
      FS-Cache: Simplify cookie retention for fscache_objects, fixing oops
      FS-Cache: The retrieval remaining-pages counter needs to be atomic_t
      FS-Cache: Don't use spin_is_locked() in assertions

Haicheng Li (1):
      cachefiles: remove unused macro list_to_page()

J. Bruce Fields (1):
      CacheFiles: name i_mutex lock class explicitly

Sebastian Andrzej Siewior (1):
      fs/fscache: remove spin_lock() from the condition in while()

 fs/cachefiles/interface.c     |   13 +-
 fs/cachefiles/namei.c         |   10 +-
 fs/cachefiles/xattr.c         |    6 +-
 fs/fscache/cache.c            |   34 +-
 fs/fscache/cookie.c           |   93 ++--
 fs/fscache/fsdef.c            |    1 +
 fs/fscache/internal.h         |   11 +-
 fs/fscache/main.c             |   11 +-
 fs/fscache/netfs.c            |    1 +
 fs/fscache/object-list.c      |  103 ++--
 fs/fscache/object.c           | 1106 +++++++++++++++++++++--------------------
 fs/fscache/operation.c        |   37 +-
 fs/fscache/page.c             |   65 ++-
 include/linux/fscache-cache.h |  175 +++----
 include/linux/wait.h          |   24 +
 kernel/wait.c                 |   88 ++++
 16 files changed, 956 insertions(+), 822 deletions(-)
