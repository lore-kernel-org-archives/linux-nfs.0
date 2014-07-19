Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f181.google.com ([209.85.223.181]:50236 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754635AbaGSUHG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 19 Jul 2014 16:07:06 -0400
Received: by mail-ie0-f181.google.com with SMTP id rp18so5616116iec.40
        for <linux-nfs@vger.kernel.org>; Sat, 19 Jul 2014 13:07:05 -0700 (PDT)
Message-ID: <1405800422.3254.4.camel@leira.trondhjem.org>
Subject: [GIT PULL] Please pull NFS client changes
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>
Date: Sat, 19 Jul 2014 16:07:02 -0400
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-Vc6MMz3m04tRvEOxcEvn"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-Vc6MMz3m04tRvEOxcEvn
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Linus,

Apologies for the relative lateness of this pull request, however the
commits fix some issues with the NFS read/write code updates in 3.16-rc1
that can cause serious Oopsing when using small r/wsize. The delay was
mainly due to extra testing to make sure that the fixes behave
correctly.

The following changes since commit 66b068604903849c5dee3842eb72564064c64c72=
:

  NFSv4: test SECINFO RPC_AUTH_GSS pseudoflavors for support (2014-06-24 18=
:46:58 -0400)

are available in the git repository at:

  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-3.16-=
3

for you to fetch changes up to f563b89b182594f827b4100bd34f916339785a77:

  NFS: Don't reset pg_moreio in __nfs_pageio_add_request (2014-07-13 15:18:=
44 -0400)

----------------------------------------------------------------
NFS client fixes for Linux 3.16

Highlights include;
- Stable fix for an NFSv3 posix ACL regression
- Multiple fixes for regressions to the NFS generic read/write code
  - Fix page splitting bugs that come into play when a small rsize/wsize
    read/write needs to be sent again (due to error conditions or page
    redirty).
  - Fix nfs_wb_page_cancel, which is called by the "invalidatepage" method
- Fix 2 compile warnings about unused variables.
- Fix a performance issue affecting unstable writes.

----------------------------------------------------------------
Christoph Hellwig (1):
      nfs: only show Posix ACLs in listxattr if actually present

Trond Myklebust (2):
      NFS: Remove 2 unused variables
      NFS: Don't reset pg_moreio in __nfs_pageio_add_request

Weston Andros Adamson (5):
      nfs: mark nfs_page reqs with flag for extra ref
      nfs: nfs_page should take a ref on the head req
      nfs: change find_request to find_head_request
      nfs: handle multiple reqs in nfs_page_async_flush
      nfs: handle multiple reqs in nfs_wb_page_cancel

 fs/nfs/direct.c   |   2 -
 fs/nfs/internal.h |   1 +
 fs/nfs/nfs3acl.c  |  43 +++++++
 fs/nfs/nfs3proc.c |   4 +-
 fs/nfs/pagelist.c |  20 +++-
 fs/nfs/write.c    | 335 +++++++++++++++++++++++++++++++++++++++++++++-----=
----
 6 files changed, 343 insertions(+), 62 deletions(-)



--=20
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


--=-Vc6MMz3m04tRvEOxcEvn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABAgAGBQJTys/mAAoJEGcL54qWCgDynYEQALk9/Qz7ZVLbw/Np65S7d1Ij
mWWLImJVcbKP7ZJcUuGRtvgnZ1lMUMTXpyLWiyxpUtJpJAj5pVVHivsCS/rwf1rF
Ng5ixIR9UE62CllJsX3BDDpq1BnEq0Vyvey/McIIxsoWecYT+dpexKIm4s+7SvRC
ei8f5kX5e7yoXSZWfRv56f2NXY3KwfyaiS9fTZJsWyUXVCfLA8t/0X1Lika65ooh
Zp5GoMnnVD/HakrAain8LrQuIIGxk0+BeOkxYgCNsrTd9Cs4h171n7SoI2rcdhX6
H/U8VPApmjEVhisqU56sghbIpTbt8g+2SA22McLVQeeFBVurrI2yJc6aItadbpnC
K2jEY1EYhS4smWEqITrn3aA65G5zV/Xa0KVDg5B/Zt+0gSryKVXwEbpjcbQFuaiZ
RLTGmAjSbOMbbhWBqL3QR1tCKFj2ogBKuIrHFIseUhNubUk3IwpJ+f1ew4gynG3w
g7HciiUGa6FTbh71fpH7QHpqR1iZsFZyWZtaknIv5rNxb1Zey9oWp1ZMZSqAYVRz
2GXBiOZUXZS6FbbRDbc73fPP93s/H6Bx0heHB5VnkK+/ZpSNa6WmarL0tj7z1tP8
WVHN+BiKyzqptnmztkRXclHM0L3FSyaxChrmFrloV9nQrqDsCLBY0aPMapwgHJmw
vSLEXn35LHpMHTngt0zX
=ndtc
-----END PGP SIGNATURE-----

--=-Vc6MMz3m04tRvEOxcEvn--

