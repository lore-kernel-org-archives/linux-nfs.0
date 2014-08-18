Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:52115 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750957AbaHRGYk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Aug 2014 02:24:40 -0400
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Mon, 18 Aug 2014 16:22:54 +1000
Subject: [PATCH 0/2] remove deadlock risk with loop-back mounted NFS
 filesystems
Cc: linux-nfs@vger.kernel.org
Message-ID: <20140818061727.1449.89101.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that the new wait_on_bit code is in the kernel (in 3.17-rc1) these
last two patches to support deadlock-free loop-back NFS mounts can be
applied (hopefully to go upstream for 3.18-rc1).

A deadlock can happen if nfsd tries to allocate memory, calls
->releasepage() on a page in an NFS filesystem, and nfs_release_page()
blocks waiting for the nfsd to confirm the COMMIT.

With this patch nfs_release_page() will not wait more than 100ms
for COMMIT to a non-remote nfs fileserver.

Thanks,
NeilBrown

---

NeilBrown (2):
      SUNRPC: track when a client connection is routed to the local host.
      NFS: avoid deadlocks with loop-back mounted NFS filesystems.


 fs/nfs/file.c               |    2 +
 fs/nfs/write.c              |   72 ++++++++++++++++++++++++++++++++++++++++---
 include/linux/freezer.h     |   10 ++++++
 include/linux/sunrpc/clnt.h |    1 +
 include/linux/sunrpc/xprt.h |    1 +
 include/uapi/linux/nfs_fs.h |    3 ++
 net/sunrpc/clnt.c           |   25 +++++++++++++++
 net/sunrpc/xprtsock.c       |    9 +++++
 8 files changed, 117 insertions(+), 6 deletions(-)

-- 
Signature

