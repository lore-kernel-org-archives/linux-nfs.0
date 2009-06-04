From: "Brian J. Murrell" <brian-SquOHqY54CVWr29BmMi2cA@public.gmane.org>
Subject: nfs4 client not surviving server reboot
Date: Thu, 04 Jun 2009 14:02:50 -0400
Message-ID: <1244138569.8469.26.camel@pc.interlinx.bc.ca>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-6jmluJnT64jQqntTRz8L"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:37481 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751347AbZFDSFD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Jun 2009 14:05:03 -0400
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1MCHJG-0004Bh-Eu
	for linux-nfs@vger.kernel.org; Thu, 04 Jun 2009 18:05:02 +0000
Received: from d67-193-247-19.home3.cgocable.net ([67.193.247.19])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 04 Jun 2009 18:05:02 +0000
Received: from brian by d67-193-247-19.home3.cgocable.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 04 Jun 2009 18:05:02 +0000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-6jmluJnT64jQqntTRz8L
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hi all,

A couple of times now I have (unforunately) needed to reboot the NFS
server here and my one NFS4 client is simply not recovering that
incident and needs to be rebooted as well.

The particulars are:

NFS Server:
-----------
Ubuntu Hardy running kernel 2.6.24-23-generic

NFS Client:
-----------
Ubuntu Jaunty running kernel 2.6.27-12-generic

The filesystems mounted are:

# grep linux: /proc/mounts
linux:/home/share /autohome/share nfs4 rw,vers=3D4,rsize=3D8192,wsize=3D819=
2,namlen=3D255,hard,nointr,proto=3Dtcp,timeo=3D600,retrans=3D2,sec=3Dkrb5,c=
lientaddr=3D10.75.22.1,addr=3D10.75.22.3 0 0
linux:/usr/local /usr/local nfs4 rw,vers=3D4,rsize=3D32768,wsize=3D32768,na=
mlen=3D255,hard,nointr,proto=3Dtcp,timeo=3D600,retrans=3D2,sec=3Dkrb5,clien=
taddr=3D10.75.22.1,addr=3D10.75.22.3 0 0
linux:/mnt/data /data nfs4 rw,vers=3D4,rsize=3D32768,wsize=3D32768,namlen=
=3D255,hard,nointr,proto=3Dtcp,timeo=3D600,retrans=3D2,sec=3Dkrb5,clientadd=
r=3D10.75.22.1,addr=3D10.75.22.3 0 0
linux:/mnt/mp3 /mnt/mp3 nfs4 rw,vers=3D4,rsize=3D32768,wsize=3D32768,namlen=
=3D255,hard,nointr,proto=3Dtcp,timeo=3D600,retrans=3D2,sec=3Dkrb5,clientadd=
r=3D10.75.22.1,addr=3D10.75.22.3 0 0

I don't really know where to even start trying to figure this one out.
Ideas?

b.


--=-6jmluJnT64jQqntTRz8L
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkooDEcACgkQl3EQlGLyuXCswQCg9GhL9uQ+GWPiXyEspMBnLePi
qe0AoPPES4nwXVuymzVdfIZmo8AbpTbo
=eCzp
-----END PGP SIGNATURE-----

--=-6jmluJnT64jQqntTRz8L--


