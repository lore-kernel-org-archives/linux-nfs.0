Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:40620 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751248Ab0HHE7c (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 8 Aug 2010 00:59:32 -0400
From: Ben Hutchings <ben@decadent.org.uk>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Steven Shiau <steven@nchc.org.tw>, 579397@bugs.debian.org,
        linux-nfs@vger.kernel.org
In-Reply-To: <4C33624D.2070405@oracle.com>
References: <4BF71C27.7070309@nchc.org.tw>
	 <1274492328.11828.3.camel@localhost> <4BFA99CD.2040902@oracle.com>
	 <4C0819C2.2020203@oracle.com> <1275769799.2870.107.camel@localhost>
	 <4C0FA7FD.3000301@nchc.org.tw>  <4C33624D.2070405@oracle.com>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-eU/A7ZuKfIiy4oCPRxrk"
Date: Sun, 08 Aug 2010 05:59:13 +0100
Message-ID: <1281243553.7543.281.camel@localhost>
Subject: Re: Bug#579397: STAT_FAIL to debian for SM_MON of 192.168.120.254,
 No canonical hostname found for 192.168.120.254
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--=-eU/A7ZuKfIiy4oCPRxrk
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2010-07-06 at 13:05 -0400, Chuck Lever wrote:
> On 06/ 9/10 10:41 AM, Steven Shiau wrote:
> >
> >
> > On 2010=E5=B9=B406=E6=9C=8806=E6=97=A5 04:29, Ben Hutchings wrote:
> >> On Thu, 2010-06-03 at 17:08 -0400, Chuck Lever wrote:
> >>> On 05/24/10 11:22 AM, Chuck Lever wrote:
> >> [...]
> >>>> We can probably remove the reverse mapping constraint for presentati=
on
> >>>> addresses. A simple fix might be to change statd_canonical_name() fr=
om:
> >>>>
> >>>> freeaddrinfo(ai);
> >>>> if (!result)
> >>>> return NULL;
> >>>>
> >>>> to
> >>>>
> >>>> freeaddrinfo(ai);
> >>>> if (!result)
> >>>> return strdup(hostname);
> >>>>
> >>>> Let me know if this works.
> >>> Any update? I have a patch ready for nfs-utils to fix this regression=
,
> >>> but I need confirmation that it addresses your problem.
> >> Steven originally had this problem, not me. Steven, do you need me to
> >> build a new package with this change?
> >>
> >> Ben.
> >>
> > Ben,
> > Yes, please.
> > Thanks.
>=20
> Any progress on this?

I've heard nothing from Steven but one positive report from another
user.  In any case we'll include this in our package.

We now have a git repository of the nfs-utils package at
<git://git.debian.org/kernel/nfs-utils.git>; currently our changes are
kept in a quilt patch series in debian/patches.

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-eU/A7ZuKfIiy4oCPRxrk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUATF45nOe/yOyVhhEJAQImthAAvmtIXEjCAVw2yN8IU2XwXUL4NzGpiZRn
fg3F4RowfhieyPrhD5NDMd8Ee13GGoFTz4jbWwNaqILVR/7MWI4i79jlOmaw89mD
iTn/rqWP5ntvWxfG7+jNQKpD24yRzvVQNOnrUWWuv7Gtv7L4vx2qWpCfgGxWzJfS
q9gBS9DDaHDb2XgUamPw2iKjIG0GQDML/qey699XXo4uxQvyoI5lJOvFpJxR+Byw
hr3O83pzRnoEbNXCFsJghHOYi3k4G+wJze4VlAP0IA/pKSquJJCyauRUltLS7dzc
sGO25LgUpVhHmuAhkl+2Y2rtUMUeHsIIv3p9eIhyiZr0PNqDQ3wjMCZd7F8g6R7t
K83HRifb+1JS1Pxq3AMZQEDmYx6YpIaqmpNf36FliTIhA7CPFUp+tjmeP1wZxghK
35OJWExFGuIveFY6IM//k3r3nO4BysYUyjNsZq6tQVhy3wzTw5xFCtiMyijEftwg
hkXNWZN4+MJUrz08Ivw0rcoHx+wd+9pscMq9HqwZhHWm+nSazPB+t44FD8LUA2Z+
W0ZMtJwK4/b6ZGLYe0movNju2KP1gbL7uJOJJEI+VfCKlbnkrJ2MDIy3qFPzGlE4
Attpsy7FF5Oj/GR8qnb5DYDmIrGF3qM2x+O1SfW3ZGJ65qigZJEGLt+Mewi8YU8s
gYh0VsVmDYw=
=LEjo
-----END PGP SIGNATURE-----

--=-eU/A7ZuKfIiy4oCPRxrk--
