Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:50921 "EHLO
	prv3-mh.provo.novell.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751352AbbJVGct (ORCPT
	<rfc822;groupwise-linux-nfs@vger.kernel.org:0:0>);
	Thu, 22 Oct 2015 02:32:49 -0400
From: Neil Brown <nfbrown@novell.com>
To: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Date: Thu, 22 Oct 2015 17:32:35 +1100
Subject: [PATCH nfs-utils] systemd/Makefile: only install rpc-svcgssd.service if it is required.
In-Reply-To: <5606D863.9060107@RedHat.com>
References: <5606D863.9060107@RedHat.com>
Message-ID: <87y4evza4c.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


If we build without rpc-svcgssd (the default), don't install matching
.service file.

Signed-off-by: NeilBrown <neilb@suse.com>

diff --git a/systemd/Makefile.am b/systemd/Makefile.am
index 0331926dcc03..03f96e93dccf 100644
=2D-- a/systemd/Makefile.am
+++ b/systemd/Makefile.am
@@ -28,9 +28,13 @@ endif
 if CONFIG_GSS
 unit_files +=3D \
     auth-rpcgss-module.service \
=2D    rpc-gssd.service \
+    rpc-gssd.service
+
+if CONFIG_SVCGSS
+unit_files +=3D \
     rpc-svcgssd.service
 endif
+endif
=20
 EXTRA_DIST =3D $(unit_files)
=20

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWKIMDAAoJEDnsnt1WYoG5DN4QALRbfa5UFXKjpN/d+McdteUC
tBV5J1etmNmySyKf41ohxqmnEleYyr2PtQOktaxap4Ag8KPXiejdwVXdw2EqMv4A
gN18wyteNCS9LX0UXQGVZnbW/RMcsdi4myjKM9QCi9a9LNr38REdlhSZFNvx8BII
HMqB0rz2XdryaMQFSVCEbZX/PSargR+LB9L27KudHP5T1kAVxSbt1HPfWNN1zZD3
YoX7wxNbsoAWz6ZQ3GUU2b4Ebb3+nVJQRn4U3wJFgGzmshiMwR8tCmhLxykJSWc4
nKUKMXxntCwbBNeAJwtTaOhLNcjaB+cgL191f2yWHd+S+1p878zGU9LzvqegP/RR
RsVQoL/GW9zKMR9O+u21HLFk/HCl/bgg2CFEtRG3Cl6M5S2M/L3DYukq0L5ESS2j
BeVIVX758NPpf2WUlEEUDnODc18ZHzcRED+zDQ8sJ686Bu/NNENrpbkszKP6N1Vc
PQps/U5hCshDRkTWspgI8lW/6zQBuUxy4DT1iBPny9IGV8L4qbQetDZXR5u0IBTA
oHjX5vfybzRrPFnvaaaCHApSWRDgMrID9kTabKBsI302cx6YXwD7oykz9oRqUt5N
YZ/enYxx4WkYBhWIuqSxdNSZ+6VghDJ+PH6kV4rqHnknqzPk2YNbLJhR2NUsLywA
FZwBZ7BM+u4vdBIsTiWM
=T9gN
-----END PGP SIGNATURE-----
--=-=-=--
