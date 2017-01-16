Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from laas.laas.fr ([140.93.0.15]:32993 "EHLO laas.laas.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751151AbdAPRFS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 16 Jan 2017 12:05:18 -0500
Date: Mon, 16 Jan 2017 18:03:45 +0100
From: Matthieu Herrb <matthieu.herrb@laas.fr>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org, Andreas Gruenbacher <agruenba@redhat.com>
Subject: Re: [PATCH] NFSv4.2: Fix file creating with O_EXCL get a bad mode
Message-ID: <20170116170345.GF30896@paperthin-usb.laas.fr>
References: <a76cec59-f007-5c26-dc26-4cc8a6e4daef@gmail.com>
 <20170112204722.GC10501@fieldses.org>
 <d1e320f8-152e-b700-a33d-37d4426503ad@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="Pql/uPZNXIm1JCle"
In-Reply-To: <d1e320f8-152e-b700-a33d-37d4426503ad@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Pql/uPZNXIm1JCle
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Jan 15, 2017 at 03:55:16PM +0800, Kinglong Mee wrote:
> On 1/13/2017 04:47, J. Bruce Fields wrote:
> > On Sat, Jan 07, 2017 at 10:45:47PM +0800, Kinglong Mee wrote:
> >> Acorrding to Matthieu Herrb's test cases, a new created file will
> >> get a bad mode as 0666 (expected 0644) after commit dff25ddb4808
> >> "nfs: add support for the umask attribute".
> >>
> >> It is caused by missing check of FATTR4_WORD2_MODE_UMASK
> >> in nfs4_exclusive_attrset.
> >=20
> > I don't understand:
> >=20
> >> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> >> index 6dcbc5d..a3e9ef1 100644
> >> --- a/fs/nfs/nfs4proc.c
> >> +++ b/fs/nfs/nfs4proc.c
> >> @@ -2697,7 +2697,8 @@ static inline void nfs4_exclusive_attrset(struct=
 nfs4_opendata *opendata,
> >>  		sattr->ia_valid |=3D ATTR_MTIME;
> >> =20
> >>  	/* Except MODE, it seems harmless of setting twice. */
> >> -	if ((attrset[1] & FATTR4_WORD1_MODE))
> >> +	if ((attrset[1] & FATTR4_WORD1_MODE) ||
> >> +	    (attrset[2] & FATTR4_WORD2_MODE_UMASK))
> >>  		sattr->ia_valid &=3D ~ATTR_MODE;
> >=20
> > If I'm understanding this function correctly, attrset is the set of
> > attributes which the server tells us were used to store the verifier.
> >=20
> > But mode_umask would never be a sensible place to store the
> > verifier, so if the server's response really says that then something's
> > wrong.
>=20
> There are some differences between EXCLUSIVE4 and EXCLUSIVE4_1,
> according to rfc5661 18.16.4,=20
>=20
>    After the client has performed a successful exclusive create, the
>    attrset response indicates which attributes were used to store the
>    verifier.  If EXCLUSIVE4 was used, the attributes set in attrset were
>    used for the verifier.  If EXCLUSIVE4_1 was used, the client
>    determines the attributes used for the verifier by comparing attrset
>    with cva_attrs.attrmask; any bits set in the former but not the
>    latter identify the attributes used to store the verifier.  The
>    client MUST immediately send a SETATTR to set attributes used to
>    store the verifier.  Until it does so, the attributes used to store
>    the verifier cannot be relied upon.  The subsequent SETATTR MUST NOT
>    occur in the same COMPOUND request as the OPEN.
>=20
> I think, this patch is a hacker implement for EXCLUSIVE4_1 that just
> treat the FATTR4_WORD1_TIME_ACCESS and FATTR4_WORD1_TIME_MODIFY for
> exclusive verifier as EXCLUSIVE4.=20
>=20
> Maybe we need update the implement of EXCLUSIVE4_1's verifier
> checking.

Hi,

this patch doesn't fix the issue against our NetApp server (which is
running an old version of the system as it has been noticed, but we
cannot upgrade until a few months) . My test program is still getting
a number of wrong issuess :

host$ ./a.out foo
foo: ok
foo: ok
foo: ok
foo: ok
foo: 700
foo: ok
foo: ok
foo: ok
foo: ok
foo: ok
foo: ok
foo: ok
foo: ok
foo: ok
foo: 700
foo: ok
foo: 700
foo: ok
foo: ok
foo: ok
foo: 700
foo: 700
foo: 700
foo: ok
foo: 700
foo: 700
foo: 700
foo: ok
foo: 700
foo: ok
foo: ok
foo: ok
foo: 700
foo: ok
foo: ok
foo: ok
foo: ok
foo: ok
foo: ok
foo: ok

>=20
> thanks,
> Kinglong Mee
>=20
> >=20
> > We should probably look at a network trace.
> >=20
> > --b.
> >=20
> >> =20
> >>  	if (attrset[2] & FATTR4_WORD2_SECURITY_LABEL)
> >> --=20
> >> 2.9.3
> >>
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >=20
>=20

--=20
Matthieu Herrb

--Pql/uPZNXIm1JCle
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUBWHz88Ghzk+430Sj4AQJ4MQ/+K5+NKDujHMBc8xeev2ZyU0P2yG3kkvSF
xs/1pllsqTPOq/3QWgQfadJH1zHN72TbU378c9+j1TQIw7DWB0wNe92JCv35e2RL
lSXEkOCpWWgp70J4ukct7HXajT5f+xucZHMRrti+NRc49uw8vQ8rRNjIm43B0wO0
7RCL+dIxvXJdxpuBF/boK2Nixh9LXtN9uL4P9VZKdOflBeStGqDweT2HG1Hm+yUa
WR1wXupoYxsFJGxmRxUeoob13JYaXx1KO/FeOtHMshvvrZrrX6NItDrVwus6ekfA
7qyT/9WdFgzoEiEUxVF07SWGm9mre2Wiq6Fw87Wd5gzXNJ5HanW4OakrUAJJrrV/
M857NLhlNpNjwKEX0v6BBbl01ca4o6y2/zK45gXBZjfsPREdGn0MEhHoKLIPxK6n
Mig8Fe4PBKp0GyYXqsmh73WWvRzzZefQLIN9U+NrSTp+zHdqDLb+0u8NaQ8PGhwi
PtczcTAEy+SG6isHUGZ0VXzhtgndslmoSk7i6dWPFCWc7mYnD8V1huxO0Q/ubPbK
yEJvRc49ud46NQ08E6mXOjm7p8x/LdbUi0Laum2g1tLPiM/xe3WvzS3m/x/xT7YC
9m9qsE5b+yfoPbpiPy8w6vp+2tmwfCpOF+C0kKiyUOFVTlI8XsiOYYIwqwHRDdVi
63Lho4LQzlI=
=fYNo
-----END PGP SIGNATURE-----

--Pql/uPZNXIm1JCle--
