Return-Path: <neilb@suse.de>
From: NeilBrown <neilb@suse.com>
To: Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Thu, 13 Oct 2016 09:59:28 +1100
Cc: Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/5] NFS: remove l_pid field from nfs_lockowner
In-Reply-To: <1476271705.2541.8.camel@redhat.com>
References: <147623977637.19592.12766016823334433969.stgit@noble> <147623995844.19592.4907099762700740448.stgit@noble> <1476271705.2541.8.camel@redhat.com>
Message-ID: <87insx18dr.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Wed, Oct 12 2016, Jeff Layton wrote:

>
> Looks ok. For my own knowledge though, in what situations would you have
> the same files pointer but a different tgid?

If you call clone(2) passing CLONE_FILES (so get the same files pointer)
but not CLONE_THREAD (so different thread-group).
Definitely possible, probably not useful.

>
> Acked-by: Jeff Layton <jlayton@redhat.com>

Thanks,

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJX/sBRAAoJEDnsnt1WYoG5qtoP/j/ao3lAp2QmD+10xJ5fEcg0
F0gyDY4b1+325y6nfdCPmxLIXwF6u7UCRiR4kV7kOnquQmIiyxBaSdRVcWfwr4J0
//Ofd/OF3o5tTnnxiRrOLbqovHEUBMP1vU/E5VP+tOzmh9+VBA66lm0ekZhja3PC
QU4YvoinmFcAS2HX5u4ORaJ7yXMgXuFdK6AmVOWy5CWlaU8VEdLavXUhnLZIRlBU
5LrDV7h6GcN9KYgycgNM+Xqo4yST3+OZ3vqt19n04SQ9Es2fX5Nb1g+ahlad+aCr
pogb7EanG7wYh0ekE/I80LAZkQSW3+NxqpaesD0Tw2v6Twa3xsULBRKCJfe7zofw
678unNM/JvBucOR+qGy0UmaNW89eqi69JigvRJSJm7Y8gAs6QF6Ikz5YnbWA3RIA
N3ca6KLynu+cf8fnxmn2IkFIDVIvep8/jtMa+ksr2Y+nZFA8ySLuFYhC5QE+PyIB
nwYQMSmivy8lH5iRzfuP0rI4vJ7Lb7lv0YGP7MRvpD0eD/GjZdUxDuiv4V5uoYoF
CF6Kv2J2f3+z5IvolKdkxO85J6mHE3fpFRlUOkXh0QOY9NrnNhOOwtzb2oOegIj8
LshNS7KqYo7oGoX2hc+HvWhapnAG+R1x2Tme/KdmILBxyzU5h0sDpN+b8z1ielwf
2ZQaGhGvY5EX7PIh6BVi
=DyM7
-----END PGP SIGNATURE-----
--=-=-=--
