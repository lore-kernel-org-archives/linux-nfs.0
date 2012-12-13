Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:38844 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751947Ab2LMEOt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Dec 2012 23:14:49 -0500
Date: Thu, 13 Dec 2012 15:14:36 +1100
From: NeilBrown <neilb@suse.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFS: avoid NULL dereference in nfs_destroy_server
Message-ID: <20121213151436.19fdd22f@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/KEgVGnUenajQKh97o65rK48"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/KEgVGnUenajQKh97o65rK48
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


In rare circumstances, nfs_clone_server() of a v2 or v3 server can get
an error between setting server->destory (to nfs_destroy_server), and
calling nfs_start_lockd (which will set server->nlm_host).

If this happens, nfs_clone_server will call nfs_free_server which
will call nfs_destroy_server and thence nlmclnt_done(NULL).  This
causes the NULL to be dereferenced.

So add a guard to only call nlmclnt_done() if ->nlm_host is not NULL.

The other guards there are irrelevant as nlm_host can only be non-NULL
if one of these flags are set - so remove those tests.  (Thanks to Trond
for this suggestion).

This is suitable for any stable kernel since 2.6.25.

Cc: stable@vger.kernel.org
Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 8b39a42..5e8d24d 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -615,8 +615,7 @@ EXPORT_SYMBOL_GPL(nfs_create_rpc_client);
  */
 static void nfs_destroy_server(struct nfs_server *server)
 {
-	if (!(server->flags & NFS_MOUNT_LOCAL_FLOCK) ||
-			!(server->flags & NFS_MOUNT_LOCAL_FCNTL))
+	if (server->nlm_host)
 		nlmclnt_done(server->nlm_host);
 }
=20

--Sig_/KEgVGnUenajQKh97o65rK48
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUMlWLTnsnt1WYoG5AQLiVg//XTEKD3oMSGh9HF5UiTUwOv880r+/FlHJ
/SbVk8amlOMmYTlHB/MWd/gpasMWYIsvkqnL+oI/BCSvZPima4pSQFaFlCs3ZkE+
AkWuEQR334B9CQJznlTbJfO66mkK8bmkQgF+ioYahFV+OZFr7zmhAVGQ7DsJOp07
NWGsNlXKGk8xtcQxw0jtIaQ19jT/7oc1INnN0txcQvVRGNc8jte3mIf0sUQTOPj+
REiG1VCgkJR5yAQPu6q6mjYNMMDytXwV+2fUPGgNAkuVJ0Sb117pUxGot9OyIMnz
Gwn+dZLzPTSKgS4vhX/Rmt6zA0x0m9XURstxCkCYDbSp/KckQoMZW4qqmlpomoPe
DMcm151rTTf1oevURlfWtTtJXBmdcJatEUjpsaJdJrhqhR3TvApgrdLWj2s9TYoU
oM7QMdSBYHSRCjDoPNTf0IB83ScknHr50E1iZ3d17t/cproSM+xmzQj5gSP18acU
FMOvI+LCERFskzUjvU6E9FvWh0an70IXgVTGSQdPHFU2vbzmbZqOKgGCQ8Yo3Ufo
zWeaIz6cp1wvq3PNCvmLW1e3cE/mwWzUAd2vzEUzQ1YI5yHqX3ujFxJt0+uH4OYf
64JlPHGvEzdaUHj6Wyz864Q7lXx+eeYVEAAe8NfsMRQua+6mj4HnOBnUF4HoEdyz
tN9QyJTL9D4=
=0EZ3
-----END PGP SIGNATURE-----

--Sig_/KEgVGnUenajQKh97o65rK48--
