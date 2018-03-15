Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:59934 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932841AbeCOXaG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 15 Mar 2018 19:30:06 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Fri, 16 Mar 2018 10:29:57 +1100
Subject: [PATCH] NFSv4: handle EINVAL from EXCHANGE_ID better.
cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-ID: <87bmfoc3yi.fsf@notabene.neil.brown.name>
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
 fs/nfs/nfs4state.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 91a4d4eeb235..7e237bb9c699 100644
=2D-- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -2219,6 +2219,8 @@ int nfs4_discover_server_trunking(struct nfs_client *=
clp,
 		clnt =3D clp->cl_rpcclient;
 		goto again;
=20
+	case -NFS4INVAL:
+		/* Server confused - assume this minor isn't supported */
 	case -NFS4ERR_MINOR_VERS_MISMATCH:
 		status =3D -EPROTONOSUPPORT;
 		break;
=2D-=20
2.14.0.rc0.dirty


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlqrAfUACgkQOeye3VZi
gbmAZg//bRFgLFRBNsMwnMf3s3nYXeM2MEaZoVfxLaXtC5LBS0s0WMk8+tIwe9O7
IUh+g/ORHFczaqAyKfqDmLFwnyMIA6iLi5MAFHwm7JYTxLvznrRay+l3SzNmcb4G
GdoB+Rt7uD72CO7Y8/CyZkxwi2nSLzLod1r3mchYc+lTAS8We1Wpl6CINXVptLlh
o9KuiGVNC7elZuql7WHNLX6ZJC8mVG9vmuYVSLED79iOOp7cU9wcw7/aR/aHTPty
Fz/KkocrwxQze4rhEYXGKgn11c9485ZJGpb1ylQD652lMwXGIIGESAZVMVJIpwgv
SmARxthoZxNKFRFwYol0F0YYzAFGaHWR7b4xIoDPLMv4h9SCLZnv5OvH4ec4egSy
jNH/8e+J8R7At5WKIHcVYYa0ARpvtaMfHk/lDRPvZWVxtwb8dECB/6UiumQ0XXHN
XLa41vF6fY58AWy/ky2FmGFxOHJlNy1mzTzU4svuV7JCDkLoyNzveesiWcOsDAfw
xJlG4kmKgpnTzc+gJE3fHbFitZ5861p4D7sV4hpwNtjUT7/PT/eB9bYyWyOL/NiB
bekZ/L5BYWE3a177evde7mMhlV0O7Ud7e6bG07ThLuvDMAvcsMMMjv1/0idrux9V
FyxYj6hL97mXAnTMnsu4PSy6LJU7A6eZQMl6gUtwEMmFWZ+RH3Q=
=J+eg
-----END PGP SIGNATURE-----
--=-=-=--
