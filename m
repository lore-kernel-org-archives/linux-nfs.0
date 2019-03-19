Return-Path: <SRS0=azWf=RW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57D19C43381
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Mar 2019 00:33:34 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 15E47206BA
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Mar 2019 00:33:34 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726639AbfCSAdd (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 18 Mar 2019 20:33:33 -0400
Received: from mx2.suse.de ([195.135.220.15]:37208 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726575AbfCSAdd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 18 Mar 2019 20:33:33 -0400
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 3A8E9ADD4;
        Tue, 19 Mar 2019 00:33:32 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date:   Tue, 19 Mar 2019 11:33:24 +1100
Cc:     Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: fix mount/umount race in nlmclnt.
Message-ID: <877ecv8zzf.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


If the last NFSv3 unmount from a given host races with a mount from the
same host, we can destroy an nlm_host that is still in use.

Specifically nlmclnt_lookup_host() can increment h_count on
an nlm_host that nlmclnt_release_host() has just successfully called
refcount_dec_and_test() on.
Once nlmclnt_lookup_host() drops the mutex, nlm_destroy_host_lock()
will be called to destroy the nlmclnt which is now in use again.

The cause of the problem is that the dec_and_test happens outside the
locked region.  This is easily fixed by using
refcount_dec_and_mutex_lock().

Fixes: 8ea6ecc8b075 ("lockd: Create client-side nlm_host cache")
Cc: stable@vger.kernel.org (v2.6.38+)
Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 fs/lockd/host.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 93fb7cf0b92b..f0b5c987d6ae 100644
=2D-- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -290,12 +290,11 @@ void nlmclnt_release_host(struct nlm_host *host)
=20
 	WARN_ON_ONCE(host->h_server);
=20
=2D	if (refcount_dec_and_test(&host->h_count)) {
+	if (refcount_dec_and_mutex_lock(&host->h_count, &nlm_host_mutex)) {
 		WARN_ON_ONCE(!list_empty(&host->h_lockowners));
 		WARN_ON_ONCE(!list_empty(&host->h_granted));
 		WARN_ON_ONCE(!list_empty(&host->h_reclaim));
=20
=2D		mutex_lock(&nlm_host_mutex);
 		nlm_destroy_host_locked(host);
 		mutex_unlock(&nlm_host_mutex);
 	}
=2D-=20
2.14.0.rc0.dirty


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlyQONQACgkQOeye3VZi
gbnMKw//YxnQsajOe6+CAFw/4ZGiSpLMi53xr47BonxPsm1JW/8q0OMpa/IRSiSz
81HS0AWR8Oa1sZAeo/meSDzC5se9PySA/dP1K0ZP+OeHYfARDnKSAyAD45GVlg3Q
XX7LiEfjiJShsZbknLv6NlUMzMfp448O1m8+ZP74rJnCxJtb9HW/YjaAlwaFDPf7
y4EOVDLJAI8TOtMaTHO7CvalpU5bAuBBx9XIHUl0pOPskGfAsmSS6sPUfFnbrxV+
JOwcmRRRZQY6BacFjwZ0+nI2LocvWhZG3m8hzwtDNyBMeuQ6JgKILDkn00yzZeog
2lYZz6L9DF28k/Oarb7gbFg/QQm7+sNDP+WkHbiZIEOcPzYTpaxjbmJmZhbN9g0p
yCZpRchwkjG7i/Fz7e2mdmUAh9xFfaY83xF7Dub3Vk1ss3jLSNjBI6ZM48kvbnav
MdqpdvfW15/spQjOA0UMjaMChxHqgWIwrpHcLfBOIio2QE/4SaoUQTZkhXqTH/Rr
zZ6YTyrZbD4fYN2S82Ny0sH+RPIdwZz5BNLTknaV0LlOZQ3xOOrBzv9xnNy9zTjq
uJhcvjdswPg4abqHO7SPRPezlp79LXJ+x3WrNBFmfwagHdgkslvVrjuP8epGrIAk
6d7h8vFHSUyAskpyY6Myhhj1OUpKVD5av3hm1keAjs4oxmnzyrE=
=Zp+2
-----END PGP SIGNATURE-----
--=-=-=--
