Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:65183 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753122AbaAaVlY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 31 Jan 2014 16:41:24 -0500
Received: by mail-ie0-f174.google.com with SMTP id tp5so4675045ieb.5
        for <linux-nfs@vger.kernel.org>; Fri, 31 Jan 2014 13:41:24 -0800 (PST)
Message-ID: <1391204481.8541.3.camel@leira.trondhjem.org>
Subject: [GIT PULL] Please pull NFS client bugfixes
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Torvalds Linus <torvalds@linux-foundation.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>
Date: Fri, 31 Jan 2014 16:41:21 -0500
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-Us2RQdUZYuxK1kh840s/"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-Us2RQdUZYuxK1kh840s/
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Linus,

The following changes since commit ed7e5423014ad89720fcf315c0b73f2c5d0c7bd2=
:

  pnfs: Proper delay for NFS4ERR_RECALLCONFLICT in layout_get_done (2014-01=
-22 18:10:49 -0700)

are available in the git repository at:

  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-3.14-=
2

for you to fetch changes up to a1800acaf7d1c2bf6d68b9a8f4ab8560cc66555a:

  nfs: initialize the ACL support bits to zero. (2014-01-31 08:28:16 -0500)

Please note that this pull excludes the fixes for the NFSv3 posix acl
regressions, since at least one of those patches will need an ack from
Al and/or Christoph.

Cheers
  Trond

----------------------------------------------------------------
NFS client bugfixes for Linux 3.14

Highlights:

- Fix several races in nfs_revalidate_mapping
- NFSv4.1 slot leakage in the pNFS files driver
- Stable fix for a slot leak in nfs40_sequence_done
- Don't reject NFSv4 servers that support ACLs with only ALLOW aces

----------------------------------------------------------------
Andy Adamson (1):
      NFSv4.1 free slot before resending I/O to MDS

Jeff Layton (3):
      NFS: fix the handling of NFS_INO_INVALID_DATA flag in nfs_revalidate_=
mapping
      sunrpc: turn warn_gssd() log message into a dprintk()
      nfs: add memory barriers around NFS_INO_INVALID_DATA and NFS_INO_INVA=
LIDATING

Malahal Naineni (2):
      nfs: handle servers that support only ALLOW ACE type.
      nfs: initialize the ACL support bits to zero.

Trond Myklebust (4):
      NFS: Fix races in nfs_revalidate_mapping
      NFSv4: Fix a slot leak in nfs40_sequence_done
      NFSv4.1: Clean up nfs41_sequence_done
      NFSv4.1: Cleanup

 fs/nfs/dir.c                   | 13 +++++++++--
 fs/nfs/inode.c                 | 51 +++++++++++++++++++++++++++++++++++---=
----
 fs/nfs/nfs4_fs.h               |  1 +
 fs/nfs/nfs4client.c            |  5 +----
 fs/nfs/nfs4filelayout.c        |  8 +++++--
 fs/nfs/nfs4proc.c              | 31 ++++++++++++-------------
 fs/nfs/nfs4xdr.c               |  2 +-
 fs/nfs/nfstrace.h              |  1 +
 fs/nfs/write.c                 |  7 +++++-
 include/linux/nfs_fs.h         |  1 +
 net/sunrpc/auth_gss/auth_gss.c |  8 +------
 11 files changed, 86 insertions(+), 42 deletions(-)

--=20
Trond Myklebust
Linux NFS client maintainer

--=-Us2RQdUZYuxK1kh840s/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABAgAGBQJS7BiBAAoJEGcL54qWCgDyXrEP/0e9wPKVw6kzdUPzYfIbMaew
QtjKiVOZmb01Z8JXsb6TZTkT6qy9H4r9JuztNKcUibBlj4V0DaCiXp15lMsHGhGq
3Kmw9RWaCUGyc4N8pm1YshjeB1i5S2xjBE4eMoKsItfv1Z0XM6icnnorDlkwpeSN
6sJ1Oc1wRK3RzywzALp7Mw6ZifwVmwUGn36zyVn5QmNDwNP26XSqGaZjrZZhThfl
8b21NjkupPhVp2uKZ14W3xOsN6O1puAS+k5nWA7erGrqlz4bapLwNMBnOF2hfPHW
VnEXV9Pp+CkKWPWsXyJH3gtI3MQxda86h3yJV7ACOd4QQDRSGDTokSd4yU2CqgMZ
M81VYbzYMRTusY+1dwxi5HJCygaQgXw95pIWrzZG0arvpL1mnLl3BOOi5F3vGI33
TlBd3eFXvie+8CYfkNtzsWnYdseAVGZO9XAPsAh7wE/7khWS+D7abz8qttVbjbrU
IgdjudIMLJgVrFtXuKpsrhL11IqMp66mGkJ9xgx8XSVwxvQIVT9GtS2AZUvJmFJO
WbePC2Hw3RK+/vLfxp1RYDprQPyDxBK5oaztvp18zS/y3PPGsr8/x9lofROa9E8Y
kIKFd/GRA4ANa967hjIPB4poHJ/5fzRA9MZDxlO4JQbsToPWDfi0oJtjp122R4pK
wZedVY2CS9YpVR6sPN8U
=+QCU
-----END PGP SIGNATURE-----

--=-Us2RQdUZYuxK1kh840s/--

