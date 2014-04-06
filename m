Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f171.google.com ([209.85.223.171]:54717 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754079AbaDFQ0W (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 6 Apr 2014 12:26:22 -0400
Received: by mail-ie0-f171.google.com with SMTP id ar20so5306037iec.16
        for <linux-nfs@vger.kernel.org>; Sun, 06 Apr 2014 09:26:21 -0700 (PDT)
Message-ID: <1396801576.5625.3.camel@leira.trondhjem.org>
Subject: [GIT PULL] Please pull NFS client changes for 3.15
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Torvalds Linus <torvalds@linux-foundation.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>
Date: Sun, 06 Apr 2014 12:26:16 -0400
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-XM5AY5wIrOZrXhWCmBBs"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-XM5AY5wIrOZrXhWCmBBs
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Linus,

The following changes since commit 2ca310fc4160ed0420da65534a21ae77b24326a8=
:

  SUNRPC: Fix oops when trace sunrpc_task events in nfs client (2014-03-07 =
19:10:08 -0500)

are available in the git repository at:

  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-3.15-=
1

for you to fetch changes up to 9581a4ae75517099bc87e1c43d1a8f35b55741b9:

  nfs: pass string length to pr_notice message about readdir loops (2014-04=
-05 09:25:42 -0400)

----------------------------------------------------------------
NFS client updates for Linux 3.15

Highlights include:

- Stable fix for a use after free issue in the NFSv4.1 open code
- Fix the SUNRPC bi-directional RPC code to account for TCP segmentation
- Optimise usage of readdirplus when confronted with 'ls -l' situations
- Soft mount bugfixes
- NFS over RDMA bugfixes
- NFSv4 close locking fixes
- Various NFSv4.x client state management optimisations
- Rename/unlink code cleanups

----------------------------------------------------------------
Chuck Lever (4):
      NFS: Clean up: revert increase in READDIR RPC buffer max size
      SUNRPC: Fix large reads on NFS/RDMA
      SUNRPC: remove KERN_INFO from dprintk() call sites
      NFS: advertise only supported callback netids

Jeff Layton (6):
      nfs: abstract out code needed to complete a sillyrename
      nfs: make nfs_async_rename non-static
      nfs: convert nfs_rename to use async_rename infrastructure
      nfs: remove synchronous rename code
      nfs: emit a fsnotify_nameremove call in sillyrename codepath
      nfs: pass string length to pr_notice message about readdir loops

Steve Dickson (1):
      SUNRPC: Ensure call_connect_status() deals correctly with SOFTCONN ta=
sks

Trond Myklebust (18):
      SUNRPC: RPC callbacks may be split across several TCP segments
      NFS: Be more aggressive in using readdirplus for 'ls -l' situations
      NFSv4.1: Fix wraparound issues in pnfs_seqid_is_newer()
      NFSv4: Don't update the open stateid unless it is newer than the old =
one
      NFSv4.1: Ensure that the layout recall callback matches layout statei=
ds
      NFSv4.1: Minor optimisation in get_layout_by_fh_locked()
      NFSv4.1: Ensure that we free existing layout segments if we get a new=
 layout
      NFSv4: Use correct locking when updating nfs4_state in nfs4_close_don=
e
      NFSv4: Clear the open state flags if the new stateid does not match
      SUNRPC: Ensure that call_connect times out correctly
      SUNRPC: Ensure that call_bind times out correctly
      Merge branch 'devel' into linux-next
      NFSv4: Schedule recovery if nfs40_walk_client_list() is interrupted
      NFSv4: Ensure we respect soft mount timeouts during trunking discover=
y
      SUNRPC: Ensure call_status() deals correctly with SOFTCONN tasks
      SUNRPC: Don't let rpc_delay() clobber non-timeout errors
      SUNRPC: rpc_restart_call/rpc_restart_call_prepare should clear task->=
tk_status
      NFSv4: Fix a use-after-free problem in open()

 fs/nfs/callback_proc.c          |  19 ++--
 fs/nfs/dir.c                    |  62 +++++++++++--
 fs/nfs/inode.c                  |  34 +++++--
 fs/nfs/internal.h               |   8 ++
 fs/nfs/nfs3proc.c               |  36 --------
 fs/nfs/nfs4_fs.h                |  11 +++
 fs/nfs/nfs4client.c             |   7 ++
 fs/nfs/nfs4proc.c               | 197 +++++++++++++++++++++---------------=
----
 fs/nfs/nfs4state.c              |   6 +-
 fs/nfs/nfs4xdr.c                |   3 +-
 fs/nfs/pnfs.c                   |  17 +++-
 fs/nfs/proc.c                   |  25 -----
 fs/nfs/unlink.c                 |  35 ++++++-
 include/linux/nfs_fs.h          |   2 +-
 include/linux/nfs_xdr.h         |   3 +-
 include/linux/sunrpc/bc_xprt.h  |   3 +-
 net/sunrpc/backchannel_rqst.c   |  93 +++++++++++++------
 net/sunrpc/clnt.c               |  23 +++--
 net/sunrpc/sched.c              |   3 +-
 net/sunrpc/xprtrdma/rpc_rdma.c  |   4 +-
 net/sunrpc/xprtrdma/transport.c |  10 +-
 net/sunrpc/xprtsock.c           |  28 ++----
 22 files changed, 368 insertions(+), 261 deletions(-)

--=20
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


--=-XM5AY5wIrOZrXhWCmBBs
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABAgAGBQJTQYAuAAoJEGcL54qWCgDyorEQAKMURkuxM09OXoBORJCiIG7Q
QAQAaKn6qpUhVXfwYHKB8MqEUcyBYtpEHSdAL5F4XIYFB9kdO5YQGDxD+QhdcRve
7extJNdkefpKWM9tMwNwOBOQNXzr4yJvgzo6i05zPTP7PQxWkM+4Vb7JiXWcSbMC
Fj3mWhsu+4EGVNWsrdJOmpr7uHRiOafVAoYiq7BfAPg+5iDmd2enC6UThsewc4De
g62zTrcQqVLdwWjH28NJoFHiT5+q6JlYrO9iz2wRi3mW9paMtKA2VWmtJU+sH95u
UHaig1rlZMQlWiIw2IcpvN2OoBYxLrNxQp+18T/Jg9Kaa86YGJ0TXaVDarY3Kh+7
+mczHr0uke1xxr22rQ0qe5RbffqXGMKZeIC9J9AkvZDP0Whxg/k465bfi1DH/G/3
JHgBSLYZ4outkzLQi2NbFOjKWOO16a8lKNI0HPK07Mn2XHUGzPSx428bFl9qeMIq
YjuRdIbo3q+FeU6wK6K2zAAruSMLCGRkKNw/TwDOq76JPXEncuoNLOVJxVfVaP7P
PUNXybMfMudOwFOt1cFH5dxqwKWy7k6/ZyjxyHfZnC4Eiv2f3CCL8Chlu2Ro3gM3
+Pmvw+qyXUeH5WORdg1CjLJcdvIsHI6xiPs3iNUeCS5hQuTlZill7B5edUvQ+s3c
PtqjJNQ20EtGC1vckXky
=iI2a
-----END PGP SIGNATURE-----

--=-XM5AY5wIrOZrXhWCmBBs--

