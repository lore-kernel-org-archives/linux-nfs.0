Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f181.google.com ([209.85.213.181]:63438 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752831AbaHMRSQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Aug 2014 13:18:16 -0400
Received: by mail-ig0-f181.google.com with SMTP id h3so2415678igd.2
        for <linux-nfs@vger.kernel.org>; Wed, 13 Aug 2014 10:18:16 -0700 (PDT)
Message-ID: <1407950297.4581.1.camel@leira.trondhjem.org>
Subject: [GIT PULL] Please pull NFS client updates for 3.17
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel mailing list <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date: Wed, 13 Aug 2014 13:18:17 -0400
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-EXmoWuZ50nbGn3bbhuB0"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-EXmoWuZ50nbGn3bbhuB0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Linus,

The following changes since commit 9a3c4145af32125c5ee39c0272662b47307a8323=
:

  Linux 3.16-rc6 (2014-07-20 21:04:16 -0700)

are available in the git repository at:

  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-3.17-=
1

for you to fetch changes up to 71a6ec8ac587418ceb6b420def1ca44b334c1ff7:

  nfs: reject changes to resvport and sharecache during remount (2014-08-04=
 17:41:52 -0400)

----------------------------------------------------------------
NFS client updates for Linux 3.17

Highlights include:

- Stable fix for a bug in nfs3_list_one_acl()
- Speed up NFS path walks by supporting LOOKUP_RCU
- More read/write code cleanups
- pNFS fixes for layout return on close
- Fixes for the RCU handling in the rpcsec_gss code
- More NFS/RDMA fixes

----------------------------------------------------------------
Alexey Khoroshilov (1):
      NFS: add checks for returned value of try_module_get()

Andrey Utkin (1):
      nfs3_list_one_acl(): check get_acl() result with IS_ERR_OR_NULL

Anna Schumaker (1):
      nfs: Fix unused variable error

Chuck Lever (21):
      xprtrdma: Fix panic in rpcrdma_register_frmr_external()
      xprtrdma: Protect ia->ri_id when unmapping/invalidating MRs
      xprtrdma: Limit data payload size for ALLPHYSICAL
      xprtrdma: Update rkeys after transport reconnect
      xprtrdma: On disconnect, don't ignore pending CQEs
      xprtrdma: Don't invalidate FRMRs if registration fails
      xprtrdma: Unclutter struct rpcrdma_mr_seg
      xprtrdma: Back off rkey when FAST_REG_MR fails
      xprtrdma: Chain together all MWs in same buffer pool
      xprtrdma: Properly handle exhaustion of the rb_mws list
      xprtrdma: Reset FRMRs when FAST_REG_MR is flushed by a disconnect
      xprtrdma: Reset FRMRs after a flushed LOCAL_INV Work Request
      xprtrdma: Don't post a LOCAL_INV in rpcrdma_register_frmr_external()
      xprtrdma: Disable completions for FAST_REG_MR Work Requests
      xprtrdma: Disable completions for LOCAL_INV Work Requests
      xprtrdma: Rename frmr_wr
      xprtrdma: Allocate each struct rpcrdma_mw separately
      xprtrdma: Schedule reply tasklet once per upcall
      xprtrdma: Make rpcrdma_ep_disconnect() return void
      xprtrdma: Remove RPCRDMA_PERSISTENT_REGISTRATION macro
      xprtrdma: Handle additional connection events

Daniel Walter (1):
      replace strict_strto calls

Fabian Frederick (3):
      FS/NFS: replace count*size kzalloc by kcalloc
      fs/nfs_common/nfsacl.c: move EXPORT symbol after functions
      NFS: use ARRAY_SIZE instead of sizeof/sizeof[0]

Himangi Saraogi (2):
      rpc_pipe: Drop memory allocation cast
      NFSv4: Drop cast

Jeff Layton (11):
      nfs4: treat lock owners as opaque values
      nfs4: queue free_lock_state job submission to nfsiod
      nfs4: turn free_lock_state into a void return operation
      auth_gss: fetch the acceptor name out of the downcall
      sunrpc: add a new "stringify_acceptor" rpc_credop
      nfs4: copy acceptor name from context to nfs_client
      sunrpc: remove __rcu annotation from struct gss_cl_ctx->gc_gss_ctx
      sunrpc: fix RCU handling of gc_ctx field
      sunrpc: clean up sparse endianness warnings in gss_krb5_seal.c
      sunrpc: clean up sparse endianness warnings in gss_krb5_wrap.c
      sunrpc: remove "ec" argument from encrypt_v2 operation

Kinglong Mee (1):
      NFS: Avoid infinite loop when RELEASE_LOCKOWNER getting expired error

NeilBrown (10):
      NFS: nfs4_do_open should add negative results to the dcache.
      NFS: nfs4_lookup_revalidate: only evaluate parent if it will be used.
      NFS: prepare for RCU-walk support but pushing tests later in code.
      sunrpc/auth: allow lockless (rcu) lookup of credential cache.
      NFS: support RCU_WALK in nfs_permission()
      NFS: teach nfs_neg_need_reval to understand LOOKUP_RCU
      NFS: teach nfs_lookup_verify_inode to handle LOOKUP_RCU
      NFS: allow lockless access to access_cache
      NFS: fix two problems in lookup_revalidate in RCU-walk
      SUNRPC: remove all refcounting of groupinfo from rpcauth_lookupcred

Peng Tao (7):
      nfsv4: set hostname when creating nfsv4 ds connection
      nfs: check hostname in nfs_get_client
      pnfs/filelayout: fix race between mark_request_commit and scan_commit=
_lists
      pnfs/filelayout: retry ds commit if nfs_commitdata_alloc fails
      nfs4: add nfs4_check_delegation
      nfs41: return layout on last close
      nfs41: layout return on close in delegation return

Scott Mayhew (1):
      nfs: reject changes to resvport and sharecache during remount

Trond Myklebust (7):
      SUNRPC: Ensure that we handle ENOBUFS errors correctly.
      SUNRPC: Handle EPIPE in xprt_connect_status
      NFSv4: Fix OPEN w/create access mode checking
      Merge branch 'bugfixes' into linux-next
      SUNRPC: Enforce an upper limit on the number of cached credentials
      NFS: Enforce an upper limit on the number of cached access call
      Merge branch 'nfs-rdma' of git://git.linux-nfs.org/projects/anna/nfs-=
rdma into linux-next

Weston Andros Adamson (13):
      nfs: move nfs_pgio_data and remove nfs_rw_header
      nfs: rename members of nfs_pgio_data
      nfs: merge nfs_pgio_data into _header
      nfs: remove unused writeverf code
      nfs: remove pgio_header refcount, related cleanup
      pnfs: clean up *_resend_to_mds
      nfs: remove unneeded EXPORTs
      nfs: get rid of duplicate dprintk
      nfs: check wait_on_bit_lock err in page_group_lock
      nfs: fix comment and add warn_on for PG_INODE_REF
      pnfs: find swapped pages on pnfs commit lists too
      pnfs: add pnfs_put_lseg_async
      nfs: clear_request_commit while holding i_lock

Yan Burman (1):
      xprtrdma: Fix DMA-API-DEBUG warning by checking dma_map result

 fs/nfs/blocklayout/blocklayout.c      | 101 +++--
 fs/nfs/callback.c                     |  12 +
 fs/nfs/client.c                       |  18 +-
 fs/nfs/delegation.c                   |  34 +-
 fs/nfs/delegation.h                   |   1 +
 fs/nfs/dir.c                          | 208 ++++++++--
 fs/nfs/direct.c                       |  33 +-
 fs/nfs/filelayout/filelayout.c        | 298 ++++++++------
 fs/nfs/filelayout/filelayoutdev.c     |   2 +-
 fs/nfs/inode.c                        |   9 +
 fs/nfs/internal.h                     |  11 +-
 fs/nfs/nfs3acl.c                      |   2 +-
 fs/nfs/nfs3proc.c                     |  21 +-
 fs/nfs/nfs4_fs.h                      |  32 +-
 fs/nfs/nfs4client.c                   |   5 +
 fs/nfs/nfs4proc.c                     | 248 ++++++++----
 fs/nfs/nfs4state.c                    |  69 ++--
 fs/nfs/nfs4trace.h                    |  28 +-
 fs/nfs/nfs4xdr.c                      |   2 +-
 fs/nfs/objlayout/objio_osd.c          |  24 +-
 fs/nfs/objlayout/objlayout.c          |  81 ++--
 fs/nfs/objlayout/objlayout.h          |   8 +-
 fs/nfs/pagelist.c                     | 276 ++++++-------
 fs/nfs/pnfs.c                         | 178 +++-----
 fs/nfs/pnfs.h                         |  45 ++-
 fs/nfs/proc.c                         |  27 +-
 fs/nfs/read.c                         |  54 ++-
 fs/nfs/super.c                        |  12 +-
 fs/nfs/write.c                        | 150 +++----
 fs/nfs_common/nfsacl.c                |   5 +-
 include/linux/nfs_fs.h                |   2 +
 include/linux/nfs_fs_sb.h             |   1 +
 include/linux/nfs_page.h              |  19 +-
 include/linux/nfs_xdr.h               |  34 +-
 include/linux/sunrpc/auth.h           |   4 +
 include/linux/sunrpc/auth_gss.h       |   3 +-
 include/linux/sunrpc/gss_krb5.h       |   4 +-
 include/linux/sunrpc/xprtrdma.h       |   2 -
 net/sunrpc/addr.c                     |  16 +-
 net/sunrpc/auth.c                     |  68 +++-
 net/sunrpc/auth_generic.c             |   6 +
 net/sunrpc/auth_gss/auth_gss.c        | 126 ++++--
 net/sunrpc/auth_gss/gss_krb5_crypto.c |   9 +-
 net/sunrpc/auth_gss/gss_krb5_seal.c   |  28 +-
 net/sunrpc/auth_gss/gss_krb5_wrap.c   |  20 +-
 net/sunrpc/auth_null.c                |   2 +
 net/sunrpc/clnt.c                     |   5 +
 net/sunrpc/rpc_pipe.c                 |   2 +-
 net/sunrpc/xprt.c                     |   1 +
 net/sunrpc/xprtrdma/rpc_rdma.c        |  83 ++--
 net/sunrpc/xprtrdma/transport.c       |  17 +-
 net/sunrpc/xprtrdma/verbs.c           | 739 +++++++++++++++++++++++-------=
----
 net/sunrpc/xprtrdma/xprt_rdma.h       |  61 ++-
 net/sunrpc/xprtsock.c                 |   9 +-
 54 files changed, 1967 insertions(+), 1288 deletions(-)

--=20
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


--=-EXmoWuZ50nbGn3bbhuB0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABAgAGBQJT653ZAAoJEGcL54qWCgDy1EQP/ROGklUfvOjv3lryl/czR2dm
BaVFSmUujcwO+0V/PQPcYUW9x/1TylH3KBvIdql6DpO9YzHR7gJNEaQEalXDjbpf
SwuNblkXaLp60ODK0VQ0lMZu4HFrOOF2mkkJbu6wMEKZDMB2xcX+r0AjR5DM+rlI
BreM/lYDVcIDjPqRUdWuANNgryns4Wz9ccOGdxfIwsNmnhggxzcT0/UQl6qN9mC7
obNrvLA2Lrr8wCDmX9BPZjwgJdN2Dg0l2ztpK7uCyTuRGDHQlMF8csFLE6txEW5U
Rx5/Of7TMzdKIJy2gPxnsCNBeeqOT3pkJlB72EagFgE/M/XKIS6d9g2+4Um8XiQO
rNbO2kddn5kIUP5v4/7zKP1lVgrtZFdFTaczEAlkntrwTa3dpioEnj4yNW/BL9md
RESwiDu0BHYz6JGU88jMFLuye1Lxl1OWrZ1b1S4mu1Dt1nZtLh4cT+FURFhYu5JW
DRKMLVoZvcwkYAOIHiRar8B5vOlOPIjv3h1cafDABwthstBtOX8WDlZtR2D1IYIf
B/myl2ibOxp6ab2JYO5/83w6MiOcVi56OKUBB9qUAUrVLnPD0Nq4croC/9QCiuGl
0i6cSrip1cT7RZqZEMm31w0D3/3bpi1TUFAnTh39KuiaKov7OgJrkArqdbKwH1gS
Wy4Ad44Orch29uHN53q8
=5Odx
-----END PGP SIGNATURE-----

--=-EXmoWuZ50nbGn3bbhuB0--

