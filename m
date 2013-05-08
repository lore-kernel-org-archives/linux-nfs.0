Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:26528 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752986Ab3EHXXJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 May 2013 19:23:09 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
CC: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Linux linux-kernel <linux-kernel@vger.kernel.org>
Subject: [GIT Pull] Please pull more NFS client bug fixes
Date: Wed, 8 May 2013 23:23:07 +0000
Message-ID: <1368055385.3282.25.camel@leira.trondhjem.org>
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="=-sYvO21jkWTjQruE2rVGt"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-sYvO21jkWTjQruE2rVGt
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable

The following changes since commit 721ccfb79b6f74f4052de70236d24047e73682d4=
:

  NFSv4: Warn once about servers that incorrectly apply open mode to setatt=
r (2013-04-29 11:11:58 -0400)

are available in the git repository at:

  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-3.10-=
2

for you to fetch changes up to c23266d532b4de796a346f57a66587c5db17d27e:

  NFS4.1 Fix data server connection race (2013-05-08 17:19:32 -0400)

----------------------------------------------------------------
More NFS client bugfixes for 3.10

- Ensure that we match the 'sec=3D' mount flavour against the server list
- Fix the NFSv4 byte range locking in the presence of delegations
- Ensure that we conform to the NFSv4.1 spec w.r.t. freeing lock stateids
- Fix a pNFS data server connection race

----------------------------------------------------------------
Andy Adamson (1):
      NFS4.1 Fix data server connection race

Trond Myklebust (4):
      NFSv4.x: Fix handling of partially delegated locks
      SUNRPC: Don't spam syslog with "Pseudoflavor not found" messages
      NFSv4: Convert nfs41_free_stateid to use an asynchronous RPC call
      NFSv4.1: Ensure that we free the lock stateid on the server

Weston Andros Adamson (1):
      NFSv3: match sec=3D flavor against server list

 fs/nfs/nfs4_fs.h               |   3 +-
 fs/nfs/nfs4filelayout.h        |   2 +
 fs/nfs/nfs4filelayoutdev.c     |  26 ++++++++-
 fs/nfs/nfs4proc.c              | 119 +++++++++++++++++++++++++++++++------=
----
 fs/nfs/nfs4state.c             |  11 ++--
 fs/nfs/nfs4xdr.c               |   2 +-
 fs/nfs/super.c                 |  48 ++++++++++++++---
 include/linux/nfs_xdr.h        |   2 +-
 net/sunrpc/auth_gss/auth_gss.c |   3 +-
 net/sunrpc/clnt.c              |   2 +-
 10 files changed, 172 insertions(+), 46 deletions(-)

--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

--=-sYvO21jkWTjQruE2rVGt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABAgAGBQJRit5ZAAoJEGcL54qWCgDyXccP/1/tl4G611j6yR7tGypCIkmR
viZUQEe9kLVJiNRu/GbO/jlqHxa14SWpx0R07A48EXE41VmPsG4Pu27pRGf9o8vx
3k7kxo9YihA1Kyhsrdyuifdhu5xu6NGsLXseUC1o72t5uQyrvVac3rEVsTqTlXvq
E1/AImpQAxpbT/j2nThJCN5MfTKvUe+U0QXmHdOA7iBna+avFzrRs4ynJAEycNhl
S+g4JfYQnH/YtffqsSNAQGC8OoeG4Wr1QBOBcQ6h9Sv6NalF5o81UfpuVqv67fCR
4LeYooCEji3PlAyK42JZKBXZB/5VSh/iuf2lEIPxvbPfzWHtIxcIBgCRHh3ZNGh3
82LdSFJDWGDg2kidph/i5VlX+BSb+tWSjYEk9iL8B7N7jR9BgYFZ6UW1BZQr6eJF
nLvnTHsCR31934DhjFME69nKT0590o97IKD5iLPGjDR+vcu7cAex2DreIOPP+MWx
gdpJaFnuvMWX83ybfLdQz5UiN0PvA2DkCQ+NaNGtvDgCfXtnXrjGh6sGYcNUdvQc
DN9d0rspTCJdyVs+/A7RxYwYp+8CEumctizeT21EAt0fTNZq6ONYmznAOzbpyfaa
lMrP8b5geV9Ilv8OaoRxMR0z5rAyp7Dg/JtXms7+ydXLLaLMrbaHOD29eqmQG5PR
ovG2seXMAmW5sX+CI6TN
=H4sS
-----END PGP SIGNATURE-----

--=-sYvO21jkWTjQruE2rVGt--
