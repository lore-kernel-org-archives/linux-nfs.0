Return-Path: linux-nfs-owner@vger.kernel.org
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:39890 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750755AbaBZA6J (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Feb 2014 19:58:09 -0500
Message-ID: <1393376280.14067.34.camel@deadeye.wl.decadent.org.uk>
Subject: Oops in nfs41_assign_slot in Linux 3.13.4
From: Ben Hutchings <ben@decadent.org.uk>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: 734268@bugs.debian.org, Arthur de Jong <adejong@debian.org>,
        linux-nfs@vger.kernel.org
Date: Wed, 26 Feb 2014 00:58:00 +0000
In-Reply-To: <1393361101.5000.26.camel@sorbet.thuis.net>
References: <1388922864.10916.7.camel@sorbet.thuis.net>
	 <1393361101.5000.26.camel@sorbet.thuis.net>
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-YzlWJQb/wA3+SsC56H79"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-YzlWJQb/wA3+SsC56H79
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Trond, Arthur seems to be hitting a similar bug to
<https://bugzilla.redhat.com/show_bug.cgi?id=3D1050206>, and it's still
occurring in 3.13.4 even though that has the two fixes you posted there.
The full bug report, with screenshots of the oopses, is at
<https://bugs.debian.org/734268>.

On Tue, 2014-02-25 at 21:45 +0100, Arthur de Jong wrote:
> Control: severity -1 critical
> Control: found -1 linux/3.12.6-2
> Control: found -1 linux/3.13.4-1
> Control: fixed -1 linux/3.11.10-1
>=20
> Raising severity to critical because it kills the whole system quite
> predictably.
>=20
> I can still reliably reproduce this with linux-image-3.13-1-amd64
> 3.13.4-1 (see photo) so I'm currently still stuck with a 3.11 kernel.
>=20
> If there is any information I can provide to help identify this bug,
> please let me know.
>=20
> The only thing that could be relevant is that I have NFS mounts from
> different NFS servers:
>=20
> /etc/fstab:
>=20
> server1:/home  /home  nfs rw,hard,intr,bg,rsize=3D4096,wsize=3D1024,acreg=
min=3D60,acregmax=3D600,acdirmin=3D60,acdirmax=3D600,noatime,sec=3Dsys,_net=
dev 0 0
> server2:/share /share nfs ro,soft,intr,bg,rsize=3D8192,nosuid,nodev,noexe=
c,acregmin=3D60,acregmax=3D600,acdirmin=3D60,acdirmax=3D600,sec=3Dsys,_netd=
ev 0 0
>=20
>=20
> server1 is Debian wheezy (kernel linux-image-3.2.0-4-amd64
> 3.2.51-1) /etc/exports:
>=20
> /home -rw,root_squash,nohide,async,no_subtree_check client1 client2(no_ro=
ot_squash) client3
>=20
> I'm mostly seeing crashes on client2, my main workstation, but also
> other machines. /home is an ext3 file system.
>=20
>=20
> server2 runs testing (kernel linux-image-3.12-1-686-pae
> 3.12.9-1) /etc/exports:
>=20
> /share *.local.domain(ro,all_squash,crossmnt,sync,no_subtree_check)
>=20
> Under /share are /share/disk1 and /share/disk2 ext3 file systems.
>=20
>=20
> On the client again, from /proc/mounts (running a 3.11 kernel again):
>=20
> server1:/home /home nfs4 rw,noatime,vers=3D4.0,rsize=3D4096,wsize=3D1024,=
namlen=3D255,acregmin=3D60,acregmax=3D600,acdirmin=3D60,acdirmax=3D600,hard=
,proto=3Dtcp,port=3D0,timeo=3D600,retrans=3D2,sec=3Dsys,clientaddr=3D192.16=
8.12.4,local_lock=3Dnone,addr=3D192.168.12.1 0 0
> server2:/share /share nfs4 ro,nosuid,nodev,noexec,relatime,vers=3D4.0,rsi=
ze=3D8192,wsize=3D131072,namlen=3D255,acregmin=3D60,acregmax=3D600,acdirmin=
=3D60,acdirmax=3D600,soft,proto=3Dtcp,port=3D0,timeo=3D600,retrans=3D2,sec=
=3Dsys,clientaddr=3D192.168.12.4,local_lock=3Dnone,addr=3D192.168.12.9 0 0
> server2:/share/disk2 /share/disk2 nfs4 ro,nosuid,nodev,noexec,relatime,ve=
rs=3D4.0,rsize=3D8192,wsize=3D131072,namlen=3D255,acregmin=3D60,acregmax=3D=
600,acdirmin=3D60,acdirmax=3D600,soft,proto=3Dtcp,port=3D0,timeo=3D600,retr=
ans=3D2,sec=3Dsys,clientaddr=3D192.168.12.4,local_lock=3Dnone,addr=3D192.16=
8.12.9 0 0
> server2:/share/disk1 /share/disk1 nfs4 ro,nosuid,nodev,noexec,relatime,ve=
rs=3D4.0,rsize=3D8192,wsize=3D131072,namlen=3D255,acregmin=3D60,acregmax=3D=
600,acdirmin=3D60,acdirmax=3D600,soft,proto=3Dtcp,port=3D0,timeo=3D600,retr=
ans=3D2,sec=3Dsys,clientaddr=3D192.168.12.4,local_lock=3Dnone,addr=3D192.16=
8.12.9 0 0
>=20
> I have some freedom to change things around to test in this network so
> let me know which things to try.
>=20
> Thanks,
>=20

--=20
Ben Hutchings
Always try to do things in chronological order;
it's less confusing that way.

--=-YzlWJQb/wA3+SsC56H79
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUw08Gee/yOyVhhEJAQpFKw//aH02EOTHouLg1kz1zwOzGAqEOQcvRRo1
g8JAMkPb2FsBkHq7wL+h4ncOq2u1JAzB1drau2SymZs+NStoJCh51O4xSPNb2I45
KyvHZw72pZcY8mLLlyGr8j1zC6gFK+5rCB5ZdeCdjQwb925RF0DFIG22p8fHyllK
U6iSGa5xsfGS08YYPV+ixNZfGnSK1cHEMXh+c1bugzk+UJp7KykoqUKTJovImV++
3V7jTGfoleda8f07wF+F+A+e9mMM+tpUWQaaWIOSbITh7oPhYl3n5CjbFgFfKyZM
1uT9ZLWS7jioRWnT2a87EW0sTGSMTKdVvUkFvfiL2LHg9/0U0NOy5pAXF3VLlEIu
RL9bquMPEEuWpph53rlsymVAUkkt0BPBZ9L6ycz0y+kA5jb1ZdgzQ8aePXoqA6MZ
uyEX91ekg2TNsETmztH2xKRL+68j+db4xN4s0hczsFV9eJBU0hqmzhQSbvxYGspZ
5zx4FFJoylOEv2QSAvgve0973OiZuDX6wHUU6ISjflqLgQB3v4YyAHMxk+Gz23e4
BRjXHRZBKaBU2JhZW9giT2mzKZ3zBYay8hMA1p8t++Je61mAWiLN2/jvsvN2Ei1A
QfzoCdTuBRCwuw0Uf2EW7MLZEyQQxoBleRDWKcJ+qNC0xMDyPf6qTPv+qkEJUeCT
ccm679hXrOU=
=JI92
-----END PGP SIGNATURE-----

--=-YzlWJQb/wA3+SsC56H79--
