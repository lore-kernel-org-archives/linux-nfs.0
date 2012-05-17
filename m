Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:36798 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759137Ab2EQGod (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 May 2012 02:44:33 -0400
Date: Thu, 17 May 2012 16:44:20 +1000
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: ANNOUNCE: nfs-utils-1.2.6 released.
Message-ID: <20120517164420.3fe761a5@notabene.brown>
In-Reply-To: <4FB159DA.2070800@RedHat.com>
References: <4FB159DA.2070800@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/tJa7kt9IOM/J5=93825tehu"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/tJa7kt9IOM/J5=93825tehu
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 14 May 2012 15:15:38 -0400 Steve Dickson <SteveD@redhat.com> wrote:

> New Features in this release:
>    * The addition the nfsdcld daemon
>    * The addition of the osd_login script which is mandated by the
>          pnfs-objects standard

Don't you hate it when people don't bother to test all your -rc's, then
report bugs against your final release?  Me too.

  mkdir /tmp/dest
  make DESTDIR=3D/tmp/dest install

fails because it tries to install osd_login in /tmp/dest/sbin/osd_login
without first creating /tmp/dest/sbin.  All other required directories get
created first.

This patch - stealing an idea from utils/mount - seem to fix it.

Thanks,
NeilBrown


commit 03bb227402ab023f4badb515022d49f82e01ff8d
Author: Neil Brown <neilb@suse.de>
Date:   Thu May 17 16:40:40 2012 +1000

    osd_login - ensure /sbin is created before installation.
   =20
    If we use a more standard approach to describing the osd_login
    script, the automake infrastructure will create /sbin before
    attempting installation.
    This is important for: make DESTDIR=3D/empty-dir install
   =20
    Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/utils/osd_login/Makefile.am b/utils/osd_login/Makefile.am
index adc493a..d17ffa7 100644
--- a/utils/osd_login/Makefile.am
+++ b/utils/osd_login/Makefile.am
@@ -1,12 +1,9 @@
 ## Process this file with automake to produce Makefile.in
=20
-OSD_LOGIN_FILES=3D osd_login
+# These binaries go in /sbin (not /usr/sbin), and that cannot be
+# overriden at config time.
+sbindir =3D /sbin
=20
-EXTRA_DIST=3D $(OSD_LOGIN_FILES)
-
-all-local: $(OSD_LOGIN_FILES)
-
-install-data-hook:
-	$(INSTALL) --mode 755 osd_login $(DESTDIR)/sbin/osd_login
+sbin_SCRIPTS =3D osd_login
=20
 MAINTAINERCLEANFILES =3D Makefile.in

--Sig_/tJa7kt9IOM/J5=93825tehu
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBT7SeRDnsnt1WYoG5AQKQ7g//Y9aoOuBEc9TU8Sy2dyXsaVOzt6zwLOwX
vrCfqm28uVZslBKFRjPf8RupGMNpRkl5YNLkidUwKqubpwt0aePHsTo4mLHVtTcH
87LCSMyUgxAaTcvnerYZDHeeY26vd2ymg3GS8QadRa2ldx6S5nAt2XRkBCRwAID+
g44NVNjbVgAo+PCp0814swXFiqo1wMyEB6/0rvqPBpjah1NNiLVbeHChmBSayCrF
GCd0opd/WPJ9Crs5n7mVZFyTHmq9hECXZIeaqvy25LGMyKSJSMbTO3k5TpYGfAUt
OKjmUt0yr7Ou7aAfPTZZdBVVgG3lZemMPj4skQZmiH4cL+RBzw5zo2jfbSTJhIv2
gv4+hqug9kSCRvZhWRcTzr8Uj3cqN+r0iGoCgQv4Ohanrsyi26ogW8KBnJVgx8m0
4g9g1/9cD0+wm3OwD33M7csOM5iovtU73bQ55E/NlYjUEwZBdcQz9e8cWGvNkPh1
oJOePrkwjQ2vQeb/uhM+bdK0wB518mxiATIC14KblWaetNEuFOL+fIM+2Ff0j3cX
O0jvmq+oNgBEESOlAQ0AODUWNurrC86jkjxdq/0umFXrDEcvjMQKi7R/IQMjJ4UP
F07HFLftT8cJI4Jn+me3+ASHRTdsym8Gf3EM85KpSOiRM56Mbly/Y9hTFoU2gfoP
F9O2dSO4R74=
=dgSB
-----END PGP SIGNATURE-----

--Sig_/tJa7kt9IOM/J5=93825tehu--
