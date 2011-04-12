Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mta-2.ms.rz.RWTH-Aachen.DE ([134.130.7.73]:39481 "EHLO
	mta-2.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751620Ab1DLOb4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Apr 2011 10:31:56 -0400
Received: from ironport-out-2.rz.rwth-aachen.de ([134.130.5.41])
 by mta-2.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0LJJ00HSELN5KVJ0@mta-2.ms.rz.RWTH-Aachen.de> for
 linux-nfs@vger.kernel.org; Tue, 12 Apr 2011 16:01:53 +0200 (CEST)
Received: from gheift ([unknown] [134.130.113.37])
 by relay-auth-2.ms.rz.rwth-aachen.de
 (Sun Java(tm) System Messaging Server 7.0-3.01 64bit (built Dec  9 2008))
 with ESMTPA id <0LJJ0057MLN2CX00@relay-auth-2.ms.rz.rwth-aachen.de> for
 linux-nfs@vger.kernel.org; Tue, 12 Apr 2011 16:01:53 +0200 (CEST)
Date: Tue, 12 Apr 2011 16:01:50 +0200
From: Gerhard Heift <ml-nfs-linux-20110412-ef47@gheift.de>
To: linux-nfs@vger.kernel.org
Subject: nfsdv4 leaks file descriptors
Message-id: <20110412140148.GA17242@gheift>
Content-type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature"; boundary=dc+cDN39EJAMEtIO
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--dc+cDN39EJAMEtIO
Content-Type: multipart/mixed; boundary="n8g4imXOkfNTN/H1"
Content-Disposition: inline


--n8g4imXOkfNTN/H1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello,

I have a linux kernel (2.6.38.2, armv5tel) running which exports a
directory with following options:

/data ip/32(rw,async,crossmnt,insecure,root_squash,no_subtree_check,fsid=0)

On the client (Debian unstable, kernel 2.6.38-2-amd64) I mounted the
directory under /media(nfs4import with

# mount -t nfs4 ip:/ /media/nfs4import

After a lot running fdupes on this folder the server kernel starts
throwing messages like this one:

  VFS: file-max limit [number] reached

After a reboot I recognised that the number of used file descriptors
increases during the run of fdupes (see /proc/sys/fs/file-nr). Even
after unmounting the exported filesystem on the client, unexport the
file system on the server and stopping the nfs-server the file
descriptors are still allocated and unmounting the filesystem is not
possible.

After a little bit of research I could create a small program, which
increases the used file descriptors by one.

Regards,
  Gerhard

--n8g4imXOkfNTN/H1
Content-Type: text/x-csrc; charset=us-ascii
Content-Disposition: attachment; filename="leak-test.c"
Content-Transfer-Encoding: quoted-printable

#include <stdio.h>

#define DIR "/media/nfs4import/"

int main(void) {
	FILE *f1;
	FILE *f2;
	char b[1024];
	int i;

	// create file1
	f1 =3D fopen(DIR "file1.txt", "w");
	fwrite("test\n", 5, 1, f1);
	close(f1);

	// open file1 in read mode
	f1 =3D fopen(DIR "file1.txt", "r");

	for (i =3D 0; i < 1; i++) {
		// open file2 in write mode and close it
		f2 =3D fopen(DIR "file2.txt", "w");
		fclose(f2);
=09
		// open file2 in read mode and close it
		// this causes the leak of a file descriptor on the server
		// just watch /proc/sys/fs/file-nr on the server
		f2 =3D fopen(DIR "file2.txt", "r");
		fclose(f2);
	}
	fclose(f1);

	return 0;
}

--n8g4imXOkfNTN/H1--

--dc+cDN39EJAMEtIO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEARECAAYFAk2kW0wACgkQa8fhU24j2fkiIACeNFbYDC/LZn69iwAd70mr2/5i
4V4AnRXfL+F/Pwn5H3dSfG08x2Fyk4AL
=84jh
-----END PGP SIGNATURE-----

--dc+cDN39EJAMEtIO--
