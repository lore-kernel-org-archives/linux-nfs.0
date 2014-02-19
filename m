Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f182.google.com ([209.85.223.182]:50244 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753844AbaBSOND (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Feb 2014 09:13:03 -0500
Received: by mail-ie0-f182.google.com with SMTP id tp5so252730ieb.13
        for <linux-nfs@vger.kernel.org>; Wed, 19 Feb 2014 06:13:02 -0800 (PST)
Message-ID: <1392819180.3670.1.camel@leira.trondhjem.org>
Subject: [GIT PULL] Please pull NFS client fixes
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Torvalds Linus <torvalds@linux-foundation.org>
Cc: Linux Kernel mailing list <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date: Wed, 19 Feb 2014 09:13:00 -0500
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-rLXzoHYJaWcvq/uLRK8g"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-rLXzoHYJaWcvq/uLRK8g
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Linus,

The following changes since commit b28a960c42fcd9cfc987441fa6d1c1a471f0f9ed=
:

  Linux 3.14-rc2 (2014-02-09 18:15:47 -0800)

are available in the git repository at:

  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-3.14-=
4

for you to fetch changes up to 2564f0dc58962a08abc960fca820e344f61981ed:

  NFS fix error return in nfs4_select_rw_stateid (2014-02-18 11:33:03 -0500=
)

----------------------------------------------------------------
NFS client bugfixes for Linux 3.14

Highlights include stable fixes for the following bugs:

- General performance regression due to NFS_INO_INVALID_LABEL being set
  when the server doesn't support labeled NFS
- Hang in the RPC code due to a socket out-of-buffer race
- Infinite loop when trying to establish the NFSv4 lease
- Use-after-free bug in the RPCSEC gss code.
- nfs4_select_rw_stateid is returning with a non-zero error value on succes=
s

Other bug fixes:

- Potential memory scribble in the RPC bi-directional RPC code
- Pipe version reference leak
- Use the correct net namespace in the new NFSv4 migration code

----------------------------------------------------------------
Andy Adamson (1):
      NFS fix error return in nfs4_select_rw_stateid

Trond Myklebust (7):
      NFS: Do not set NFS_INO_INVALID_LABEL unless server supports labeled =
NFS
      SUNRPC: Don't create a gss auth cache unless rpc.gssd is running
      SUNRPC: Fix races in xs_nospace()
      SUNRPC: Fix potential memory scribble in xprt_free_bc_request()
      SUNRPC: Ensure that gss_auth isn't freed before its upcall messages
      SUNRPC: Fix a pipe_version reference leak
      NFSv4: Use the correct net namespace in nfs4_update_server

 fs/nfs/inode.c                 | 14 ++++++++++----
 fs/nfs/internal.h              | 12 +++++++++++-
 fs/nfs/nfs4client.c            |  7 ++++---
 fs/nfs/nfs4namespace.c         | 12 ++++++------
 fs/nfs/nfs4state.c             |  1 +
 net/sunrpc/auth_gss/auth_gss.c | 19 ++++++++++++++++---
 net/sunrpc/backchannel_rqst.c  |  6 ++++--
 net/sunrpc/xprtsock.c          |  6 +++++-
 8 files changed, 57 insertions(+), 20 deletions(-)

--=20
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


--=-rLXzoHYJaWcvq/uLRK8g
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABAgAGBQJTBLvsAAoJEGcL54qWCgDysTgQAIc5HbZ/FH9FpYJ05VvrCRSi
6gBqxPmJbYRCOOACSO0GkGAZ0LMPMxGJAie/2cRx1ykgs61fu747aXUuJozWnXd+
OJ1tZ6qYQ0PttI5clJdJfeKNAMh0jnLesvjo+RrMgCsYGzHQAU+yAaqCuXQ5QpA7
Ot0BWyVIkgkRykU5f+NSK4Gewyv+kvr/eildhCAogPgpKoHKv2XxU0LFV2C0in50
2cLKwjeCV2lpHf9yG51bMIQTqNhYS09KiUkDyxFc9ekYAeSx3oRB/tekgxfo2R3G
aS4o1zLcszOWSqIT5NswKX2DXiS27S2n4auGETwHKuV42Pd1w7UimrK/3Z00qf76
I8LYjwDuB9a+Ke90faFbNV9r3jOwPFWP1HlfkVEYfkJM7565O7lBQi0ppbJbXloq
9TGW8u6RwFoTVjUiwtgKR/tRiHY5WoTQCiJFCshfeAfQKzWyYaPtDfdQb5/v1sAW
IeZ+wM1rLQsxhQD1/LPByvYdVVLjCXanBtS7WOQWN9X6cPE28O6FPxYN6zp9MWUM
KXylRr+sCmcOypcalxwC4CqaNRbEj4Br1VDEqLgAY8YuDshRISv8aQ48qKR79n7v
KuU8sKMTVE9AV2kimN5kZR3GckrDiAm3RIR1Kt6MKd6EDSs3i15Ab67JVBcIaJuD
+lI61Pb1TAI3KBfGDWsx
=eME4
-----END PGP SIGNATURE-----

--=-rLXzoHYJaWcvq/uLRK8g--

