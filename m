Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f177.google.com ([209.85.213.177]:42467 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752039AbaLHDJG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Dec 2014 22:09:06 -0500
Received: by mail-ig0-f177.google.com with SMTP id z20so2105110igj.16
        for <linux-nfs@vger.kernel.org>; Sun, 07 Dec 2014 19:09:05 -0800 (PST)
Message-ID: <1418008142.3957.1.camel@primarydata.com>
Subject: [GIT PULL] Please pull NFS client changes
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>
Date: Sun, 07 Dec 2014 22:09:02 -0500
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-Rq/iQrWI7T7hnrRuX7Af"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-Rq/iQrWI7T7hnrRuX7Af
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Linus,

The following changes since commit 5d01410fe4d92081f349b013a2e7a95429e4f2c9=
:

  Linux 3.18-rc6 (2014-11-23 15:25:20 -0800)

are available in the git repository at:

  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-3.19-=
1

for you to fetch changes up to 388f0c776781fe64ce951701bfe712b2182a31f2:

  sunrpc: add a debugfs rpc_xprt directory with an info file in it (2014-11=
-27 13:14:52 -0500)

----------------------------------------------------------------
NFS client updates for Linux 3.19

Highlights include:

Features:
- NFSv4.2 client support for hole punching and preallocation.
- Further RPC/RDMA client improvements.
- Add more RPC transport debugging tracepoints.
- Add RPC debugging tools in debugfs.

Bugfixes:
- Stable fix for layoutget error handling
- Fix a change in COMMIT behaviour resulting from the recent io code update=
s

----------------------------------------------------------------
Anna Schumaker (3):
      NFS: Use nfs_server_capable() for checknig NFS_CAP_SEEK
      nfs: Add ALLOCATE support
      nfs: Add DEALLOCATE support

Christoph Hellwig (1):
      pnfs/blocklayout: fix end calculation in pnfs_num_cont_bytes

Chuck Lever (10):
      xprtrdma: Return an errno from rpcrdma_register_external()
      xprtrdma: Cap req_cqinit
      xprtrdma: unmap all FMRs during transport disconnect
      xprtrdma: Refactor tasklet scheduling
      xprtrdma: Re-write rpcrdma_flush_cqs()
      xprtrdma: Enable pad optimization
      xprtrdma: Display async errors
      SUNRPC: serialize iostats updates
      NFS: SETCLIENTID XDR buffer sizes are incorrect
      NFS: Clean up nfs4_init_callback()

Jan Kara (1):
      nfs: Remove dead case from nfs4_map_errors()

Jeff Layton (8):
      sunrpc: add some tracepoints in svc_rqst handling functions
      sunrpc: add new tracepoints in xprt handling code
      sunrpc: add tracepoints in xs_tcp_data_recv
      lockd: eliminate LOCKD_DEBUG
      sunrpc: eliminate RPC_DEBUG
      sunrpc: eliminate RPC_TRACEPOINTS
      sunrpc: add debugfs file for displaying client rpc_task queue
      sunrpc: add a debugfs rpc_xprt directory with an info file in it

Li RongQing (2):
      nfs: replace nfs_add_stats with nfs_inc_stats when add one
      nfs: define nfs_inc_fscache_stats and using it as possible

Markus Elfring (1):
      NFS: Deletion of unnecessary checks before the function call "nfs_put=
_client"

Peng Tao (1):
      nfs41: fix nfs4_proc_layoutget error handling

Trond Myklebust (2):
      Merge tag 'nfs-cel-for-3.19' of git://git.linux-nfs.org/projects/anna=
/nfs-rdma into linux-next
      Merge tag 'nfs-rdma-for-3.19' of git://git.linux-nfs.org/projects/ann=
a/nfs-rdma into linux-next

Weston Andros Adamson (1):
      NFS: fix subtle change in COMMIT behavior

 fs/lockd/svclock.c                      |   2 +-
 fs/nfs/blocklayout/blocklayout.c        |   2 +-
 fs/nfs/callback_proc.c                  |   2 +-
 fs/nfs/filelayout/filelayoutdev.c       |   3 +-
 fs/nfs/fscache.c                        |  24 +--
 fs/nfs/inode.c                          |   9 +-
 fs/nfs/iostat.h                         |   5 +
 fs/nfs/nfs42.h                          |   2 +
 fs/nfs/nfs42proc.c                      |  77 ++++++++-
 fs/nfs/nfs42xdr.c                       | 139 +++++++++++++++
 fs/nfs/nfs4_fs.h                        |   1 +
 fs/nfs/nfs4client.c                     |  46 +++--
 fs/nfs/nfs4file.c                       |  31 ++++
 fs/nfs/nfs4proc.c                       |  12 +-
 fs/nfs/nfs4xdr.c                        |  12 +-
 fs/nfs/pagelist.c                       |  11 +-
 fs/nfs/read.c                           |   2 +-
 fs/nfs/write.c                          |  19 ++-
 include/linux/lockd/debug.h             |   6 +-
 include/linux/nfs4.h                    |   2 +
 include/linux/nfs_fs.h                  |   4 +-
 include/linux/nfs_fs_sb.h               |   2 +
 include/linux/nfs_xdr.h                 |  14 ++
 include/linux/sunrpc/auth.h             |   2 +-
 include/linux/sunrpc/clnt.h             |   4 +
 include/linux/sunrpc/debug.h            |  64 +++++--
 include/linux/sunrpc/metrics.h          |   3 +
 include/linux/sunrpc/sched.h            |   8 +-
 include/linux/sunrpc/xprt.h             |   3 +
 include/linux/sunrpc/xprtsock.h         |  59 +++++++
 include/trace/events/sunrpc.h           | 160 +++++++++++++++++
 include/uapi/linux/nfsd/debug.h         |   2 +-
 net/sunrpc/Kconfig                      |   1 +
 net/sunrpc/Makefile                     |   1 +
 net/sunrpc/auth.c                       |   4 +-
 net/sunrpc/auth_generic.c               |   2 +-
 net/sunrpc/auth_gss/auth_gss.c          |   2 +-
 net/sunrpc/auth_gss/gss_generic_token.c |   2 +-
 net/sunrpc/auth_gss/gss_krb5_crypto.c   |   2 +-
 net/sunrpc/auth_gss/gss_krb5_keys.c     |   2 +-
 net/sunrpc/auth_gss/gss_krb5_mech.c     |   2 +-
 net/sunrpc/auth_gss/gss_krb5_seal.c     |   2 +-
 net/sunrpc/auth_gss/gss_krb5_seqnum.c   |   2 +-
 net/sunrpc/auth_gss/gss_krb5_unseal.c   |   2 +-
 net/sunrpc/auth_gss/gss_krb5_wrap.c     |   2 +-
 net/sunrpc/auth_gss/gss_mech_switch.c   |   2 +-
 net/sunrpc/auth_gss/gss_rpc_xdr.h       |   2 +-
 net/sunrpc/auth_gss/svcauth_gss.c       |   2 +-
 net/sunrpc/auth_null.c                  |   4 +-
 net/sunrpc/auth_unix.c                  |   2 +-
 net/sunrpc/backchannel_rqst.c           |   2 +-
 net/sunrpc/clnt.c                       |  16 +-
 net/sunrpc/debugfs.c                    | 292 ++++++++++++++++++++++++++++=
++++
 net/sunrpc/rpcb_clnt.c                  |   2 +-
 net/sunrpc/sched.c                      |   4 +-
 net/sunrpc/stats.c                      |  21 ++-
 net/sunrpc/sunrpc_syms.c                |  12 +-
 net/sunrpc/svc.c                        |  23 +--
 net/sunrpc/svc_xprt.c                   |  31 ++--
 net/sunrpc/sysctl.c                     |   2 +-
 net/sunrpc/xprt.c                       |  19 ++-
 net/sunrpc/xprtrdma/rpc_rdma.c          |   4 +-
 net/sunrpc/xprtrdma/transport.c         |  12 +-
 net/sunrpc/xprtrdma/verbs.c             | 122 ++++++++++---
 net/sunrpc/xprtrdma/xprt_rdma.h         |   6 +
 net/sunrpc/xprtsock.c                   |  77 ++-------
 66 files changed, 1171 insertions(+), 244 deletions(-)
 create mode 100644 net/sunrpc/debugfs.c

--=20
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com




--=-Rq/iQrWI7T7hnrRuX7Af
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABAgAGBQJUhRZOAAoJEGcL54qWCgDymKwQAJkZoYDVmGAPByVMmf75E/54
0L5dKChvtDntksKjo084MrQTuqNOsfp3lHW9qmae4nGqAlelh1aQ8V6D0TmQoebQ
qCj+a6qTJZDVI0UuAKcxY+M/yMwNjVQWKET8auXhA+rZZom4VzxexBLL3mwyN40e
IpEUirvGI04iTX0U5Ep+WOfgeBJv7RkXrmr8drdqLrn7FlsWvzrk2W8D2xDOx1JT
8EqfzLfpyracYGb3MRsxPgcSf9yiwBMg//fVUvm1yQ8z6bustw1YQaoFomQPhnKy
ljB9tZf0OHFwCmVOGWE6wfvdwnW+FuCd+I2P2d5Kddu/Bhk/c0Hi+mvFEU045S+e
XJvt79xeVUjBpKvjmqVShTh9Vqn3U3DHiI4JBlcbxwYXv84fs8PzsncY+cPxDDTp
j/Zkya+r6zaGQp8C3wcOusUd6gg+zfm/+pCSh/7/DjqRyYgN4AfeQr/jlBxegj4G
aealsssGQC5H6BwcCvDkB+iBrj/ULNWsVd8TV0d/oFGmFovecBJBCoacY/pZbF1F
X0YNvphQCBvfJp6UozP0lf02sZwvMBazcsx1oRwpR/T6RD3wbsCJZmYPO3t5aJ9B
w9hE9yvDgIFXeAK0QLBrCyP4RqSl9sPFnpaZypF6tz+LKeNA9VbYKLpfR2mOibwC
T3sv8MViCo6vmMQuO3M1
=lW1h
-----END PGP SIGNATURE-----

--=-Rq/iQrWI7T7hnrRuX7Af--

