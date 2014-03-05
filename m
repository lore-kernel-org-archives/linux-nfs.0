Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:52580 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755237AbaCEEHw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Mar 2014 23:07:52 -0500
Date: Wed, 5 Mar 2014 15:07:41 +1100
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, Simo Sorce <simo@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH: nfs-utils] mountd: use SONAME fir libnfsjunct when loading
 with dlopen.
Message-ID: <20140305150741.19cead16@notabene.brown>
In-Reply-To: <20140305144503.7310db31@notabene.brown>
References: <20140226161646.1520358b@notabene.brown>
	<1393425572.18299.157.camel@willson.li.ssimo.org>
	<3A4B7C90-54B8-4373-B751-B02D940199BC@oracle.com>
	<20140227095859.19ba8a87@notabene.brown>
	<6259E7ED-5D8C-4E29-A8B3-E0D11F2D6FFB@oracle.com>
	<20140305144503.7310db31@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/46Z.hdHP+0AjjTy1T.yXUIy"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/46Z.hdHP+0AjjTy1T.yXUIy
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable



The standard for loading shared libraries is to identify them by their
"soname" (Which "objdump -x $BINARY | grep SONAME" will report).
However mountd currently loads using the "linker name" which should only
be used when building new code.

Future releases of fedfs-utils will define the soname in the include
file, so if that is defined, use it.  If not, use the soname of the
first version: "libnfsjunct.so.0".

This is a slight behavioural change.  However all distros known to
package fedfs-utils will install "libnfsjunct.so.0" whenever they
install the old name of "libnfsjunct.so", and "make install" will
install both.  So it should not be a noticeable change.

Also only test the JP_API_VERSION if it is defined.  As the version is
embedded in the soname, a secondary test is not needed.

Cc: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index ca35de28847a..9a1bb2767ac2 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -1087,12 +1087,13 @@ static struct exportent *invoke_junction_ops(void *=
handle, char *dom,
 			__func__, error);
 		return NULL;
 	}
+#ifdef JP_API_VERSION
 	if (ops->jp_api_version !=3D JP_API_VERSION) {
 		xlog(D_GENERAL, "%s: unrecognized junction API version: %u",
 			__func__, ops->jp_api_version);
 		return NULL;
 	}
-
+#endif
 	status =3D ops->jp_init(false);
 	if (status !=3D JP_OK) {
 		xlog(D_GENERAL, "%s: failed to resolve %s: %s",
@@ -1139,7 +1140,11 @@ static struct exportent *lookup_junction(char *dom, =
const char *pathname,
 	struct link_map *map;
 	void *handle;
=20
-	handle =3D dlopen("libnfsjunct.so", RTLD_NOW);
+#ifdef JP_NFSPLUGIN_SONAME
+	handle =3D dlopen(JP_NFSPLUGIN_SONAME, RTLD_NOW);
+#else
+	handle =3D dlopen("libnfsjunct.so.0", RTLD_NOW);
+#endif
 	if (handle =3D=3D NULL) {
 		xlog(D_GENERAL, "%s: dlopen: %s", __func__, dlerror());
 		return NULL;

--Sig_/46Z.hdHP+0AjjTy1T.yXUIy
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUxajDTnsnt1WYoG5AQI/fxAAr0Nk6fftOXbJZpy7iai8h45HAu9bJaHe
diLV9do3CANhvlE58hhXtRO6UuoVXKXICOhoeobC1fpfG9J0hNdXvVyaDtu8joaT
fpJlvhEmEydov8BYha0p9ZLZkVFE5b5RztabT18lJfPDPCb9IiYiFB3sgqaNPrKO
pUQC2l6I+IvezGvZn13PI5RVkyJZFuGkFc+1bOJ0w1KeQHiDEiySywV29wDMa4xv
jZA18XpVOb6VfeswOAtU8RiGLXGWZMGVSk3l5DcyN+x+NcNS2Lkm9qUT2f1VSDa5
3mgCLNB7HD2icgJDC6a58HPE6AB3B03xTa26kR1wGnJclrlM4FyM4sk0I2+PFNDE
kP9YREfLWaS9NLMfyH1eqRXjCquo5le8P3CHEZNyqg167az9Czq8lBD3P6/RmbH5
NZ6JhDuWBtVM72rsTlxnxAHZRCyuYxazZqwkR4BBAkfF4x9hkSt2R+71Y4CWiG10
yrc/02dxW6rXiISstT7i4P1LrRShBNw0McA+74/Ac8PF/Ox2e9fVt/3JZ6xqtA7k
66kp1X3gyOUbuxz6624rV8Ou4jKHZs+L8HlLrpNS1skkmUE+7Q5Z9dc2okMLwBxb
q1a/V91IkTy2bhLXyQtX2ZtP7CDtzD1n01pQLyGDUA7oL+F00uBE10vjnuWXUiJa
emTjP4eMhck=
=5Y3z
-----END PGP SIGNATURE-----

--Sig_/46Z.hdHP+0AjjTy1T.yXUIy--
