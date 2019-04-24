Return-Path: <SRS0=08pM=S2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2915BC10F03
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 02:00:18 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id F1862218D3
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 02:00:17 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727085AbfDXCAR (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 23 Apr 2019 22:00:17 -0400
Received: from mx2.suse.de ([195.135.220.15]:42098 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726461AbfDXCAR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 23 Apr 2019 22:00:17 -0400
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 4B8CDAC3A;
        Wed, 24 Apr 2019 02:00:16 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     Jeff Layton <jlayton@kernel.org>
Date:   Wed, 24 Apr 2019 12:00:08 +1000
Cc:     Bruce Fields <bfields@fieldses.org>, slawek1211@gmail.com,
        "open list\:NFS\, SUNRPC\, AND..." <linux-nfs@vger.kernel.org>
Subject: [PATCH] locks: move checks from locks_free_lock() to locks_release_private()
In-Reply-To: <CAOhYWN+qtb3fRRbxJBMOCyyivc5-rYAfeVZ362HxWjett+UGHQ@mail.gmail.com>
References: <20190422163424.19402-1-jlayton@kernel.org> <20190422163424.19402-2-jlayton@kernel.org> <87wojl61s5.fsf@notabene.neil.brown.name> <CAOhYWN+qtb3fRRbxJBMOCyyivc5-rYAfeVZ362HxWjett+UGHQ@mail.gmail.com>
Message-ID: <87r29s5fiv.fsf@notabene.neil.brown.name>
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


Code that allocates locks using locks_alloc_lock() will free it
using locks_free_lock(), and will benefit from the BUG_ON()
consistency checks therein.

However some code (nfsd and lockd) allocate a lock embedded in
some other data structure, and so free the lock themselves after
calling locks_release_private().  This path does not benefit from
the consistency checks.

To help catch future errors, move the BUG_ON() checks to
locks_release_private() - which locks_free_lock() already calls.
This ensures that all users for locks will find out if the lock
isn't detached properly before being free.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 fs/locks.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 71d0c6c2aac5..456a3782c6ca 100644
=2D-- a/fs/locks.c
+++ b/fs/locks.c
@@ -352,6 +352,12 @@ EXPORT_SYMBOL_GPL(locks_alloc_lock);
=20
 void locks_release_private(struct file_lock *fl)
 {
+	BUG_ON(waitqueue_active(&fl->fl_wait));
+	BUG_ON(!list_empty(&fl->fl_list));
+	BUG_ON(!list_empty(&fl->fl_blocked_requests));
+	BUG_ON(!list_empty(&fl->fl_blocked_member));
+	BUG_ON(!hlist_unhashed(&fl->fl_link));
+
 	if (fl->fl_ops) {
 		if (fl->fl_ops->fl_release_private)
 			fl->fl_ops->fl_release_private(fl);
@@ -371,12 +377,6 @@ EXPORT_SYMBOL_GPL(locks_release_private);
 /* Free a lock which is not in use. */
 void locks_free_lock(struct file_lock *fl)
 {
=2D	BUG_ON(waitqueue_active(&fl->fl_wait));
=2D	BUG_ON(!list_empty(&fl->fl_list));
=2D	BUG_ON(!list_empty(&fl->fl_blocked_requests));
=2D	BUG_ON(!list_empty(&fl->fl_blocked_member));
=2D	BUG_ON(!hlist_unhashed(&fl->fl_link));
=2D
 	locks_release_private(fl);
 	kmem_cache_free(filelock_cache, fl);
 }
=2D-=20
2.14.0.rc0.dirty


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAly/wygACgkQOeye3VZi
gbm98A//dJd3a9vasGk3V/zAjeu9zlBjxlNEfESnJVjj9EwHXIEF7w+2Si7lNiHD
NKfJhW5AHctAUx3UwzNZSDgT5JUNs4QR6GRK5EaZXvp5reDEIsL4aA4W9nfqGob6
PH+X5DFydpBy+nwxBHjmu6bc9NEvkpRwVyzfEZWPSzdc7WgHwe0rDkHi3GTZSfh/
3MKYBc/j31mAfReDkMakGZrh5fIpegI4+PaYnN9638lRKQLIDX3kXwXzGVqqk8VE
rcko5tbypCTt1icCoPV/S9y3dbq6+x6Jy/S9OT+K/4TP5vXGbAiMUlOtAxgAMdiW
KuwESC48Ajy0W5VBXnLNGc3a17NCHjOicNjhsXLLTQch3uzVpDv/8BRHP+R9KZ/d
HOPjON/aaxfSePzKVbEBuGWFdjeOEh2ijJfpkevwLxqbRQ3X1NbkmueTLfeDUIeK
0CvKg0wt6qwx4xmWZnMqjduhQyvjXXq0njw4RjQvRsaBkx39hV76JOnRbjpcVPkZ
XCSMvPPpwPYMypPy279OD3LQToJLbBZTWxHOoXnpofc96ULBmURlXrEP4uT51Eo2
Zi5k2RQTVZTRNjlu6sKTRE95WXXNbrIFoNNwroYi0HSdtos6uia2HJ4e0Y4iZjLV
aSIc2GWEanAsJSoGSzGGkxAO1TUbFScP/pL0xFUC2icr+C4SoKU=
=upqO
-----END PGP SIGNATURE-----
--=-=-=--
