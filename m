Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:46665 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750940Ab2EOEG7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 May 2012 00:06:59 -0400
Date: Tue, 15 May 2012 14:06:46 +1000
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: ANNOUNCE: nfs-utils-1.2.6 released.
Message-ID: <20120515140646.554c378c@notabene.brown>
In-Reply-To: <4FB159DA.2070800@RedHat.com>
References: <4FB159DA.2070800@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/_52BPj3bUPw7JwEl26FJuUk"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/_52BPj3bUPw7JwEl26FJuUk
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 14 May 2012 15:15:38 -0400 Steve Dickson <SteveD@redhat.com> wrote:

> New Features in this release:
>    * The addition the nfsdcld daemon
>    * The addition of the osd_login script which is mandated by the
>          pnfs-objects standard
>    * The addition of -l option to rpcgssd to enforce legacy behaviour
>=20
> As well as the usual assorted bug fixes... =20
>=20
> The tarball can only be found at Sourceforge.net since=20
> still unable to access ftp://ftp.kernel.org (I'm working
> on it):
>   http://sourceforge.net/projects/nfs
>=20
> The git tree is at:
>    git://linux-nfs.org/nfs-utils
>=20
> The change log is also only on Sourceforge.net:
>    http://sourceforge.net/projects/nfs/files/nfs-utils/1.2.6/Changelog-1.=
2.6/download
>=20
> steved.
>

Thanks Steve.

I noticed that the "default download" was still 1.2.5.

I wondered why and eventually found this:

https://sourceforge.net/apps/trac/sourceforge/ticket/20991

So I took the liberty of making the appropriate change, and now the default
download is 1.2.6.
I hope that's OK.

NeilBrown

--Sig_/_52BPj3bUPw7JwEl26FJuUk
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBT7HWVjnsnt1WYoG5AQKMeQ//ZJpHI1SNrmDzaGCiFCmPUWJMofyjR0MI
aN5U2NI42tNQoXjMdBAP+tQBPmjQAc2PWFKP1dfZYy9S9DbDVgk+7UvRUJ09gsGp
bavjdfMnKSXmaoZRoVD7eYYJvxGgkruQfHmzlV1gS0rOD6cIXdwzTBs9HUuGOOU7
etiq+3wYBFeCRELFEDSJlkSB36HVUicxnq2NptrbmVu3nJe3m7VTgFWo0luEzLpo
Iub7T/5IxxUtK/UsgyF+J3qs14m1iF4bdbn0Qxg8ad5B6wt5Jek7OBdi4dwx1vUi
nWSyBIjzxaGUN4YbvL0pHMqZ3muDwPfV5boUBPeotVndIHyKlAt4/OvGoKyyPsIo
Ify3E14SKgx2sf0C8zDeEZtHcms/c7gCGunVC539u9zmK9CJoF/3ccXIf9srqGxh
KZhujVjzGBPByOGX2gXu4VLDAXdrCxNUYhgnHjgeuZjntlRtyL1Ze0oEi26qx3wU
5AfpSX9GqSyIfPKXc6rQj25uok0Kn4bcv5oR06A+/s38FTb58W9B8drl5L2Fk4xZ
U+AG8qRzpCDIqcYVM3fKH3mgDLjf8e2pg7wMY4vQQ9IuHGQ4Lmc++DciLJEXMFB/
hdVgilxaCsqZ53jCuFK1n5TUTLJkcxgqtO2QBeM6zP8YLa3MSGrLJ89//KvTKzyU
10OyrHf0biY=
=lGY8
-----END PGP SIGNATURE-----

--Sig_/_52BPj3bUPw7JwEl26FJuUk--
