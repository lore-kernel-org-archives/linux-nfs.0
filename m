From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: nfsd changes for 2.6.31
Date: Mon, 22 Jun 2009 14:16:40 -0400
Message-ID: <20090622181640.GA19619@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 174-143-236-118.static.slicehost.net ([174.143.236.118]:32846
	"EHLO fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752147AbZFVSQl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Jun 2009 14:16:41 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following nfsd-related changes are available from the for-2.6.31
branch at:

  git://fieldses.org/git/linux-nfsd.git for-2.6.31

(Not the usual URL: CITI is moving tomorrow and linux-nfs.org won't be
up reliably for the next couple days, so I'm hosting this temporarily on
my personal server.)

This includes a few small preliminaries for further 4.1 changes
(backchannel support and a DRC overhaul), but most of that will be
queued up for 2.6.32.

The NFSv4 server will now use ext4's i_version when available, though
some more ext4 changes, and testing of performance impact, are needed to
make it usable.

The rest is miscellaneous cleanup and bugfixes.  Thanks to everyone who
contributed!

--b.

Alexandros Batsakis (1):
      nfsd41: move channel attributes from nfsd4_session to a nfsd4_channel_attr struct

Andy Adamson (3):
      nfsd41: sanity check client drc maxreqs
      nfsd41: Backchannel: cleanup nfs4.0 callback encode routines
      nfsd41: Backchannel: minorversion support for the back channel

Anton Blanchard (1):
      sunrpc: align cache_clean work's timer

Benny Halevy (1):
      update Documentation/filesystems/00-INDEX with new nfsd related docs.

Bian Naimeng (1):
      nfsd4: distinguish expired from stale stateids

Christian Engelmayer (1):
      sunrpc: potential memory leak in function rdma_read_xdr

Chuck Lever (17):
      SUNRPC: Fix error return value of svc_addr_len()
      NFSD: Refactor transport removal out of __write_ports()
      NFSD: Refactor transport addition out of __write_ports()
      NFSD: Refactor portlist socket closing into a helper
      NFSD: Refactor socket creation out of __write_ports()
      NFSD: Note an additional requirement when passing TCP sockets to portlist
      NFSD: Finish refactoring __write_ports()
      NFSD: move lockd_up() before svc_addsock()
      NFSD: Prevent a buffer overflow in svc_xprt_names()
      SUNRPC: pass buffer size to svc_addsock()
      SUNRPC: pass buffer size to svc_sock_names()
      SUNRPC: Switch one_sock_name() to use snprintf()
      SUNRPC: Support PF_INET6 in one_sock_name()
      SUNRPC: Clean up one_sock_name()
      NFSD: Stricter buffer size checking in write_recoverydir()
      NFSD: Stricter buffer size checking in write_versions()
      NFSD: Stricter buffer size checking in fs/nfsd/nfsctl.c

Felix Blyakher (1):
      lockd: call locks_release_private to cleanup per-filesystem state

Greg Banks (3):
      knfsd: reply cache cleanups
      knfsd: fix reply cache memory corruption
      knfsd: remove unreported filehandle stats counters

H Hartley Sweeten (1):
      net/sunrpc/svc_xprt.c: fix sparse warnings

J. Bruce Fields (19):
      nfsd: eliminate ENCODE_HEAD macro
      nfsd4: delete obsolete xdr comments
      nfsd: support ext4 i_version
      nfsd: quiet compile warning
      nfsd4: setclientid_confirm callback-change fixes
      nfsd4: set shorter timeout
      nfsd4: set cb_client inside setup_callback_client
      nfsd4: create rpc callback client from server thread
      nfsd4: lookup up callback cred only once
      nfsd4: replace callback thread by asynchronous rpc
      nfsd4: rename callback struct to cb_conn
      nfsd4: eliminate struct nfs4_cb_recall
      nfsd4: remove unused dl_trunc
      nfsd4: track recall retries in nfs4_delegation
      nfsd4: make recall callback an asynchronous rpc
      Merge commit 'v2.6.30' into for-2.6.31
      nfsd: track last inode only in use_wgather case
      nfsd: Pull write-gathering code out of nfsd_vfs_write
      nfsd: minor nfsd_vfs_write cleanup

Mike Sager (1):
      nfsd41: Remove ip address collision detection case

NeilBrown (2):
      nfsd: don't take nfsd_mutex twice when setting number of threads.
      nfsd: optimise the starting of zero threads when none are running.

Randy Dunlap (2):
      nfsd: use C99 struct initializers
      lockd: fix FILE_LOCKING=n build error

Roel Kluin (1):
      rpcgss: remove redundant test on unsigned

Trond Myklebust (2):
      nfsd: Use write gathering only with NFSv2
      SUNRPC: Fix the TCP server's send buffer accounting

Wang Chen (1):
      nfsd: nfs4_stat_init cleanup

Yu Zhiguo (3):
      NFSv4: do exact check about attribute specified
      NFSv4: kill off complicated macro 'PROC'
      NFS: kill off complicated macro 'PROC'

 Documentation/filesystems/00-INDEX      |    4 +
 fs/Kconfig                              |    2 +
 fs/lockd/svclock.c                      |    2 +
 fs/locks.c                              |    3 +-
 fs/nfs/Kconfig                          |    2 +-
 fs/nfsd/export.c                        |   13 +-
 fs/nfsd/nfs3proc.c                      |  237 ++++++++++++++++++++++---
 fs/nfsd/nfs3xdr.c                       |    1 +
 fs/nfsd/nfs4callback.c                  |  247 ++++++++++++++++----------
 fs/nfsd/nfs4proc.c                      |  129 +++++++++++---
 fs/nfsd/nfs4state.c                     |  171 ++++++++++--------
 fs/nfsd/nfs4xdr.c                       |  296 ++++++++++++++-----------------
 fs/nfsd/nfscache.c                      |   33 +++--
 fs/nfsd/nfsctl.c                        |  294 +++++++++++++++++++------------
 fs/nfsd/nfsfh.c                         |    6 -
 fs/nfsd/nfsproc.c                       |  198 +++++++++++++++++----
 fs/nfsd/nfssvc.c                        |   12 +-
 fs/nfsd/vfs.c                           |   93 +++++-----
 include/linux/fs.h                      |    1 +
 include/linux/nfsd/cache.h              |    3 +-
 include/linux/nfsd/nfsfh.h              |    7 +
 include/linux/nfsd/state.h              |   44 +++---
 include/linux/nfsd/xdr4.h               |   28 ++--
 include/linux/sunrpc/svc_xprt.h         |    7 +-
 include/linux/sunrpc/svcsock.h          |    7 +-
 net/sunrpc/cache.c                      |    2 +-
 net/sunrpc/svc_xprt.c                   |   57 ++++--
 net/sunrpc/svcsock.c                    |  122 +++++++++----
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |    8 +-
 29 files changed, 1329 insertions(+), 700 deletions(-)
