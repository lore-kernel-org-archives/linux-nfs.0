Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from laas.laas.fr ([140.93.0.15]:39551 "EHLO laas.laas.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752602AbdAEO6x (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 5 Jan 2017 09:58:53 -0500
Received: from paperthin-usb.laas.fr (timmy.laas.fr [IPv6:2001:660:6602:4:6600:6aff:fe90:be61])
        by laas.laas.fr (8.15.2/8.15.2) with ESMTPS id v05EOdw6010928
        (version=TLSv1.2 cipher=DHE-RSA-AES128-SHA bits=128 verify=NO)
        for <linux-nfs@vger.kernel.org>; Thu, 5 Jan 2017 15:24:41 +0100 (CET)
Date: Thu, 5 Jan 2017 15:24:39 +0100
From: Matthieu Herrb <matthieu.herrb@laas.fr>
To: linux-nfs@vger.kernel.org
Subject: problem with open(name, O_RDWR|O_CREAT|O_EXCL, 0666) on NetApp
 servers
Message-ID: <20170105142439.GB9922@paperthin-usb.laas.fr>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="cvVnyQ+4j833TQvp"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--cvVnyQ+4j833TQvp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

After upgrading my machine to Ubuntu 16.04, I noticed that 'git clone'
started creating files with wrong mode (0700 instead of 0644
typically) on NFSv4 partitions mounted from our NetApp servers.

I've first tracked this down to the fact that git uses=20

 open(name, O_RDWR|O_CREAT|O_EXCL, 0666);

to create files. If O_EXCL is not present, the files are created
normally.

I've tried various kernels from Ubuntu and the problems appeared
between their 4.2.0-42-generic kernel-image (as found on willy) and
the 4.4.0 kernels found on xenial. I tried building 4.9 from
kernel.org and the problem is also there.

I've then bisected the kernel to figure out that this is caused by the
following commit:

https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=
=3D5334c5bdac926c5f8d89729beccb46fe88eda9e7

ie NFS: Send attributes in OPEN request for NFS4_CREATE_EXCLUSIVE4_1

Our NetApp filers are running:

NetApp Release 8.2.3P3 7-Mode: Tue Apr 28 14:48:22 PDT 2015

Any idea on how to fix the problem (either on the NetApp side, or on
Linux kernel side)?=20

Appended is a small program to reproduce the issue:

Thanks in advance,

#include <sys/types.h>
#include <sys/stat.h>
#include <err.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

/*
 * Demonstrate file creation bug on NFS v4 and linux kernel 4.4+
 *
 * mktemp() is used on purpose.
 */
int
main(int argc, char *argv[])
{
	const char *name =3D argv[1];
	char tmp[] =3D "./tmpXXXXXXXXXX";
	struct stat buf;
	mode_t expected;
	int fd, i, n =3D 40;

	umask(S_IWGRP | S_IWOTH);
	expected =3D 0666 & ~(S_IWGRP | S_IWOTH);
	if (argv[1] =3D=3D NULL)
		name =3D mktemp(tmp);
	for (i =3D 0; i < n; i++) {
		fd =3D open(name, O_RDWR|O_CREAT|O_EXCL, 0666);
		if (fd < 0)
			err(1, "open %s", name);
		memset(&buf, 0, sizeof(buf));
		if (stat(name, &buf) < 0)
			err(1, "stat %s", name);
		if ((buf.st_mode & (S_IRWXU|S_IRWXG|S_IRWXO)) !=3D expected)
			printf("%s: %o\n", name,=20
			    (int)buf.st_mode & (S_IRWXU|S_IRWXG|S_IRWXO));
		else
			printf("%s: ok\n", name);
		unlink(name);
	}
	exit(0);
}
--=20
Matthieu Herrb

--cvVnyQ+4j833TQvp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUBWG5XJ2hzk+430Sj4AQIESw//TLVlw9zUeLkN7J9Cshww6uTRjgF4P0RO
JO9E1aXXa5lDqOO0GPMlUiegBY/4/rIQyd+0CZJcx+b4mWWHtU+gV95u02fWd/q0
dLo6hSNy7ZkbIs+T4Bq+Sos98wISVvwCjMR5WgE3t3ScyWowP9e0QF9ppNUz2/FW
QZLyL1OhiNp8YkBKrT7nLnEMYx1RDcus3A8cv3vmFJzbQntng1ER2CLat3AGl1Ac
V9S1mWgci7XW8KttoBSRzicAc9RvorgHvLtrlfyCHMpwH0sTFtniv32FMzcSaAHG
NJUP3V2oGkDu3nOR0Si/b3+FakfTDb2mbqWOptP59WTILQXImaIK+4o2m5Z38lQ1
hmk9Zf+Uf0IE0pg7rR/yv6BAPjd9cZliA31eYuSoiHf60CGTEQOAtRxo+chSegCc
38KfwNM093koKidYfa4nNsxLkZzz4+RGLd7yEL48VryDO4IvMhb8dmfVgDRzH4VB
YCDCNN7PFfUvN2MgGayZd4mqxT75GaIRcPOmtACzuVIJrXLvvuK2u/BSc0rTpBaP
ElKGlawd0i6odrwIUkZ7JhtfBVAPo85Yc9tTldCkUQxWPGwXfhYU7yYC4WJQdvmC
8r7aNoT8beDJKbxNhViaszfWKTtdX3ry0VENKpq3oUnf+ys2X6tRHb3zeaxkVU4z
ra+VLpQEw+8=
=LD8o
-----END PGP SIGNATURE-----

--cvVnyQ+4j833TQvp--
