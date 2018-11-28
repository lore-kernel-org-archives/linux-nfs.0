Return-Path: <SRS0=zHXY=OH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 961FEC43441
	for <linux-nfs@archiver.kernel.org>; Wed, 28 Nov 2018 00:54:00 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 60D7E2082F
	for <linux-nfs@archiver.kernel.org>; Wed, 28 Nov 2018 00:54:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 60D7E2082F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726457AbeK1Lxl (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 28 Nov 2018 06:53:41 -0500
Received: from mx2.suse.de ([195.135.220.15]:48402 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726418AbeK1Lxl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 28 Nov 2018 06:53:41 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
X-Amavis-Alert: BAD HEADER SECTION, Duplicate header field: "To"
Received: from relay1.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id E143AAC38;
        Wed, 28 Nov 2018 00:53:56 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     "J. Bruce Fields" <bfields@redhat.com>,
        kernel test robot <rong.a.chen@intel.com>
To:     Jeff Layton <jlayton@kernel.org>
Date:   Wed, 28 Nov 2018 11:53:48 +1100
Cc:     LKML <linux-kernel@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>, lkp@01.org,
        linux-nfs@vger.kernel.org
Subject: [PATCH] locks: fix performance regressions.
In-Reply-To: <87mupup0ot.fsf@notabene.neil.brown.name>
References: <20181127060102.GF6163@shao2-debian> <20181127174315.GA29963@parsley.fieldses.org> <87mupup0ot.fsf@notabene.neil.brown.name>
Message-ID: <87k1kyowdf.fsf@notabene.neil.brown.name>
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


The kernel test robot reported two performance regressions
caused by recent patches.
Both appear to related to the global spinlock blocked_lock_lock
being taken more often.

This patch avoids taking that lock in the cases tested.

Reported-by: kernel test robot <rong.a.chen@intel.com>
Signed-off-by: NeilBrown <neilb@suse.com>
=2D--

Hi Jeff,
 you might like to merge these back into the patches that introduced
 the problem.
 Or you might like me to re-send the series with these merged in,
 in which case, please ask.

 And a BIG thank-you to the kernel-test-robot team!!

Thanks,
NeilBrown

 fs/locks.c | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/fs/locks.c b/fs/locks.c
index f456cd3d9d50..67519a43e27a 100644
=2D-- a/fs/locks.c
+++ b/fs/locks.c
@@ -444,6 +444,13 @@ static void locks_move_blocks(struct file_lock *new, s=
truct file_lock *fl)
 {
 	struct file_lock *f;
=20
+	/*
+	 * As ctx->flc_lock is held, new requests cannot be added to
+	 * ->fl_blocked_requests, so we don't need a lock to check if it
+	 * is empty.
+	 */
+	if (list_empty(&fl->fl_blocked_requests))
+		return;
 	spin_lock(&blocked_lock_lock);
 	list_splice_init(&fl->fl_blocked_requests, &new->fl_blocked_requests);
 	list_for_each_entry(f, &fl->fl_blocked_requests, fl_blocked_member)
@@ -749,6 +756,20 @@ int locks_delete_block(struct file_lock *waiter)
 {
 	int status =3D -ENOENT;
=20
+	/*
+	 * If fl_blocker is NULL, it won't be set again as this thread
+	 * "owns" the lock and is the only one that might try to claim
+	 * the lock.  So it is safe to test fl_blocker locklessly.
+	 * Also if fl_blocker is NULL, this waiter is not listed on
+	 * fl_blocked_requests for some lock, so no other request can
+	 * be added to the list of fl_blocked_requests for this
+	 * request.  So if fl_blocker is NULL, it is safe to
+	 * locklessly check if fl_blocked_requests is empty.  If both
+	 * of these checks succeed, there is no need to take the lock.
+	 */
+	if (waiter->fl_blocker =3D=3D NULL &&
+	    list_empty(&waiter->fl_blocked_requests))
+		return status;
 	spin_lock(&blocked_lock_lock);
 	if (waiter->fl_blocker)
 		status =3D 0;
=2D-=20
2.14.0.rc0.dirty


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlv95xwACgkQOeye3VZi
gbk0jBAAjDCBtfHca0W64cD2SH8WRTmbw4F0oGVbrS63g96xW8ap6IkKDQYIV2d2
D2yHOyySmAhmQqKhG2sfcz5W3Mtib5FiauzVES7iz+o5cAvBErCzALfq3B76mBlY
Q3MnSGLge46xOpENsfUxkuboH/v3fYBIBdB/c7lK45XU32c8CJ6fRZzrBhn9lVI4
Ege1P1rpJiXMALuN/Csc0Lr9uX9PO7fQd9mvX/79noV2L02hzu7VytZ8XEoXnzFM
o/2gdSLmlSeCijH/t2loq8A6DPvuAhKTOHfkO4QNZFLQ9N6n9EizdpRhDbQtXlfZ
d3Hp3p3mf9/BtrNcYiNW85LEbffLhPH8mWTzt6aT5owd3Xx0KExQXQjakr7Rj2fp
EDXCpnilzSuh5Ia55nWGmBAA/hMeJYtKqp6mpErVkElFf/1qh3LbH7ixhlDJu+sp
AmOQm+E26V8nbTUWst4j8wIEq/ux4uzkRGlLqLGHbA0T9TZlyslGBrIl4/edJbZz
+ucFrjlzy1RSm7P86UvzV1s0cAgh9VS8Yto5/Ou26ZXrHIf+IjnAKPtF1q7lb+co
sGDxbLvHABmkTmaNs0NS6DFM3P2nIOgEb4pGCcYI8hJtu+KcuTZlKRwMP4PlALzc
frcFONJYdcwl5Ad1ZY32hi2v8q/LfnEX6OA38n/XJxR5KtFz7YY=
=R6to
-----END PGP SIGNATURE-----
--=-=-=--
