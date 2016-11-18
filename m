Return-Path: <neilb@suse.de>
From: NeilBrown <neilb@suse.com>
To: Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Fri, 18 Nov 2016 15:59:19 +1100
Cc: Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/6] NFSv4: Fix stateid used when flock locks in use. - V2
In-Reply-To: <8737jtz5nf.fsf@notabene.neil.brown.name>
References: <147633263771.766.17853370901003798934.stgit@noble> <1476372661.12134.14.camel@redhat.com> <8737jtz5nf.fsf@notabene.neil.brown.name>
Message-ID: <878tshfkns.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain


Hi all,
 what is the status here.  I don't see these in linux-next, nor do I see
 any issues raise with them.
 Is there any chance they can get into 4.10??

Thanks,
NeilBrown


On Wed, Oct 19 2016, NeilBrown wrote:

> [ Unknown signature status ]
> On Fri, Oct 14 2016, Jeff Layton wrote:
>
>>
>> This all looks good to me aside from some minor documentation nits.
>> Kudos too on doing this with a net removal of code. :)
>>
>> Reviewed-by: Jeff Layton <jlayton@redhat.com>
>
> Thanks.
>
> The full series, with Reviewed-by added, is available as below if
> a "git pull" is easier that plucking them out of emails
>
> NeilBrown
>
>
> The following changes since commit 1001354ca34179f3db924eb66672442a173147dc:
>
>   Linux 4.9-rc1 (2016-10-15 12:17:50 -0700)
>
> are available in the git repository at:
>
>   git://neil.brown.name/linux tags/nfs-flock-fix
>
> for you to fetch changes up to 077829bfd0e32131b49d87476b69a189e8e13ae8:
>
>   NFS: discard nfs_lockowner structure. (2016-10-19 08:44:25 +1100)
>
> ----------------------------------------------------------------
> Series to fix NFSv4 stateid used for flock locks
>
> ----------------------------------------------------------------
> NeilBrown (6):
>       NFS: remove l_pid field from nfs_lockowner
>       NFSv4: add flock_owner to open context
>       NFSv4: change nfs4_do_setattr to take an open_context instead of a nfs4_state.
>       NFSv4: change nfs4_select_rw_stateid to take a lock_context inplace of lock_owner
>       NFSv4: enhance nfs4_copy_lock_stateid to use a flock stateid if there is one
>       NFS: discard nfs_lockowner structure.
>
>  fs/nfs/dir.c           |  6 +++---
>  fs/nfs/inode.c         | 14 +++++++-------
>  fs/nfs/nfs4_fs.h       |  2 +-
>  fs/nfs/nfs4file.c      |  2 +-
>  fs/nfs/nfs4proc.c      | 44 +++++++++++++++++++-------------------------
>  fs/nfs/nfs4state.c     | 49 ++++++++++++++++++++++++++++++++-----------------
>  fs/nfs/pagelist.c      |  3 +--
>  fs/nfs/write.c         |  3 +--
>  include/linux/nfs_fs.h | 10 +++-------
>  9 files changed, 68 insertions(+), 65 deletions(-)

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYLoqnAAoJEDnsnt1WYoG5QDMP/Rky62kTTFXEECFSeSLJ//RO
ZjBalBE2Ux+96NLED5TPOhXOagd56wEV6lNE9wiXslnNbNs9Z2cnS5sLU+3BXVsk
uOsSGHxUF3HDtCohjxvekJ7ozy3yQelo3VwOipT84ayaT4bBtfaWcLbXzI8QV6m4
arD5lHwY49hYbZdt4NkTSkFrUhHi3W4deswehP3hA/X3EZxRlvMKLDxBCKG8FPxd
tY+oLWPOKhtqU0Qs+ppZjw9Hwib04k0JJgyLz9NE0EfnG45kEGpwdktKPqEKxLyi
g4Rqlk3Zkyn/N3X9VS1E5W6qKZ6oIj/KNTXn5K2D6cNLWSiu3NBBS/DFchYV3AvJ
OZe5KNUPrepYhfUEfPmQmLjiWjvyUxhT7ot+8GMFNGj740q4ppM8iZEGBj2vAy6G
jpd0938xjGkGQaSDDXgq2OxVnt6uPvPVwnRjrV4NLkvDJtU6BRdj28UjxmgEaS4/
rutwrjc170HMR/tjqLBqyJ90/5inPZBpAy8l0NTyo4kLPIebE0MftUaphnP6vkW8
r1Hx0IUkpO3exUkWCzDuDiYy8qtJCoBsNBdH7g5o+m+t2N6gP06lPfVBTutckUQB
AzK93cLFY+R1M0dWoJrF0zTSk+Ju0265FhmQTtN58MCRxN+NJ+/ivf2ay8LfoHoK
5mrCH1hJdDRRYsPctUUU
=y3Aq
-----END PGP SIGNATURE-----
--=-=-=--
