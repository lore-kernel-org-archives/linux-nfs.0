Return-Path: <SRS0=juBO=ON=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5CFDBC04EB9
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Dec 2018 00:42:37 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E76A32081C
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Dec 2018 00:42:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E76A32081C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725903AbeLDAmg (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 Dec 2018 19:42:36 -0500
Received: from mx2.suse.de ([195.135.220.15]:36410 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725915AbeLDAmg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 3 Dec 2018 19:42:36 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 79342AF86;
        Tue,  4 Dec 2018 00:42:34 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     Steve Dickson <SteveD@RedHat.com>
Date:   Tue, 04 Dec 2018 11:42:27 +1100
Subject: [PATCH nfs-utils] nfsidmap: honour --with-pluginpath for instalation.
cc:     linux-nfs@vger.kernel.org
Message-ID: <87y3966s24.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


The path set with --with-pluginpath is not currently
used when installing plugins.  It should be.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 configure.ac                 | 1 +
 support/nfsidmap/Makefile.am | 2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/configure.ac b/configure.ac
index 4163f6a518f5..4bf5aea4442f 100644
=2D-- a/configure.ac
+++ b/configure.ac
@@ -450,6 +450,7 @@ if test -n "$path_plugins" ; then
                 [Define this to change the plugins path])
 fi
 AM_CONDITIONAL(PATH_PLUGINS, test -n "$path_plugins")
+AC_SUBST(PATH_PLUGINS, "$path_plugins")
=20
 AC_SUBST(AM_CPPFLAGS, "$AM_CPPFLAGS")
 AC_DEFINE([HAVE_NFS4_SET_DEBUG], 1,
diff --git a/support/nfsidmap/Makefile.am b/support/nfsidmap/Makefile.am
index 8b5dfe4e784a..cdbeb4c1a9ac 100644
=2D-- a/support/nfsidmap/Makefile.am
+++ b/support/nfsidmap/Makefile.am
@@ -1,4 +1,4 @@
=2Dpkgplugindir=3D$(libdir)/libnfsidmap
+pkgplugindir=3D$(PATH_PLUGINS)
=20
 if ENABLE_LDAP
 UMICH_LDAP_LIB =3D umich_ldap.la
=2D-=20
2.14.0.rc0.dirty


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlwFzXQACgkQOeye3VZi
gbm3mxAAn2QirNt3ZBPnnmfrgMBO2DnzGw7mh3iBGy1Fk31BJOFshd5gYSTHXjHT
drvcRNDW6jl9jwVpYTuAJxgMilAV/wsRofTWKmcoIWtzH7Dto71PSGLLFJjFDfO+
MUrhWeQTjWGDbeMxAUETVODKP41TCFc3a2g/Ub3H6qWRH9k8SRtJPfpzpva55MUA
m5HsJtsZ0SWuVH08/4MNd+Qqi827Hvswr42cfjgJn8wl20I4/JB9Vy6XBgNg0Jcb
EDx7KpL5r8lESgvWds7hrjEvvImgz0EC6K07011ZCalS950YyeenuAfSjcIuvkhz
gODE74j1FgJW4hrLknwIeKvYjF2U2MvJbMvL/UMqxrxInIYO1P/4CeUtjVpcyIvH
lDv4XPrAyO+hQj/oAlfSrlXjpIrdK39nPr7tDtlXoSxTH1WO46UyoOx6W6nBdoFO
AVzzIgOkxghA02Ischd2SRWhmDhkcpSk7xSSgapEjK2mIPFxoZ34AN5BbEql82BR
hReQVITjwSl5E3CCg17IIZ9hVtcxdU9TzyRm5N3uc+P+yu3bRwklXxoMrMR+jLq4
ZoAB+x8L1DNZh6rUsOKqEmUFS7hxzvSG99hcvyzrStEiksbN0SlWfe/+Zep21kWb
jwnwLl25c9wrNIPAOkavsJ+Rx2/VDbUuSn0ZbM+rZaaRlNJVt7M=
=dYwE
-----END PGP SIGNATURE-----
--=-=-=--
