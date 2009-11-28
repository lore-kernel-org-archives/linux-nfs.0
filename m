From: "Brian J. Murrell" <brian-SquOHqY54CVWr29BmMi2cA@public.gmane.org>
Subject: NFSv4 and EPERM for all but one user
Date: Sat, 28 Nov 2009 16:46:45 -0500
Message-ID: <1259444804.13762.29.camel@pc.interlinx.bc.ca>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-o8B4L+Oxl5IbEBGZWAWc"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:45989 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752381AbZK1VrD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 28 Nov 2009 16:47:03 -0500
Received: from list by lo.gmane.org with local (Exim 4.50)
	id 1NEV8G-0005fm-2Z
	for linux-nfs@vger.kernel.org; Sat, 28 Nov 2009 22:47:08 +0100
Received: from d67-193-197-208.home3.cgocable.net ([67.193.197.208])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Sat, 28 Nov 2009 22:47:08 +0100
Received: from brian by d67-193-197-208.home3.cgocable.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Sat, 28 Nov 2009 22:47:08 +0100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-o8B4L+Oxl5IbEBGZWAWc
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

I have an NFSv4 export configured on a server with kernel
2.6.24-24-generic:

/usr/local      pc(sec=3Dkrb5,rw,no_root_squash,sync,subtree_check) \
                pvr(sync,subtree_check)

On the machine "pc" one user (me) is able to read it:

$ sudo su - brian -c "ls -l /usr/local"
total 36
drwxr-xr-x  2 root root 4096 2009-06-19 10:05 bin
drwxr-xr-x  4 root root 4096 2009-01-01 09:56 Brother
drwxr-xr-x  2 root root 4096 2008-11-29 10:49 etc
drwxr-xr-x  2 root root 4096 2007-03-24 21:01 games
drwxr-xr-x  2 root root 4096 2007-03-24 21:01 include
drwxr-xr-x  7 root root 4096 2009-08-02 11:54 lib
lrwxrwxrwx  1 root root    9 2007-03-24 21:01 man -> share/man
drwxr-xr-x  2 root root 4096 2007-03-24 21:01 sbin
drwxr-xr-x 12 root root 4096 2009-07-07 08:40 share
drwxr-xr-x  2 root root 4096 2007-03-24 21:01 src

But any other user is not:

$ sudo su - brianm -c "ls -l /usr/local"
No directory, logging in with HOME=3D/
bind: Address already in use
ls: cannot open directory /usr/local: Permission denied

$ sudo su - nobody -c "ls -l /usr/local"
No directory, logging in with HOME=3D/
bind: Address already in use
ls: cannot open directory /usr/local: Permission denied

This filesystem is mounted with autofs on "pc" which is running
2.6.30-10-generic:

/usr/local	-fstype=3Dnfs4,sec=3Dkrb5	linux:/usr/local

I'm positive this is PEBKAC but I'm not sure of what nature.

Any ideas?

b.


--=-o8B4L+Oxl5IbEBGZWAWc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAksRmkEACgkQl3EQlGLyuXCDcACeLNPiJuKQUHOyl7WoB/NgF4tn
RZAAoJ4NTtmYvPBhSdjoyqEnDSgrOqVe
=gZoC
-----END PGP SIGNATURE-----

--=-o8B4L+Oxl5IbEBGZWAWc--


