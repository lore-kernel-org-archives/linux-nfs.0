From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [PATCH] make capabilities support optional
Date: Mon, 26 Apr 2010 12:51:11 -0400
Message-ID: <201004261251.12210.vapier@gentoo.org>
References: <1271753213-17374-1-git-send-email-vapier@gentoo.org> <4BD5B013.9060705@oracle.com> <4BD5BAD8.5040209@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2087435.BgKUE38yDX";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:37258 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751947Ab0DZQtU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Apr 2010 12:49:20 -0400
In-Reply-To: <4BD5BAD8.5040209-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--nextPart2087435.BgKUE38yDX
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

On Monday 26 April 2010 12:10:00 Steve Dickson wrote:
> On 04/26/2010 11:24 AM, Chuck Lever wrote:
> > At the very least, I think the man page should mention this bug somehow,
> > and maybe a warning should be generated during the build.  Since this is
> > mostly for embedded systems, according to Mike, I doubt an actual
> > generated run-time warning would be visible to anyone.
>=20
> Mike would you be willing to test this out and document any
> differences in statd behaviour with and without that config
> flag set?

i think a BUGS section in statd is sufficient, but if you wanted to go=20
further, then a simple syslog() would be OK as well.  dumping warnings to=20
stderr/stdout is obnoxious and non-standard for daemons.  those really only=
=20
should be written when a daemon is quitting due to misconfiguration.

i can send a patch for the man page, but i'd only copy and paste what Chuck=
=20
wrote (about statd remaining registered upon exit).
=2Dmike

--nextPart2087435.BgKUE38yDX
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iQIcBAABAgAGBQJL1cSAAAoJEEFjO5/oN/WBffIP/0QLAk0p/RBw9ssf6SsLi7jP
FgOJ0sXUmyqQdHupD1gxPT/t3XUamknScUcNsJyRJ9CICXqwi2nWBbKSRe7hruqx
G+LSHxgu6/+zDBCdflc42YQIgkcmT5SbCU6ZdNhL6iqcv2aF54beNmraqRoiMWzr
pCMRrJYR3hbalOgMkh1m5ZQ+Om026VTt8lU4Vp24LJw9NfjGTBOS64mT3kSI4YWV
DmTtf3WQSzUF9nhJmF34+IynO+E6OJvFBykmcrysFqlbjtnKjQf6UCUcaw36kijl
xhesZaGFjqDoWcwK4GWl2uLz8ySoqcqk+pKg7plsZ+Zpo/6DvPDTZgcLKZre88AU
fjNB+DeABd/WkAedl8DNStT8nU7Rpp7IRBHcWB4ADoK+pz9mW4lBaLQeIqHvljqY
E04veZlylwKTIT4m83fAqavFU7AZNICSkS96p/vXy5lhntQTStJ+RJz8ZLNDni3E
lfU+5g7AgS4fGofycO4cYTtLeRZz3m6wuF3Uu5AfGl/NYF0REijFbwv+NcMS1fTZ
1JvIHf6E2NzgJuM2CJd+EcgRQrvwOTyn2+Q9qYgSTOMDTEB3l4r5XE6MWlDi5BBk
vwua/tgFOQhShP3m+LQPyfrfAqURZZN9BaKGwZiWImHLQkt0noKbeEHbohwmiy3E
1URpVp42X+jaFN6Y57iu
=D5JR
-----END PGP SIGNATURE-----

--nextPart2087435.BgKUE38yDX--
