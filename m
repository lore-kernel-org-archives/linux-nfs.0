Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:37271 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932197Ab2GEWeg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Jul 2012 18:34:36 -0400
Date: Fri, 6 Jul 2012 08:34:30 +1000
From: NeilBrown <neilb@suse.de>
To: stable@vger.kernel.org, "J.Bruce Fields" <bfields@fieldses.org>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH] Revert "svcrpc: destroy server sockets all at once" from
 2.6.32.y
Message-ID: <20120706083430.4bdb1bad@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/fCb7XyOy22uvp3Y33oqQEUx"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/fCb7XyOy22uvp3Y33oqQEUx
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


This reverts commit 4ad71a69292de1f9d8f7a38a3f7e6508e89b3089 from 2.6.32.y

That commit (2fefb8a09e7ed251ae8996e0c69066e74c5aa560 in mainline)
was not a bugfix.  It was sent to -stable because it is a necessary
precursor for
   commit b4f36f88b3ee7cf26bf0be84e6c7fc15f84dcb71
      svcrpc: avoid memory-corruption on pool shutdown

However that patch didn't make it to 2.6.32.y, presumably because it
doesn't apply.  So this commit (2fefb8a09e7e) shouldn't have been
applied either.

It is a problem because in 2.6.32, it is important to delay destroying
the permsocks until after ->sv_shutdown has been called.  The nfsd
sv_shutdown walks the list of permsocks and calls lockd_down() for each.
If the permsocks have already been closed, lockd_down() isn't called
so the lockd thread never exits.

(upstream commit
   commit ac77efbe2b4d2a1e571a4f1e5b6e47de72a7d737
      nfsd: just keep single lockd reference for nfsd
 changes nfsd so that the patch being reverted here is safe.
 It went into 2.6.36).

Cc: "J.Bruce Fields" <bfields@fieldses.org>
Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index da2e7df..1b353a7 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -34,7 +34,7 @@ struct svc_sock {
 /*
  * Function prototypes.
  */
-void		svc_close_all(struct svc_serv *);
+void		svc_close_all(struct list_head *);
 int		svc_recv(struct svc_rqst *, long);
 int		svc_send(struct svc_rqst *);
 void		svc_drop(struct svc_rqst *);
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 3d98b6e..e664aa5 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -475,11 +475,16 @@ svc_destroy(struct svc_serv *serv)
=20
 	del_timer_sync(&serv->sv_temptimer);
=20
-	svc_close_all(serv);
+	svc_close_all(&serv->sv_tempsocks);
=20
 	if (serv->sv_shutdown)
 		serv->sv_shutdown(serv);
=20
+	svc_close_all(&serv->sv_permsocks);
+
+	BUG_ON(!list_empty(&serv->sv_permsocks));
+	BUG_ON(!list_empty(&serv->sv_tempsocks));
+
 	cache_clean_deferred(serv);
=20
 	if (svc_serv_is_pooled(serv))
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 314320a..cc1fb36 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -927,7 +927,7 @@ void svc_close_xprt(struct svc_xprt *xprt)
 }
 EXPORT_SYMBOL_GPL(svc_close_xprt);
=20
-static void svc_close_list(struct list_head *xprt_list)
+void svc_close_all(struct list_head *xprt_list)
 {
 	struct svc_xprt *xprt;
 	struct svc_xprt *tmp;
@@ -945,15 +945,6 @@ static void svc_close_list(struct list_head *xprt_list)
 	}
 }
=20
-void svc_close_all(struct svc_serv *serv)
-{
-	svc_close_list(&serv->sv_tempsocks);
-	svc_close_list(&serv->sv_permsocks);
-	BUG_ON(!list_empty(&serv->sv_permsocks));
-	BUG_ON(!list_empty(&serv->sv_tempsocks));
-
-}
-
 /*
  * Handle defer and revisit of requests
  */

--Sig_/fCb7XyOy22uvp3Y33oqQEUx
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBT/YWdznsnt1WYoG5AQLsOg//Q9EfkAdn5oMrGIUrowDtV5HI8tgvZE3e
2jc46Wuv5qVHjPibO3jS5/4gSCptHR7siV5474nyVUeUkqSiYNkGW9BD6A34/t15
idNP37E0hiMMjb4aYktmF1uxMcw7yqY6fgwhOuCZjhFbfDCpudYDXCGqnpgx+yk2
jEKrdcTRCUam+pIVqtySPDBTjjsMD4uRNu5vWa6J1LxPjftsSI/0ledvuSRw6BfB
6py3vUN4qRzL6f6kDScF0rdGwjcoqcFvS0TUZ/EZkVR153XAnJcY/cuAJNu7j1HH
sbqqDRRnT1VmJXrtcpS5zBljiBNckn/S1MFrxhph7uBCOeCjgjxTyLWHCn8aUTXy
mWj8lz/rPoTuRm0e+fQ+j2KXvqwMzU1dfWOwxqWI1EpUvj3MwQaE4Hw1E8nb4SbN
Dz6mRH2/wa0XFgMyruq3HCxkVWpSVysO4sHViCxxdqLxcydzsUWlNVj156x4vT2D
KLTQXFhAGVEX8GGqgTJwYFvEnuwbQ+a/MG2e293bYZfP0KK5NGCA6bdoSnOLsLrQ
bB76ag2dP9dC0M8Xnf65qUQlOByefWuvmQK8NZxzQ9jVW1Xy5oQ6rHj+nIOCDk9C
l5dD7DD9DDuEkHIhm+Z6IdLXeJjNsgk1n0cREE0zV+zgrmw3Jt/+z1Grn/SBePXs
v2vphYlOzkE=
=lX+I
-----END PGP SIGNATURE-----

--Sig_/fCb7XyOy22uvp3Y33oqQEUx--
