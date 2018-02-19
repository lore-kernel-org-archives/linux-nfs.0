Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38394 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750753AbeBSFDL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Feb 2018 00:03:11 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Mon, 19 Feb 2018 16:02:28 +1100
Subject: [PATCH 00/23] Remove generic rpc credentials,
 and associated changed - V3
Cc: linux-nfs@vger.kernel.org
Message-ID: <151901634940.17421.7637564368419392071.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here is the revises (For 4.16-rc2) version of a patch series I sent in
Dec and Jan.
This series has 4 'cred' patches at the front.  I sent them separately
to people who might be interested, and got no response.
I don't think that are at all controversial, so I think it would be
reasonable to submit them to Linux through the NFS tree with no Acks.
Would you be OK with that?

This series includes the fix for the rpcsec-gss problem that Anna
found.



---

NeilBrown (23):
      cred: add cred_fscmp() for comparing creds.
      cred: add get_cred_rcu()
      cred: export get_task_cred().
      cred: allow get_cred() and put_cred() to be given NULL.
      SUNRPC: add 'struct cred *' to auth_cred and rpc_cred
      SUNRPC: remove groupinfo from struct auth_cred.
      SUNRPC: remove uid and gid from struct auth_cred
      SUNRPC: remove machine_cred field from struct auth_cred
      NFSv4: add cl_root_cred for use when machine cred is not available.
      NFSv4: don't require lock for get_renew_cred or get_machine_cred
      SUNRPC: discard RPC_DO_ROOTOVERRIDE()
      NFS/SUNRPC: don't lookup machine credential until rpcauth_bindcred().
      SUNRPC: introduce RPC_TASK_NULLCREDS to request auth_none
      SUNRPC: add side channel to use non-generic cred for rpc call.
      NFS: move credential expiry tracking out of SUNRPC into NFS.
      SUNRPC: remove RPCAUTH_AUTH_NO_CRKEY_TIMEOUT
      NFS: change access cache to use 'struct cred'.
      NFS: struct nfs_open_dir_context: convert rpc_cred pointer to cred.
      NFS/NFSD/SUNRPC: replace generic creds with 'struct cred'.
      SUNRPC: remove generic cred code.
      SUNRPC: remove crbind rpc_cred operation
      SUNRPC: simplify auth_unix.
      SUNRPC: discard cr_uid from struct rpc_cred.


 fs/lockd/clntproc.c                       |    6 -
 fs/nfs/blocklayout/blocklayout.c          |    2 
 fs/nfs/client.c                           |    9 -
 fs/nfs/delegation.c                       |   26 +--
 fs/nfs/delegation.h                       |   10 -
 fs/nfs/dir.c                              |   59 ++----
 fs/nfs/flexfilelayout/flexfilelayout.c    |   62 +++---
 fs/nfs/flexfilelayout/flexfilelayout.h    |    8 -
 fs/nfs/flexfilelayout/flexfilelayoutdev.c |   16 +-
 fs/nfs/inode.c                            |   12 +
 fs/nfs/internal.h                         |    8 -
 fs/nfs/nfs3proc.c                         |    4 
 fs/nfs/nfs4_fs.h                          |   65 +++---
 fs/nfs/nfs4client.c                       |    4 
 fs/nfs/nfs4proc.c                         |  149 +++++++-------
 fs/nfs/nfs4renewd.c                       |    9 -
 fs/nfs/nfs4session.c                      |    4 
 fs/nfs/nfs4state.c                        |  127 ++++++------
 fs/nfs/pagelist.c                         |    2 
 fs/nfs/pnfs.c                             |   10 -
 fs/nfs/pnfs.h                             |   10 -
 fs/nfs/pnfs_dev.c                         |    4 
 fs/nfs/pnfs_nfs.c                         |    2 
 fs/nfs/proc.c                             |    2 
 fs/nfs/unlink.c                           |   15 -
 fs/nfs/write.c                            |   24 ++
 fs/nfsd/nfs4callback.c                    |   42 +---
 fs/nfsd/nfs4state.c                       |   10 -
 fs/nfsd/state.h                           |    4 
 include/linux/cred.h                      |   26 ++-
 include/linux/nfs_fs.h                    |   13 +
 include/linux/nfs_fs_sb.h                 |    2 
 include/linux/nfs_xdr.h                   |   16 +-
 include/linux/sunrpc/auth.h               |   53 -----
 include/linux/sunrpc/clnt.h               |    1 
 include/linux/sunrpc/sched.h              |    6 -
 kernel/cred.c                             |   58 ++++++
 net/sunrpc/Makefile                       |    2 
 net/sunrpc/auth.c                         |  115 ++++++-----
 net/sunrpc/auth_generic.c                 |  299 -----------------------------
 net/sunrpc/auth_gss/auth_gss.c            |   45 +---
 net/sunrpc/auth_null.c                    |    4 
 net/sunrpc/auth_unix.c                    |  110 +++--------
 net/sunrpc/clnt.c                         |   26 +--
 net/sunrpc/sched.c                        |    5 
 45 files changed, 551 insertions(+), 935 deletions(-)
 delete mode 100644 net/sunrpc/auth_generic.c

--
Signature

