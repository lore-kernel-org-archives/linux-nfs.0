Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:37367 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753228Ab2ANAz6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 19:55:58 -0500
Date: Sat, 14 Jan 2012 11:55:46 +1100
From: NeilBrown <neilb@suse.de>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, trond.myklebust@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 43/44] NFS: Export functions needed by a v4 module
Message-ID: <20120114115546.1ec4273a@notabene.brown>
In-Reply-To: <4F109C99.7030809@netapp.com>
References: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
	<1326485453-1350-44-git-send-email-bjschuma@netapp.com>
	<EA1EBEFB-A2C7-4696-B32F-BE83B4871E52@oracle.com>
	<4F109C99.7030809@netapp.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/GQCxMIeP2Xt5wY3Yg_guBAA"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/GQCxMIeP2Xt5wY3Yg_guBAA
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Fri, 13 Jan 2012 16:05:29 -0500 Bryan Schumaker <bjschuma@netapp.com>
wrote:


> >
> > It seems like an enormous amount of code movement.  Isn't there a way t=
o accomplish modularization without moving things into separate directories?
>=20
> Not that I know of.  I found examples for compiling directories as=20
> modules, but not specific files or parts of files.
>=20


You can definitely compile specific files or small collections of files into
modules.
See for example drivers/md/

In Makefile

  obj-$(CONFIG_FOO) +=3D foo.o

will make a "foo.ko" if CONFIG_FOO =3D=3D m

If you want two .c files to make a modules, then

  foo-y :- foo-top.o foo-bot.o

  obj-$(CONFIG_FOO) +=3D foo.o

will do the trick.

Compiling parts of a file into one module and parts into another - while
possible - would certainly be frowned upon.  Definitely split such files up.

NeilBrown

--Sig_/GQCxMIeP2Xt5wY3Yg_guBAA
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBTxDSkjnsnt1WYoG5AQLbxQ//dX3G6TKFLoXwEHAONZ8MHMhFNBsDvCB3
Z2rXxV+sBmgcY4eMUiA7Ogx9kFiU8aeTpJEa2N97D6P4S0EdU1SYTuCbCtjMhtm7
uWfo/OUvTTYu/rS1ZUbjdFQAL7hw89aa7+gqqu6bjRVZhDb4fvoK+xNxuYEc0oLl
CrMq+iudHWwhxRI2ojx1/TPdZLsg/3Te04d5QpVk0akGcpZqEl3QlejRyuHP4sE6
T6JaVch6CwXg2HR83v8tUy0SJZiuniwUrLaaLZ1ZJ9x+SmOeRwCu3fgQxvssKhrR
cDZ7glsVdm0hYD7NLWFMN67MNrlckttkZJ3t3L6KmYrVkkYHc8yyMcIArofDjcmS
jHXMk+Z35lizShPN+rmS/zZZBvt3lpzRxiciaLxG1cq4ELTodSQBhZLMCwIYJo2f
CfLhGxKNMag8RRmT6lYXSb7Ql/hHmfXxOOcWPOFDfOyBk5Tuj6adze9qNsfo1e0z
wbC/kuZBPoDkUMHSB3/Z9N4AvEok68a8u5GF28VtsSAMgHj/2Q60N6kWMORYv7dG
NOgtnMlmW3IZF4dXaUG9wQhkgzhAZWxhwSPYzhcbt/9M9NC2wUVESRNb4Y3bGVrZ
tq7Q9SNNO7iMwBwcfx5Z3+3gKB5qRAItdQFqfCoDTKWEO2TN+oIA8xdrLv6UgDTo
ZOXuVMNdSFA=
=OgrH
-----END PGP SIGNATURE-----

--Sig_/GQCxMIeP2Xt5wY3Yg_guBAA--
