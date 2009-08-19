Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39738 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754072AbZHSXk6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Aug 2009 19:40:58 -0400
Received: from svlrsexc2-prd.hq.netapp.com (svlrsexc2-prd.hq.netapp.com [10.57.115.31])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n7JNe7Xv028517
	for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2009 16:40:44 -0700 (PDT)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 00/32] The following patches have been committed to branch
 nfs-for-2.6.32
Date: Wed, 19 Aug 2009 19:38:23 -0400
Message-Id: <1250725135-14632-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Bartlomiej Zolnierkiewicz (1):
      nfs: remove superfluous BUG_ON()s

Peter Staubach (1):
      NFS: read-modify-write page updating

Roel Kluin (1):
      nfs: Keep index within mnt_errtbl[]

Trond Myklebust (29):
      NFSv4: Don't loop forever on state recovery failure...
      NFSv4: Add 'server capability' flags for NFSv4 recommended attributes
      NFSv4: Don't do idmapper upcalls for asynchronous RPC calls
      SUNRPC: convert some sysctls into module parameters
      NFSv4: Clean up the nfs.callback_tcpport option
      SUNRPC: Constify rpc_pipe_ops...
      SUNRPC: Allow rpc_pipefs_ops to have null values for upcall and downcall
      SUNRPC: Clean up rpc_pipefs lookup code...
      SUNRPC: Clean up file creation code in rpc_pipefs
      SUNRPC: Clean up rpc_unlink()
      SUNRPC: Clean up rpc_lookup_create
      SUNRPC: Clean up rpc_populate/depopulate
      SUNRPC: rpc_pipefs cleanup
      SUNRPC: Rename rpc_mkdir to rpc_create_client_dir()
      SUNRPC: Clean up rpc_create_client_dir()
      SUNRPC: Replace rpc_client->cl_dentry and cl_mnt, with a cl_path
      SUNRPC: clean up rpc_setup_pipedir()
      SUNRPC: One more clean up for rpc_create_client_dir()
      NFSD: Clean up the idmapper warning...
      SUNRPC: Ensure we initialise the cache_detail before creating procfs files
      SUNRPC: Remove the global temporary write buffer in net/sunrpc/cache.c
      SUNRPC: Allow the cache_detail to specify alternative upcall mechanisms
      SUNRPC: Move procfs-specific stuff out of the generic sunrpc cache code
      SUNRPC: Add an rpc_pipefs front end for the sunrpc cache code
      NFS: Add a ->migratepage() aop for NFS
      SUNRPC: Fix a typo in cache_pipefs_files
      NFS: Add a dns resolver for use with NFSv4 referrals and migration
      NFS: Use the DNS resolver in the mount code.
      SUNRPC: cache must take a reference to the cache detail's module on open()

 Documentation/filesystems/nfs.txt   |   98 +++++
 Documentation/kernel-parameters.txt |   29 ++
 fs/nfs/Makefile                     |    3 +-
 fs/nfs/cache_lib.c                  |  140 +++++++
 fs/nfs/cache_lib.h                  |   27 ++
 fs/nfs/callback.c                   |   26 +-
 fs/nfs/client.c                     |   15 +-
 fs/nfs/dns_resolve.c                |  335 +++++++++++++++++
 fs/nfs/dns_resolve.h                |   14 +
 fs/nfs/file.c                       |   49 +++-
 fs/nfs/idmap.c                      |    6 +-
 fs/nfs/inode.c                      |  100 +++++-
 fs/nfs/internal.h                   |    6 +
 fs/nfs/mount_clnt.c                 |    4 +-
 fs/nfs/nfs4namespace.c              |   18 +-
 fs/nfs/nfs4proc.c                   |   40 ++-
 fs/nfs/nfs4xdr.c                    |   86 +++--
 fs/nfs/write.c                      |   91 ++++--
 fs/nfsd/export.c                    |   14 +-
 fs/nfsd/nfs4idmap.c                 |   20 +-
 include/linux/nfs_fs_sb.h           |    9 +
 include/linux/sunrpc/cache.h        |   40 ++-
 include/linux/sunrpc/clnt.h         |    5 +-
 include/linux/sunrpc/rpc_pipe_fs.h  |   18 +-
 net/sunrpc/auth_gss/auth_gss.c      |   12 +-
 net/sunrpc/auth_gss/svcauth_gss.c   |    7 +-
 net/sunrpc/cache.c                  |  622 ++++++++++++++++++++++++--------
 net/sunrpc/clnt.c                   |   60 ++-
 net/sunrpc/rpc_pipe.c               |  685 ++++++++++++++++++++---------------
 net/sunrpc/svcauth_unix.c           |   14 +-
 net/sunrpc/xprtsock.c               |   52 +++
 31 files changed, 2065 insertions(+), 580 deletions(-)

