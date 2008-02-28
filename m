From: Toralf =?iso-8859-15?q?F=F6rster?= <toralf.foerster@gmx.de>
Subject: [NFS] mount.nfs4 issue
Date: Thu, 28 Feb 2008 15:06:00 +0100
Message-ID: <200802281506.05177.toralf.foerster@gmx.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1750375700=="
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:35346 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752519AbYB1OGZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Feb 2008 09:06:25 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JUjOw-0000fZ-Qh
	for linux-nfs@vger.kernel.org; Fri, 29 Feb 2008 01:06:22 +1100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--===============1750375700==
Content-Type: multipart/signed; boundary="nextPart31695871.aIRBgT9DGv";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Content-Transfer-Encoding: 7bit

--nextPart31695871.aIRBgT9DGv
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Under a stable Gentoo Linux I'm not able to mount an NFSv4 exported dir. Wi=
th NFSv3 however I didn't have a problem:

n22 ~ # mount -t nfs n22:/tmp /mnt/nfs/uml_tmp/
n22 ~ # umount -t nfs n22:/tmp /mnt/nfs/uml_tmp/
n22 ~ # mount -t nfs4 n22:/tmp /mnt/nfs/uml_tmp/
mount.nfs4: mount point /mnt/nfs/uml_tmp does not exist

An strace gives :
=2E..
lstat64("/etc/mtab", {st_mode=3DS_IFREG|0644, st_size=3D402, ...}) =3D 0
getcwd("/root", 4095)                   =3D 6
readlink("/root/n22:", 0xbfb9836b, 4096) =3D -1 ENOENT (No such file or dir=
ectory)
stat64("/sbin/mount.nfs4", {st_mode=3DS_IFREG|S_ISUID|0511, st_size=3D47352=
, ...}) =3D 0
clone(child_stack=3D0, flags=3DCLONE_CHILD_CLEARTID|CLONE_CHILD_SETTID|SIGC=
HLD, child_tidptr=3D0xb7e79748) =3D 26527
wait4(-1, mount.nfs4: mount point /mnt/nfs/uml_tmp does not exist
[{WIFEXITED(s) && WEXITSTATUS(s) =3D=3D 32}], 0, NULL) =3D 26527
=2D-- SIGCHLD (Child exited) @ 0 (0) ---
exit_group(32)                          =3D ?


I'm really wondering about the line starting with : >>> readlink("/root/n22=
:"

b/c n22 is my machine name and I didn't see any reason why the mount comman=
d wants access that non-existant directory.

Here's my machine data:

n22 ~ # uname -a
Linux n22 2.6.23-gentoo-r9 #1 Wed Feb 27 10:25:06 CET 2008 i686 Intel(R) Pe=
ntium(R) M processor 1700MHz GenuineIntel GNU/Linux

n22 ~ # equery l nfs
[ Searching for package 'nfs' in all categories among: ]
 * installed packages
[I--] [  ] net-fs/nfs-utils-1.1.0-r1 (0)
[I--] [  ] net-libs/libnfsidmap-0.19 (0)

n22 ~ # cd /proc/fs/nfs
n22 /proc/fs/nfs # tail -v *
=3D=3D> exports <=3D=3D
# Version 1.1
# Path Client(Flags) # IPs
/tmp    n22*(rw,root_squash,all_squash,sync,wdelay,no_subtree_check,fsid=3D=
0,uuid=3Db5eb53c1:a8f44d71:bf7bc81c:aa83ea88)

=3D=3D> filehandle <=3D=3D
tail: error reading `filehandle': Invalid argument

=3D=3D> max_block_size <=3D=3D
131072

=3D=3D> nfsv4leasetime <=3D=3D
90

=3D=3D> nfsv4recoverydir <=3D=3D
tail: error reading `nfsv4recoverydir': Invalid argument

=3D=3D> pool_threads <=3D=3D
8

=3D=3D> portlist <=3D=3D
ipv4 tcp 0.0.0.0 2049
ipv4 udp 0.0.0.0 2049

=3D=3D> threads <=3D=3D
8

=3D=3D> versions <=3D=3D
+2 +3 +4

=2D-=20
MfG/Sincerely

Toralf F=F6rster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3

--nextPart31695871.aIRBgT9DGv
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.7 (GNU/Linux)

iD8DBQBHxr/NhyrlCH22naMRAqwNAJ0eVcurGqdueJS1j2RKfDYeMmKstgCfTAXc
w2d1NMHH9BRxFjJXYTmPFwc=
=10v8
-----END PGP SIGNATURE-----

--nextPart31695871.aIRBgT9DGv--


--===============1750375700==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
--===============1750375700==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

--===============1750375700==--


