Return-Path: <neilb@suse.de>
From: NeilBrown <neilb@suse.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Date: Thu, 13 Oct 2016 15:04:48 +1100
Cc: Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/5] NFSv4: change nfs4_select_rw_stateid to take a lock_context inplace of lock_owner
In-Reply-To: <3006e49d-0e09-96c1-74c6-9ffe789ce0e5@Netapp.com>
References: <147623977637.19592.12766016823334433969.stgit@noble> <147623995856.19592.8461168656619949864.stgit@noble> <1476275602.2541.20.camel@redhat.com> <3006e49d-0e09-96c1-74c6-9ffe789ce0e5@Netapp.com>
Message-ID: <87bmyo28tb.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Oct 13 2016, Anna Schumaker wrote:
>>=20
>> Also, as a side note: There were some changes around the NFS file
>> locking code that went into the CB_NOTIFY_LOCK patches. Those are in
>> linux-next now, and I _think_ Anna is going to merge them for v4.9. I
>> don't see any obvious conflicts here, but you may want to ensure that
>> you're basing this on top of linux-next to minimize them.
>
> Yep, they'll be in 4.9.  Updating against those changes wouldn't hurt :)

Ok....
I note that
  git://git.linux-nfs.org/projects/anna/linux-nfs.git#linux-next

isn't in
  git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git

Should it be?

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJX/wfgAAoJEDnsnt1WYoG5gkgP/21wLo+IF2Ck1tWgnCljh9Fn
aj3DvZHA9d5XGVpdn1Q/7+IZVjSLWr9i08qD83WbjQEBAEzNn6lP/xq7GDhKLgRf
Fcvkqiri9o7Sg5BRZ1LFACck7F8mzkuy+FfZ6TcpAjJ3cWTasDbUTZm/oacpS4dE
wPDsafbkKXb8i8vQLdERSNhv7I0Y9JGl0Tc6tsrYGwUY91GrMctn5hng1yB+sSS1
9t2q46uKyNhfemD6DWVX7ktaKyKWZozm+zWQeWN5v9AignZgZMd8nDgtR/o+CIzd
25s1Eh9dFgquV7aPb8xT0n7J8wAqMIwL6WKYEtqRKy/W+v250JbswxQGAMPnDRh5
pTaz+l8uE5UsXALQeZsKyOw9lABMRlYO6jE91sAPqq4r9nmY1FjNW/JaaJY7tEYU
Q2uI0LmmrlpnrFg7hQABcbbm4ZSqHNe1oS634DkeSYj1ICMchIVzoYFdVtZzgMox
srvX/jL64jqRAIm7LwLvCkNEbmnZkBGraureAZnzbyt+RytyFkSVf3jP0NwUVCIo
lZuDdFwzDp6uWKIfmsmXS5cUuJBeqJoxqE5oGhi21JMiW3UDg4896mccH4a+wPxt
fBM1HYmZ1woyohHrmNO9fprNpHr4/LWxUF1J3Br7Tk35VEs+mms+K+LUyJICGGDI
R7McSugHpPP9JK/y+W3o
=ha2N
-----END PGP SIGNATURE-----
--=-=-=--
