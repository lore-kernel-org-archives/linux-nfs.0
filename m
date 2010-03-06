Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:37044 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753737Ab0CFRuy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 6 Mar 2010 12:50:54 -0500
Date: Sat, 6 Mar 2010 12:52:12 -0500
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: nfsd changes for 2.6.34
Message-ID: <20100306175212.GB22650@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Please pull the following nfsd changes from the 'nfsd' branch at:

  git://linux-nfs.org/~bfields/linux.git for-2.6.34 nfsd

This is an unusually quiet cycle for the NFS server--bugfixes, some IPv6
progress, and one new export operation to improve sync performance.

One exception to the 'mostly quiet' statement was a regression in the
rpc code which hit a lot of people: enormous thanks to Neil for tracking
that down.

--b.

Aime Le Rouzic (1):
      NFSD: Support AF_INET6 in svc_addsock() function

Ben Myers (2):
      commit_metadata export operation replacing nfsd_sync_dir
      xfs_export_operations.commit_metadata

Christoph Hellwig (1):
      nfsd: use vfs_fsync for non-directories

Chuck Lever (5):
      SUNRPC: Use rpc_pton() in ip_map_parse()
      SUNRPC: Bury "#ifdef IPV6" in svc_create_xprt()
      SUNRPC: NFS kernel APIs shouldn't return ENOENT for "transport not found"
      NFSD: Create PF_INET6 listener in write_ports
      NFSD: NFSv4 callback client should use RPC_TASK_SOFTCONN

J. Bruce Fields (6):
      nfsd: 4.1 has an rfc number
      Revert "sunrpc: fix peername failed on closed listener"
      Revert "sunrpc: move the close processing after do recvfrom method"
      svcrpc: treat uid's as unsigned
      nfsd4: fix minor memory leak
      Merge branch 'for-linus' of git://oss.sgi.com/xfs/xfs into for-2.6.34-incoming

Jeff Layton (2):
      lockd: release reference to nsm_handle in nlm_host_rebooted
      lockd: don't clear sm_monitored on nsm_reboot_lookup

Neil Brown (2):
      sunrpc: remove unnecessary svc_xprt_put
      nfsd: ensure sockets are closed on error

Ricardo Labiaga (3):
      nfsd41: nfsd4_decode_compound() does not recognize all ops
      nfsd4: Use FIRST_NFS4_OP in nfsd4_decode_compound()
      nfsd41: Create the recovery entry for the NFSv4.1 client

Trond Myklebust (1):
      nfsd: Use vfs_fsync_range() in nfsd_commit

 Documentation/filesystems/nfs/nfs41-server.txt |    5 +-
 fs/lockd/host.c                                |    2 +-
 fs/lockd/mon.c                                 |   12 +--
 fs/lockd/svc.c                                 |    2 -
 fs/nfs/callback.c                              |    2 -
 fs/nfsd/nfs4callback.c                         |    5 +-
 fs/nfsd/nfs4recover.c                          |    4 +-
 fs/nfsd/nfs4state.c                            |    4 +-
 fs/nfsd/nfs4xdr.c                              |    2 +-
 fs/nfsd/nfsctl.c                               |   24 +++-
 fs/nfsd/vfs.c                                  |  153 +++++++++++------------
 fs/xfs/linux-2.6/xfs_export.c                  |   20 +++
 include/linux/exportfs.h                       |    5 +
 net/sunrpc/svc_xprt.c                          |   27 ++--
 net/sunrpc/svcauth_unix.c                      |   49 ++++----
 net/sunrpc/svcsock.c                           |    3 +-
 16 files changed, 174 insertions(+), 145 deletions(-)
