Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.gentoo.org ([140.211.166.183]:36320 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755666Ab2EQQIO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 May 2012 12:08:14 -0400
From: Mike Frysinger <vapier@gentoo.org>
To: Jim Rees <rees@umich.edu>
Subject: Re: [PATCH] osd_login: fix DESTDIR install
Date: Thu, 17 May 2012 12:08:40 -0400
Cc: Boaz Harrosh <bharrosh@panasas.com>, linux-nfs@vger.kernel.org
References: <1337232243-18088-1-git-send-email-vapier@gentoo.org> <4FB4ECDA.2080506@panasas.com> <20120517130925.GA10380@umich.edu>
In-Reply-To: <20120517130925.GA10380@umich.edu>
MIME-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3046833.Sm0D6MDraL";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Message-Id: <201205171208.42226.vapier@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--nextPart3046833.Sm0D6MDraL
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

On Thursday 17 May 2012 09:09:25 Jim Rees wrote:
> Boaz Harrosh wrote:
>=20
>   On second thought, You know, I'm not sure about this fix.
>=20
>   A lot of times we install to a side folder, so we can later
>   tar and package the sub-folder without actually affecting
>   our live system. What will happen with the packagers that
>   are not RPM don't they rely on this?
>=20
>   I would like to let the user to install nfs-utils on the
>   side and to not conflict with the running system. Someone
>   how knows what he is doing can override the Kernel path
>   to what he wants. Just as he will need to override the
>   nfs init scripts.
>=20
>   So I would prefer if we can just create the $(DESTDIR)/sbin/
>=20
> I think the makefiles already create $(DESTDIR)$(sbindir).  The problem w=
as
> that you weren't using $(DESTDIR)$(sbindir), you were using
> $(DESTDIR)/sbin.  The patch sets $(sbindir) to /sbin, so everything should
> just work.
>=20
> But I could be wrong, automake is a black box to me.

i don't think that was the issue.  the osd_login dir wasn't telling automak=
e=20
that it was installing anything (whether sbindir or /sbin or anywhere else)=
,=20
so this makefile didn't create the destdir automatically.

now that automake knows we have things to install into $sbindir (regardless=
 of=20
its value), it knows it has to create it before trying to install things.

it might have worked in the past for people because either (1) they didn't =
use=20
DESTDIR into an empty path or (2) they weren't running in parallel so the=20
other subdir (that installs `mount`) took care of implicitly creating=20
$(DESTDIR)/sbin for them.
=2Dmike

--nextPart3046833.Sm0D6MDraL
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iQIcBAABAgAGBQJPtSKKAAoJEEFjO5/oN/WBClgQAJbTOQefkRKmJwPmT/6W8l3w
dsZMJA+pTajSsLIP51z8uv47lQ3GXKDi/AvjRSNnNfhlHc7w9Rg/OneneXtP7o/4
2NTrsi7leCuJxuV8KBf9sGC3BQrOwXV30ocqkpfmLGi47xL9jZ6+AIcbWpAxX7if
bhqaZlKwEDMFNJ2koV5uhN408M7rNEA0UosILxyLjT7+mI8dwzMQa9bsnFN+2yO6
mdUe+1ZQNwSqQnJv8LzWio8F43/rsHT3AVD3yrSMzy3+7CVulqO/+hIlxxNwxYZR
b/+fqh4+7t4l9/8vMut9WatkKp2WKQ9quca6B/tal4WjizY2xVzXb6451kYwFUE0
LMzyy3AsYzmVvMr3hC7Sf/rBc7KMbp1um/dwOCD6WoM9fFYKRa0nMGwGEfrH2oLh
6nLE+yLRliuQk7yY7SWnEasCi73YjbxNGb7aCYKv1RcgfzU92cwNQHBoe0XuQ+f+
Vgr1SMeDZJyLZDJ4xh9VrVzO5IoB1Mr5AGuUgfhlJewyAuDUY6iwp9+MyLrDyG1V
dkt/99r1FfuIwRxDx5PkMnlAyr6ic3mNW84a2OHiGxl3HG8z0ZGntF4n7vBwtoEk
XfUOSykW7aVMe7BClivRkPhPP00Sxu/yjnUiF+zBhHtH4/BzcY947EJE3p8SxaZN
p1bsywma6cxzeRjKmEsQ
=8SxU
-----END PGP SIGNATURE-----

--nextPart3046833.Sm0D6MDraL--
