Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:60890 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932981AbeCOXod (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 15 Mar 2018 19:44:33 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Fri, 16 Mar 2018 10:44:23 +1100
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH - v2] NFSv4: handle EINVAL from EXCHANGE_ID better.
In-Reply-To: <87bmfoc3yi.fsf@notabene.neil.brown.name>
References: <87bmfoc3yi.fsf@notabene.neil.brown.name>
Message-ID: <878tasc3ag.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


nfs4_proc_exchange_id() can return -EINVAL if the server
reported NFS4INVAL (which I have seen in a packet trace),
or nfs4_check_cl_exchange_flags() exchange flags detects
a problem.
Each of these mean that NFSv4.1 later cannot be use, but
they should not prevent fallback to NFSv4.0.

Currently this EINVAL error is returned by nfs4_proc_exchange_id() to
nfs41_discover_server_trunking(), and thence to
nfs4_discover_server_trunking().
nfs4_discover_server_trunking() doesn't understand EINVAL, so converts
it to EIO which causes mount.nfs to think something is horribly wrong
and to give up.

It would be a more graceful failure if nfs4_discover_server_trunking()
mapped -EINVAL to -EPROTONOSUPPORT - a failure to negotiate a client
ID clearly shows that NFSv4.1 cannot be supported, but isn't as
general a failure as EIO.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--

Sorry - a bit too trigger-happy with that first version of the patch.

NeilBrown

 fs/nfs/nfs4state.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 91a4d4eeb235..b988e460553d 100644
=2D-- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -2219,6 +2219,8 @@ int nfs4_discover_server_trunking(struct nfs_client *=
clp,
 		clnt =3D clp->cl_rpcclient;
 		goto again;
=20
+	case -NFS4ERR_INVAL:
+		/* Server confused - assume this minor isn't supported */
 	case -NFS4ERR_MINOR_VERS_MISMATCH:
 		status =3D -EPROTONOSUPPORT;
 		break;
=2D-=20
2.14.0.rc0.dirty


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlqrBVgACgkQOeye3VZi
gbkhrBAAusmljo87yE/ditzAbhDvQn7HmyctAH3TljBbgnULlbrs5B3WlgUKQV8e
0qK9ZCQoTh1cuOrdBD9xCbwsihe1FeBzxKJORHzk9zOCRyL6+O7ytU8GNp4qRNcW
zSdAtC9PWgmWAMrrnughQhRSIQaPXieTwwJoXw+Nfq+CLl+6hLtN/JfRGv3uckgO
9xiaxSnZTnK7VJD6JE8ZV5COdk3oUggXnTLa3hrAitZ+j2n7hmrdxn+3GjFv9zFe
TGKl3xxqB8u/LlaDiLDf+L2gnZW7OD6PnLGG/0JUdUHWlq8fk9DVuPvg8lb0O6tE
m1/I8S0FFntRSwt0NZNZe7N/vwRxK7VIZefVCkFREeNkJSYn1xCkDGq+Fmlm8ZDv
4Vq3UVLyovQlyhH4eHvdSohRzguSnnRyP4wlnDTay9BdlxnQ+Vhe56ztahx0wSw+
supYHe8E9fUlEWLGNvtpx7xcMO1/swEKPzwaC+ewguHTPp6+gKGlk+2hPv/A0kHK
rg2qA9t2X8dfjJ0eT4e+6BavHv/wSY1EDTGOwib+6eWmmNRreJ3RZDUAaPhGfKIL
0cAAbH18qbwopvdgqZJy9DMrjgllGVLla2l5kqm/fEMAvxLp/iV/IHmghGxRK/lZ
R7xPJCU1DbxZZg0PVUju24K66manxrS+zpbhLg7IaZRlGh6MECo=
=qsb0
-----END PGP SIGNATURE-----
--=-=-=--
