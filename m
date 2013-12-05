Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f175.google.com ([209.85.223.175]:54043 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753122Ab3LERUd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Dec 2013 12:20:33 -0500
Received: by mail-ie0-f175.google.com with SMTP id x13so29051773ief.6
        for <linux-nfs@vger.kernel.org>; Thu, 05 Dec 2013 09:20:32 -0800 (PST)
Message-ID: <1386264029.2572.1.camel@leira.trondhjem.org>
Subject: [GIT PULL] Please pull NFS client bugfixes
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Torvalds Linus <torvalds@linux-foundation.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>
Date: Thu, 05 Dec 2013 12:20:29 -0500
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-pQ1NGriv4ugg90GsT3Ei"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-pQ1NGriv4ugg90GsT3Ei
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Linus,

The following changes since commit 8c2fabc6542d9d0f8b16bd1045c2eda59bdcde13=
:

  nfs: fix pnfs Kconfig defaults (2013-11-15 13:41:43 -0500)

are available in the git repository at:

  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-3.13-=
3

for you to fetch changes up to 3873d064b8538686bbbd4b858dc8a07db1f7f43a:

  nfs: fix do_div() warning by instead using sector_div() (2013-12-04 12:57=
:37 -0500)

----------------------------------------------------------------
NFS client bugfixes

- Stable fix for a NFSv4.1 delegation and state recovery deadlock
- Stable fix for a loop on irrecoverable errors when returning delegations
- Fix a 3-way deadlock between layoutreturn, open, and state recovery
- Update the MAINTAINERS file with contact information for Trond Myklebust
- Close needs to handle NFS4ERR_ADMIN_REVOKED
- Enabling v4.2 should not recompile nfsd and lockd
- Fix a couple of compile warnings

----------------------------------------------------------------
Andy Adamson (2):
      NFSv4 wait on recovery for async session errors
      SUNRPC: do not fail gss proc NULL calls with EACCES

Anna Schumaker (1):
      NFS: Enabling v4.2 should not recompile nfsd and lockd

Helge Deller (1):
      nfs: fix do_div() warning by instead using sector_div()

Trond Myklebust (5):
      NFS: Fix a warning in nfs_setsecurity
      NFSv4: Update list of irrecoverable errors on DELEGRETURN
      NFSv4: close needs to handle NFS4ERR_ADMIN_REVOKED
      NFSv4.1: Prevent a 3-way deadlock between layoutreturn, open and stat=
e recovery
      MAINTAINERS: Update contact information for Trond Myklebust

 MAINTAINERS                      |  4 ++--
 fs/nfs/blocklayout/blocklayout.h |  1 +
 fs/nfs/blocklayout/extents.c     |  2 +-
 fs/nfs/dns_resolve.c             |  2 ++
 fs/nfs/inode.c                   |  2 +-
 fs/nfs/internal.h                | 15 +++++++++++++++
 fs/nfs/nfs4_fs.h                 |  8 ++++++++
 fs/nfs/nfs4proc.c                | 30 +++++++++++++++++++++++-------
 include/linux/nfs4.h             | 10 ----------
 include/linux/nfs_fs.h           | 18 ------------------
 net/sunrpc/auth_gss/auth_gss.c   |  2 +-
 11 files changed, 54 insertions(+), 40 deletions(-)


--=-pQ1NGriv4ugg90GsT3Ei
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABAgAGBQJSoLXdAAoJEGcL54qWCgDyytgQAIM7qNrEQcqnvQzbQk+v+ouc
9D9+HSWoeyS5mWgupuYkyQNgGHzaKWkivFwQqYFcEdsUnNaDUfclmXYwhfhNPYrs
TdZpNlMCCESkxF28Tx6Ks99De7sMoIo8Rgm30fTGmGrjNJECfzB8yro3GlyianDm
Z+bqAKCgB6qqPtypKzOKwu+6EQvjVEHzFgCYcmE9e0s0JUaNh5hqSRzfSb3b7Iom
JgjhzeF/59EHT27EOWxPoD4Bck4qOFZNc61aY+P1TVS95lgt7rAkmEIfoHqq++dx
dKI5qhGq5MPGlieGIFWq3vGZARpgyDarChcYeX8IisP48GT4+MarTgEDxoIuD6xg
UGgZ96czMV0f/NZa8UUkCVsqXDx43pg3wMs4a7Q589sP21IQ2MQFAIcHrGJoxV5i
OvsaKFUgxvdP7jhIz3cEOV67H+YKGby7bkgnEgJgP4Lg4ZNqZpvVIS6Lejf0Dd7m
//DTxFmuPC2Wj4DNipSAEAHJJbPna3pETmFNG1Zob4bByr12kcQs2Y2yWaBnfj2y
b5hZIFOie9M1ZtcOQOiX2xDYm6ZVkEJyYIxJFXu3GuOkIlbiGhNN8QhmpCHORQ7k
RO1TxhMKePkyNBlv3X4o5ytYfA7SijQv7pUGEnjR4zllb9Jo3OKUv5n2LkR43Nai
vZJDgCVxETQ9Lxvh6eUp
=sB4E
-----END PGP SIGNATURE-----

--=-pQ1NGriv4ugg90GsT3Ei--

