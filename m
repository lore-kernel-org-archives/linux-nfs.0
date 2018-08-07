Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:41576 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726975AbeHHBgz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 7 Aug 2018 21:36:55 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Wed, 08 Aug 2018 09:20:02 +1000
Subject: [PATCH] NFS: Use an appropriate work queue for direct-write completion
cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Message-ID: <878t5hydb1.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


When a direct-write completes, a work_struct is schedule to handle
the completion.
When NFS is being used for swap, the direct write might be a swap-out,
so memory allocation can block until the write completes.
The work queue currently used is not WQ_MEM_RECLAIM, so tasks
can block waiting for memory - this leads to deadlock.

So use nfsiod_workqueue instead.  This will always have a running
thread, and work items should never block waiting for memory.

Signed-off-by: Neil Brown <neilb@suse.com>
=2D--
 fs/nfs/direct.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 621c517b325c..aa12c3063bae 100644
=2D-- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -758,7 +758,7 @@ static void nfs_direct_write_schedule_work(struct work_=
struct *work)
=20
 static void nfs_direct_write_complete(struct nfs_direct_req *dreq)
 {
=2D	schedule_work(&dreq->work); /* Calls nfs_direct_write_schedule_work */
+	queue_work(nfsiod_workqueue, &dreq->work); /* Calls nfs_direct_write_sche=
dule_work */
 }
=20
 static void nfs_direct_write_completion(struct nfs_pgio_header *hdr)
=2D-=20
2.14.0.rc0.dirty


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAltqKSMACgkQOeye3VZi
gbnfBxAAsQmDECwLH6JuKN6lmOPVFoQR1odn1cLtQznviSUf8ekpz4eiKrSFKGaK
B+KdRxT9o/YGP5klcfzo6HqFT75tAo5Jo5ZE07zdc4txchm3OmbM8818fMbdcUA4
aJDtGpIsBHOACoUDEakXwUHjskRnSftR+Vbic7o3HWpy+NNwrjA8yaKRrBGKpmkK
BbsjlA2BOxt5Daad4zffbMSbrrR4nGE6vQg5FslKCmXp/StuxZyWYWbXac2+5QQJ
7mNdFXl0tKpU5LDLkwRUu4HbyONJjbtXTg4LGJN+k2W7i7HOY60cQMwF/JMcoa0e
a+UwPF7+MWWu4WVWqm8aeWR/YjzIYQePom/eZUloeqeV59049Q4anlLPxVbbS142
FZSlihq78dtaVfB2icZCZI9DmwmmJxZkxlQE0roc3F+/KGFikiYOB2E3r4XLmECR
fcpr4QGurz/gE0NEqCKnC/VG9a7zh9U+nC0estqRp2oZXZL6XBpT9pnMOPsa/V1Y
J/yWjCpbj1DoKTZ5tTA0XUJGv8nZIwg4Oanu+8H0YdmlkmDNHUXL4ntSH/tsxv0s
rugLNayT3Q/hXW/ZIgQt1SWKPBYoAQAiSbUWD+kOnWnV2YqtCZLOZTryo1Djrmzx
woTLNpmhuQdMsAWewxKWP4r+KA9xzUBt5iwS5pPly6ZKAuuYB4o=
=ERjw
-----END PGP SIGNATURE-----
--=-=-=--
