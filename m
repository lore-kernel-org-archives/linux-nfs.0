Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:56201 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753460Ab3BSAbR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Feb 2013 19:31:17 -0500
Date: Tue, 19 Feb 2013 11:31:02 +1100
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <steved@redhat.com>
Cc: NFS <linux-nfs@vger.kernel.org>, Leonardo Chiquitto <lchiquitto@suse.com>
Subject: [PATCH - nfs-utils] gssd:  use correct test for success of
 getrlimit()
Message-ID: <20130219113102.265d9d03@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/7AC02lUga91tEnOL7W/wYnE"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/7AC02lUga91tEnOL7W/wYnE
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


commit 7c5cb5e732a4b8704f8c79ec819c5d271e040339
    gssd: base the size of the fd array on the RLIMIT_NOFILE limit.

didn't actually work as claimed.  It only uses the returned value
if getrlimit() returns -1  -- which of course it only does when
there was an error.

So change the test to "=3D=3D 0".

Reported-by: Leonardo Chiquitto< lchiquitto@suse.com>
Signed-off-by: NeilBrown <neilb@suse.de>

--
hangs head in shame .... NeilBrown

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index c17ab3b..e10bda6 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -477,7 +477,7 @@ init_client_list(void)
 	TAILQ_INIT(&clnt_list);
 	/* Eventually plan to grow/shrink poll array: */
 	pollsize =3D FD_ALLOC_BLOCK;
-	if (getrlimit(RLIMIT_NOFILE, &rlim) < 0 &&
+	if (getrlimit(RLIMIT_NOFILE, &rlim) =3D=3D 0 &&
 	    rlim.rlim_cur !=3D RLIM_INFINITY)
 		pollsize =3D rlim.rlim_cur;
 	pollarray =3D calloc(pollsize, sizeof(struct pollfd));

--Sig_/7AC02lUga91tEnOL7W/wYnE
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUSLHxznsnt1WYoG5AQKKxhAAgliHvxAYJrlJIMLyK3BxX/lic22K2EF6
nZ89IXvh95f2wIQW/6gNRAqKLxOyj1mQji2lCDoBr/6OJO6bnU8gheImgAv8NQz8
vCmQTkyqlZXmXXklc+hZcUGLBhZf80pEWQza/MDHHlcbftCBJvMiPwBQ4PBTP3dp
c1fzbjJj3emQQrTUY101VASe/n6BpKJbsgK56gb2YTaW0wvg4Qj1zFeeLHqCf64i
aGW+D4FjillHo/vPPBh2+7dJ010fyGTmbbvgjK3WIPKWQ3YTbqQ9Ys662vAoN2H6
PaQFoSPk1+etceLdUVdZK21eGMOVqmjzd5DBy2FY4gPBVdommLHDWnNHdlDOBWMJ
y4VSKKOjCKZNhHjPRES884dFBM3EODX/kkH8kHCKm9sga06aI6alTmwGYXkd/Epc
iC7ahlKtkGYs4qcvRmM7AtaHI+c3yDFwM7OXrYC7agKGNZDYabd5KGo+WZgGiSVy
vUw61GtckHEXFiXroCQASQy4tqSvuBR/GbCZijHkS5AqUNqt7oRIAtXPrSd0IhNU
mOsD3ujoyKE/xIvj5oTklGNfd1eUO3R6l5V56JylT1cOVTD0SUG68i24zNijaYhb
hOpNUQs5rdRJEQnJkFhNm9ddlklGdiUrrfW2z2VFKCWY2xQgxW4VWIEkWWZLjDy/
ZKoe5v1dqck=
=vEcg
-----END PGP SIGNATURE-----

--Sig_/7AC02lUga91tEnOL7W/wYnE--
