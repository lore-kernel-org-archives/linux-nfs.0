Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f175.google.com ([209.85.223.175]:64764 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752949AbaFJVmP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Jun 2014 17:42:15 -0400
Received: by mail-ie0-f175.google.com with SMTP id tp5so6191927ieb.34
        for <linux-nfs@vger.kernel.org>; Tue, 10 Jun 2014 14:42:15 -0700 (PDT)
Message-ID: <1402436530.9440.1.camel@leira.trondhjem.org>
Subject: [GIT PULL] Please pull NFS client updates
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Torvalds Linus <torvalds@linux-foundation.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>
Date: Tue, 10 Jun 2014 17:42:10 -0400
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-dinaBu2NsQynTCH4Xsj8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-dinaBu2NsQynTCH4Xsj8
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Linus,

The following changes since commit c9eaa447e77efe77b7fa4c953bd62de8297fd6c5=
:

  Linux 3.15-rc1 (2014-04-13 14:18:35 -0700)

are available in the git repository at:

  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-3.16-=
1

for you to fetch changes up to a914722f333b3359d2f4f12919380a334176bb89:

  NFS: populate ->net in mount data when remounting (2014-06-10 11:10:29 -0=
400)

----------------------------------------------------------------
NFS client updates for Linux 3.16

Highlights include:

- Massive cleanup of the NFS read/write code by Anna and Dros
- Support multiple NFS read/write requests per page in order to deal with
  non-page aligned pNFS striping. Also cleans up the r/wsize < page size
  code nicely.
- stable fix for ensuring inode is declared uptodate only after all the
  attributes have been checked.
- stable fix for a kernel Oops when remounting
- NFS over RDMA client fixes
- move the pNFS files layout driver into its own subdirectory

----------------------------------------------------------------
Allen Andrews (1):
      nfs-rdma: Fix for FMR leaks

Andy Adamson (1):
      NFSv4: Use error handler on failed GETATTR with successful OPEN

Anna Schumaker (17):
      NFS: Create a common argument structure for reads and writes
      NFS: Create a common results structure for reads and writes
      NFS: Create a common read and write data struct
      NFS: Create a common read and write header struct
      NFS: Move the write verifier into the nfs_pgio_header
      NFS: Create a common pgio_alloc and pgio_release function
      NFS: Create a common rw_header_alloc and rw_header_free function
      NFS: Create a common pgio_rpc_prepare function
      NFS: Create a common nfs_pgio_result_common function
      NFS: Create a common rpc_call_ops struct
      NFS: Create a common rpcsetup function for reads and writes
      NFS: Create a common pgio_error function
      NFS: Create a generic_pgio function
      NFS: Create a common initiate_pgio() function
      NFS: Create a common multiple_pgios() function
      NFS: Create a common generic_pg_pgios()
      NFS: Create a common nfs_pageio_ops struct

Christoph Hellwig (3):
      nfs: commit layouts in fdatasync
      nfs: remove ->write_pageio_init from rpc ops
      nfs: remove ->read_pageio_init from rpc ops

Chuck Lever (21):
      xprtrdma: RPC/RDMA must invoke xprt_wake_pending_tasks() in process c=
ontext
      xprtrdma: Remove BOUNCEBUFFERS memory registration mode
      xprtrdma: Remove MEMWINDOWS registration modes
      xprtrdma: Remove REGISTER memory registration mode
      xprtrdma: Fall back to MTHCAFMR when FRMR is not supported
      xprtrdma: mount reports "Invalid mount option" if memreg mode not sup=
ported
      xprtrdma: Simplify rpcrdma_deregister_external() synopsis
      xprtrdma: Make rpcrdma_ep_destroy() return void
      xprtrdma: Split the completion queue
      xprtrmda: Reduce lock contention in completion handlers
      xprtrmda: Reduce calls to ib_poll_cq() in completion handlers
      xprtrdma: Limit work done by completion handler
      xprtrdma: Reduce the number of hardway buffer allocations
      xprtrdma: Ensure ia->ri_id->qp is not NULL when reconnecting
      xprtrdma: Remove Tavor MTU setting
      xprtrdma: Use macros for reconnection timeout constants
      xprtrdma: Reset connection timeout after successful reconnect
      SUNRPC: Move congestion window constants to header file
      xprtrdma: Avoid deadlock when credit window is reset
      xprtrdma: Remove BUG_ON() call sites
      xprtrdma: Disconnect on registration failure

David Rientjes (1):
      net, sunrpc: suppress allocation warning in rpc_malloc()

Kinglong Mee (1):
      NFS: Fix memroy leak for double mounts

Mateusz Guzik (1):
      NFS: populate ->net in mount data when remounting

Scott Mayhew (1):
      nfs: Apply NFS_MOUNT_CMP_FLAGMASK to nfs_compare_remount_data()

Shirley Ma (1):
      xprtrdma: Allocate missing pagelist

Steve Wise (1):
      xprtrdma: mind the device's max fast register page list depth

Tom Haynes (3):
      Push the file layout driver into a subdirectory
      NFSv4.1: Comment is now wrong and redundant to code
      NFSv4.1: Fix typo in dprintk

Trond Myklebust (9):
      NFS: Don't declare inode uptodate unless all attributes were checked
      NFS: Don't ignore suid/sgid bit changes after a successful write
      SUNRPC: Fix a module reference issue in rpcsec_gss
      NFS: Fix error handling in __nfs_pageio_add_request
      NFS: Fix a potential busy wait in nfs_page_group_lock
      pNFS: Handle allocation errors correctly in filelayout_alloc_layout_h=
dr()
      pNFS: Handle allocation errors correctly in objlayout_alloc_layout_hd=
r()
      Merge tag 'nfs-rdma-3.16' of git://git.linux-nfs.org/projects/anna/nf=
s-rdma into linux-next
      NFS: Use raw_write_seqcount_begin/end int nfs4_reclaim_open_state

Weston Andros Adamson (19):
      pnfs: fix race in filelayout commit path
      nfs: clean up PG_* flags
      nfs: remove unused arg from nfs_create_request
      nfs: modify pg_test interface to return size_t
      nfs: call nfs_can_coalesce_requests for every req
      nfs: add support for multiple nfs reqs per page
      nfs: page group syncing in read path
      nfs: page group syncing in write path
      nfs: page group support in nfs_mark_uptodate
      pnfs: clean up filelayout_alloc_commit_info
      nfs: allow coalescing of subpage requests
      nfs: chain calls to pg_test
      nfs: use > 1 request to handle bsize < PAGE_SIZE
      nfs: remove data list from pgio header
      pnfs: support multiple verfs per direct req
      pnfs: allow non page aligned pnfs layout segments
      pnfs: filelayout: support non page aligned layouts
      nfs: support page groups in nfs_read_completion
      pnfs: fix lockup caused by pnfs_generic_pg_test

 fs/nfs/Makefile                                    |   4 +-
 fs/nfs/blocklayout/blocklayout.c                   |  38 +-
 fs/nfs/direct.c                                    | 117 +++-
 fs/nfs/filelayout/Makefile                         |   5 +
 .../{nfs4filelayout.c =3D> filelayout/filelayout.c}  | 203 +++---
 .../{nfs4filelayout.h =3D> filelayout/filelayout.h}  |   2 +-
 .../filelayoutdev.c}                               |   6 +-
 fs/nfs/getroot.c                                   |   3 +-
 fs/nfs/inode.c                                     |  26 +-
 fs/nfs/internal.h                                  |  33 +-
 fs/nfs/nfs2xdr.c                                   |  14 +-
 fs/nfs/nfs3proc.c                                  |  21 +-
 fs/nfs/nfs3xdr.c                                   |  16 +-
 fs/nfs/nfs4_fs.h                                   |   4 +-
 fs/nfs/nfs4file.c                                  |   3 +-
 fs/nfs/nfs4proc.c                                  |  56 +-
 fs/nfs/nfs4state.c                                 |   6 +-
 fs/nfs/nfs4trace.h                                 |   8 +-
 fs/nfs/nfs4xdr.c                                   |  19 +-
 fs/nfs/objlayout/objio_osd.c                       |  24 +-
 fs/nfs/objlayout/objlayout.c                       |  24 +-
 fs/nfs/objlayout/objlayout.h                       |   8 +-
 fs/nfs/pagelist.c                                  | 633 +++++++++++++++--
 fs/nfs/pnfs.c                                      | 166 ++---
 fs/nfs/pnfs.h                                      |  30 +-
 fs/nfs/proc.c                                      |  21 +-
 fs/nfs/read.c                                      | 414 +++--------
 fs/nfs/super.c                                     |  27 +-
 fs/nfs/write.c                                     | 588 +++++-----------
 include/linux/nfs.h                                |   5 +-
 include/linux/nfs_fs.h                             |   2 -
 include/linux/nfs_page.h                           |  46 +-
 include/linux/nfs_xdr.h                            | 106 +--
 include/linux/sunrpc/xprt.h                        |   6 +
 net/sunrpc/auth_gss/gss_mech_switch.c              |   4 +-
 net/sunrpc/sched.c                                 |   5 +-
 net/sunrpc/xprt.c                                  |  28 +-
 net/sunrpc/xprtrdma/rpc_rdma.c                     | 119 ++--
 net/sunrpc/xprtrdma/transport.c                    |  90 +--
 net/sunrpc/xprtrdma/verbs.c                        | 753 +++++++++--------=
