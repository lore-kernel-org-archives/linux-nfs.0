Return-Path: <SRS0=4THU=SH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72E4BC4360F
	for <linux-nfs@archiver.kernel.org>; Fri,  5 Apr 2019 00:34:50 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 48711217D4
	for <linux-nfs@archiver.kernel.org>; Fri,  5 Apr 2019 00:34:50 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730335AbfDEAet (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 4 Apr 2019 20:34:49 -0400
Received: from mx2.suse.de ([195.135.220.15]:35946 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727053AbfDEAet (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 4 Apr 2019 20:34:49 -0400
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id DEE0EABCF;
        Fri,  5 Apr 2019 00:34:46 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Vasily Averin <vvs@virtuozzo.com>
Date:   Fri, 05 Apr 2019 11:34:40 +1100
Cc:     Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org,
        Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
Subject: Re: [PATCH 0/1] cache_head leak in sunrpc_cache_lookup()
In-Reply-To: <87sguxza1o.fsf@notabene.neil.brown.name>
References: <d6bac5b8-9ee9-289c-7e85-0d4b6f55c931@virtuozzo.com> <20181128233514.GC24160@fieldses.org> <87zhtso38v.fsf@notabene.neil.brown.name> <87sguxza1o.fsf@notabene.neil.brown.name>
Message-ID: <87k1g9z3vj.fsf@notabene.neil.brown.name>
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

On Fri, Apr 05 2019, NeilBrown wrote:
>
> Unfortunately I was wrong.  See below.
>

Arrghh.. Ignore that patch.  Use this one.

NeilBrown

From=20b7a8dced1a34869710a5d68a64e8bd37bf2ab426 Mon Sep 17 00:00:00 2001
From: NeilBrown <neilb@suse.com>
Date: Fri, 5 Apr 2019 09:04:41 +1100
Subject: [PATCH] sunrpc: don't mark uninitialised items as VALID.

A recent commit added a call to cache_fresh_locked()
when an expired item was found.
The call sets the CACHE_VALID flag, so it is important
that the item actually is valid.
There are two ways it could be valid:
1/ If ->update has been called to fill in relevant content
2/ if CACHE_NEGATIVE is set, to say that content doesn't exist.

An expired item that is waiting for an update will be neither.
Setting CACHE_VALID will mean that a subsequent call to cache_put()
will be likely to dereference uninitialised pointers.

So we must make sure the item is valid, and we already have code to do
that in try_to_negate_entry().  This takes the hash lock and so cannot
be used directly, so take out the two lines that we need and use them.

Now cache_fresh_locked() is certain to be called only on
a valid item.

Cc: stable@kernel.org # 2.6.35
Fixes: 4ecd55ea0742 ("sunrpc: fix cache_head leak due to queued request")
Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 net/sunrpc/cache.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 12bb23b8e0c5..261131dfa1f1 100644
=2D-- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -54,6 +54,7 @@ static void cache_init(struct cache_head *h, struct cache=
_detail *detail)
 	h->last_refresh =3D now;
 }
=20
+static inline int cache_is_valid(struct cache_head *h);
 static void cache_fresh_locked(struct cache_head *head, time_t expiry,
 				struct cache_detail *detail);
 static void cache_fresh_unlocked(struct cache_head *head,
@@ -105,6 +106,8 @@ static struct cache_head *sunrpc_cache_add_entry(struct=
 cache_detail *detail,
 			if (cache_is_expired(detail, tmp)) {
 				hlist_del_init_rcu(&tmp->cache_list);
 				detail->entries --;
+				if (cache_is_valid(tmp) =3D=3D -EAGAIN)
+					set_bit(CACHE_NEGATIVE, &tmp->flags);
 				cache_fresh_locked(tmp, 0, detail);
 				freeme =3D tmp;
 				break;
=2D-=20
2.14.0.rc0.dirty


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlymoqAACgkQOeye3VZi
gbmLpA//e4EQf3l5hxnbqcdJ7by77HChQwbvv68mSJQJahwpdbI3AWomHF4aFxBj
CZVkDX37XeGc4HG66L3VRqi3nMa+1fYPFpi6C2QphryF40n9AX891zQzy0429cCN
LO0Rss/sJmS+nIrCfFEAdx1zao4VOKEy76O0gJeCgIx6DoX96WvjUm7OuFdBqTH3
tKPxWHz9WYhlb3la44afHIgLMKB2aeS951aY5wLd4Zw8UxyL6EP6OPywguMbRkuP
GYwdKyVZBdN8qwN5dr75g8M/ePsIOk/P4AWU9SB8hLYLXOdTE8nWgQdhRqM3Dych
L5ZhCqX/p7msOLvXjWCHCp+YK2+3vTr9XjVIqvkxRV9FK28KZJadIBQjI3PoaA5z
JXtAR5yBPWElElSueuL+sN8n3RTBTPak2kWZHIOSCUp5IrsZrLbtIUcvaZdvaXJ3
WRcRKRjwU0HIjm/rGNBc4cawPYwomLkXWoRaUO0a8DL+ludKg7cPA+9fh+yOkeYN
Qi8ZWRxI4RGcn12a+sp0LTuhDyZxD9U4+dSZ+5HfQQvOxB19YsYcwdBkdXxpJhyG
wriIYdjeDsT0+ZjOlvI0bRf19djR1oG0PrRx6wwx5X1L81WX0QIHNwW8DsTi+Fhj
T8tqoqeaFxA1uqgSMdYz6iO//hC4ib/hmxMiowK+e0Yn6ApbyAI=
=96j/
-----END PGP SIGNATURE-----
--=-=-=--
