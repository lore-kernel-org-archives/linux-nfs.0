Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:27879 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751985AbeAJSCd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Jan 2018 13:02:33 -0500
From: Trond Myklebust <trondmy@primarydata.com>
To: "neilb@suse.com" <neilb@suse.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2] Support statx() mask and query flags parameters
Date: Wed, 10 Jan 2018 18:02:28 +0000
Message-ID: <1515607340.8219.9.camel@primarydata.com>
References: <20180109162353.10698-1-trond.myklebust@primarydata.com>
         <87h8rubfy0.fsf@notabene.neil.brown.name>
In-Reply-To: <87h8rubfy0.fsf@notabene.neil.brown.name>
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="=-Mmux09VRL6U11SgYb7G/"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-Mmux09VRL6U11SgYb7G/
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2018-01-10 at 13:33 +1100, NeilBrown wrote:
> On Tue, Jan 09 2018, Trond Myklebust wrote:
>=20
> > Support the query flags AT_STATX_FORCE_SYNC by forcing an attribute
> > revalidation, and AT_STATX_DONT_SYNC by returning cached attributes
> > only.
> >=20
> > Use the mask to optimise away server revalidation for attributes
> > that are not being requested by the user.
> >=20
> > Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> > ---
> > v2:
> >  - Respect the attribute cache timeout.
> >  - Unless AT_STATX_DONT_SYNC is set, we must only return attributes
> >    that have been duly revalidated.
>=20
> This looks good, thanks.
> It handles _FORCE_SYNC and _DONT_SYNC and avoids the flush if
> CTIME/MTIME aren't requested.
>=20
> I note that you no longer call nfs_need_revalidate_inode().
> Most of the checks in there you have included in a different form,
> but I don't see a test for NFS_INO_INVALID_LABEL.  Is there a reason
> that we don't need that test any more?  Was it redundant previously?

It's a good question. NFS_INO_INVALID_LABEL is definitely not needed in
order to satisfy a stat() or statx() request. We wanted to be able to
revalidate the security label somewhere, but it doesn't really make
much sense to peg that to stat(), and I've never really been happy with
that decision.

We can add it back in for now.

--=20
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

--=-Mmux09VRL6U11SgYb7G/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEESQctxSBg8JpV8KqEZwvnipYKAPIFAlpWVSwACgkQZwvnipYK
APJPSg//aMlJJQGBcVDvBuJdKBOFZ5o2RVStBhWlM83L6gz8qhScfA1oh/ABvSdg
xmOSgsXwPGqhwG/EWLlabqKJcLgjOZKgj+hilQggKY1uEnMVwmvejCCKHD2bJpvt
d9IDVoacplRzlwGY7lDcXYSf5lljP/PXt4kC0zAi1EBA461KXhJIqkb51lY4HxBQ
imVwKosrmxJPsm3KznJ+suTkl54oeTDiaA7MZ3rxRQQv0PVqsHefiCU6JDrdpk0S
koap9yo6HceD2gP2/1KGZkJFd44PHMJEomfParRV0t/Yf0J7k5IumU24zG03+In7
jCGvKYYYh6Iw9um05mEOt6EOpLI4ObhzdE5xaatJK+eGX+WxY3wnft+4KvKXd2Sh
i1ww0OfHFYNVT56xjl5WsAJmXNFkzCcUkUyHMVyLa+nNEgASggvy9JrCgqONEtVd
4VLVsacz7Rc4vvqXivGx4wej5d6ZW8lZbUqr4gDiLyAGFLrK5dqREPkfsPYfTG/a
ae5DitNGUAymrZO0p3AJr19/K9OQMdxUIzCdb12aJn8/UdQMeQWcSSNUcAq0xKdS
VpcyFCtAQ5yzTDCqjsSTY+PuwUSaHffALPhr1qSagCy+wxvYAHMum/ibCNXJ/Ulc
HV125bJyE9hIc3kYCwm+RLWn4/YB9fsY/WBPN4xY29w9NH01qO0=
=WS3S
-----END PGP SIGNATURE-----

--=-Mmux09VRL6U11SgYb7G/--