----
 net/sunrpc/xprtrdma/xprt_rdma.h                    |  17 +-
 41 files changed, 1804 insertions(+), 1896 deletions(-)
 create mode 100644 fs/nfs/filelayout/Makefile
 rename fs/nfs/{nfs4filelayout.c =3D> filelayout/filelayout.c} (90%)
 rename fs/nfs/{nfs4filelayout.h =3D> filelayout/filelayout.h} (99%)
 rename fs/nfs/{nfs4filelayoutdev.c =3D> filelayout/filelayoutdev.c} (99%)

--=20
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


--=-dinaBu2NsQynTCH4Xsj8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABAgAGBQJTl3uyAAoJEGcL54qWCgDy2rgP/jyejDefVU2f/iFT2TNtUTy/
kZgr5Iqr5fPWHYb83EyOSAY8IkBwym5flUzKN0KXQkW6XBNdM2I1mhvVBYW4aGZ+
AYMhVrHoeZJnMY3Duc6pImevDJ28bGhiUNOpYan9Zi3pDYVEwpnrLbIX1pStRSv8
I5pdN5pQdi1YtjdgF52aTZad91bim07yjElI1Ud1mu5A6PwLT7Kd48xrrBFfv4Vj
43dp2CNCnXuuR0FDhdEkAX+oBNg9A/y5PN9AM3GVm8UbLZgD1qV3bdN9Od9uJIQ+
QcxZ0yWDPn+Ts6hGjcrwpF54Mu1SvexPd2cFJ9U1ARNb1rGVAHVnbFyc838Q/bhc
ydQtYSbr9DK4D+2Okq8jVgh1M0810J2FTgJhKP8B/qMoWffvC/SuOU+yUXwxxul2
rMV3XeMgNzWuAsVXdup6Ge92AxK6ZujUB7mj4qtTDNbtUtVGj+YHOzm0z/rrS/Dd
abn1KWVI2zYi6jNKeamzoClG/Ig8c8Y4y/s5VMPhTiNxzcywTS/k2GpPI1NngxO3
bIdU7qmHRI069sMkARjdXLCkIMGEXfIY+/v+OEq8IuJ13zozFsMXhzpAu7EysSLC
pRD0hVzGc0s/7QM59Z0nFNVZam4q2KASaATvtP98yQyX6LWIRndxqKI858kVmWeg
bwFGJuh0yx6SboieViXU
=O/9P
-----END PGP SIGNATURE-----

--=-dinaBu2NsQynTCH4Xsj8--

