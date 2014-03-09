Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f175.google.com ([209.85.213.175]:42098 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752508AbaCIQW7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 9 Mar 2014 12:22:59 -0400
Received: by mail-ig0-f175.google.com with SMTP id ur14so6230109igb.2
        for <linux-nfs@vger.kernel.org>; Sun, 09 Mar 2014 09:22:59 -0700 (PDT)
Message-ID: <1394382175.3819.1.camel@leira.trondhjem.org>
Subject: [GIT PULL] Please pull NFS client updates
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Torvalds Linus <torvalds@linux-foundation.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>
Date: Sun, 09 Mar 2014 12:22:55 -0400
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-96HpFPN4lUghX8RLJPzl"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-96HpFPN4lUghX8RLJPzl
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Linus,

The following changes since commit 146d70caaa1b87f64597743429d7da4b8073d0c9=
:

  NFS fix error return in nfs4_select_rw_stateid (2014-02-19 09:31:56 -0500=
)

are available in the git repository at:

  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-3.14-=
5

for you to fetch changes up to 2ca310fc4160ed0420da65534a21ae77b24326a8:

  SUNRPC: Fix oops when trace sunrpc_task events in nfs client (2014-03-07 =
19:10:08 -0500)

----------------------------------------------------------------
NFS client bugfixes for Linux 3.14

Highlights include:

- Fix another nfs4_sequence corruptor in RELEASE_LOCKOWNER
- Fix an Oopsable delegation callback race
- Fix another bad stateid infinite loop
- Fail the data server I/O is the stateid represents a lost lock
- Fix an Oopsable sunrpc trace event

----------------------------------------------------------------
Andy Adamson (1):
      NFSv4.1 Fail data server I/O if stateid represents a lost lock

Ditang Chen (1):
      SUNRPC: Fix oops when trace sunrpc_task events in nfs client

Trond Myklebust (5):
      NFSv4: Fix another nfs4_sequence corruptor
      NFS: Fix a delegation callback race
      NFSv4: nfs4_stateid_is_current should return 'true' for an invalid st=
ateid
      NFSv4: Fix the return value of nfs4_select_rw_stateid
      NFSv4: Fail the truncate() if the lock/open stateid is invalid

 fs/nfs/delegation.c           | 11 +++++++----
 fs/nfs/nfs4filelayout.c       | 10 ++++++----
 fs/nfs/nfs4proc.c             | 24 ++++++++++++++----------
 fs/nfs/nfs4state.c            | 14 +++-----------
 include/linux/nfs_xdr.h       |  5 +++++
 include/trace/events/sunrpc.h |  4 ++--
 6 files changed, 37 insertions(+), 31 deletions(-)

--=20
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


--=-96HpFPN4lUghX8RLJPzl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABAgAGBQJTHJVfAAoJEGcL54qWCgDy82oP/Akmv45Oz57LwaVUesYsTG6O
Cli6qsZoSbTWn9xIZsuNQYzgoRgt2wUsW+6b9yv5vtzzks3RQ7BR+Jru60eG78+r
jfZYN2tk8LSrtlnAZfd7uEz9JDa6+WAKcSksjhYrS9rYMj+UkzYDqlbln1pXEoJx
NqGa+vkpfPfOuOyxbIZQ4IfWEBhRUMpKdqJaZk6eYaYP3jz0Lux47dozEHL/jFrd
om1ix/jL5nCKfLAPLCQUSqvYG2To/cExLzQfgYQoMuxi3+BziMNHhPaGxelTDwnY
T5qjcK07O3ZsN9UhhDecMRGtHQ7m9K9D2b4I3gsGa6WI/4t7crjCACevUEo8bvc7
0742nQx8o7cO8sOa+cLbXboBr1XSS+/7QpFCghI7YkDz8JYEWHWjttfGtGMRNp9p
dzVIkVRxv6FPKwjCYEP5Z0OLiEM1ZtTxmfRGTMrXIDBE6i0+h2S2NVaz2+KBNvlr
qgwjs0JH0aTOYJIJRQU/g16dUOmDze5XDW9PCaBg1bwUNxCrNCIoxhM07yFSngZB
ZMztSRooOFfrKiy6O/neXwDZAiuv/+Y7MWVdapTXle5mePQvYD8VYmLlIF0llQ+W
O5D26xGfAmkjy+nk7ROVat88f1rbwPOnozahLBpQ5WehNbjgwyIke2o/xvCAWr75
2n+sdEDf/GJchyT6c748
=k1NE
-----END PGP SIGNATURE-----

--=-96HpFPN4lUghX8RLJPzl--

