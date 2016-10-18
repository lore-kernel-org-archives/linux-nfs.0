Return-Path: <neilb@suse.de>
From: NeilBrown <neilb@suse.com>
To: Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Wed, 19 Oct 2016 08:52:36 +1100
Cc: Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/6] NFSv4: Fix stateid used when flock locks in use. - V2
In-Reply-To: <1476372661.12134.14.camel@redhat.com>
References: <147633263771.766.17853370901003798934.stgit@noble> <1476372661.12134.14.camel@redhat.com>
Message-ID: <8737jtz5nf.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Fri, Oct 14 2016, Jeff Layton wrote:

>
> This all looks good to me aside from some minor documentation nits.
> Kudos too on doing this with a net removal of code. :)
>
> Reviewed-by: Jeff Layton <jlayton@redhat.com>

Thanks.

The full series, with Reviewed-by added, is available as below if
a "git pull" is easier that plucking them out of emails

NeilBrown


The following changes since commit 1001354ca34179f3db924eb66672442a173147dc:

  Linux 4.9-rc1 (2016-10-15 12:17:50 -0700)

are available in the git repository at:

  git://neil.brown.name/linux tags/nfs-flock-fix

for you to fetch changes up to 077829bfd0e32131b49d87476b69a189e8e13ae8:

  NFS: discard nfs_lockowner structure. (2016-10-19 08:44:25 +1100)

----------------------------------------------------------------
Series to fix NFSv4 stateid used for flock locks

----------------------------------------------------------------
NeilBrown (6):
      NFS: remove l_pid field from nfs_lockowner
      NFSv4: add flock_owner to open context
      NFSv4: change nfs4_do_setattr to take an open_context instead of a nfs4_state.
      NFSv4: change nfs4_select_rw_stateid to take a lock_context inplace of lock_owner
      NFSv4: enhance nfs4_copy_lock_stateid to use a flock stateid if there is one
      NFS: discard nfs_lockowner structure.

 fs/nfs/dir.c           |  6 +++---
 fs/nfs/inode.c         | 14 +++++++-------
 fs/nfs/nfs4_fs.h       |  2 +-
 fs/nfs/nfs4file.c      |  2 +-
 fs/nfs/nfs4proc.c      | 44 +++++++++++++++++++-------------------------
 fs/nfs/nfs4state.c     | 49 ++++++++++++++++++++++++++++++++-----------------
 fs/nfs/pagelist.c      |  3 +--
 fs/nfs/write.c         |  3 +--
 include/linux/nfs_fs.h | 10 +++-------
 9 files changed, 68 insertions(+), 65 deletions(-)

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYBpmkAAoJEDnsnt1WYoG5KgkP/38W1TNRzVTZFIny59xfKAoS
V0o+LfPKpz6AFVHzN7OSeBDnwSBZPSVevzQtYUrD2IU5fIp1nG0cfYeHd0jRzuWR
ps6/XU8NizdP/NuAsDSAzSwNKQWs7+FPO9AOVFLNlVp//RWgo6UMOmd8a4hEimnM
tLVUMKNVh6Kqryt3iR+WspTMwNyag73zroitEXszkoeZGGZj9rBJA2546nL0gQ/k
qp/DkAbCe8JWpCQZ2ZJ0PWUss+c47DM9LuuOqnQEl6jyDbNajlQNrc+KsO3YkiBS
klMg/H8hKVfCqIM8J3hPSZ6jjE8T7xqV8sg0PG6CuUcU3dg17coCBE2E/bZC6INm
y/I64TGSUtC+NRFEoc61ZlP+6C/KOs48z25Eem2+rIV1uI06p15zYNnbzGCY6pnt
iTc0obDOH6ZjV+/qs4MOHEPOWy3kzBpN+7f3kpQRCe/vqAvDvrXZFJCRV4DsBt2v
7c+523ysE/8f46QL/yZW1VWfeKldQcLof8CLxOE4uJFOclobfsjeIAnIWwNhRmyE
SsH2kPj7rWsSwp0rx9oPURaUVzk5YIseItdKfdpRXuU9AdTR23vXZNdx10Xa11B4
/9DzZQfg1bSphhqHpdixSi6iOXFKeXGc2VVwd9EiR8HIVL1+xVe7fEdekNmJIKBW
Fm1faw2E1YmzFYek0dVA
=Wy+4
-----END PGP SIGNATURE-----
--=-=-=--
