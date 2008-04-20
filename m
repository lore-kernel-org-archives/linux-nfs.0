From: Mike Frysinger <vapier@gentoo.org>
Subject: [NFS] [patch] rpcgen: include sys/ioctl.h on linux systems
Date: Sun, 20 Apr 2008 06:49:44 -0400
Message-ID: <200804200649.44542.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_I/xCIULC0HnqBrF"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:42873 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762968AbYDTKtx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 20 Apr 2008 06:49:53 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JnX7I-0006hk-9D
	for linux-nfs@vger.kernel.org; Sun, 20 Apr 2008 20:49:52 +1000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Boundary-00=_I/xCIULC0HnqBrF
Content-Type: multipart/signed; boundary="nextPart1214265.iFRnkbCNCF";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Content-Transfer-Encoding: 7bit

--nextPart1214265.iFRnkbCNCF
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

the rpcgen tool included with nfs-utils will generate calls to ioctl() but =
not=20
actually generate the sys/ioctl.h header include.  attached patch should fi=
x=20
this.
=2Dmike

--nextPart1214265.iFRnkbCNCF
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.7 (GNU/Linux)

iQIVAwUASAsfyEFjO5/oN/WBAQL19Q/+JbBJQutdISRN40VgAH7MmML5tB6YY868
SnR/EmoUmhsUf4uv56Z93qqIeLEvhngEs8/vzgUiHxK10hhKSVRolskNfIoz3/5Y
dSAjGFfdN9+iRDuv+zr8eRznCLvWKkxt6B3KutCvYQixKxAWhWYLF7L5eywxTeCI
eVJ95e0lBDvMzMbCcCBck4hyP6K1CUuf2P1R8CRP4jOgRMKXDx5fwElnqUHF1ViF
WgDHNJ9RmkhdtNajvOiY/q7ZWJwihPDKDzEIvAg8eKYvQCtsSfalQHWZygpGkQFG
HBXuimi9hizocOsGy/xrfhNirTMNg9Moi52DAvRXiOmz8TK2kondisHLHKS+XsBI
wx2R7yMLL2qrlgD5gHcUfyWl+qeGekGV2FCOujgAa0Ckl0OfIPvdhdHfgyhizsBq
Wo4THtkbV/SAvpLypt1ssOPZ2WyPs5xy8wmuxfR5IzYkCTAKcgCAG4zk1VsdJmaZ
4LAPWW8M0f5qhAMAubcXqebItcwh3IAWnL4Ar2ZAsPgDEbZqe0WW/dQt8HyP2Fqf
Of99u14rE8ulYiRs4K6ElaKxXaMzlJ04MJyobkNq4TanlYKvd2ZnJgW6KuwBsPz2
WhhRB3pKQZtGrnxc6W/Q7ELNcCOOW9OD6H6TjyfK0H9HtOoFc4t9rRIk08p6XAF/
z5hc1PLO/YI=
=tJhx
-----END PGP SIGNATURE-----

--nextPart1214265.iFRnkbCNCF--

--Boundary-00=_I/xCIULC0HnqBrF
Content-Type: text/x-diff; charset="us-ascii";
	name="nfs-utils-1.1.2-rpcgen-ioctl.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="nfs-utils-1.1.2-rpcgen-ioctl.patch"

--- tools/rpcgen/rpc_main.c
+++ tools/rpcgen/rpc_main.c
@@ -548,6 +548,9 @@
 #ifndef linux
 	if( !tirpcflag && inetdflag )
 	  f_print(fout, "#include <sys/ttycom.h>/* TIOCNOTTY */\n");
+#else
+	if( !tirpcflag )
+	  f_print(fout, "#include <sys/ioctl.h>/* TIOCNOTTY */\n");
 #endif
 	if( Cflag && (inetdflag || pmflag ) ) {
 	  f_print(fout, "#ifdef __cplusplus\n");

--Boundary-00=_I/xCIULC0HnqBrF
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Don't miss this year's exciting event. There's still time to save $100. 
Use priority code J8TL2D2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
--Boundary-00=_I/xCIULC0HnqBrF
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

--Boundary-00=_I/xCIULC0HnqBrF--


