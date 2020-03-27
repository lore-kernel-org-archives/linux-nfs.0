Return-Path: <SRS0=DrMw=5M=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2BD11C43331
	for <linux-nfs@archiver.kernel.org>; Fri, 27 Mar 2020 05:10:42 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0502320705
	for <linux-nfs@archiver.kernel.org>; Fri, 27 Mar 2020 05:10:41 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726071AbgC0FKl (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 27 Mar 2020 01:10:41 -0400
Received: from mx2.suse.de ([195.135.220.15]:50560 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725936AbgC0FKl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 27 Mar 2020 01:10:41 -0400
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx2.suse.de (Postfix) with ESMTP id 46EFCAFAA;
        Fri, 27 Mar 2020 05:10:39 +0000 (UTC)
From:   NeilBrown <neilb@suse.de>
To:     Steve Dickson <SteveD@RedHat.com>
Date:   Fri, 27 Mar 2020 16:10:33 +1100
Subject: [PATCH nfs-utils] conffile: Don't give warning for optional config files.
cc:     linux-nfs <linux-nfs@vger.kernel.org>
Message-ID: <87imiq7586.fsf@notabene.neil.brown.name>
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


A recent commit added the possibility of optional config files for which
warning messages would be suppressed.
Unfortunately only one of the possible warning messages - the least
likely one - was suppressed.

This patch suppresses the other.

Fixes: c6fdcbe0a5cf ("conffile: allow optional include files")
Signed-off-by: NeilBrown <neilb@suse.de>
=2D--
 support/nfs/conffile.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)


That was careless - sorry.  I really have tested this time.
NeilBrown

diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index d55bfe10120a..3d13610ee766 100644
=2D-- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -429,9 +429,9 @@ conf_parse_line(int trans, char *line, const char *file=
name, int lineno, char **
=20
 		subconf =3D conf_readfile(relpath);
 		if (subconf =3D=3D NULL) {
=2D			xlog_warn("config error at %s:%d: "
=2D				"error loading included config",
=2D				  filename, lineno);
+			if (!optional)
+				xlog_warn("config error at %s:%d: error loading included config",
+					  filename, lineno);
 			if (relpath)
 				free(relpath);
 			return;
=2D-=20
2.25.2


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAl59isoACgkQOeye3VZi
gbkumxAAgRGtWcFY7mZ3OuGeP0ZTxknMERRrceoNKS1eRogiSjLPn+GVVDgG7Z2f
HH81LBqmIcWv301lQWbOoMkIAJDz0pNiCKV3elY4raKHAjo/n+ELePmzzjxJWWUq
Bnvb258Ypz8CB7et8x/7wu4qLTv86SB7nbrkIi+nriOWPxPlTsSFiD4FCKsIHWd6
A4H6+JHYCwdvD38n3cXD+2C3zT9bKEiAWbb8MXXEV0NJA9PwegD/sSnLKF3qbsIC
uIU/njMY/N8ggDTp11bPaP4UVAO1lOad4CO65IQHj0F8jfcyGZbO6RcN9mYBtJD1
Ho15CrGDuSde+bLZGWeJ+y284QwE6rN2STZao9F++VZjljn/jSwjkvrp/FNKsX/l
t2rohQi5OvRbs8JC8BHn2k24VG9PoVAkGAic2x06Asq9lDiirM5FyAJRMKxcY+vl
Pai9TN4Rl8dgNit2xA5Eyg1kvwEXkEISDKP+ut7T3/QuYwvT5SZ9iPzZclhQ/VtL
HGinpJj9DtU+WBQEpAqbPLjp0wIO/+hqWLi08+CVdJK90jY4flf21h+okX5afQG7
CHeQY9gNOIZplwCsj2ZnLgUudMyiVr8byvNvImidXFVbqXt6D1teWdyimFcrBzJt
j6OgJ5BZrK7m8Mabt0ovJDyKx7QR0mS8bW+L4FypDAkFFMlMtHQ=
=9/w/
-----END PGP SIGNATURE-----
--=-=-=--
