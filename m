Return-Path: linux-nfs-owner@vger.kernel.org
Received: from messinet.com ([50.196.241.75]:54038 "EHLO chicago.messinet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750853AbaCVGnz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 22 Mar 2014 02:43:55 -0400
Received: from localhost (localhost [127.0.0.1])
	by chicago.messinet.com (Postfix) with ESMTP id D2A1F67B3F96
	for <linux-nfs@vger.kernel.org>; Sat, 22 Mar 2014 01:43:54 -0500 (CDT)
Received: from chicago.messinet.com ([127.0.0.1])
	by localhost (chicago.messinet.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id oJ7jeogF3Kcj for <linux-nfs@vger.kernel.org>;
	Sat, 22 Mar 2014 01:43:52 -0500 (CDT)
Received: from linux-ws1.messinet.com (unknown [IPv6:2001:470:c1dc:7779:d6be:d9ff:fe8d:7c1e])
	(using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	by chicago.messinet.com (Postfix) with ESMTPSA id 1970667B3F8C
	for <linux-nfs@vger.kernel.org>; Sat, 22 Mar 2014 01:43:52 -0500 (CDT)
From: Anthony Messina <amessina@messinet.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Issue with SELinux Labeled NFS
Date: Sat, 22 Mar 2014 01:43:47 -0500
Message-ID: <6129740.NJmSgFusgb@linux-ws1.messinet.com>
In-Reply-To: <2308691.6kaIE5X6fN@linux-ws1.messinet.com>
References: <2308691.6kaIE5X6fN@linux-ws1.messinet.com>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart5503233.gcSt5FPPEI"; micalg="pgp-sha1"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--nextPart5503233.gcSt5FPPEI
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="us-ascii"

On Tuesday, March 11, 2014 01:41:49 PM you wrote:
> I've begun testing out the labeled NFSv4.2 features with good success=
 with=20
> only one exception so far.  I have several workstations that use NFSv=
4.2=20
> mounted /home directories.  I've been able to remove the SELinux bool=
ean=20
> requirement for 'use_nfs_home_dirs', however, on *one* of these
> workstations,  the /home directory is labeled 'unlabeled_t' after boo=
t when
> it should be labeled with 'home_root_t'.  This problem causes failure=
s, as
> you can imagine.
>=20
> I mount the filesystem on all of the workstations in the same manner:=

> # /etc/fstab
> ...
> server.com:/home /home nfs rw,minorversion=3D2,sec=3Dkrb5p,x-systemd.=
automount 0
> 0
>=20
> Yet the issue occurs on only *one* workstation.  If I manually issue
>=20
> chcon -t home_root_t /home
>=20
> then I am able to login and use the system without issue.
>=20
> All of the servers and workstations are using
>=20
> kernel-3.13.6-200.fc20.x86_64
> nfs-utils-1.2.9-3.0.fc20.x86_64
>=20
> I realize this is not the SELinux mailing list, but I was wondering i=
f
> anyone  had any pointers on how to investigate this issue.  The
> workstations are all nearly identical in configuration with the excep=
tion
> of a few user-based differences such as GnuCash on one, but not the o=
ther,
> etc.

While I haven't yet found a solution to this problem, I am able to conf=
irm=20
that I now see this other workstations and it appears that it may be so=
me sort=20
of race condition between the two mounts in the clients' fstab since it=
=20
doesn't always occur on every workstation.  Perhaps someone can help me=
 spot a=20
problem in the following server or client configuration.

My single NFS server has the following in /etc/exports:

/export =092001:123:456:789::/64(fsid=3D0,crossmnt,sec=3Dkrb5p:krb5i) \=

=09=0910.1.1.0/24(fsid=3D0,crossmnt,sec=3Dkrb5p:krb5i)
/export/home=092001:123:456:789::/64(rw,sec=3Dkrb5p) \
=09=0910.1.1.0/24(rw,sec=3Dkrb5p)
/export/media=092001:123:456:789::/64(rw,sec=3Dkrb5p:krb5i) \
=09=0910.1.1.0/24(rw,sec=3Dkrb5p:krb5i)
/export/software=092001:123:456:789::/64(rw,sec=3Dkrb5p:krb5i) \
=09=09=0910.1.1.0/24(rw,sec=3Dkrb5p:krb5i)

And the following bind mounts in /etc/fstab:

/home           /export/home            none    bind    0 0
/srv/media      /export/media           none    bind    0 0
/srv/software   /export/software        none    bind    0 0


And the following labels for the exported filesystems:

~]# ls -lZ /
drwxr-xr-x. root  root    system_u:object_r:home_root_t:s0 home

~]# ls -lZ /srv
drwxr-x---. auser agroup  system_u:object_r:public_content_rw_t:s0 medi=
a
drwxr-x---. auser family  system_u:object_r:public_content_rw_t:s0 soft=
ware

~]# ls -lZ /export
drwxr-xr-x. root  root    system_u:object_r:home_root_t:s0 home
drwxr-x---. auser agroup  system_u:object_r:public_content_rw_t:s0 medi=
a
drwxr-x---. auser family  system_u:object_r:public_content_rw_t:s0 soft=
ware


The clients mount the exports via the following in /etc/fstab

server.com:/home /home nfs rw,minorversion=3D2,sec=3Dkrb5p,x-systemd.au=
tomount 0 0
server.com:/ /mnt/srv  nfs rw,minorversion=3D2,sec=3Dkrb5i,x-systemd.au=
tomount 0 0

Again, the issue is that the /home mount on the clients tends to be mou=
nted as=20
"unlabeled_t" which causes failures with SELinux enabled.

Is there an issue in the way I'm exporting things that may cause this?

Thanks in advance for any pointers.  -A

=2D-=20
Anthony - http://messinet.com - http://messinet.com/~amessina/gallery
8F89 5E72 8DF0 BCF0 10BE 9967 92DC 35DC B001 4A4E

--nextPart5503233.gcSt5FPPEI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iEYEABECAAYFAlMtMScACgkQktw13LABSk667gCfdOU8x9thGTrF//y8GoX9vv29
uEYAn0w81BM8HFDWw4urpbhrFxQ59bAH
=FHY2
-----END PGP SIGNATURE-----

--nextPart5503233.gcSt5FPPEI--

