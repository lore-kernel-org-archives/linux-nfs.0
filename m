Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:44968 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753520AbcJUABX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 20 Oct 2016 20:01:23 -0400
From: NeilBrown <neilb@suse.com>
To: Andy Adamson <andros@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Fri, 21 Oct 2016 11:01:13 +1100
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFSv4.1: nfs4_fl_prepare_ds must be careful about reporting
 success.
Message-ID: <87lgxiwoxi.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


Various places assume that if nfs4_fl_prepare_ds() turns a non-NULL
'ds', then ds->ds_clp will also be non-NULL.

This is not necessasrily true in the case when the process received a
fatal signal while nfs4_pnfs_ds_connect is waiting in
nfs4_wait_ds_connect().  In that case ->ds_clp may not be set, and the
devid may not recently have been marked unavailable.

So add a test for ->ds_clp =3D=3D NULL and return NULL in that case.

Fixes: c23266d532b4 ("NFS4.1 Fix data server connection race")
Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 fs/nfs/filelayout/filelayoutdev.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/filelayout/filelayoutdev.c b/fs/nfs/filelayout/filelayo=
utdev.c
index 4946ef40ba87..85ef38f9765f 100644
=2D-- a/fs/nfs/filelayout/filelayoutdev.c
+++ b/fs/nfs/filelayout/filelayoutdev.c
@@ -283,7 +283,8 @@ nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg, u3=
2 ds_idx)
 			     s->nfs_client->cl_rpcclient->cl_auth->au_flavor);
=20
 out_test_devid:
=2D	if (filelayout_test_devid_unavailable(devid))
+	if (ret->ds_clp =3D=3D NULL ||
+	    filelayout_test_devid_unavailable(devid))
 		ret =3D NULL;
 out:
 	return ret;
=2D-=20
2.10.1


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYCVrJAAoJEDnsnt1WYoG5n04QAJQlCoiUj5YGbrR7jAyQS+mY
UGj0rWKWmAqKZUf789SY8SvQuHe7pD9a1MHi+XLQwBDv+ggrY/iBjdmOfC+iwKGI
tyJzGVdcN66oiVVTcWj58Z0irQHoEBlOCKEJGEHvF/xgVskxVhHQNv5Yr8nkNSR1
i1vYIBVNzU+WdYEjl1+90FdNlmmk8/wfnZ6xIXp1ZI8s/65GAcEviK5lMZC/rQo8
ZeG4vtOb8zsZsUId1KqzR6kb5jEjQEArKOvKGRIfhWayVij+kEZnBdQHKTt4hQt/
uv7Y529DgG973V448uurwoUQTRB5NBtNsfUoVsFSLIz8Wg4UoYwhbGbrVJ36PPhU
7RkGMJjs1OiFxtIC72jlmvHUN7Z3iLq8+6n5RqetOcRWm0oiXXaRymXNj6s08dZr
P/RDqFxwHNU/R8y9HoPU+jkc1Z3m9M0q1/Rwmmp7czOjuxeI6EDxBpJRQlNZC2NO
kjHTJey60Smemep1JZu41+X2CmvbHMmGMPFt8b+nBy/9F3gh5Gg5SK5FLzSc4Dpj
7Ow8wYzTzKu20rGLVuB12RQGIIOo6QExjLusDyhQClTYl7ZC7dA6OdGEFGGxDjbC
0D6KNijmhsfopwCDeevdSOgxXpYEvrUfcXVoM18fbqKrvas8gYSqVg+tyd1Y6K+u
CVGA81ZHfX9YQ9kqtYWL
=fdFt
-----END PGP SIGNATURE-----
--=-=-=--
