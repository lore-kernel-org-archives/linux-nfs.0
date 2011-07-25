Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:34509 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751963Ab1GYXnT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Jul 2011 19:43:19 -0400
Date: Mon, 25 Jul 2011 19:43:18 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: nfsd (and lock) changes for 3.1
Message-ID: <20110725234318.GB28271@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

nfsd changes for 3.1 are available from the 3.1 branch at

  git://linux-nfs.org/~bfields/linux.git for-3.1

Thanks to Mi Jinlong and to Bryan Schumaker for continued progress on
NFSv4.1.

Other than that, mostly bugfixes.

I also slipped in some minor fs/locks.c cleanup.  I may try to get in a
little more of that later in the merge window, if there *is* a later in
this merge window....

--b.

Benny Halevy (1):
      NFSD: allow OP_DESTROY_CLIENTID to be only op in COMPOUND

Bryan Schumaker (2):
      NFSD: added FREE_STATEID operation
      NFSD: Added TEST_STATEID operation

Casey Bodley (1):
      nfsd: don't break lease on CLAIM_DELEGATE_CUR

H Hartley Sweeten (2):
      svcsock.c: include sunrpc.h to quiet sparse noise
      svcauth_unix.c: quiet sparse noise

J. Bruce Fields (8):
      rpc: allow autoloading of gss mechanisms
      svcrpc: fix list-corrupting race on nfsd shutdown
      nfsd4: remember to put RW access on stateid destruction
      nfsd4: fix file leak on open_downgrade
      nfsd4: call nfsd4_release_compoundargs from pc_release
      nfsd: turn on reply cache for NFSv4
      nfsd4: update nfsv4.1 implementation notes
      locks: rename lock-manager ops

Mi Jinlong (3):
      nfsd41: error out when client sets maxreq_sz or maxresp_sz too small
      nfsd41: check the size of request
      nfsd41: Deny new lock before RECLAIM_COMPLETE done

Miklos Szeredi (1):
      fs: locks: remove init_once

NeilBrown (1):
      nfsd: Remove deprecated nfsctl system call and related code.

 Documentation/feature-removal-schedule.txt     |   10 -
 Documentation/filesystems/Locking              |   24 +-
 Documentation/filesystems/nfs/nfs41-server.txt |   33 +--
 arch/tile/configs/tilegx_defconfig             |    1 -
 fs/Makefile                                    |    1 -
 fs/compat.c                                    |  246 --------------
 fs/dlm/plock.c                                 |   10 +-
 fs/fuse/file.c                                 |    2 +-
 fs/lockd/svclock.c                             |    8 +-
 fs/locks.c                                     |   75 ++---
 fs/nfsctl.c                                    |  100 ------
 fs/nfsd/Kconfig                                |   12 -
 fs/nfsd/cache.h                                |    2 +-
 fs/nfsd/export.c                               |  418 ------------------------
 fs/nfsd/lockd.c                                |    2 -
 fs/nfsd/nfs4proc.c                             |   58 +++-
 fs/nfsd/nfs4state.c                            |  265 +++++++++++++---
 fs/nfsd/nfs4xdr.c                              |  144 ++++++++-
 fs/nfsd/nfscache.c                             |    3 +-
 fs/nfsd/nfsctl.c                               |  343 -------------------
 fs/nfsd/nfssvc.c                               |   33 +-
 fs/nfsd/state.h                                |    1 +
 fs/nfsd/xdr4.h                                 |   30 ++-
 include/linux/compat.h                         |    9 -
 include/linux/fs.h                             |   12 +-
 include/linux/nfsd/export.h                    |    2 -
 include/linux/sunrpc/cache.h                   |    9 -
 include/linux/sunrpc/svc.h                     |    1 +
 net/sunrpc/auth_gss/gss_krb5_mech.c            |    7 +
 net/sunrpc/auth_gss/gss_mech_switch.c          |   32 ++-
 net/sunrpc/svc_xprt.c                          |   11 +-
 net/sunrpc/svcauth_unix.c                      |   79 +-----
 net/sunrpc/svcsock.c                           |    2 +
 33 files changed, 559 insertions(+), 1426 deletions(-)
 delete mode 100644 fs/nfsctl.c
