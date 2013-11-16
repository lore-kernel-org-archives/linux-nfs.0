Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:6439 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752622Ab3KPVKB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 16 Nov 2013 16:10:01 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
CC: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
Subject: [GIT PULL] Please pull NFS client bugfixes
Date: Sat, 16 Nov 2013 21:09:57 +0000
Message-ID: <1384636196.5080.1.camel@leira.trondhjem.org>
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="=-HViyGKp+Wz80BcrajNY/"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-HViyGKp+Wz80BcrajNY/
Content-Type: text/plain; charset="UTF-7"
Content-Transfer-Encoding: quoted-printable

Hi Linus

The following changes since commit fab99ebe39fe7d11fbd9b5fb84f07432af9ba36f=
:

  NFSv4.2: Remove redundant checks in nfs+AF8-setsecurity+-nfs4+AF8-label+A=
F8-init+AF8-security (2013-11-04 16:42:52 -0500)

are available in the git repository at:

  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-3.13-=
2

for you to fetch changes up to 8c2fabc6542d9d0f8b16bd1045c2eda59bdcde13:

  nfs: fix pnfs Kconfig defaults (2013-11-15 13:41:43 -0500)

----------------------------------------------------------------
NFS client bugfixes:

- Stable fix for data corruption when retransmitting O+AF8-DIRECT writes
- Stable fix for a deep recursion/stack overflow bug in rpc+AF8-release+AF8=
-client
- Stable fix for infinite looping when mounting a NFSv4.x volume
- Fix a typo in the nfs mount option parser
- Allow pNFS layouts to be compiled into the kernel when NFSv4.1 is

----------------------------------------------------------------
Christoph Hellwig (1):
      nfs: fix pnfs Kconfig defaults

Jeff Layton (1):
      nfs: don't retry detect+AF8-trunking with RPC+AF8-AUTH+AF8-UNIX more =
than once

NeilBrown (1):
      NFS: correctly report misuse of +ACI-migration+ACI mount option.

Trond Myklebust (2):
      SUNRPC: Fix a data corruption issue when retransmitting RPC calls
      SUNRPC: Avoid deep recursion in rpc+AF8-release+AF8-client

 fs/nfs/Kconfig        +AHw  6 +-+-+----
 fs/nfs/nfs4state.c    +AHw  7 +-+-+-+-+-+--
 fs/nfs/super.c        +AHw  2 +--
 net/sunrpc/clnt.c     +AHw 29 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-----------=
--
 net/sunrpc/xprtsock.c +AHw 28 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+---=
-----
 5 files changed, 48 insertions(+-), 24 deletions(-)

--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com

--=-HViyGKp+Wz80BcrajNY/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABAgAGBQJSh98kAAoJEGcL54qWCgDyYVQP/i0uI/ul1H0rblNNahDNnSXR
kILqPdlKJkIx+JqF7zK+YaY9vHB17BnLsCNVwM9K6zQZmzDl8wzEQp8uO0ZNzkVX
DVpDEn2j6i2vDti9L7BI8uFa9OVW438DEi8CU6ceYNqjpg3bQ35v9tOKV1qRB5kv
uLnokTs+86TCc/FhZj0iJHdXfuYqyZGvMZQHQlCnHa6Q6/wl5Qk8AfuVy+U9rd9/
U+uV5ZlcavDJl2ZpIy5UZOpMJwUVwQRbwfuxV0gEQW5bE2yOs/9LxdvAtndDUN4Q
Of4PlU2kroAyv8CTh9bNnHDc3dXygTznPlD4qmlV0JGU/iWs490L31DobVEFmJ7A
9RgwZIBTFHABb4pEvtoIf7btIyiGCuNsNRb7HGHd3KRwEc33Q+Ws9Xj1OrgHxP/V
u/8ghU/ZqAwssmNzVQtUq7qzZPL7Dl6WzRsReD6CcnGWNpYbFd3s6iKX4jLyh6WP
7khPzZwfiTRC6rTU7W8nmJuCLDxKd+uqLZMjLiiVs28G9Us1r9nM7/1L+byEwEE4
8O7NyVrXFeJPgc2T0SJ3OPMzSnY4g41IWUKnHoE5MKP3Gjrxid4Av/xMrO2aezHm
W+QRHp/mY306nW6/IDlx5tnJpSWCKFovu3YAxPDaFBQmknRdXXvULbfpWi6gJYsf
Zbsj+FoQJDMGhypm/Nbk
=SwEk
-----END PGP SIGNATURE-----

--=-HViyGKp+Wz80BcrajNY/--
