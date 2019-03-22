Return-Path: <SRS0=31iP=RZ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4066C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Mar 2019 22:32:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BBC40218D4
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Mar 2019 22:32:19 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727770AbfCVWcT (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Mar 2019 18:32:19 -0400
Received: from mx2.suse.de ([195.135.220.15]:53332 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727248AbfCVWcS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 22 Mar 2019 18:32:18 -0400
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 82335AF96;
        Fri, 22 Mar 2019 22:32:17 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>
Date:   Sat, 23 Mar 2019 09:32:08 +1100
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] sunrpc/cache: handle missing listeners better.
In-Reply-To: <20190322165338.GB7692@fieldses.org>
References: <87pnqj64br.fsf@notabene.neil.brown.name> <20190322165338.GB7692@fieldses.org>
Message-ID: <87bm225ymv.fsf@notabene.neil.brown.name>
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

On Fri, Mar 22 2019, J. Bruce Fields wrote:

> I've gotten complaints about the same thing and said "well, in
> retrospect we shouldn't have designed the interface this way, but we
> did, so just stop opening those files".

As the fool who actually "designed" this, I can say with some confidence
that the intention was always the requests would block for at most 30
seconds.
Unfortunately the implementation was sloppy and the testing was
haphazard.=20

>
> But maybe this is a reasonable compromise.
>
> One advantage of waiting for mountd to come back is that you could
> upgrade mountd in place.  That shouldn't take 30 seconds, though.  And I
> haven't heard of anyone actually doing that.

Surely upgrading of mountd in-place happens whenever you install a new
version.
That was (iirc) the main reason for not treating a recent close as fatal.

>
> It's too bad that not opening auth.unix.gid is the only way for mountd
> to communicate that gids shouldn't be mapped.

I have a general preference for reusing existing functionality rather
than creating new special-purpose functionality.  I think this has
served me well more often than not.  Maybe this is one case of "not".

If you want to restart mountd without --managed-gids (where previously
it had that option), there is a chance that you will hit this problem.
That is a case where the answer "just stop opening those files" doesn't
really apply.

Thanks,
NeilBrown

>
> --b.
>
> On Fri, Mar 22, 2019 at 01:16:56PM +1100, NeilBrown wrote:
>> If no handler (such as rpc.mountd) has opened
>> a cache 'channel', the sunrpc cache responds to
>> all lookup requests with -ENOENT.  This is particularly
>> important for the auth.unix.gid cache which is
>> optional.
>>=20
>> If the channel was open briefly and an upcall was written to it,
>> this upcall remains pending even when the handler closes the
>> channel.  When an upcall is pending, the code currently
>> doesn't check if there are still listeners, it only performs
>> that check before sending an upcall.
>>=20
>> As the cache treads a recently closes channel (closed less than
>> 30 seconds ago) as "potentially still open", there is a
>> reasonable sized window when a request can become pending
>> in a closed channel, and thereby block lookups indefinitely.
>>=20
>> This can easily be demonstrated by running
>>   cat /proc/net/rpc/auth.unix.gid/channel
>>=20
>> and then trying to mount an NFS filesystem from this host.  It
>> will block indefinitely (unless mountd is run with --manage-gids,
>> or krb5 is used).
>>=20
>> When cache_check() finds that an upcall is pending, it should
>> perform the "cache_listeners_exist()" exist test.  If no
>> listeners do exist, the request should be negated.
>>=20
>> With this change in place, there can still be a 30second wait on
>> mount, until the cache gives up waiting for a handler to come
>> back, but this is much better than an indefinite wait.
>>=20
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>>  net/sunrpc/cache.c | 4 +++-
>>  1 file changed, 3 insertions(+), 1 deletion(-)
>>=20
>> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
>> index 12bb23b8e0c5..be9e29385adc 100644
>> --- a/net/sunrpc/cache.c
>> +++ b/net/sunrpc/cache.c
>> @@ -40,6 +40,7 @@
>>=20=20
>>  static bool cache_defer_req(struct cache_req *req, struct cache_head *i=
tem);
>>  static void cache_revisit_request(struct cache_head *item);
>> +static bool cache_listeners_exist(struct cache_detail *detail);
>>=20=20
>>  static void cache_init(struct cache_head *h, struct cache_detail *detai=
l)
>>  {
>> @@ -303,7 +304,8 @@ int cache_check(struct cache_detail *detail,
>>  				cache_fresh_unlocked(h, detail);
>>  				break;
>>  			}
>> -		}
>> +		} else if (!cache_listeners_exist(detail))
>> +			rv =3D try_to_negate_entry(detail, h);
>>  	}
>>=20=20
>>  	if (rv =3D=3D -EAGAIN) {
>> --=20
>> 2.14.0.rc0.dirty
>>=20

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlyVYmkACgkQOeye3VZi
gblMUhAAj9fcy0KKgeqOpFCHf+ajfEjXfiVJBRMNUhblSedJFyhnMfAwzZEIUr9Q
S2h8Lup0xQSL8DoRY3TaOfw5llOxaUX8m1q5VTX0kBr4reheRvfWpZJ2BuNcT32Z
I52W1YCPqnF1rV2IvEwk9+hcoWyoIazY115fcaNNJy9O8eUfb73INOmvWBaC9r6o
4JKPmtGzjAYAiM3DbszlzmGoWm+p6cqqjaNy2+YEw+6jEPxYCqcg0a3eOwwHiUAD
vOVTNotY1QsK/rWq5Q+oB5XJrZeMtEjR/fN5EK/iFL5wQUBN1I3RUFLTpQYvjhNv
HVdtp2b79+KDKrVf2NxYU1JgeXITRSBwoXH9Mwoy5O9tW5MGcjtmHvbD+nI6+mXy
AmqOlCCSbnM3CLUMZIpWDlHXccXjJND40YraGCgixtoyh1DfcJyVVSr83n7S3ldA
fPcSPGVTDzsFeOEFr40qOQmgxmffHTeaQB+rdkDobBMMliyzG/KpoGXFZqf003wT
JLbYs0voqhLQE3kFt2xU+8rc29/GIOOZWgpKYUIeHAwIae5wNyRYIwwHdIFp/1XD
KswfKjrUq2wTMFcaoVWJ7BQ+EFALHimISJuPXonmbdO9yU5NHOsE2GmqAO/fGguD
O1FJ8nRShilvUWpQcNYMhuCYyBovFvT8pukZDsUQk5MxDYLoxCQ=
=+oRN
-----END PGP SIGNATURE-----
--=-=-=--
