Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:38557 "EHLO
        mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750998AbeBTWtC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Feb 2018 17:49:02 -0500
Received: from frontend01.mail.m-online.net (unknown [192.168.8.182])
        by mail-out.m-online.net (Postfix) with ESMTP id 3zmG4r18Nqz1qtPd
        for <linux-nfs@vger.kernel.org>; Tue, 20 Feb 2018 23:49:00 +0100 (CET)
Received: from localhost (dynscan1.mnet-online.de [192.168.6.70])
        by mail.m-online.net (Postfix) with ESMTP id 3zmG4r13WMz1qrrw
        for <linux-nfs@vger.kernel.org>; Tue, 20 Feb 2018 23:49:00 +0100 (CET)
Received: from mail.mnet-online.de ([192.168.8.182])
        by localhost (dynscan1.mail.m-online.net [192.168.6.70]) (amavisd-new, port 10024)
        with ESMTP id 0PIFC_xtQmN9 for <linux-nfs@vger.kernel.org>;
        Tue, 20 Feb 2018 23:48:59 +0100 (CET)
Received: from localhost (ppp-188-174-156-23.dynamic.mnet-online.de [188.174.156.23])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.mnet-online.de (Postfix) with ESMTPSA
        for <linux-nfs@vger.kernel.org>; Tue, 20 Feb 2018 23:48:59 +0100 (CET)
Date: Tue, 20 Feb 2018 23:48:58 +0100
From: Matthias Gerstner <matthias.gerstner@nefkom.net>
To: linux-nfs@vger.kernel.org
Subject: nfs-utils: rpc.svcgssd segmentation fault in nss_gss_princ_to_ids()
Message-ID: <20180220224858.GA14972@q910.gerrit.home>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="eAbsdosE1cNLO4uF"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--eAbsdosE1cNLO4uF
Content-Type: multipart/mixed; boundary="J/dobhs11T7y2rNN"
Content-Disposition: inline


--J/dobhs11T7y2rNN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello!

I hope I have found the right place to report this.

I have recently upgraded from nfs-utils-1.3.4 to nfs-utils-2.3.1 on a Gentoo
Linux (hardened) system. After this upgrade the rpc.svcgssd crashes on my
kerberized NFS server each time a client tries to mount an NFS export.

The crash is a segmentation fault:

  kernel: rpc.svcgssd[19772]: segfault at 8 ip 00007f6b6aafa98c sp 00007fff=
2ca8ce30 error 4 in nsswitch.so[7f6b6aaf9000+7000]

The call stack leading up to this looks as follows:

  (gdb)=20
  Program received signal SIGSEGV, Segmentation fault.
  nss_gss_princ_to_ids (secname=3D<optimized out>, princ=3D0x55cabc7d9940 "=
nfs/host.example.domain@EXAMPLE.HOME",=20
      uid=3D0x7ffca550e0d8, gid=3D0x7ffca550e0dc, UNUSED_ex=3D<optimized ou=
t>) at nss.c:415
  415	nss.c: No such file or directory.

  (gdb) bt
  #0  nss_gss_princ_to_ids (secname=3D<optimized out>, princ=3D0x55cabc7d99=
40 "nfs/host.example.domain@EXAMPLE.HOME",=20
      uid=3D0x7ffca550e0d8, gid=3D0x7ffca550e0dc, UNUSED_ex=3D<optimized ou=
t>) at nss.c:415
  #1  0x00007f6c97cc2886 in nfs4_gss_princ_to_ids (secname=3Dsecname@entry=
=3D0x55caba8e2030 <m2f+16> "krb5",=20
      princ=3Dprinc@entry=3D0x55cabc7d9940 "nfs/host.example.domain@EXAMPLE=
=2EHOME", uid=3D0x7ffca550e0d8, uid@entry=3D0x1,=20
      gid=3D0x7ffca550e0dc, gid@entry=3D0x7f6c95cf3a76 <conf_get_section+86=
>) at libnfsidmap.c:682
  #2  0x000055caba6da138 in get_ids (cred=3D0x7ffca550e038, mech=3D<optimiz=
ed out>, client_name=3D<optimized out>)
      at svcgssd_proc.c:251
  #3  handle_nullreq (f=3Df@entry=3D3) at svcgssd_proc.c:407
  #4  0x000055caba6d996a in gssd_run () at svcgssd_main_loop.c:91
  #5  0x000055caba6d83b1 in main (argc=3D1, argv=3D<optimized out>) at svcg=
ssd.c:211

  (gdb) p realms
  $1 =3D (struct conf_list *) 0x0

I debugged this a bit and strange things came about. There seem to be
duplicate instances of the local_realms variable in the
support/nfsidmap/nfsidmap_common.c compilation unit:

  gdb --args /usr/sbin/rpc.svcgssd  -f
  (gdb) start
  Temporary breakpoint 1 at 0x2170: file svcgssd.c, line 94.
  Starting program: /usr/sbin/rpc.svcgssd -f
  Temporary breakpoint 1, main (argc=3D2, argv=3D0x7fffffffddc8) at svcgssd=
