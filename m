Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:15829 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752151Ab2FNQAs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Jun 2012 12:00:48 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: [GIT PULL] Please pull bugfixes for the NFS client
Date: Thu, 14 Jun 2012 16:00:25 +0000
Message-ID: <1339689623.2886.28.camel@lade.trondhjem.org>
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="=-0FWvh9xZ7zNRcNUBdnLJ"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-0FWvh9xZ7zNRcNUBdnLJ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

The following changes since commit 2d117403b30cd7301af60d7d54b279a9f566d10d=
:

  Merge tag 'please-pull-mce' of git://git.kernel.org/pub/scm/linux/kernel/=
git/ras/ras (2012-05-31 10:53:37 -0700)

are available in the git repository at:


  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git bugfixes

for you to fetch changes up to e216c8c771c9a77f14d7e8b4131846b038f6c145:

  NFS: add an endian notation for sparse (2012-06-12 09:54:40 -0400)

----------------------------------------------------------------
NFS client bugfixes for Linux 3.5

Highlights include:

 - Fix a couple of mount regressions due to the recent cleanups.
 - Fix an Oops in the open recovery code
 - Fix an rpc_pipefs upcall hang that results from some of the
   net namespace work from 3.4.x (stable kernel candidate).
 - Fix a couple of write and o_direct regressions that were found
   at last weeks Bakeathon testing event in Ann Arbor.

----------------------------------------------------------------
Andy Adamson (1):
      NFSv4 do not send an empty SETATTR compound

Bryan Schumaker (2):
      NFS4: Set parsed mount data version to 4
      NFS: Use the NFS_DEFAULT_VERSION for v2 and v3 mounts

Dan Carpenter (2):
      NFSv4.1: integer overflow in decode_cb_sequence_args()
      NFS: add an endian notation for sparse

Fred Isaman (2):
      NFS4: Fix open bug when pnfs module blacklisted
      NFS: fix directio refcount bug on commit

Jeff Layton (1):
      rpc_pipefs: allow rpc_purge_list to take a NULL waitq pointer

Sachin Prabhu (1):
      NFSv2: EOF incorrectly set on short read

Steve Dickson (1):
      NFS: Map minor mismatch error to protocol not support error.

Trond Myklebust (9):
      NFSv4.1: Fix a request leak on the back channel
      NFSv4: Fix an Oops in the open recovery code
      NFSv4: Fix up decode_attr_mdsthreshold
      NFSv4.1: Convert a trivial printk into a dprintk
      NFSv4.1: Ensure we clear session state flags after a session creation
      NFS: Fix a commit bug
      NFS: Remove incorrect BUG_ON in nfs_found_client
      NFSv4.1: Convert another trivial printk into a dprintk
      NFSv4: Fix unnecessary delegation returns in nfs4_do_open

 fs/nfs/callback_xdr.c   |    8 ++++----
 fs/nfs/client.c         |    2 --
 fs/nfs/direct.c         |    8 ++++----
 fs/nfs/nfs4_fs.h        |    2 +-
 fs/nfs/nfs4proc.c       |   42 ++++++++++++++++++++++++++++++++++--------
 fs/nfs/nfs4state.c      |   22 ++++++++++++----------
 fs/nfs/nfs4xdr.c        |   15 ++++++++++-----
 fs/nfs/pnfs.h           |    2 +-
 fs/nfs/proc.c           |    2 +-
 fs/nfs/super.c          |    3 +++
 fs/nfs/write.c          |    7 ++++---
 include/linux/nfs_xdr.h |    3 +++
 net/sunrpc/rpc_pipe.c   |   12 ++++++------
 net/sunrpc/svc.c        |    3 ++-
 14 files changed, 85 insertions(+), 46 deletions(-)

--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com


--=-0FWvh9xZ7zNRcNUBdnLJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABAgAGBQJP2gqXAAoJEGcL54qWCgDy3jgP/1jarXxhzb+O/97wEMrkyYCY
BGblQ1FJNmFay5JqJOzY/qve8XADtJf9BHovELWT7UNsMXWC3vXiKuB5nLpC9pdJ
H3PiCNgv1bqrr70TGCCr7WNUCL7GRkW+YM5UhVKdgykJHByKBWvq/weg4s8iu/Dv
Kpi05RpXxwycHYKLUUd6wKeVoIs3tEteNb14iE2jN8RhsTKSyQt3J/Ilaccy9BaG
F8N1U6tMXcl89f59e6JxEZ4I/OT3BzhIn8X+M7AD7bwlNg91cxkUwI+f22343hRd
w0idt0Wd4wBZhSmEAndjzlYU3GQypVWVEuxxKbDg4SAYcBmV6ZJYvrJHtSWKuSBq
DcPllOuj1FVt9V7ap2B8S1Ns6v+vCiwHmZtP31RQhBeJqTzSGj14CEB07GmZMokD
Wb15XJDNwnAhEo3UXSIK3BMsHQLgKpZKJcfJtAuWXeKMiECmSFf+DIqOwkmok+yB
Gf9x4TOaHUBoMsyWRiuPO3KjbFPcnSs8YCSsFYPv5tkAluNpmk1ryvuL/O59qXxY
JyBbWj3FCjSJXQh3tuOAP9MmivI9R0FJgiW3LtQwtOvHg5e79UZ7ugddYzvzNGIW
XEWjftSG7fXh6KRJDU6mZdEG2+Jo12/0Oqmnc0LRIAvhEQIovWtBX7Z9a5NQcRAa
wYpwI2zAaETawl/nk1x+
=4QdL
-----END PGP SIGNATURE-----

--=-0FWvh9xZ7zNRcNUBdnLJ--
