Return-Path: <matthieu.herrb@laas.fr>
Date: Mon, 30 Jan 2017 15:25:11 +0100
From: Matthieu Herrb <matthieu.herrb@laas.fr>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: problem with open(name, O_RDWR|O_CREAT|O_EXCL, 0666) on NetApp
 servers
Message-ID: <20170130142511.GC25669@paperthin-usb.laas.fr>
References: <20170105142439.GB9922@paperthin-usb.laas.fr>
 <45F25643-F51D-4CA0-AC7D-55B6D6D6FE22@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="E13BgyNx05feLLmH"
In-Reply-To: <45F25643-F51D-4CA0-AC7D-55B6D6D6FE22@redhat.com>
List-ID: <linux-nfs.vger.kernel.org>


--E13BgyNx05feLLmH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jan 24, 2017 at 11:48:33AM -0500, Benjamin Coddington wrote:
> Hi Matthieu, are you willing to test this one:
>=20
> http://marc.info/?l=3Dlinux-nfs&m=3D148527567624411&w=3D2
>=20

Hi,

sorry for the delay in answering. This patch does fix the problem for
my  configuration.=20

Thanks.

> Ben
>=20
> On 5 Jan 2017, at 9:24, Matthieu Herrb wrote:
>=20
> >Hi,
> >
> >After upgrading my machine to Ubuntu 16.04, I noticed that 'git clone'
> >started creating files with wrong mode (0700 instead of 0644
> >typically) on NFSv4 partitions mounted from our NetApp servers.
> >
> >I've first tracked this down to the fact that git uses
> >
> > open(name, O_RDWR|O_CREAT|O_EXCL, 0666);
> >
> >to create files. If O_EXCL is not present, the files are created
> >normally.
> >
> >I've tried various kernels from Ubuntu and the problems appeared
> >between their 4.2.0-42-generic kernel-image (as found on willy) and
> >the 4.4.0 kernels found on xenial. I tried building 4.9 from
> >kernel.org and the problem is also there.
> >
> >I've then bisected the kernel to figure out that this is caused by the
> >following commit:
> >
> >https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?=
id=3D5334c5bdac926c5f8d89729beccb46fe88eda9e7
> >
> >ie NFS: Send attributes in OPEN request for NFS4_CREATE_EXCLUSIVE4_1
> >
> >Our NetApp filers are running:
> >
> >NetApp Release 8.2.3P3 7-Mode: Tue Apr 28 14:48:22 PDT 2015
> >
> >Any idea on how to fix the problem (either on the NetApp side, or on
> >Linux kernel side)?
> >
> >Appended is a small program to reproduce the issue:
> >
> >Thanks in advance,
> >
> >#include <sys/types.h>
> >#include <sys/stat.h>
> >#include <err.h>
> >#include <fcntl.h>
> >#include <stdio.h>
> >#include <stdlib.h>
> >#include <string.h>
> >#include <unistd.h>
> >
> >/*
> > * Demonstrate file creation bug on NFS v4 and linux kernel 4.4+
> > *
> > * mktemp() is used on purpose.
> > */
> >int
> >main(int argc, char *argv[])
> >{
> >	const char *name =3D argv[1];
> >	char tmp[] =3D "./tmpXXXXXXXXXX";
> >	struct stat buf;
> >	mode_t expected;
> >	int fd, i, n =3D 40;
> >
> >	umask(S_IWGRP | S_IWOTH);
> >	expected =3D 0666 & ~(S_IWGRP | S_IWOTH);
> >	if (argv[1] =3D=3D NULL)
> >		name =3D mktemp(tmp);
> >	for (i =3D 0; i < n; i++) {
> >		fd =3D open(name, O_RDWR|O_CREAT|O_EXCL, 0666);
> >		if (fd < 0)
> >			err(1, "open %s", name);
> >		memset(&buf, 0, sizeof(buf));
> >		if (stat(name, &buf) < 0)
> >			err(1, "stat %s", name);
> >		if ((buf.st_mode & (S_IRWXU|S_IRWXG|S_IRWXO)) !=3D expected)
> >			printf("%s: %o\n", name,
> >			    (int)buf.st_mode & (S_IRWXU|S_IRWXG|S_IRWXO));
> >		else
> >			printf("%s: ok\n", name);
> >		unlink(name);
> >	}
> >	exit(0);
> >}
> >--=20
> >Matthieu Herrb
>=20

--=20
Matthieu Herrb

--E13BgyNx05feLLmH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUBWI9Mx2hzk+430Sj4AQJaMg//UZhry7s4ORBJmhMlQUZk6WdxZyBJ9o4X
FqLHWSILrbFdvlj0UTof5CCygeWJOf2LltQ6q11OPq+l/Nrer5IN3e6E1Ov1Ezs5
Cq1utENIFByPdH+/GkEF4zvq9Ap1VMgNIemGQ+9ikE9sXbl4xARAMmwt5eIx6TTl
tV+Kr01r5btyuZRJY03xxpOGuON8AMmdDW028HKEmU0EiwIkbpL7/mjq4kWyTTFh
uGXRSsjiA3vUdmL+NEzVQEy5A0xG7aYzGhqZLy+p3Cje+9b8nHClr/XGIZUIUdPt
0BQ46ySJ6qjS8SIqFtopXLXSl6ytH892Zet+lZlkU93F/cDO1C9M6ln/eAANoQoA
mQPv7rWae21PcNVO+QmUSJG/5zqRreqiXZ3Kiy2qeY397LZn67mHFuWFqMekUOsT
zUp8W+n14sCbiHqpA0TNF3Z6JGJg8Q2mfjZpXrMN17Sv8jIyaZFaGxXMqlcSKhdx
ROrezvQzpH416AYTf86g3cTv3qu6lvGAMTKPSqSt0LRARJONUSBTJQcaYyqaRwOw
0bEhuJOiC6Cyq9mJSNnWV1lCRo23Buo4SMAtOJKi1ru5+TrW9W5znA7/pOIGcWTt
ZB6TY/tsPYY7KFMLk8vnm9OlUdOVzHHJDnefyaTnPqmpZ6NPim6MpNSfbz06QS12
VAKQVZtfySI=
=EDkl
-----END PGP SIGNATURE-----

--E13BgyNx05feLLmH--
