Return-Path: <SRS0=31iP=RZ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5FC39C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Mar 2019 02:17:05 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 34D3A213F2
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Mar 2019 02:17:05 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727427AbfCVCRE (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 21 Mar 2019 22:17:04 -0400
Received: from mx2.suse.de ([195.135.220.15]:40074 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726460AbfCVCRE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 21 Mar 2019 22:17:04 -0400
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 32B0AAEE7;
        Fri, 22 Mar 2019 02:17:03 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>
Date:   Fri, 22 Mar 2019 13:16:56 +1100
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH] sunrpc/cache: handle missing listeners better.
Message-ID: <87pnqj64br.fsf@notabene.neil.brown.name>
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


If no handler (such as rpc.mountd) has opened
a cache 'channel', the sunrpc cache responds to
all lookup requests with -ENOENT.  This is particularly
important for the auth.unix.gid cache which is
optional.

If the channel was open briefly and an upcall was written to it,
this upcall remains pending even when the handler closes the
channel.  When an upcall is pending, the code currently
doesn't check if there are still listeners, it only performs
that check before sending an upcall.

As the cache treads a recently closes channel (closed less than
30 seconds ago) as "potentially still open", there is a
reasonable sized window when a request can become pending
in a closed channel, and thereby block lookups indefinitely.

This can easily be demonstrated by running
  cat /proc/net/rpc/auth.unix.gid/channel

and then trying to mount an NFS filesystem from this host.  It
will block indefinitely (unless mountd is run with --manage-gids,
or krb5 is used).

When cache_check() finds that an upcall is pending, it should
perform the "cache_listeners_exist()" exist test.  If no
listeners do exist, the request should be negated.

With this change in place, there can still be a 30second wait on
mount, until the cache gives up waiting for a handler to come
back, but this is much better than an indefinite wait.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 net/sunrpc/cache.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 12bb23b8e0c5..be9e29385adc 100644
=2D-- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -40,6 +40,7 @@
=20
 static bool cache_defer_req(struct cache_req *req, struct cache_head *item=
);
 static void cache_revisit_request(struct cache_head *item);
+static bool cache_listeners_exist(struct cache_detail *detail);
=20
 static void cache_init(struct cache_head *h, struct cache_detail *detail)
 {
@@ -303,7 +304,8 @@ int cache_check(struct cache_detail *detail,
 				cache_fresh_unlocked(h, detail);
 				break;
 			}
=2D		}
+		} else if (!cache_listeners_exist(detail))
+			rv =3D try_to_negate_entry(detail, h);
 	}
=20
 	if (rv =3D=3D -EAGAIN) {
=2D-=20
2.14.0.rc0.dirty


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlyURZkACgkQOeye3VZi
gbkVpA/9EWaVc5Avg1LjbCnRYME1VsWYg8oK6fwlIHth2QJRKNU9bcmq+gibC0KT
0jzqyRmlJvUmBVA30BI1DQs4/XZXuVe5M8OXfIvWerpLEs7vH3TTY9YAwSfqRzuv
ABDRS42Rt41x+kPR2Afms9al4Q7asKSeh5uClIAbYkzmF49lgKN4kA3t0X0t03/v
ge2s2j1apGXahsYHMRI64AP/iets1xTLQQu9CP4Ickq8xfwLNUH+mWcmMR8+WX8W
3BJZpdgyUQJewAm48oAvla7bxYtNm7PCr5L4jrIYT+sNb9Ck1e3T3YofyN0VJVWg
JJuDs70ROMj8xAOyGfRUteeRNjuq7mWiH+55RX6448rYcxfq1AhQJ4sd4y13ku8j
9P3mltbMDQdtsfeWbf8sEMuRPli5kWaz0TrjE2Qig8wlFA3ZxgQP8mvAdH8HsIi4
RSahJMn+KbzoN0rEFtnu7rZdupCDTqeVxciFw0lrcV/gbnp4Aimj5+kEvXuVNUJJ
3cS1RAnUB98BmGIW1K6w5eNH0mPqbDCLXG7c/TOGxf2mGs7aioBahPV/RqbO0Zj1
WAOYIDYMsVCeOLOQh5DPGgmopBs7Yyy2XPvcGsyCzsuDyBT0nXP/cQ45uRPoy9s5
da5xD7AUuDkDZ7nNpHos33DhHwWbbqt6x+bowWws60hm/zBvibM=
=rBuQ
-----END PGP SIGNATURE-----
--=-=-=--
