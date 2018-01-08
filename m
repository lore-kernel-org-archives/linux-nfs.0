Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:33682 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751511AbeAHFaj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 8 Jan 2018 00:30:39 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
To: David Howells <dhowells@redhat.com>
Date: Mon, 08 Jan 2018 16:26:18 +1100
Subject: [PATCH 00/20] Remove generic rpc credentials,
 and associated changed - V2
Cc: linux-nfs@vger.kernel.org
Message-ID: <151538903497.25812.13293229343061416612.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,
 this is a revised version of a series I sent last month.  The summary
 I included then is below.
 This version adds a cred_fscmp() function to do credential
 comparison properly.

David: if you could Ack the cred_fscmp(), I suspect it would be simplest
if it went in through the NFS tree ?? Thanks.

Thanks,
NeilBrown


---------------
I recently posted a patch to change (again) the hash function for
credcache lookups because it isn't good in some cases.
Chuck correctly suggested that this was a bandaid and that some
sort of proper fix like changing the data structure might be a better
approach.

This series is the result.  It works for me in simple testing, but I
haven' tested with kerberos yet.

I fixed the problem with slow lookups in the credcache by removing
the credcache.  There is no longer a cache for generic credentials,
and, in fact, no generic credentials at all.  There is also no longer
a cred cache for unix credentials.  They are allocated on demand.
There is still a credcache for auth_gss, but it has never been a
problem (to my knowledge).  We do need a cache there, and it might
be appropriate to change it to an rbtree one day.

The removal of generic rpc credentials was achieved by using "struct
cred *" instead.  The only thing that a generic credential could
do that 'struct cred' cannot do is to describe a machine credential.
To meet this need, there is a statically allocated "struct cred"
which is used whenever a generic machine credential is needed.
It does not store the principal name - that is stored in the
rpc_client.

I have two particular concerns about this code (apart from the need
for testing and review) that I welcome input on.

1/ generic credentials were unique, so equality tests could just
   test the pointers.  'struct cred' are only opportunistically
   shared, so equal pointer will often be sufficient to detect
   equal credentials, but this is not a guarantee.
   This affects:
      the access cache
      nfs_match_open_context()
      nfs_find_open_context()
      pnfs_roc()

   I'm wondering how important it is that these reliably detect
   when two credentials are the same.
   It obviously isn't hard to write a cred_same() or cred_cmp()
   and I probably will, but I wanted to get more context first is
   possible.

2/ There are several places that try to get a machine credential
   and, if that fails, fall back to something else.
   In particular nfs4_get_renew_cred().
   As far as I can tell, nfs4_get_machine_cred_locked() always
   works.  It just gets a generic cred, not a gss cred, so
   there is no reason that it would fail.
   Does this need to be fixed?  How should it be fixed?

Thanks,
NeilBrown


---

NeilBrown (20):
      cred: add cred_fscmp() for comparing creds.
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
      SUNRPC discard cr_uid from struct rpc_cred.


 fs/lockd/clntproc.c                       |    6 -
 fs/nfs/client.c                           |    9 -
 fs/nfs/delegation.c                       |   24 +-
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
 fs/nfs/nfs4proc.c                         |  146 +++++++-------
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
 include/linux/cred.h                      |   12 +
 include/linux/nfs_fs.h                    |   13 +
 include/linux/nfs_fs_sb.h                 |    2 
 include/linux/nfs_xdr.h                   |   16 +-
 include/linux/sunrpc/auth.h               |   53 -----
 include/linux/sunrpc/clnt.h               |    1 
 include/linux/sunrpc/sched.h              |    6 -
 kernel/cred.c                             |   55 +++++
 net/sunrpc/Makefile                       |    2 
 net/sunrpc/auth.c                         |  122 ++++++------
 net/sunrpc/auth_generic.c                 |  299 -----------------------------
 net/sunrpc/auth_gss/auth_gss.c            |   44 +---
 net/sunrpc/auth_null.c                    |    4 
 net/sunrpc/auth_unix.c                    |  109 +++--------
 net/sunrpc/clnt.c                         |   26 +--
 net/sunrpc/sched.c                        |    5 
 44 files changed, 538 insertions(+), 929 deletions(-)
 delete mode 100644 net/sunrpc/auth_generic.c

--
Signature

