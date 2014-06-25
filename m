Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f53.google.com ([209.85.216.53]:63685 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752091AbaFYWwI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jun 2014 18:52:08 -0400
Received: by mail-qa0-f53.google.com with SMTP id j15so2105102qaq.40
        for <linux-nfs@vger.kernel.org>; Wed, 25 Jun 2014 15:52:08 -0700 (PDT)
Message-ID: <1403736725.3457.1.camel@leira.trondhjem.org>
Subject: [GIT PULL] Please pull NFS client bugfixes for Linux 3.16
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>
Date: Wed, 25 Jun 2014 18:52:05 -0400
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-KyPm5aLxPalqIrx8Hf69"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-KyPm5aLxPalqIrx8Hf69
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Linus,

The following changes since commit a497c3ba1d97fc69c1e78e7b96435ba8c2cb42ee=
:

  Linux 3.16-rc2 (2014-06-21 19:02:54 -1000)

are available in the git repository at:

  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-3.16-=
2

for you to fetch changes up to 66b068604903849c5dee3842eb72564064c64c72:

  NFSv4: test SECINFO RPC_AUTH_GSS pseudoflavors for support (2014-06-24 18=
:46:58 -0400)

----------------------------------------------------------------
NFS client fixes for Linux 3.16

Highlights include:

- Stable fix for a data corruption case due to incorrect cache validation
- Fix a couple of false positive cache invalidations
- Fix NFSv4 security negotiation issues

----------------------------------------------------------------
Andy Adamson (3):
      NFS check the return of nfs4_negotiate_security in nfs4_submount
      NFS Return -EPERM if no supported or matching SECINFO flavor
      NFSv4: test SECINFO RPC_AUTH_GSS pseudoflavors for support

Scott Mayhew (1):
      nfs: Fix cache_validity check in nfs_write_pageuptodate()

Trond Myklebust (2):
      NFS: Clear NFS_INO_REVAL_PAGECACHE when we update the file size
      NFS: Don't mark the data cache as invalid if it has been flushed

 fs/nfs/inode.c         |  76 +++++++++++++++++++-----------------
 fs/nfs/nfs4_fs.h       |   2 +-
 fs/nfs/nfs4namespace.c | 102 +++++++++++++++++++++++++++------------------=
----
 fs/nfs/nfs4proc.c      |   2 +-
 fs/nfs/write.c         |   4 +-
 net/sunrpc/auth.c      |   1 +
 6 files changed, 104 insertions(+), 83 deletions(-)

--=20
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


--=-KyPm5aLxPalqIrx8Hf69
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABAgAGBQJTq1KVAAoJEGcL54qWCgDyHXgQAJdh3y3P7zIISKfBqsmnzj2k
odxw1cOfKYvPqKO/r7SJrsgQA1mWYZZ0HzxJekV03yubiWjpKRx8IMjD7KgXpxnO
5NQKi/9DiCrlsmxzuMHcELrG1HV76yc5P4h/bHe+lLjb8XywhMGTtSk43oPZTfga
hCFj7fimwtdF1OAmaWC130t/AEYxxPcGVejkpbRlizyLhPMV9AZLEGbLyvbqAn2W
zOMTAEtMcXeyk+1uIlrXkgVDpzV1rHtOzsitbQYTYLtFLwdDw1TS4e+Go60LwCH9
q8fca8h9LSYke1xBzUJ1S/6/3dPAZn+qq+fgnPq/+F9BOKYSFTU+EvkWYEYKKMzY
AkHvUWSLDmBl4uhxn0Z5fdEw0R/2oWMsU/Zfsf/wYv77tSajkdOyzKKOC2ArTgdM
+7aAqoyOCfsq4R/bpXmBtwV9f4KOokZCkU43Vqq7cqZcNVG29TRBNqrYGGhWNCTM
YQ5b+uc0OJRwT4NUoSyVHDeASHVFQJoqXuhc5Ac8tVxPQgb9GJvYcccKUYAWdCTG
PeF67uE1s0YhU4IBd2vIXdluE3RTOjEbnXq9WcyG7ZToUd88t5uS4QyEe3S9kGpS
J1PAedBfjXVEXa/2hMfuhrtdT7VAnw5FnX8uvXpfw0EsIEZN20FK+l6+l6xSJjnR
Tqptex20DxHck47/VUqa
=BNpt
-----END PGP SIGNATURE-----

--=-KyPm5aLxPalqIrx8Hf69--

