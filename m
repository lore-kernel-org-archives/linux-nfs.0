Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:55362 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750877AbdHRHNf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 18 Aug 2017 03:13:35 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Fri, 18 Aug 2017 17:12:51 +1000
Subject: [PATCH 0/8] Assorted NFS patches.
Cc: linux-nfs@vger.kernel.org
Message-ID: <150304014011.30218.1636255532744321171.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,
 this is an ad-hoc collection of NFS patches that I have
 waiting for me to act on.

 Some have been posted the list before but didn't get a response
 (maybe people were busy).  A couple have been revised a little.
 Some are new.

 Some fix real bugs (hanging mounts, unflushed data, wrong
 credentials for CLOSE), others are just clean-ups.

Thanks,
NeilBrown


---

NeilBrown (8):
      SUNRPC: ECONNREFUSED should cause a rebind.
      NFSv4: don't let hanging mounts block other mounts
      NFS: don't expect errors from mempool_alloc().
      NFS: flush out dirty data on file fput().
      SUNRPC: remove some dead code.
      NFS: flush data when locking a file to ensure cache coherence for mmap.
      NFS: remove error handling for callers of rpc_new_task()
      NFSv4.1: don't use machine credentials for CLOSE when using 'sec=sys'


 fs/lockd/clntproc.c            |    4 ---
 fs/nfs/file.c                  |   17 ++++++++---
 fs/nfs/nfs42proc.c             |    2 -
 fs/nfs/nfs4_fs.h               |   11 +++++++
 fs/nfs/nfs4client.c            |    2 +
 fs/nfs/nfs4proc.c              |   62 ++++------------------------------------
 fs/nfs/pagelist.c              |    5 ---
 fs/nfs/unlink.c                |    9 +-----
 fs/nfs/write.c                 |    8 +----
 net/sunrpc/auth_gss/auth_gss.c |    3 +-
 net/sunrpc/clnt.c              |   22 +++++---------
 net/sunrpc/rpcb_clnt.c         |    6 ----
 net/sunrpc/svc.c               |    6 ----
 13 files changed, 43 insertions(+), 114 deletions(-)

--
Signature

