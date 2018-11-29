Return-Path: <SRS0=NEh4=OI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E77ADC43441
	for <linux-nfs@archiver.kernel.org>; Thu, 29 Nov 2018 05:35:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AB7F3206B6
	for <linux-nfs@archiver.kernel.org>; Thu, 29 Nov 2018 05:35:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB7F3206B6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727219AbeK2Qja (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 29 Nov 2018 11:39:30 -0500
Received: from mx2.suse.de ([195.135.220.15]:39460 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727406AbeK2Qja (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 29 Nov 2018 11:39:30 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay1.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 488A8B0B1;
        Thu, 29 Nov 2018 05:35:21 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Vasily Averin <vvs@virtuozzo.com>
Date:   Thu, 29 Nov 2018 16:35:12 +1100
Cc:     Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
Subject: Re: [PATCH 0/1] cache_head leak in sunrpc_cache_lookup()
In-Reply-To: <20181128233514.GC24160@fieldses.org>
References: <d6bac5b8-9ee9-289c-7e85-0d4b6f55c931@virtuozzo.com> <20181128233514.GC24160@fieldses.org>
Message-ID: <87zhtso38v.fsf@notabene.neil.brown.name>
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

On Wed, Nov 28 2018, J. Bruce Fields wrote:

> On Wed, Nov 28, 2018 at 11:45:46AM +0300, Vasily Averin wrote:
>> Dear all, we have found memory leak on OpenVz7 node and believe it
>> affects mainline too.
>>=20
>> sunrpc_cache_lookup() removes exprired cache_head from hash, however
>> if it waits for reply on submitted cache_request both of them can leak
>> forever, nobody cleans unhashed cache_heads.
>>=20
>> Originally we had claim on busy loop device of stopped container, that
>> had executed nfs server inside.  Device was kept by mount that was
>> detached from already destroyed mount namespace.  By using crash
>> search we have found some structure with path struct related to our
>> mount.  Finally we have found that it was alive svc_export struct used
>> by to alive cache_request, however both of them pointed to already
>> freed cache_detail.
>>=20
>> We decided that cache_detail was correctly freed during destroy of net
>> namespace, however svc_export with taken path struct, cache_request
>> and some other structures seems was leaked forever.
>>=20
>> This could  happen only if cache_head of svc_export was removed from
>> hash on cache_detail before its destroy. Finally we have found that it
>> could happen when sunrpc_cache_lookup() removes expired cache_head
>> from hash.
>>=20
>> Usually it works correctly and cache_put(freeme) frees expired
>> cache_head.  However in our case cache_head have an extra reference
>> counter from stalled cache_request.  Becasue of cache_head was removed
>> from hash of cache_detail it cannot be found in cache_clean() and its
>> cache_request cannot be freed in cache_dequeue(). Memory leaks
>> forever, exactly like we observed.
>>=20
>> After may attempts we have reproduced this situation on OpenVz7
>> kernel, however our reproducer is quite long and complex.
>> Unfortunately we still did not reproduced this problem on mainline
>> kernel and did not validated the patch yet.
>>=20
>> It would be great if someone advised us some simple way to trigger
>> described scenario.
>
> I think you should be able to produce hung upcalls by flushing the cache
> (exportfs -f), then stopping mountd, then trying to access the
> filesystem from a client.  Does that help?
>
>> We are not sure that our patch is correct, please let us know if our
>> analyze missed something.
>
> It looks OK to me, but it would be helpful to have Neil's review too.

Yes, it makes sense to me.
 Reviewed-by: NeilBrown <neilb@suse.com>

Thanks,
NeilBrown


>
> I think I'd also copy some of the above into the changelog--e.g. it
> might be useful to document that this can manifest as a stray reference
> cuont on a mount.
>
> --b.

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlv/epEACgkQOeye3VZi
gbkROA//a4PI8DKhUXejP1EnUPx4XKKa/5l0+ZXTIh0ny2EdTECfcGiRwSUysoN0
x/h5ErxWFpS7OOfdv6Ok6ulyaERvYtscUchsvB9FRrMGnf7x9uc70tguB3qjbcn+
voH8R3bZOtZDBfMwnwZkpCyqJxpQlEKUi1f5v49suWuPACQf30OACkyrOXG9J6N7
9gPc1Pmfg/tHwN7rTeFEqt6+THoOZMtcRXuFyLzbnCt3vjQ/0N91W+OI5glxWR4E
6OLQZCxicxzwgGzmMcsetzVFAQAamNklprcBZsJ0pOLumrz/atZP2u9FGy8apy4e
zQyC6C6Pj+3jznC03B0R5X53uZU9mLb4J3YPtQ+7f1EWBR2YM7pbwl1dRu7sah+d
Y6gsTxoWJ2AkxmviBvF6pGGoMY+3hpgx2non6g0p48lSQYB66p29kHwaISGicfft
aWgt2m/5g3Bl5pjViJz1NyvCiKA+6Co+0HRa2p5NcmSj07RRcqW4EdyG5+KyRxjy
duFLbRPtFBtLjBKlTnUN08MxFuIp94ObAUPXRQEOkTU7vfv5ipYTWnQw5yflx1By
mRgOiRYooLLvadPF214XNGISpMEfkE2awOYeclQqHSZB19DToYW0V17MN+4RI0yF
MeC6kjQHlE8T81noxcPipcdQUcjJTmUwuaiLAD8OmopmfUjNOl8=
=lFnz
-----END PGP SIGNATURE-----
--=-=-=--
