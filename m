From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [PATCH] make capabilities support optional
Date: Sat, 24 Apr 2010 00:42:26 -0400
Message-ID: <201004240042.27705.vapier@gentoo.org>
References: <1271753213-17374-1-git-send-email-vapier@gentoo.org> <201004231529.42370.vapier@gentoo.org> <4BD1FE77.1050000@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1573647.x3AmUj6LEG";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:50246 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750993Ab0DXElS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 24 Apr 2010 00:41:18 -0400
In-Reply-To: <4BD1FE77.1050000@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--nextPart1573647.x3AmUj6LEG
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

On Friday 23 April 2010 16:09:27 Chuck Lever wrote:
> On 04/23/2010 03:29 PM, Mike Frysinger wrote:
> > On Friday 23 April 2010 15:12:33 Chuck Lever wrote:
> >> If we really do need to drop libcap for some configurations, then such=
 a
> >> change should be thoroughly tested in those environments.  Some featur=
es
> >> won't always work without libcap, and appropriate warnings should be
> >> added to man pages and/or should be displayed by statd.
> >=20
> > there should be appropriate documentation regardless.  current nfs-utils
> > lists no information at all in ChangeLog/NEWS/README/INSTALL or any
> > other document explaining why/what/how libcap is needed/used.  you cant
> > do documentless dumps on distro maintainers and expect them to "just
> > know" what is going on.
>=20
> "git log" has served as the ChangeLog for some time now.  The commits I
> referenced in my last e-mail explain exactly why libcap was introduced.

none of the scm metadata is relevant to distro maintainers.  that info is f=
ine=20
for developers of nfs-utils, but that's it.  people attempting to package n=
fs-
utils shouldnt need to crawl these backends to try and glean info themselve=
s.

> Patches are posted on this mailing list for review before they are
> committed.  Anyone has a chance to object, comment, or suggest a simpler
> way to do things.

again, this isnt relevant to distro maintainers.

> It's important to realize that it's much harder to make things optional
> than to insist that they be built in.  Adding build options means
> there's more work for distributors to configure the build, and it
> exponentially increases our test matrix (which is already out of
> control).  Every change now has to be tested with each combination of
> build options.  Add one more --enable option, and that doubles the
> number of combinations.

hardcoding optional features in autotools is worse for distro maintainers t=
han=20
proper optional configure flags.  dont kid yourself in this regard.

> I didn't see a clear explanation of why your proposed change was
> necessary, nor was it clear from the patch description that you
> understood why libcap was added in the first place, nor does it seem
> that the regressions caused by disabling libcap are adequately addressed.

things worked before libcap was introduced, so clearly it's possible.  it m=
ay=20
be reduced security footprint, but plenty of people are fine with it.

> So, why do you want to make libcap optional?

there are plenty of systems where privileges are meaningless (like embedded=
)=20
and so libcap is pure cruft.

> And why is yet another build option needed (rather than just using
> AC_FUNCTIONS and HAVE_LIBCAP) ?

magic detections are terrible for distro maintainers and one of the things =
we=20
spend a lot of time fixing.
=2Dmike

--nextPart1573647.x3AmUj6LEG
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iQIcBAABAgAGBQJL0nazAAoJEEFjO5/oN/WBeX4P/RR19evG6tOSu4f4gAZrmnln
MuesOAEwvre5mDqXlSyA1nVaUSrFFoZSRiq7aQWYm4c9T8dh/ovu5rr5nKUzZ2IM
XSzo0NSOrH4ghhMUWa+322VpGWeXVEa0KfifqEVdGnJwxJY814oPq1s4UAs5gusm
ySEzrJoDtf1vs06L3NkOmZU2M9YQXM3M3NUI0LeVIMO+80osA9OChDIQpKaWYveW
pfoBngWMVg9h5BE3AsAsVv2gX+/jukjUcR+4nyRXYvUaixtDBy2UXFv0xyCXirhQ
CsIBFwu76V62DiNWpG1FxMu4jl2wSEdGiOJYZU9PEb4iHWuFOuPclKNNsjxl8BrI
CTkDMDVC6v/gotQwgYctCEje75yI5FJTWIDTnw2+OjTi5bJTLJQznaCXlNjKGcs2
mhbLUvJfvNZgBxIRY+EM8lzkX3EZpn/yRQ9oWG6KMfwFvEagBGolBQqjImENphFN
AggnyLtRQE+6cTgEtccfTspyLAyFHJfahyaaQBAOhhoNOPxABD66ELC8bUCidLzi
Rob50Pa7cAkYKXYGFzfeIIywBYKworaNPCNihhTCiQ5G1uCe8diwm69SW/KZjHoP
HQiVyYIreV+P7r6fnJOcdYZVqsmR96pSL5vmQRXjdl7CQPvFtjbAk3ltueE1HSwS
tUD7SVFMmsg52sD/PRj+
=LauP
-----END PGP SIGNATURE-----

--nextPart1573647.x3AmUj6LEG--
