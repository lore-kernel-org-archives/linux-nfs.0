Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:53412 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751334AbaGNBa7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 13 Jul 2014 21:30:59 -0400
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Mon, 14 Jul 2014 11:28:20 +1000
Subject: [PATCH 0/7] Add RCU-walk support to NFS.
Cc: linux-nfs@vger.kernel.org
Message-ID: <20140714011630.12562.1940.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS current abort and attempt at filename lookup in RCU mode.
This can have serious performance impact on a highly parallel load.

The "Makefile" below generates just such a load.  On a 40-core
machine "make -j 40" is about 6 times as fast at "make -j 5"
when a local filesystem is used (e.g. XFS), but as much as half
as fast when NFS is used.
With this patch set, "make -j 40" is about 3 times as fast as
"make -j 5" on NFS, and "perf" data doesn't show spinlocks to be a big
problem any more.

This is a re-submission with a few small improvements of a patch set
posted in March.  Since then I have recieved confirmation that it
definitely fixes the problem, when combined with a patch set which
enhances autofs4 in a similar way.  So it has had quite a bit of
testing.

NeilBrown

The makefile.  Run
  make -f this-makefile NFS_PATH=/some/nfs/mounted/empty/directory

and an 'objs' directory will be created with lots of objects.
Use "make clean" before trying again.

---
# Options available from the command line
NUM_NFS_INCLUDES := 50
NUM_COMPILES := 200
NFS_PATH:=/import/dummySrc
# When adding includes, they will be of the form $(NFS_PATH)/x where
# x ranges from 1 to NUM_NFS_INCLUDES.  Those directories are created
# automatically by the 'dirs' target.

SHELL:=bash
OBJ_DIR:=objs
ifeq ($(VERBOSE),1)
  Q =
else
  Q = @
endif

MY_INCLUDES := $(addprefix -I$(NFS_PATH)/, $(shell echo {1..$(NUM_NFS_INCLUDES)}))
INCLUDE_DIRS := $(addprefix $(NFS_PATH)/, $(shell echo {1..$(NUM_NFS_INCLUDES)}))
MY_OBJS     := $(addsuffix _test.o, $(addprefix $(OBJ_DIR)/, $(shell echo {1..$(NUM_COMPILES)})))

build: dirs $(MY_OBJS)

dirs:
	$(Q)mkdir -p $(INCLUDE_DIRS)

clean:
	$(Q)rm -rf $(OBJ_DIR)

$(OBJ_DIR)/:
	$(Q)/bin/mkdir $(OBJ_DIR)

$(MY_OBJS): test.cpp | $(OBJ_DIR)/
	$(Q)gcc $(MY_INCLUDES) -c test.cpp -o $@

test.cpp:
	$(Q)echo "#include <iostream>" > test.cpp

.PHONY: all build clean


---

NeilBrown (7):
      NFS: nfs4_lookup_revalidate: only evaluate parent if it will be used.
      NFS: prepare for RCU-walk support but pushing tests later in code.
      sunrpc/auth: allow lockless (rcu) lookup of credential cache.
      NFS: support RCU_WALK in nfs_permission()
      NFS: teach nfs_neg_need_reval to understand LOOKUP_RCU
      NFS: teach nfs_lookup_verify_inode to handle LOOKUP_RCU
      NFS: allow lockless access to access_cache


 fs/nfs/dir.c                |  166 ++++++++++++++++++++++++++++++++++---------
 fs/nfs/inode.c              |    9 ++
 include/linux/nfs_fs.h      |    2 +
 include/linux/sunrpc/auth.h |    2 +
 net/sunrpc/auth.c           |   17 ++++
 net/sunrpc/auth_generic.c   |    6 ++
 net/sunrpc/auth_null.c      |    2 +
 7 files changed, 168 insertions(+), 36 deletions(-)

-- 
Signature

