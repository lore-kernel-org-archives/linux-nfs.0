From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [PATCH] make capabilities support optional
Date: Mon, 26 Apr 2010 12:46:58 -0400
Message-ID: <201004261246.59497.vapier@gentoo.org>
References: <1271753213-17374-1-git-send-email-vapier@gentoo.org> <201004240042.27705.vapier@gentoo.org> <4BD5AD68.6010200@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1634175.iQst6ALUvq";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:43468 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751451Ab0DZQpJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Apr 2010 12:45:09 -0400
In-Reply-To: <4BD5AD68.6010200@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--nextPart1634175.iQst6ALUvq
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

On Monday 26 April 2010 11:12:40 Chuck Lever wrote:
> On 04/24/2010 12:42 AM, Mike Frysinger wrote:
> > On Friday 23 April 2010 16:09:27 Chuck Lever wrote:
> >> "git log" has served as the ChangeLog for some time now.  The commits I
> >> referenced in my last e-mail explain exactly why libcap was introduced.
> >=20
> > none of the scm metadata is relevant to distro maintainers.  that info =
is
> > fine for developers of nfs-utils, but that's it.
>=20
> Obviously, that metadata _is_ relevant to distro maintainers, as your
> example shows.  The nfs-utils ChangeLog is an exact copy of the the git
> log (up to about mid 2006).  Why keep an extra copy?

it's trivial to include the full ChangeLog in the dist tarball without keep=
ing=20
it in git.  plenty of GNU projects are doing this already.

> However, as soon as a distributor sends patches (rather than, say,
> simply posting a bug report), you become a developer, and are thus
> obligated to act like one by reviewing the content of the local source
> management system before making changes, and by posting your patches to
> this list for us to review.

expecting anyone who sends a patch to be fully versed in NFS internals and =
the=20
full history is completely unreasonable.  i'm not saying people shouldnt do=
 a=20
little research here, but your position appears to be poor: if you want nfs-
utils info, regardless of who you are, you must go to the scm source and di=
ve=20
through mounds of history and divine the answer yourself.

> > people attempting to package nfs-
> > utils shouldnt need to crawl these backends to try and glean info
> > themselves.
>=20
> As I pointed out, you don't need git on your local system to look at
> this metadata: it's already available on linux-nfs.org if you have a web
> browser.

the interface is irrelevant -- you're still saying people have to dig throu=
gh=20
piles of information that is not relevant to packaging.

> >> Patches are posted on this mailing list for review before they are
> >> committed.  Anyone has a chance to object, comment, or suggest a simpl=
er
> >> way to do things.
> >=20
> > again, this isnt relevant to distro maintainers.
>=20
> How are nfs-utils developers supposed to know of a problem if distro
> maintainers don't tell us?

you're saying distro maintainers are expected to subscribe to the developme=
nt=20
list and review patches ?  that's bunk.

> I specifically asked on this list about libcap before adding it.  We've
> been discussing the addition of libsqlite and libtirpc as well, and I
> specifically requested feedback from distributors.  There was no
> response.  So how are we supposed to know these are problems?  Where
> else should I have asked this question?

create a list/alias maintainers can subscribe to and anytime you want to as=
k=20
them a question, cc that.  i used to be on the nfs list but there is way to=
o=20
much noise going through about crap i dont care about.  i'm not going to wa=
de=20
through it all to find the one e-mail a month that is relevant to me.

> I claim that "things" did not work.  When statd was shut down, it left a
> dangling rpcbind registration, and that's a bug in all environments.

perhaps, but some people are ok with that.  considering that has always bee=
n=20
the behavior then, ive never seen one complaint about this via Gentoo.  cle=
ar=20
documentation explaining the tradeoffs would be sufficient and there are=20
plenty of systems where this bug is meaningless.  on my nfs servers, either=
=20
everything is up, or everything is down.  there is no "in between" where so=
me=20
services are left running while others are not.

> If my bug fix is not complete or is inappropriate for some environments,
> then we should have a discussion about that.  It's pretty hard to tell
> what you were trying to address from your patch description

i already stated my logic pretty clearly in previous e-mails.  nfs-utils=20
provides no documentation, libraries get dropped in arbitrarily, so i made=
=20
things optional.

> (and that's all I have right now because the actual patch was never publi=
cly
> posted).

go read a mailing archive then.  not my problem if your client ate it.

> >> So, why do you want to make libcap optional?
> >=20
> > there are plenty of systems where privileges are meaningless (like
> > embedded) and so libcap is pure cruft.
>=20
> In that case, your patch description should explain that so we can
> understand why you've added another --enable switch.  These switches are
> overused, so a clear rationalization is needed when adding yet another.
>=20
> By and large, those who participate on this list felt that "--enable"
> flags are less desirable than automatic feature checking.  Your view is
> novel, I think.

the view of distro maintainers in this regard matters more than that of=20
developers.  the configure script is designed for the end packagers to use,=
=20
not developers.  my position here is not unique to me or something i pulled=
=20
out of nowhere.

> >> And why is yet another build option needed (rather than just using
> >> AC_FUNCTIONS and HAVE_LIBCAP) ?
> >=20
> > magic detections are terrible for distro maintainers and one of the
> > things we spend a lot of time fixing.
>=20
> nfs-utils uses autotools, so that's what we have.  How else should it be
> done?

i already told you how and posted a patch: a proper configure flag should=20
*always* be used to control optional non-C library linking.
=2Dmike

--nextPart1634175.iQst6ALUvq
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iQIcBAABAgAGBQJL1cODAAoJEEFjO5/oN/WBrxIQAIjNoEB9VQpgfDF8U/1B43Zm
CmFpr8vWFo4zUuIYR+x4ua9Eg/rSQOTZ/rTB0VQL9qJT0vNZhPFqXfehgR497I1U
qQ5HA3XlLt0BHgXd6o3i47ZwPL+MJt5uBQ+vc5jAR0t61NLlfF7Qq2pp1cDKGSJ/
VFLR1s+QUXnLdpSNoNnrgdUrDB2D3DCWGM9ocs+OcrrkBrqfOoHqQwY3ZuGj4lIA
wpaCyarxeMu3zRqOmI8afMIpFRHSMfBptcJ+xnYDCtg4jgut5RMmS9vlsJR7a4J2
fabi5IZ0qULPk/2lxbifJmPJ5qfMCz0sSVXAoH9DWTHONm61EqrP1RQgKqxFV9CY
yTQ0Yq052nzHNuCKql04UisuUQKCiAPpbkGYddicXRlm/ad9hq1MuR6AAXSJsmZ5
UWxNU7eQqOFnwYPG8vPNOT2LeJh4NRQ/DFbz6K11xyFksUnzv7jRPKdEiJTeP7Pw
aSSKIG7bzWFTD6S+hmKclPGIBk8VAr/4enSeC135Z3cywkIRwRU+XBp6STR0PkFa
10xQ0nnOHhxZB/qGKBkf+VhKADLdbWeKFhDf3d02ejdT536gab/d49G5bVMFu3bL
zt08J1+nocci9Swe9rW8fvnsC33mc4k44WEpNSgNLJN679KpNxs3JpIepsgdm0Wh
mH479/ShekOccLAgMLLg
=1eFj
-----END PGP SIGNATURE-----

--nextPart1634175.iQst6ALUvq--
