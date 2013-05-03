Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:35761 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753238Ab3ECAdT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 May 2013 20:33:19 -0400
Subject: [PATCH 0/8] Fix assorted FS-Cache issues
To: linux-cachefs@redhat.com
From: David Howells <dhowells@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        hjayasur@redhat.com, jlayton@redhat.com, linux-kernel@vger.kernel.org
Date: Fri, 03 May 2013 01:33:16 +0100
Message-ID: <20130503003316.14952.51791.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Following this mail is a series of patches to fix a number of FS-Cache issues,
including a number of oopses.  The patches can also be found at:

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=fscache

The patches are as follows:

 (1) Don't put spin_lock() in a while-condition as spin_lock() may be wrapped
     with do {} while(0) (cleanup).

 (2) Name i_mutex lock classes rather than using numbers in CacheFiles (cleanup).

 (3) Don't sleep in page release if __GFP_FS is not set (deadlock vs ext4).

 (4) Uninline fscache_object_init() (cleanup).

 (5) Wrap checks on object state (cleanup).

 (6) Provide a system wait_on_atomic_t() and wake_up_atomic_t() (enhancement).

 (7) Simplify the object state machine (need #4 and #5).

 (8) Simplify cookie retention by objects (oops fix, need #6 and #7).

David
---
David Howells (6):
      FS-Cache: Don't sleep in page release if __GFP_FS is not set
      FS-Cache: Uninline fscache_object_init()
      FS-Cache: Wrap checks on object state
      Add wait_on_atomic_t() and wake_up_atomic_t()
      FS-Cache: Fix object state machine to have separate work and wait states
      FS-Cache: Simplify cookie retention for fscache_objects, fixing access problems

J. Bruce Fields (1):
      CacheFiles: name i_mutex lock class explicitly

Sebastian Andrzej Siewior (1):
      fs/fscache: remove spin_lock() from the condition in while()


 fs/cachefiles/interface.c     |   11 
 fs/cachefiles/namei.c         |   10 
 fs/cachefiles/xattr.c         |    6 
 fs/fscache/cache.c            |   34 +
 fs/fscache/cookie.c           |   93 +---
 fs/fscache/fsdef.c            |    1 
 fs/fscache/internal.h         |   11 
 fs/fscache/main.c             |   11 
 fs/fscache/netfs.c            |    1 
 fs/fscache/object-list.c      |  103 ++--
 fs/fscache/object.c           | 1077 +++++++++++++++++++++--------------------
 fs/fscache/operation.c        |   36 +
 fs/fscache/page.c             |   55 +-
 include/linux/fscache-cache.h |  170 +++---
 include/linux/wait.h          |   29 +
 kernel/wait.c                 |   85 +++
 16 files changed, 922 insertions(+), 811 deletions(-)

