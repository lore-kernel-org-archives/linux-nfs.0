Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:33276 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751670AbdEWX2F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 23 May 2017 19:28:05 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>
Date: Wed, 24 May 2017 09:27:55 +1000
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH/RFC] NFSv4: don't let hanging mounts block other mounts
Message-ID: <87vaori26c.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


If you try an NFSv4 mount from an inaccessible server, it will hang as
you would expect.
If you then try an NFSv4 mount from a different accessible server,
it will also hang.  This is not expected.

The second mount is blocked in
  nfs4_init_client()
  -> nfs4_discover_server_trunking()
  -> nfs40_discover_server_trunking()
  -> nfs40_walk_client_list()
  -> nfs4_match_client()
  -> nfs_wait_client_init_complete()
It is waiting for the first mount to complete so that it can then
see if the two servers are really one and the same.

It is not necessary to wait here when an nfs_client cl_cons_state is
NFS_CS_INITING.  Such a client will, after changing cl_cons_state, call
nfs4_discover_server_trunking() itself.  So if the current client just
skips those clients, trunking will still be discovered if necessary.

I am unsure of situation with NFS_CS_SESSION_INITING, but I suspect
that the comment "Wait for CREATE_SESSION to finish" implies that
it is only clients in NFS_CS_SESSION_INITING that need to be waited for.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 fs/nfs/nfs4client.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 692a7a8bfc7a..386901dfdca7 100644
=2D-- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -481,7 +481,7 @@ static int nfs4_match_client(struct nfs_client  *pos,  =
struct nfs_client *new,
 	 * remaining fields in "pos", especially the client
 	 * ID and serverowner fields.  Wait for CREATE_SESSION
 	 * to finish. */
=2D	if (pos->cl_cons_state > NFS_CS_READY) {
+	if (pos->cl_cons_state =3D=3D NFS_CS_SESSION_INITING) {
 		atomic_inc(&pos->cl_count);
 		spin_unlock(&nn->nfs_client_lock);
=20
=2D-=20
2.12.2


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlkkxXwACgkQOeye3VZi
gbkDUg/+PSjc5N5sZ6p2WQzE+/SXehSZPiM69nD2dzrldnf1YeQzYHHAV9/UvLmC
aR6NQN0Z9LAJKxwcmmNLgcL51Oav/eFSfX0xJL+v0q2ePGdGOxkJBLhaV797p5J4
NgUsk/eVCM8guQ83erN+MWToWXdxZp1hWPGpqeyfUln/3lsY9+XVaKwjlwN0ViA+
CXkXsAyzGt9hFupWcy4AXHM/LzSPWKUdW0CADGHuDQYaE4Hys5HA0I87IbUrwYJ/
W4HKtvSMyEQ+Wc5ipOm9Dd8RJBHFmoP9pPsJ8NtedXAEANzH8xyP3nDL9M+kPCsC
peeIA293yvajbiFSuzPSjuANwdB8ADkUQAfx8JwfGkf7YAwp+YF4Tf8F/MZWm6nd
B9afstRcrEEMyyFykOihQLWnY28sXHDd9K4ZEGbPTIhNHQyWUhpAJBLYVYTUoL6H
IBfbK8gtPiKS5BpVg+HISF/3Ge1rgm+pVFy2VpWkDKMWpgnDBC7TxPmafpHKK5ki
XGEej4Djk57bhDkePMu1FTEMyTfySiS5OQDnsP4kzKtyqNH4uNDKDYbaSxOpaHnP
RFrNQl7UhBmwDwaplLg9PrrwQjDKOq75ulCUtO55CqqyyZMWAMCpWP25rR3BIqkk
52n9GuotKDpbnIWosN9/GZ0a+Kk+EpQNUKN8lZslwgYEMPFkqK4=
=33eM
-----END PGP SIGNATURE-----
--=-=-=--
