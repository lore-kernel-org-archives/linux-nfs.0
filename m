Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:47894 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752962Ab2HVPmL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Aug 2012 11:42:11 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
CC: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        "Linux Kernel mailing list" <linux-kernel@vger.kernel.org>
Subject: [GIT PULL] Please pull NFS client fixes
Date: Wed, 22 Aug 2012 15:41:55 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA93C635D@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="=-g5SuOcIOoqFfFH+eHuYx"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-g5SuOcIOoqFfFH+eHuYx
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Linus,

The following changes since commit 2d534926205db9ffce4bbbde67cb9b2cee4b835c=
:

  Merge tag 'irqdomain-for-linus' of git://git.secretlab.ca/git/linux-2.6 (=
2012-07-31 20:44:03 -0700)

are available in the git repository at:


  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-3.6-3

for you to fetch changes up to 086600430493e04b802bee6e5b3ce0458e4eb77f:

  NFSv3: Ensure that do_proc_get_root() reports errors correctly (2012-08-2=
0 12:52:42 -0400)

----------------------------------------------------------------
NFS client bugfixes for Linux 3.6

- NFSv3 mounts need to fail if the FSINFO rpc call fails
- Ensure that the NFS commit cache gets torn down when we unload the
  NFS module.
- Fix memory scribble issues when interrupting a LAYOUTGET rpc call
- Fix NFSv4 legacy idmapper regressions
- Fix issues with the NFSv4 getacl command
- Fix a regression when using the legacy "mount -t nfs4"

----------------------------------------------------------------
Boaz Harrosh (1):
      pnfs-obj: Better IO pattern in case of unaligned offset

Bryan Schumaker (2):
      NFS: Clear key construction data if the idmap upcall fails
      NFS: return -ENOKEY when the upcall fails to map the name

Idan Kedar (2):
      pnfs: defer release of pages in layoutget
      pnfs: nfs4_proc_layoutget returns void

Jeff Layton (1):
      nfs: tear down caches in nfs_init_writepagecache when allocation fail=
s

Peng Tao (1):
      NFS41: add pg_layout_private to nfs_pageio_descriptor

Trond Myklebust (6):
      NFSv4.1: Remove a bogus BUG_ON() in nfs4_layoutreturn_done
      NFSv4: Fix pointer arithmetic in decode_getacl
      NFSv4: Fix the acl cache size calculation
      NFSv4: Don't use private xdr_stream fields in decode_getacl
      NFSv4: Ensure that nfs4_alloc_client cleans up on error.
      NFSv3: Ensure that do_proc_get_root() reports errors correctly

bjschuma@gmail.com (2):
      NFS: Fix a regression when loading the NFS v4 module
      NFS: Alias the nfs module to nfs4

 fs/nfs/Makefile              | 18 +++++------
 fs/nfs/client.c              |  2 +-
 fs/nfs/idmap.c               | 62 +++++++++++++++++++++++++-----------
 fs/nfs/nfs3proc.c            |  2 +-
 fs/nfs/nfs4_fs.h             |  3 ++
 fs/nfs/nfs4client.c          |  2 +-
 fs/nfs/nfs4proc.c            | 76 +++++++++++++++++++++++++++++++++++++---=
----
 fs/nfs/nfs4super.c           | 15 ---------
 fs/nfs/nfs4xdr.c             | 26 ++++++---------
 fs/nfs/objlayout/objio_osd.c | 55 ++++++++++++++++++++++++++++++--
 fs/nfs/pagelist.c            |  2 ++
 fs/nfs/pnfs.c                | 39 +----------------------
 fs/nfs/pnfs.h                |  2 +-
 fs/nfs/super.c               | 39 ++++++++++++++++++++++-
 fs/nfs/write.c               | 15 +++++++--
 include/linux/nfs_page.h     |  1 +
 include/linux/nfs_xdr.h      |  1 +
 17 files changed, 241 insertions(+), 119 deletions(-)

--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com


--=-g5SuOcIOoqFfFH+eHuYx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABAgAGBQJQNP3BAAoJEGcL54qWCgDyf6gP+wd5iVJd4e4Lc0FDgJFCbTv1
pV7DxAQcZQ65yLo3TeP25Exa5iSYPj1A44tICyb5tW0dhsDuwPDju5Dw6LvN7Rs6
EIWqodvvb+iTkd2o8hCTyiZUz6aOFVPFs+h5CXYoKACfOtsLe4G4qdci6wubBH0D
ilz+TP2uZEgvqxH7yHkVlcZhWZn4uLT3O4hGDtL8aK8eQ7+icDOwcIkVgb1RKSf3
SqgaYGuP53FZJUBCH6odUS6RG5UktBhwjm3YODtU5Dit15m7nIPnakHBW3HGVyvo
VsBVprzyMbPF+eHosVl4MayeYGMKA7Rvzn31fMp1QuRmzkvbXgBbJ8YUFVUtjKdN
Mx63eYbBrLgl+B3epafAob3sJiJKItavXh1hfqsR1g3qHtcm5b0EIxXEDXnF/wUL
WWSzrNK6uEj3Mfl4oOyISa0E5t14DzrhF9DSzH+CANDT9k4nxfa73avxWDj5iTtD
/xEogoSCpTrE2Ezi4h4A/s+dpo1E7OoTkNZ3bOztLuxqvkFUDR0MUQv/omaSVFFI
ogTZSVUdatpp3OLgMsGIAHf+SoDF8dKX8HwQfKXdLNWHD62PfYucWa0tH9Kod0hp
C0mBy63AMEH+DGGenC6TXCpp+oZEe2/2x17EnHglaCttmmfh5lXyMFGwEwYR1ZlC
1geE9juf+Mdo1XGpzpK5
=hawh
-----END PGP SIGNATURE-----

--=-g5SuOcIOoqFfFH+eHuYx--
