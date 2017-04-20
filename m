Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:42905 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S937362AbdDTCPe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 19 Apr 2017 22:15:34 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Thu, 20 Apr 2017 12:15:27 +1000
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH] sunrpc: set cl_nodelen correctly when nodename truncated.
Message-ID: <87r30nsu2o.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


rpc_clnt_set_nodename() appears to assume that the return
value from strlcpy() is the size of the copied string.  It
is not.  It is the size of the string that strlcpy() was
asked to copy.  If truncation happened, the return value
will be longer than the buffer.

So we need to compare the returned value with the buffer size-1
and record the smaller of the two.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 net/sunrpc/clnt.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index b5cb921775a0..b62ab1a7bb98 100644
=2D-- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -287,6 +287,9 @@ static void rpc_clnt_set_nodename(struct rpc_clnt *clnt=
, const char *nodename)
 {
 	clnt->cl_nodelen =3D strlcpy(clnt->cl_nodename,
 			nodename, sizeof(clnt->cl_nodename));
+	if (clnt->cl_nodelen >=3D sizeof(clnt->cl_nodename))
+		/* nodename was truncated... */
+		clnt->cl_nodelen =3D sizeof(clnt->cl_nodelen) - 1;
 }
=20
 static int rpc_client_register(struct rpc_clnt *clnt,
=2D-=20
2.12.2


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlj4Gb8ACgkQOeye3VZi
gblJKw/+LB3q5kiNbRzzC3CCzKezjZ8APxxvmTR2js6kzxZ2F59gJi0DyNO1Qs94
cqYM/l/8Qaz20VU04QVOiaaewMrOvWflTGYBNswUn2JxKgpc9+U1CiXsHAL0MTPY
AwQQbx40M7NEbgbMy2PVCSHq/Wuilmbc7YSpRvefqHXU41o343wMtPgtyPYVdvVj
XRMH2Tu7QZRkgszdR0cGW1Gy9nmg09qt1ng3sufWMviX51OYcq5W6Jo4iWqTmEx+
IbRLwNq3tIeoRsdHgtF8zwSW97ZMAexyovqe8MYlYGMcyngUu3yoOM6MSoroWsyY
DvtUQ0YPVGzlGY5xt4N+NrrRlyC5YKZUcG7se6JSXwtoO7OqqDcRBLDH6FE1hOi8
kKTSK5/jUeo1y1ZvEhMCbeOkdY1n/+JusufOqemrRDriGJb2Ohv30hM8dowZxWAi
zO/j5kQLZP+jqgeCFazdaDvSW/wJ5YtrH3aoQsAS5SL3Hg3J4xrrtljJgXFHYMTo
2sYOAeKynp1bRufADzH2UVcWWUHPfNfxBG2c3u0MoX42tE3Vfp5kX1CFJXplShq1
HfSVOjzBPGQJR0ci/ddXq70LaYbcIIjOWGyTNb/KMZlrQAgay8E2tkclgRGPZZCH
UJeU5Emw79yN+nxUwhUZ38BP/T6DECcbV11oSDA/MQ2vCWiGyII=
=3PI3
-----END PGP SIGNATURE-----
--=-=-=--
