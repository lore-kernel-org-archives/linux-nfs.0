From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [PATCH] make capabilities support optional
Date: Fri, 23 Apr 2010 15:29:41 -0400
Message-ID: <201004231529.42370.vapier@gentoo.org>
References: <1271753213-17374-1-git-send-email-vapier@gentoo.org> <4BD1E55B.2090703@RedHat.com> <4BD1F121.1060001@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2711601.59qovGvnsZ";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:33878 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750818Ab0DWT2k (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Apr 2010 15:28:40 -0400
In-Reply-To: <4BD1F121.1060001@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--nextPart2711601.59qovGvnsZ
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

On Friday 23 April 2010 15:12:33 Chuck Lever wrote:
> If we really do need to drop libcap for some configurations, then such a
> change should be thoroughly tested in those environments.  Some features
> won't always work without libcap, and appropriate warnings should be
> added to man pages and/or should be displayed by statd.

there should be appropriate documentation regardless.  current nfs-utils li=
sts=20
no information at all in ChangeLog/NEWS/README/INSTALL or any other documen=
t=20
explaining why/what/how libcap is needed/used.  you cant do documentless du=
mps=20
on distro maintainers and expect them to "just know" what is going on.  thi=
s=20
isnt the first time the nfs related packages suddenly started requiring new=
=20
libraries out of the blue when in reality things could be done optionally, =
nor=20
is this the first patch ive sent to try and address what appears to be=20
unnecessarily hard deps.  kerberos readily comes to mind.

i'd point out that from a distro POV, the DAEMON section of the top level=20
README is single handily the best thing added in a long time.
=2Dmike

--nextPart2711601.59qovGvnsZ
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iQIcBAABAgAGBQJL0fUmAAoJEEFjO5/oN/WBy1IQAKwCYJ13WJRbKN8SNFfjDKgI
baPUO+0DrygGnsJontL5JMeOeBsajvjrId+U8aMLAkfUZYT7vCE1Fe2sz6hsvPWk
sa/EIUeRZR1fbWHQlvnr7PQziXxy9cNK/Gg2rWzMOWL4cY1twZRYqXozMPmGjVkC
xLJRYLb7OtnP+oS34fV9ZuuvGYz2eGcyo9G0NhkYGu3npzSovY8h1ogSvK1Ja7VW
dVP9q8xS7gKEOmfOLt9IRrfUYBUsT5jGeo4j+Zy69Uza8CHk/jmKl5brHEWp+jUr
Tzyu7Pp6b1lqAsFGUHnAaQowPoiWvgy8zD7UpKGxeWYv+6sUr3ZRTOmcwf3EAE6q
fxGL6pA38VZct1vG/IDc7bpIo5GsWrCb1AvflRBqdkCRDt9ZX26w3loP8WBpteR9
WdEJ5meSWRGb4le1blu7q7RFjVc9n1+YwB2PurVCYhKx9n68vyga7p6yT0FM74Ab
+9iKEaIQlHIn5eobfJ4RPN5g91ts+oGlUDXFs9D7Fpr6ZXImdjSMnA9ArVpFazll
wH6Qk7Xmvx7ATlhbBjznxyDwbaJTTj7no7x7MkUUO7WNDNJnfwIAH72D0WcqRMqQ
F/3iJbdsUiAnLcQOX4lsO8lmvK9uS0iiJwZdX2WFbxaPFiStMM3Po0BmoBjytFkq
97+Z9PECtvmbSCBTWaBn
=kfGP
-----END PGP SIGNATURE-----

--nextPart2711601.59qovGvnsZ--
