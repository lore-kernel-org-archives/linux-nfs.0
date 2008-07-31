From: Alex Samad <alex-SGFoFqf0RKf0CCvOHzKKcA@public.gmane.org>
Subject: mount issue with Mac OSX and --manage-gids, client hangs
Date: Fri, 1 Aug 2008 06:47:01 +1000
Message-ID: <20080731204701.GE26609@samad.com.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="0eh6TmSyL6TZE2Uz"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-out11.tpgi.com.au ([220.244.226.121]:34151 "EHLO
	mail11.tpgi.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752979AbYGaVKD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Jul 2008 17:10:03 -0400
Received: from sydrt01.samad.com.au (adsl.samad.com.au [60.241.248.86])
	by mail11.tpgi.com.au (envelope-from alex-SGFoFqf0RKf0CCvOHzKKcA@public.gmane.org) (8.14.3/8.14.3) with ESMTP id m6VKl3dh021885
	(version=TLSv1/SSLv3 cipher=AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Fri, 1 Aug 2008 06:47:06 +1000
Received: from alex by smtp.samad.com.au with local  (Exim 4.69 #1 (Debian))
	id 1KOf38-00077k-Ei
	for <linux-nfs@vger.kernel.org>; Fri, 01 Aug 2008 06:47:02 +1000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--0eh6TmSyL6TZE2Uz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi

I have a nfs debian amd64 server, with a few linux clients that is
working well. I recently tried to attach a mac osx (10.5 Leopard)
client.

Everytime I attached it would hang when i attempted to use the mount

on the nas box I have this line in /etc/exports
/exports/shared
-async,no_subtree_check,no_root_squash,insecure,mp=3D/exports/shared
192.168.8.0/22(rw)


I mounted with this command=20

mount -t nfs -o rw,async,rsize=3D32768,wsize=3D32768
nas.hme1.samad.com.au:/exports/shared /mounts/shared


I then tried=20

df -h &
ls -l /mounts/shared &
umount -f /mounts/shared &

all the commands failed to return, I could not kill them with -9, I had
to reboot

I have attached a tcpdump (tcpdump -pni eth0 ether host
xx:xx:xx:xx:xx:xx -s 9100 -w
nas.capture.dmp) on the nas box

a copy of the dumo is at www.samad.com.au/~alex/nas.capture.dmp

I tracked it down to --manage-gids - when I remove this from
/etc/defaults/nfs-kernel-server everything works fine.

Note though, the UID's, GIDs are not synced between the linux box and
the mac box. so the 2 users I have on the mac box uid 501 & 502, do not
exist on the nas box


I read that manage-gids was a means of handle a uid with more than 16
gids and it was protocol compliant, so I have opened a bug report with
Apple, and opened a bug report with debian


I have had a quick look at the source code, but it looks more like
something that is in the kernel.

Is there another place I can log a bugreport for this ?

Thanks
Alex


--0eh6TmSyL6TZE2Uz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkiSJMUACgkQkZz88chpJ2MHXgCgtfGAogy3RbEkqvacDNwvzYqf
nikAn3P0J3bB+/Kx6TSmJiK35mAF7+Xh
=T+Kq
-----END PGP SIGNATURE-----

--0eh6TmSyL6TZE2Uz--
