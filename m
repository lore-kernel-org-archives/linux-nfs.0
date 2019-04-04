Return-Path: <SRS0=4rwz=SG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A025C4360F
	for <linux-nfs@archiver.kernel.org>; Thu,  4 Apr 2019 22:21:35 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D60E02177E
	for <linux-nfs@archiver.kernel.org>; Thu,  4 Apr 2019 22:21:34 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729833AbfDDWVe (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 4 Apr 2019 18:21:34 -0400
Received: from mx2.suse.de ([195.135.220.15]:45820 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727441AbfDDWVe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 4 Apr 2019 18:21:34 -0400
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id AB5D4AD07;
        Thu,  4 Apr 2019 22:21:31 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Vasily Averin <vvs@virtuozzo.com>
Date:   Fri, 05 Apr 2019 09:21:23 +1100
Cc:     Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org,
        Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
Subject: Re: [PATCH 0/1] cache_head leak in sunrpc_cache_lookup()
In-Reply-To: <87zhtso38v.fsf@notabene.neil.brown.name>
References: <d6bac5b8-9ee9-289c-7e85-0d4b6f55c931@virtuozzo.com> <20181128233514.GC24160@fieldses.org> <87zhtso38v.fsf@notabene.neil.brown.name>
Message-ID: <87sguxza1o.fsf@notabene.neil.brown.name>
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

On Thu, Nov 29 2018, NeilBrown wrote:

> On Wed, Nov 28 2018, J. Bruce Fields wrote:
>
>> On Wed, Nov 28, 2018 at 11:45:46AM +0300, Vasily Averin wrote:
>>> Dear all, we have found memory leak on OpenVz7 node and believe it
>>> affects mainline too.
>>>=20
>>> sunrpc_cache_lookup() removes exprired cache_head from hash, however
>>> if it waits for reply on submitted cache_request both of them can leak
>>> forever, nobody cleans unhashed cache_heads.
>>>=20
>>> Originally we had claim on busy loop device of stopped container, that
>>> had executed nfs server inside.  Device was kept by mount that was
>>> detached from already destroyed mount namespace.  By using crash
>>> search we have found some structure with path struct related to our
>>> mount.  Finally we have found that it was alive svc_export struct used
>>> by to alive cache_request, however both of them pointed to already
>>> freed cache_detail.
>>>=20
>>> We decided that cache_detail was correctly freed during destroy of net
>>> namespace, however svc_export with taken path struct, cache_request
>>> and some other structures seems was leaked forever.
>>>=20
>>> This could  happen only if cache_head of svc_export was removed from
>>> hash on cache_detail before its destroy. Finally we have found that it
>>> could happen when sunrpc_cache_lookup() removes expired cache_head
>>> from hash.
>>>=20
>>> Usually it works correctly and cache_put(freeme) frees expired
>>> cache_head.  However in our case cache_head have an extra reference
>>> counter from stalled cache_request.  Becasue of cache_head was removed
>>> from hash of cache_detail it cannot be found in cache_clean() and its
>>> cache_request cannot be freed in cache_dequeue(). Memory leaks
>>> forever, exactly like we observed.
>>>=20
>>> After may attempts we have reproduced this situation on OpenVz7
>>> kernel, however our reproducer is quite long and complex.
>>> Unfortunately we still did not reproduced this problem on mainline
>>> kernel and did not validated the patch yet.
>>>=20
>>> It would be great if someone advised us some simple way to trigger
>>> described scenario.
>>
>> I think you should be able to produce hung upcalls by flushing the cache
>> (exportfs -f), then stopping mountd, then trying to access the
>> filesystem from a client.  Does that help?
>>
>>> We are not sure that our patch is correct, please let us know if our
>>> analyze missed something.
>>
>> It looks OK to me, but it would be helpful to have Neil's review too.
>
> Yes, it makes sense to me.
>  Reviewed-by: NeilBrown <neilb@suse.com>

Unfortunately I was wrong.  See below.

NeilBrown

From: NeilBrown <neilb@suse.com>
Subject: [PATCH] sunrpc: don't mark uninitialised items as VALID.

A recent commit added a call to cache_fresh_locked()
when an expired item was found.
The call sets the CACHE_VALID flag, so it is important
that the item actually is valid.
There are two ways it could be valid:
1/ If ->update has been called to fill in relevant content
2/ If CACHE_NEGATIVE is set, to say that content doesn't exist.

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
 net/sunrpc/cache.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 12bb23b8e0c5..f5f8ce8c3443 100644
=2D-- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -105,6 +105,8 @@ static struct cache_head *sunrpc_cache_add_entry(struct=
 cache_detail *detail,
 			if (cache_is_expired(detail, tmp)) {
 				hlist_del_init_rcu(&tmp->cache_list);
 				detail->entries --;
+				if (cache_is_valid(tmp) =3D=3D -EAGAIN)
+					set_bit(CACHE_NEGATIVE, &h->flags);
 				cache_fresh_locked(tmp, 0, detail);
 				freeme =3D tmp;
 				break;
=2D-=20
2.14.0.rc0.dirty


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlymg2MACgkQOeye3VZi
gblvaA/+NxUWbnZk2JA/7nkLFZ/rE65ku/wi661AVVmZxcQODWeQOcbvxCmeJtjc
mdTapZ1c4F9Z4nYqQoju3MN+ndT1lzQVGq2bLQ6t0cGQXfo0Ui7QHHSrbi9x9ytN
jOcoi5QxpcxoO1zo0ATYTkfcouwWHZ58EHmbFHvC+Op9HEf+GM3n0hjaiy2OGW+1
sApeSzhXvHEFU4homHnzWKH8sgiuEAPihpND2y7L0EiVFg+wOeEnLqmsDRbo91vx
PYWShfUbE3kxx9QlUOaJ+0F7EIgCzUeUiI7JEN6jwOtvjwqE26ocdzE2sd4rx36O
Z8PlmAKM9kIC5+9Abo7BG7DV0urD7e7k9fzmxAqz0tMLJvLGQOBxnHAzFd3qyQaT
fCyYpXuIAMiX4+dPPc9le7lhms5pBF8olL1RTWw/4ojfSgNvAgmAjj988PURfs8+
SuSA+5xJ5INdozb1hII5VWjuMf+XyZjPZ7oad90KI+EaOAh9X3OG/WuxHG2zYBso
h7th5EWb91nqeJBWgbjiC5HC1FwSVfS+FyamznAAIoZc8cPtuc/vPExu/KQvhBtJ
xpUSak9QUJGrcLl5jngCCnnHMJLpB3Dp4dYP0iMS3WolBZt+h2ZuW+RouuCiDoug
MRxwjJNYfOYgybS4kwUpDzz4BhzRm3zWjk8lMshtLNf8L6tUaVA=
=pme7
-----END PGP SIGNATURE-----
--=-=-=--
