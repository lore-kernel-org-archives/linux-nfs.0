Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:35932 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752186Ab3IBE6C (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Sep 2013 00:58:02 -0400
Date: Mon, 2 Sep 2013 14:57:50 +1000
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH - nfs-utils] gssd: suppress error message if rpc_pipefs dir
 disappears.
Message-ID: <20130902145750.357c303a@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/AFmSpe/YZ0_5mY3+pyQyOWr"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/AFmSpe/YZ0_5mY3+pyQyOWr
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


It is possible for a race to cause a name to appear when an rpc_pipefs
dir is scanned but to no longer be present when we try to open it.

So if the error is ENOENT, don't complain.

This is similar to

commit 5ac9bcfd820f09af4d3f87f1f7346d896f70bc9a
Author: David Jeffery <djeffery@redhat.com>
Date:   Wed Jan 16 15:21:55 2013 -0500

    rpc.idmapd: Ignore open failures in dirscancb()

which addressed a similar issue in idmapd.

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index b7e2bbb..2d3dbec 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -467,8 +467,9 @@ process_clnt_dir(char *dir, char *pdir)
 	}
 	sprintf(clp->dirname, "%s/%s", pdir, dir);
 	if ((clp->dir_fd =3D open(clp->dirname, O_RDONLY)) =3D=3D -1) {
-		printerr(0, "ERROR: can't open %s: %s\n",
-			 clp->dirname, strerror(errno));
+		if (errno !=3D ENOENT)
+			printerr(0, "ERROR: can't open %s: %s\n",
+				 clp->dirname, strerror(errno));
 		goto fail_destroy_client;
 	}
 	fcntl(clp->dir_fd, F_SETSIG, DNOTIFY_SIGNAL);

--Sig_/AFmSpe/YZ0_5mY3+pyQyOWr
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUiQazjnsnt1WYoG5AQLSEQ/+IeRIJLl2LQ/oWNmUAaRXuEFUMzns7Dpi
5NGMBScmE/Qyy7LnimMIUPN6XBIbyFcbvJ+4PdgAIBADaCSWeEwJGuIfcdFt1AVc
Z4+cfqIb9jATwzUEXlqm0nB773MUZP5AG9zlkuYXl0w9WyGyLOaqW53upYve/5qF
+fw68Up6pFKIDYb+vymhboS1y1KdjKoK7vrAlmOIyuGfhmovPKsfO8Qzsvs5W0Pl
EUqwYafypGdARPqzl8gwctaexuLfsvDdeCBUFbkoIynKbY8mziR297o20f8ccj1R
2dU2alOOSG57tKwEwNpURbsiwc9UtQ5Rim3TrRZoSPUrea7WHS6/0aVQaqkCJvo9
SPajGy5NbMdKb51Iu5XH8FoRfVEsp4xZplEACv6SRvOS/zctmm/04uplUeBZtdr6
yts+DwzDxxGDzOcsJNH+p2VWNe1lMotNKSKVOKL7ls6QgObcQKVHcIFHMNrrJcGV
bGHiZa3L3p69gbmonhjubhZRTbaVModd/JSiCIP/0TUnZmPVS+LvzYpKFnCq/Ayq
edYBxWBpna+unuhwZwHRUiRcxlU9UfMtC2Gc98eRvXkrTE7dKHH9CurvaXgkW9JG
wWInj+Fhv0JArBw4ucp12928X6oJw8gSp3kqFDZN6EWmDQVX15dirGSxGGiy0AQD
YWbxFclVcqA=
=iLNr
-----END PGP SIGNATURE-----

--Sig_/AFmSpe/YZ0_5mY3+pyQyOWr--
