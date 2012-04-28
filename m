Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:48847 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753102Ab2D1Lrd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 28 Apr 2012 07:47:33 -0400
Date: Sat, 28 Apr 2012 21:47:26 +1000
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 0/3] Fix use_ipaddr race
Message-ID: <20120428214726.1742c905@notabene.brown>
In-Reply-To: <20120428112639.GA22396@fieldses.org>
References: <1334961978-2843-1-git-send-email-bfields@redhat.com>
	<20120423110419.1311c364@notabene.brown>
	<20120428112639.GA22396@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/Hq6M1UDyw1utNLBm1gu+0Z0"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/Hq6M1UDyw1utNLBm1gu+0Z0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sat, 28 Apr 2012 07:26:39 -0400 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Mon, Apr 23, 2012 at 11:04:19AM +1000, NeilBrown wrote:
> > On Fri, 20 Apr 2012 18:46:15 -0400 "J. Bruce Fields" <bfields@redhat.co=
m>
> > wrote:
> >=20
> > >   mountd: unconditionally resolve ip address
> >=20
> > Not a good idea.  If /etc/exports only contains IP address and subnets,=
 then
> > we don't ever want to do any address resolution.  The "resolve ip addre=
ss"
> > must at least be conditional on "are there any domain-name, wild-cards,
> > netgroups in /etc/exports".
>=20
> The bug is my changelog.  All we're really doing there is parsing the ip
> address, not resolving anything.

Ahhh. I see that now.  Thanks.

>=20
> ...
> > >   mountd: ignore use_ipaddr and just try both client types
> >=20
> > Maybe ... though if we could syntactically distinguish "use_ipaddr" dom=
ains
> > from "!use_ipaddr" domain and still just choose one test to perform, I =
think
> > I'd prefer that.
>=20
> Hm, OK.  Something like the following?  (Totally untested.)

Yes, that looks good.

I could probably bike-shed for a while about the leading '?', and wonder if
'!' or '$' might be better choices, or if leading '[' and trailing ']' is
best but I won't.  He who writes the code makes the choice.

Thanks,
NeilBrown

--Sig_/Hq6M1UDyw1utNLBm1gu+0Z0
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBT5vYzjnsnt1WYoG5AQKjTRAAi3biAkMZjZgOC6pfEo9qAoOx7noYz+XG
Wr2w0JYJ5k3W5izoHOr6X7015ITZ8ZlXzddBt3eCzQaT3p858Dhoxmmj2ZNRi0GB
xvDO8OyCeNKW9ynH87/aJQsE8Qk4aWONaDFFyWSwSL8ULvXuexszCtcAqsHganPu
tJgWnxNav6yZxG9BqUEtY51O6cN1Ml2bthY9VhhvU93k3TeUkepzSodbWfOZ+joC
xXckny9gybgYuW/yLJ9Vv6cx8y901tfdIhS7pso/0wXEqvF4//bIygBTFSsPqFi0
g94WyTRjebYOXUhhAc0wW3EWWLESppF+is4XBhtkKHcWQge/L78D8noJCrgMftPX
GDwiNgE6r7+2SaKhWvFBrWcwVmMAYVEO0GRAEJZYqe489pb/Mh8arjXzcmeSVP5h
aEsRf4Lk5xRItpPLRJPFpG8+tiQlSN3Gm28n30ocr56SasVygjAK2dD4VmBHCVsf
fF31LGm0yzSuslwjCSaborw3G8xdbffkO7HRBnpXxPZUK0ihN3ItZbU4GwHUh2W2
1IuPq2Htm4Q/v9+U7EAeKje8x89SDXfxYySXFYYUCCtSkp3a/LnfRRFAeHAEBjrP
R7qCyfciXV0T0waYK+xbi97ymDgYC+5dgb1HsTAVBJPnN4HxqFj0d/6jR709mTMl
5JOhnyptDLU=
=id3+
-----END PGP SIGNATURE-----

--Sig_/Hq6M1UDyw1utNLBm1gu+0Z0--
