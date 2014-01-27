Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f177.google.com ([209.85.213.177]:36401 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753347AbaA0Qtf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Jan 2014 11:49:35 -0500
Received: by mail-ig0-f177.google.com with SMTP id k19so9477242igc.4
        for <linux-nfs@vger.kernel.org>; Mon, 27 Jan 2014 08:49:34 -0800 (PST)
Message-ID: <1390841372.4631.3.camel@leira.trondhjem.org>
Subject: [GIT PULL] Please pull NFS client changes
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Torvalds Linus <torvalds@linux-foundation.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>
Date: Mon, 27 Jan 2014 11:49:32 -0500
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-/698AripKlEcq/WOQQVF"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-/698AripKlEcq/WOQQVF
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Linus,

The following changes since commit 374b105797c3d4f29c685f3be535c35f5689b30e=
:

  Linux 3.13-rc3 (2013-12-06 09:34:04 -0800)

are available in the git repository at:

  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-3.14-=
1

for you to fetch changes up to ed7e5423014ad89720fcf315c0b73f2c5d0c7bd2:

  pnfs: Proper delay for NFS4ERR_RECALLCONFLICT in layout_get_done (2014-01=
-22 18:10:49 -0700)

----------------------------------------------------------------
NFS client updates for Linux 3.14

Highlights include:

- Stable fix for an infinite loop in RPC state machine
- Stable fix for a use after free situation in the NFSv4 trunking discovery
- Stable fix for error handling in the NFSv4 trunking discovery
- Stable fix for the page write update code
- Stable fix for the NFSv4.1 mount time security negotiation
- Stable fix for the NFSv4 open code.
- O_DIRECT locking fixes
- fix an Oops in the pnfs file commit code
- RPC layer needs finer grained handling of connection errors
- More RPC GSS upcall fixes

----------------------------------------------------------------
Alexander Aring (1):
      nfs: fix dead code of ipv6_addr_scope

Boaz Harrosh (1):
      pnfs: Proper delay for NFS4ERR_RECALLCONFLICT in layout_get_done

Christoph Hellwig (7):
      nfs: fix size updates for aio writes
      nfs: defer inode_dio_done call until size update is done
      nfs: increment i_dio_count for reads, too
      nfs: merge nfs_direct_read into nfs_file_direct_read
      nfs: merge nfs_direct_write into nfs_file_direct_write
      nfs: take i_mutex during direct I/O reads
      nfs: page cache invalidation for dio

Jeff Layton (6):
      sunrpc: create a new dummy pipe for gssd to hold open
      sunrpc: replace sunrpc_net->gssd_running flag with a more reliable ch=
eck
      nfs: check if gssd is running before attempting to use krb5i auth in =
SETCLIENTID call
      rpc_pipe: remove the clntXX dir if creating the pipe fails
      sunrpc: add an "info" file for the dummy gssd pipe
      rpc_pipe: fix cleanup of dummy gssd directory when notification fails

Niels de Vos (1):
      NFS: dprintk() should not print negative fileids and inode numbers

Scott Mayhew (1):
      nfs: always make sure page is up-to-date before extending a write to =
cover the entire page

Toralf F=C3=B6rster (1):
      point to the right include file in a comment (left over from a9004abc=
3)

Trond Myklebust (8):
      NFSv4: OPEN must handle the NFS4ERR_IO return code correctly
      SUNRPC: Ensure xprt_connect_status handles all potential connection e=
rrors
      SUNRPC: Handle connect errors ECONNABORTED and EHOSTUNREACH
      SUNRPC: Report connection error values to rpc_tasks on the pending qu=
eue
      SUNRPC: Add tracepoint for socket errors
      NFSv4.1: Don't trust attributes if a pNFS LAYOUTCOMMIT is outstanding
      NFSv4.1: Fix a race in nfs4_write_inode
      NFSv4.1: Handle errors correctly in nfs41_walk_client_list

Weston Andros Adamson (4):
      sunrpc: Fix infinite loop in RPC state machine
      nfs4.1: properly handle ENOTSUP in SECINFO_NO_NAME
      nfs4: fix discover_server_trunking use after free
      pnfs: fix BUG in filelayout_recover_commit_reqs

 fs/nfs/dir.c                       |  18 +--
 fs/nfs/direct.c                    | 279 ++++++++++++++++++++-------------=
----
 fs/nfs/file.c                      |   6 +-
 fs/nfs/inode.c                     |  48 ++++---
 fs/nfs/nfs3acl.c                   |   4 +-
 fs/nfs/nfs4client.c                |  25 ++--
 fs/nfs/nfs4filelayout.c            |  16 +--
 fs/nfs/nfs4filelayoutdev.c         |   2 +-
 fs/nfs/nfs4proc.c                  |  43 ++++--
 fs/nfs/nfs4state.c                 |   4 +-
 fs/nfs/nfs4super.c                 |  14 +-
 fs/nfs/nfs4xdr.c                   |  47 ++++---
 fs/nfs/pnfs.c                      |  67 ++++-----
 fs/nfs/pnfs.h                      |  16 +++
 fs/nfs/read.c                      |  12 +-
 fs/nfs/write.c                     |  19 +--
 include/linux/sunrpc/rpc_pipe_fs.h |   5 +-
 include/trace/events/sunrpc.h      |   1 +
 net/sunrpc/auth_gss/auth_gss.c     |  17 +--
 net/sunrpc/clnt.c                  |  15 +-
 net/sunrpc/netns.h                 |   3 +-
 net/sunrpc/rpc_pipe.c              | 169 +++++++++++++++++++++-
 net/sunrpc/sunrpc_syms.c           |   8 +-
 net/sunrpc/xprt.c                  |   5 +
 net/sunrpc/xprtsock.c              |  42 +++++-
 25 files changed, 597 insertions(+), 288 deletions(-)

--=20
Trond Myklebust
Linux NFS client maintainer

--=-/698AripKlEcq/WOQQVF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABAgAGBQJS5o4cAAoJEGcL54qWCgDyZUkQAIPAuzsNPFr5hGa0kGPDroPg
LFs7+Tkpvjs9mYju+vywtbL1bSOtSAYFyZSFEiq1UBzGc5NtBeS+eqF8sjn2XG0y
jx3gkPAhkfU9ld4q0nDuLfLYi2bl/I3b08yBdamnlV3ni5f7xUjVdJtViBNLu11u
x8MfaItUi/KZ9NIC6JGANcLsiDlCn9U/mLE4zsjNP9cNhc20tWsnW767+kjVbtOA
lYc4vdk4m5+zaQhIfBDur0SNPZz6A6f9fIPMMWq3lk114pX+S1JGxGWQ+qown5f9
snOFrXak9lL02Q5Zb9eFCebZcTCc8qpps7mhthJi9nPnmU38ELAH1zH5YWvbXShm
808ipyP9YGIsa/3N6m+zNw2azVHamXSc+4D74pNNylCVmW7cNau6U2E/Cl5/YXM0
CGvN7eWN9/rbYpKVlR7K+7OSMXd5o2ZY1cf9i2fg2a/Dp+i15lr64bmQ3ff2QfLt
CE9a/Rp3fcuq9DR1rOiWkfxn0jyPj+3RmPStb26sC7TblG8sGYilJlbAIl2kJLXi
1HlJdWoudFpwgbFs1KbdpGT3lfTp0maVQ3wQmXRWsiMHNPEysIkosk+SgKPUKZgh
carSzT3Gfob2JzHYOsb+MjBRknauyYtoYT2yT0+JhTFwsz1t4PZr+gwH8zCzeUSb
ptN3tC/+xKRuDnzNrdT2
=soFt
-----END PGP SIGNATURE-----

--=-/698AripKlEcq/WOQQVF--