=2Ec:94
  94	svcgssd.c: No such file or directory.

  (gdb) b get_local_realms=20
  Breakpoint 2 at 0x7ffff7bd1fc0: file nfsidmap_common.c, line 30.
  (gdb) c
  Continuing.

  Breakpoint 2, get_local_realms () at nfsidmap_common.c:30
  30	nfsidmap_common.c: No such file or directory.
  (gdb) disassemble=20
  Dump of assembler code for function get_local_realms:
  =3D> 0x00007ffff5e0b4a0 <+0>:	sub    $0x1038,%rsp
     0x00007ffff5e0b4a7 <+7>:	orq    $0x0,(%rsp)
     0x00007ffff5e0b4ac <+12>:	add    $0x1020,%rsp
     0x00007ffff5e0b4b3 <+19>:	mov    %fs:0x28,%rax
     0x00007ffff5e0b4bc <+28>:	mov    %rax,0x8(%rsp)
     0x00007ffff5e0b4c1 <+33>:	xor    %eax,%eax
     0x00007ffff5e0b4c3 <+35>:	mov    0x204f7e(%rip),%rax        # 0x7ffff6=
010448 <local_realms>
     0x00007ffff5e0b4ca <+42>:	mov    0x8(%rsp),%rdx
     0x00007ffff5e0b4cf <+47>:	xor    %fs:0x28,%rdx
     0x00007ffff5e0b4d8 <+56>:	jne    0x7ffff5e0b4df <get_local_realms+63>
     0x00007ffff5e0b4da <+58>:	add    $0x18,%rsp
     0x00007ffff5e0b4de <+62>:	retq  =20
     0x00007ffff5e0b4df <+63>:	callq  0x7ffff5e0a250 <__stack_chk_fail@plt>

  End of assembler dump.

  (gdb) p local_realms
  $1 =3D (struct conf_list *) 0x555555764300
  (gdb) p &local_realms
  $2 =3D (struct conf_list **) 0x7ffff7dd7208 <local_realms>

  (gdb) x /1g 0x7ffff6010448
  0x7ffff6010448 <local_realms>:	0x0000000000000000

So there's one instance of the variable that was actually assigned the
expected data. And there's another one that is at NULL and returned from
get_local_realms().

This is related to the "#pragma GCC visibility push(hidden)" in the
compilation unit. Moving it after the local_realms variable declaration fix=
es
the issue. I've attached a patch that does just this.

I am not quite sure whether this is a compiler issue or an invalid use of t=
he
visibility hidden pragma. The compiler used is:

  gcc (Gentoo Hardened 6.4.0-r1 p1.3) 6.4.0

Please advise.

Regards

Matthias

--J/dobhs11T7y2rNN
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="local_realms_segfault.patch"
Content-Transfer-Encoding: quoted-printable

commit b1935a982aa68890ffe888381f7905f57c6b055d
Author: Matthias Gerstner <Matthias.Gerstner@nefkom.net>
Date:   Tue Feb 20 23:33:18 2018 +0100

    get_local_realms: work around strange duplication of local_realms
   =20
    The hidden visibility seems to cause the get_local_realms() function to
    return a NULL pointer, although the local_realms global variable is
    actually assigned. Assembler code shows there are two instances of this
    variable around, one set to NULL, the other to the expected value.
   =20
    This happened on Gentoo Hardened with gcc 4.6.0-r1.

diff --git a/support/nfsidmap/nfsidmap_common.c b/support/nfsidmap/nfsidmap=
_common.c
index 891c855..e5c33a8 100644
--- a/support/nfsidmap/nfsidmap_common.c
+++ b/support/nfsidmap/nfsidmap_common.c
@@ -19,13 +19,13 @@
 #include "nfsidmap_plugin.h"
 #include "conffile.h"
=20
-#pragma GCC visibility push(hidden)
-
 int reformat_group =3D 0;
 int no_strip =3D 0;
=20
 struct conf_list *local_realms;
=20
+#pragma GCC visibility push(hidden)
+
 struct conf_list *get_local_realms(void)
 {
 	return local_realms;

--J/dobhs11T7y2rNN--

--eAbsdosE1cNLO4uF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEQMifAG+4oyi4OjfMFK1vZXkJcoQFAlqMpdoACgkQFK1vZXkJ
coTb3Q/8DQP7SmN5FCx9AECyyw2FuwsHqNMtXJPmyjsphK3/4NxAfXdtaGHy2sEh
agjAh29mIdSuR5QCn+Afd78tQbSxBQSwbkBuqIm8B5wR+VFtpoW8UArPJY+35ImZ
ymt7z7TO3fNLbH5rIAkpm3Z/GBS6OFFyrvwM3hCoae3iGD5LVBzc/Jg574FXRKCb
SZYR5JA0gR/2QBmEjFvVSuUPtccDr1OPreaLp22NXVDduvt6CQFxysV6VN7NQD71
AIFy2c34chIlkO5rmK94dTMu6e8a7XPAERqk1YHtCOaudANyMhWNLJ7OxsRrUdP8
Ql7QP18GIRwwoqbOq4ANgerOA0xgEN3JTinNkbRaPbpaT6KAvIy6ctH2P50OmxyB
F96qN3dC48+TYUcHwkHXZDhgUOiXUmPtTwh03gvED1w2Bliyej6VLn64NKT/rFsC
nwO5EeMb8yKbbfWzAIGtgBg5Sl48h9e+QFiS1iFYD6rxy1TDk0GD+USgfC24CX5q
fjb4kOiNbw3v4RxsWkx8YjDaop2NnPnTaMUxjclfTo7K6nNmreE52anhPhkMJQl7
iu9ivlB3hVGraZQ7gIPlbLGp3vXm3f5QW9cg6iwkKGEEdULpWqchyfXBMQ6WXSRN
RrrPxiiY8EY74UYh7/QsXqTSTP4ep5JgtOETe16BvsXSZ5y/4M4=
=8/cx
-----END PGP SIGNATURE-----

--eAbsdosE1cNLO4uF--
