Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:13152 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755098Ab3FAAuz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 31 May 2013 20:50:55 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
CC: Mailing List Linux NFS <linux-nfs@vger.kernel.org>,
        Linux linux-kernel <linux-kernel@vger.kernel.org>
Subject: [GIT PULL] Please pull 2 NFS client bugfixes
Date: Sat, 1 Jun 2013 00:50:53 +0000
Message-ID: <1370047853.21304.3.camel@leira.trondhjem.org>
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="=-KHKRvsopKdTsupmT/0x+"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-KHKRvsopKdTsupmT/0x+
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable

Hi Linus,

The following changes since commit 83c168bf8017212a9d502536f9dcd0b54d24e330=
:

  NFS: Fix SETCLIENTID fallback if GSS is not available (2013-05-23 18:50:4=
0 -0400)

are available in the git repository at:

  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-3.10-=
4

for you to fetch changes up to eb54d43707c69340581940e1fcaecb4d7d17b814:

  NFS: Fix security flavor negotiation with legacy binary mounts (2013-05-3=
0 16:31:34 -0400)

----------------------------------------------------------------
NFS client fixes:

- Fix a regression that broke NFS mounting using klibc and busybox
- Stable fix to check access modes correctly on NFSv4 delegated open()

----------------------------------------------------------------
Chuck Lever (1):
      NFS: Fix security flavor negotiation with legacy binary mounts

Trond Myklebust (1):
      NFSv4: Fix a thinko in nfs4_try_open_cached

 fs/nfs/nfs4proc.c | 2 +-
 fs/nfs/super.c    | 2 ++
 2 files changed, 3 insertions(+), 1 deletion(-)


--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

--=-KHKRvsopKdTsupmT/0x+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABAgAGBQJRqUVtAAoJEGcL54qWCgDy9FIP/0WVGX2idVpyh8Pe5YdocAii
pByiMsVSSDVLgIiRdugkNdHUTZ+gsvRr9lcM3lD5+A4W7RUlM3zuXoyUyXtUdfJW
sMTz9pXTCHY0TDQw412USAUKfr4K3dT2gbMkb63Ca3TnsLolI67TXS1FmEqVTPn5
XWDGuxdQveF3wDXGhRhXFiIbQaXQYY4qpn1XlwcdUuVYpvqiZObG/iFrbsRg+pFx
uGxcYEYiNby6pcfgrU/NYsMQOQ/t7LzxEDBhO8+JWzQM1H8/4tVtOjptwxYOLgKX
sFJ2h7xyJx0sb1du7i8zh9x39v6VfPyBHI4qoDRl6bPOQSIOk1o3+PX3NEHNx9y4
LfqLiO9VdkGR1TndRuLiU5gXGwqllGbjiOuo95/hwMoGTNHK3hSd/ZWFbbGH0Fb1
oxUynI3HOFwza5scSOv9q91bLgj60XcDlXzcgU/S41yplN4MEFcyBBQIomaDzfZZ
tgMGHhosGrLD1DWXtx2oUqh6AlhADTDvPMwQIuZ08UlnbF6ll+zprnjt40S7W1yD
IG78jDbGhvuBEKEgUicfAabJcKq6N2LmSDRl0RG4+jH5oXyvl2NLldmNQrMUSrrd
DlU3VSYCuy57s+RU8MBFe1JXsjEsZ8UWf1Flv7oCPktUE575r8gYWa4ycpxTJd82
ye1ysDHMtdgySWVmyxeY
=lQIH
-----END PGP SIGNATURE-----

--=-KHKRvsopKdTsupmT/0x+--
