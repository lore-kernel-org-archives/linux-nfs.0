Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:52461 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751179Ab3DXFf3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Apr 2013 01:35:29 -0400
Date: Wed, 24 Apr 2013 15:35:17 +1000
From: NeilBrown <neilb@suse.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH-RFC] NFS: don't use STABLE writes during writeback.
Message-ID: <20130424153517.4222da09@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/2U3O=YcfYUAEzrFTQSv4OMu"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/2U3O=YcfYUAEzrFTQSv4OMu
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


Hi Trond,
 you might remember little over two years ago we discussed an issue with
 small O_SYNC writes which resulted in commit
   b31268ac793fd300da66b9c28bbf0a200339ab96
 The Subject: of the emails was "Small O_SYNC writes are no longer NFS_DATA=
_SYNC"

 This solved the problem at the time but created a new one.  Now *all* small
 writes are NFS_FILE_SYNC whether they are O_SYNC or not.
 The following seems to work for me without apparently introducing any regr=
essions.=20

 Thoughts?

Thanks,
NeilBrown



commit b31268ac793fd300da66b9c28bbf0a200339ab96
  FS: Use stable writes when not doing a bulk flush

was a bit heavy handed.
The particular problem that lead to this patch was that
small writes to an O_SYNC file we being written as UNSTABLE writes
followed by a commit.
This is appropriate for large writes (which require multiple NFS
requests) but for small writes (single NFS request), using
NFS_FILE_SYNC is more efficient.

So that patch causes the code to select between the two methods
depending on how many nfs requests get generated.

Unfortunately this ends up applying to non O_SYNC writes as well.
In particular if you memory-map a file and update random pages, then
when they are eventually written out by writeback they will go as
NFS_FILE_SYNC.  This is inefficient and slows down the application.


So: only set FLUSH_COND_STABLE when wbc->sync_mode is WB_SYNC_ALL.
With this patch:
 O_SYNC writes are NFS_FILE_SYNC for single requests, and NFS_UNSTABLE
    followed by COMMIT for multiple requests
 Writing immediately before close of fsync follow the same pattern.
 Non-O_SYNC writes without an fsync of close eventually get flushed
 out as UNSTABLE and a commit follows eventually as appropriate.

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index c483cc5..05220b5 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -225,11 +225,14 @@ static void nfs_mark_uptodate(struct page *page, unsi=
gned int base, unsigned int
=20
 static int wb_priority(struct writeback_control *wbc)
 {
+	int ret =3D 0;
 	if (wbc->for_reclaim)
 		return FLUSH_HIGHPRI | FLUSH_STABLE;
+	if (wbc->sync_mode =3D=3D WB_SYNC_ALL)
+		ret =3D FLUSH_COND_STABLE;
 	if (wbc->for_kupdate || wbc->for_background)
-		return FLUSH_LOWPRI | FLUSH_COND_STABLE;
-	return FLUSH_COND_STABLE;
+		ret |=3D FLUSH_LOWPRI;
+	return ret;
 }
=20
 /*

--Sig_/2U3O=YcfYUAEzrFTQSv4OMu
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUXdvFTnsnt1WYoG5AQJwxQ//b3Ljjm7fNfHzxLuRqIMe25RGYmTNBmyx
rAGKRXZ0m88ErLh7vjM3R42uYNyd9z5TiKJAIzcDtNWH7rPC0ndPOq+5KAKn778t
DLtgH7nM/DK8lGMykLIZxk++3nCMZFtwAMQG0WLq1kQvSTdsEkg8qFYV42kUvn16
0gvS8WT65FwxOkFq2h+kFXwel46ajMqtBZ2/OQqFa4SbB3enBCTyR8m8UHKsl6FF
rH3CK78erNE5Wp1eOwdoNfIUY9WV48mBdtoMBs4Kao1/hJZXX407M1f6LEx+T2Nf
kXgVxtYnW3L7U4vZohqXbE7GVpHfZttyVZ/gszUtysn2yjOwWmH7p2nKSl/3dsS+
9Nlc7xdkuUfbgig+AjJdfAXqX1DwSZ3EFFmQ2hfnaMLdfTLKWPmVzZ7XIVkP2Efs
WA/5nJlnCHYK4wo4OqlHhlZ8nIxyrnQDdyujy+MJcq/rwuBfQW4X/HTCIAnZ7JKr
Xwb9uBMS7v+M2tfAERX1AhIPi0rAj11/evwSumUqgnvUDxfNBgmzn2oe7q3q5fbi
W7uANdq+Kg8KLxSIkDgr+t+8zrnY6H/tAkILCzEeUWxMu2q34jFs+99PEkxLVbi3
4s0NNO2zHIX9lymCY9sW1ltyt1tMKggMNW20irJ2Ldv3ZVmHphRG6CStr5zTaeuB
fdzeGE+hp2U=
=MyFS
-----END PGP SIGNATURE-----

--Sig_/2U3O=YcfYUAEzrFTQSv4OMu--
