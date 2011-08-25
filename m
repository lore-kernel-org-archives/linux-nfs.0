Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from atreides.gradator.net ([212.85.155.42]:54968 "EHLO
	atreides.gradator.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755436Ab1HYVrI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Aug 2011 17:47:08 -0400
Date: Thu, 25 Aug 2011 23:47:04 +0200
From: Sylvain Rochet <gradator@gradator.net>
To: Jamie Lokier <jamie@shareable.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Message-ID: <20110825214704.GA31931@gradator.net>
References: <20101018223540.GA20730@gradator.net>
 <20110819230344.GA24784@gradator.net>
 <20110819233756.GI11512@jl-vm1.vm.bytemark.co.uk>
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="R3G7APHDIzY6R/pk"
In-Reply-To: <20110819233756.GI11512@jl-vm1.vm.bytemark.co.uk>
Subject: Re: PROBLEM: 2.6.35.7 to 3.0 Inotify events missing
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--R3G7APHDIzY6R/pk
Content-Type: multipart/mixed; boundary="82I3+IH0IqGh5yIs"
Content-Disposition: inline


--82I3+IH0IqGh5yIs
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Sat, Aug 20, 2011 at 12:37:56AM +0100, Jamie Lokier wrote:
>=20
> Can it also be bypassed with sys_open_by_handle_at?

Just checked that and... as planned it can be bypassed with=20
name_to_handle_at/open_by_handle_at as well.

(I added my quick'n'dirty test code, maybe someone will be interested by=20
a working fhandle example on Linux 3.0.x).

Sylvain

--82I3+IH0IqGh5yIs
Content-Type: text/x-csrc; charset=iso-8859-1
Content-Disposition: attachment; filename="fhandle3.c"

#include <stdio.h>
#include <stdlib.h>

#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>

struct file_handle {
	int handle_size;
	int handle_type;
	void *f_handle;
};


int main(int argc, char *argv[])
{
	int ret;
	int fd;
	int mntfd;
	struct file_handle fh;
	fh.handle_type = 0;
	fh.f_handle = malloc(100);
	fh.handle_size = 100/sizeof(int);
	errno  = 0;

	printf("%s\n", argv[1]);

	int mntid = 20;

	ret = syscall(303, 0, argv[1], &fh, &mntid, 0);
	if (ret) {
		perror("303 Error:");
		exit(1);
	}
	printf("%d - %d\n", mntid, fh.handle_size);

	printf("sleep\n");
	sleep(60);


	mntfd = open("/data", O_RDONLY);
	printf("dir = %d\n", mntfd );

	fd = syscall(304, mntfd, &fh, O_WRONLY);
	if (fd < 0 ) {
		perror("304 Error:");
		exit(1);
	}
	printf("fd = %d\n", fd);


	write(fd, "toto", 4);


	if( close(fd) ) {
		printf("close failed\n");
	}

	return 0;
}




--82I3+IH0IqGh5yIs--

--R3G7APHDIzY6R/pk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAk5WwtgACgkQDFub3qtEsS9roQCfbUOMoAOWt872TnH8CzbZZ9D4
/NIAn3zVE0Q3uG/sIIFshWnfy9fiYSGX
=MWHl
-----END PGP SIGNATURE-----

--R3G7APHDIzY6R/pk--
