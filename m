Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:47858 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751535AbdFIGU0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 9 Jun 2017 02:20:26 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Date: Fri, 09 Jun 2017 16:20:17 +1000
Subject: Re: [PATCH V2] mount.nfs: Use default minor version when -t nfs4 is specified
In-Reply-To: <20170608183314.15247-1-steved@redhat.com>
References: <20170608183314.15247-1-steved@redhat.com>
Message-ID: <87a85hadi6.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Jun 08 2017, Steve Dickson wrote:

> When the nfs4 filesystem specified, the default major
> and minor versions should be used.
>
> Signed-off-by: Steve Dickson <steved@redhat.com>

Hi Steve,
 I think this is definitely heading in the right direction.
 I particularly like that you've #defined for the default major/minor.

 However as I reflected on it, I realised that "-o v4" needs to set
 the same version as "-t nfs4", and even with this patch it doesn't.

 I think we need to focus on nfs_default_version() and make sure it does
 the right thing.

 If v.mode =3D=3D V_DEFAULT, we need to copy both 'major' and 'minor'
 from config_default_vers if they are set.  If
 config_default_vers.v_mode =3D=3D V_GENERAL, .minor won't be set so in
 that case we need to use NFS_DEFAULT_MINOR;

 If v.mode =3D=3D V_GENERAL, then only copy the minor if it is set and the
 major is correct.  So we need to check for V_SPECIFIC, and other wise
 use the default minor.

 If v.mode =3D=3D V_SPECIFIC, nfs_default_version isn't called, so it
 doesn't matter.

 I think this gets it right...

 Thoughts?

Thanks,
NeilBrown

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index c0266e51ad1c..7dfdd9e62115 100644
=2D-- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -73,6 +73,13 @@
 #define NFS_DEF_BG_TIMEOUT_MINUTES	(10000u)
 #endif
=20
+#ifndef NFS_DEFAULT_MAJOR
+#define NFS_DEFAULT_MAJOR	4
+#endif
+#ifndef NFS_DEFAULT_MINOR
+#define NFS_DEFAULT_MINOR	2
+#endif
+
 extern int nfs_mount_data_version;
 extern char *progname;
 extern int verbose;
@@ -110,22 +117,27 @@ static void nfs_default_version(struct nfsmount_info =
*mi)
 	}
=20
 	if (mi->version.v_mode =3D=3D V_DEFAULT &&
=2D		config_default_vers.v_mode !=3D V_DEFAULT) {
+	    config_default_vers.v_mode !=3D V_DEFAULT) {
 		mi->version.major =3D config_default_vers.major;
=2D		mi->version.minor =3D config_default_vers.minor;
+		if (config_default_vers.v_mode =3D=3D V_SPECIFIC)
+			mi->version.minor =3D config_default_vers.minor;
+		else
+			mi->version.minor =3D NFS_DEFAULT_MINOR;
 		return;
 	}
=20
 	if (mi->version.v_mode =3D=3D V_GENERAL) {
=2D		if (config_default_vers.v_mode !=3D V_DEFAULT &&
+		if (config_default_vers.v_mode =3D=3D V_SPECIFIC &&
 		    mi->version.major =3D=3D config_default_vers.major)
 			mi->version.minor =3D config_default_vers.minor;
+		else
+			mi->version.minor =3D NFS_DEFAULT_MINOR;
 		return;
 	}
=20
 #endif /* MOUNT_CONFIG */
=2D	mi->version.major =3D 4;
=2D	mi->version.minor =3D 2;
+	mi->version.major =3D NFS_DEFAULT_MAJOR;
+	mi->version.minor =3D NFS_DEFAULT_MINOR;
 }
=20
 /*

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlk6PiMACgkQOeye3VZi
gbkQDw//U5GZYBqfA3rNIud8nwNF9su50xtDceoRFJdGPqoLC2R6rmVqH+bOl0mO
WtEa77sSyCEqRwPsALH67BW1SlzYAVYqI1U2ZMmxAQmR+tmDK5QanyNXGfBwho6q
WHI3AQKG74npDmnh1w+//BEbFzTF+UQ/uCEjhVr3pjKCOJIA7/AGurp9t1rAXpiS
RfZ8pd415175A6PfUQ9GebbuZmpVmEKmBtopUeySpwE3Z19PoegugTcYV1JfSE4V
XDNA9K0kk92UHKYl4eyHfcirpvjuAbBOa9J9MBzRrXGJ/PmUP05cl7FqaKExJWty
AwZA4Wo8+/yjsKeEkubf8zq5RxYqMDnr1WJ+feq7UjlsyvCMOwb1uX0LdlXphJ9/
Kqo3DCpPF+gxrijHJTYwf9AjR3x+VJJaDfbUkPKojkgLo5S4WCv0mx/DRAeLlM9/
130Aoy8eNMvO6Y4b+YMz2i7pMhU9HK11dhJsO8P5Ml0Ck9AtGnbJI2j1EKaFEPGi
K7tc+SXPzTHRgnFIrychoBmhqo2br+i7BXhWa0Hfwh99McNpBrweS3TdpHOxTiaG
Soq76LaLu/c2HlFWtTTGx27a8rprLY/WLWJNaPpYgFUuZixTZRxujcWDJhxcYkvL
4B/a2YNAgVrhGo+KoEcbb2C+xq6O+n1zO2VTxzgsWqembKALpE4=
=8Mi+
-----END PGP SIGNATURE-----
--=-=-=--
