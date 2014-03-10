Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:51799 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752090AbaCJA5H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 9 Mar 2014 20:57:07 -0400
Date: Mon, 10 Mar 2014 11:56:59 +1100
From: NeilBrown <neilb@suse.de>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: David Heidelberger <david.heidelberger@ixit.cz>, linux-nfs@vger.kernel.org
Subject: Re: DNOTIFY to INOTIFY migration
Message-ID: <20140310115659.098a7c06@notabene.brown>
In-Reply-To: <20140310002015.GH18016@ZenIV.linux.org.uk>
References: <b59b1e4ede0b1d0a476c85465d480c8a@ixit.cz>
	<20140310102102.3c886726@notabene.brown>
	<20140310002015.GH18016@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/6cqoXkD=KijVPRsuvA=4+fL"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/6cqoXkD=KijVPRsuvA=4+fL
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 10 Mar 2014 00:20:15 +0000 Al Viro <viro@ZenIV.linux.org.uk> wrote:

> On Mon, Mar 10, 2014 at 10:21:02AM +1100, NeilBrown wrote:
> > On Fri, 07 Mar 2014 21:30:34 +0100 David Heidelberger
> > <david.heidelberger@ixit.cz> wrote:
> >=20
> > > Hello,
> > >=20
> > > in linux kernel is DNOTIFY actually marked as deprecated, with superi=
or=20
> > > replacement INOTIFY.
> >=20
> > Where is it marked as deprecated?  I would be very surprised if dnotify
> > wasn't supported indefinitely.
>=20
> Unfortunately, it will be - once it's in, it's in.
>=20
> > (I have no opinion on whether rpc.idmapd should be changed to use inoti=
fy,
> > except based on the "if it ain't broke, don't fix it" principle).
>=20
> I still don't understand WTF does rpc.imapd *want* either of those, TBH.

The rpc_pipefs filesysem which is mounted on /var/lib/nfs/rpc_pipefs creates
new channels for talking to userspace by making new pipes appear in some
directory.  Any client needs to arrange some notification for these new pip=
es
appearing so that it can open them and hold a conversation over them.
This calls for dnotify (in gssd and idmapd) or inotify (in blkmapd).

NeilBrown

>=20
> Said that, the original posting does read a bit like "herpes is so last c=
entury,
> shouldn't we upgrade to clap by now?"...*0O(and I don't want to think what
> that makes fanotify, thank you very much)


--Sig_/6cqoXkD=KijVPRsuvA=4+fL
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUx0N2znsnt1WYoG5AQIefA/+IHtPqGPcP3wBX6LSm5TgokbWc1EOWi09
QDaBHVW5JBXvmqmN9HhaOdJsO3+MbXivmEndNUc0EoLjEn8jLFdx1BSl6ZdMdjhU
lvclrDIY/XFX+++VfnlLq8m3Xn2BuIF6RFded4ZVxWyIXV1u4pIYZDnGa0FG+n3r
J/2dx+/Vfwe6rUplD+Gce2RSTbbANGu6Ykp/LtvDj/bHApxz9kxOx7HSCiVznbUT
mSG9uOo+DJ4KRSpn1jbWqNn9GPeEFBCjDwEYyTMv9FG72/85ZYT1er8zCyOfAeTF
88J2lbkkk8Z9oiWg/DI9LtLBRDje6A1WejUJlUVdgdRICLZidLzh2GcurXSi7Dq1
dQwXEftjYPiRFB1guVNinUEP3oJMaz/RevjzhJH8UZvVsjls/VXMWxguWlVFngM/
8XenPi9pPI6Onjt/5uLoK4RIQIfROgic9GgwZaTaY73FKlJLTn5ZmBq/ifBwT6H8
/q+yscMERIHIWurb9aqSY6gmq/rjgsOo203ndLxWXIIZNf5KDsiXfJkZ3xEckIP9
Y2AYhDGKEgja4cjjNWLgvoMLlfSEKnI7lwSUYCKmEbWAakac5T0KN9tCTnbVrmnf
z/X782JFaVL1ZnOo3N8ZAu2qRtMq6GGG68/4yq5eMA8hxf+7DqXJRUwTK4lBlO/L
3x43K0Unrk4=
=hwMp
-----END PGP SIGNATURE-----

--Sig_/6cqoXkD=KijVPRsuvA=4+fL--
