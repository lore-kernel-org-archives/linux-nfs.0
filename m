Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:49550 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753865AbdDSARw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 18 Apr 2017 20:17:52 -0400
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Wed, 19 Apr 2017 10:17:09 +1000
Cc: linux-nfs@vger.kernel.org, Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] nfsd: check for oversized NFSv2/v3 arguments
In-Reply-To: <20170418171351.GF6208@fieldses.org>
References: <20170414150440.GA5362@fieldses.org> <20170414150940.GB5362@fieldses.org> <87h91mtvdb.fsf@notabene.neil.brown.name> <20170418171351.GF6208@fieldses.org>
Message-ID: <878tmxtfne.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, Apr 18 2017, J. Bruce Fields wrote:

> On Tue, Apr 18, 2017 at 10:25:20AM +1000, NeilBrown wrote:
>>  I can't say that I like this patch at all.
>>=20
>> The problem is that:
>>=20
>> 	pages =3D size / PAGE_SIZE + 1; /* extra page as we hold both request a=
nd reply.
>> 				       * We assume one is at most one page
>> 				       */
>>=20
>> this assumption is never verified.
>> To my mind, the "obvious" way to verify this assumption is that an
>> attempt to generate a multi-page reply should fail if there was a
>> multi-page request.
>
> A third option, by the way, which Ari Kauppi argued for, is adding a
> null check each time we increment rq_next_page, since we seem to arrange
> for the page array to always be NULL-terminated.

Not a bad idea.   That is what nfsaclsvc_encode_getaclres() and
nfs3svc_encode_getaclres do.
Hmm... your change to xdr_argsize_check will break
nfsaclsvc_decode_setaclargs(), won't it?  It performs the check before
the final nfsacl_decode().


>
>> Failing if there was a little bit of extra noise at the end of the
>> request seems harsher than necessary, and could result in a regression.
>
> You're worrying there might be a weird old client out there somewhere?
> I guess it seems like a small enough risk to me.  I'm more worried the
> extra garbage might violate assumptions elsewhere in the code.

Something like that.  Probably no client does that...  I wouldn't be
overly surprised if some old boot-from-NFS code in a some ROM somewhere
took a shortcut like this though.

>
> But, this looks good too:
>
>> We already know how big replies can get, so we can perform a complete
>> sanity check quite early:
>>=20
>> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
>> index a08aeb56b8e4..14f4d425cf8c 100644
>> --- a/net/sunrpc/svc.c
>> +++ b/net/sunrpc/svc.c
>> @@ -1196,6 +1196,12 @@ svc_process_common(struct svc_rqst *rqstp, struct=
 kvec *argv, struct kvec *resv)
>>  		goto err_bad_proc;
>>  	rqstp->rq_procinfo =3D procp;
>>=20=20
>> +	if ((procp->pc_xdrressize =3D=3D 0 ||
>> +	     procp->pc_xdrressize > XDR_QUADLEN(PAGE_SIZE)) &&
>> +	    rqstp->rq_arg.len > PAGE_SIZE)
>> +		/* The assumption about request/reply sizes in svc_init_buffer() is v=
iolated! */
>> +		goto err_garbage;
>> +
>>  	/* Syntactic check complete */
>>  	serv->sv_stats->rpccnt++;
>>=20=20
>>=20
>> I haven't tested this at all and haven't even convinced myself that
>> it covers every case (though I cannot immediately think of any likely
>> corners).
>>=20
>> Does it address your test case?
>
> I'll check, it probably does.
>
> We'd need to limit the test to v2/v3.

Why?  Does v4 allocate extra pages?  Or is it more careful about using
them?
v4 does need something different, as pc_xdrressize is always zero..

Thanks,
NeilBrown

>
> I'm also not opposed to doing both (or all three).
>
> --b.

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlj2rIYACgkQOeye3VZi
gbnhJw/8CjksRafIZJYRMj5g2A4/cXqyESyA5DFgX24D8Ufwf+68xcohRwU74w+N
3QZjp69ovjptJvdqteCF1SUSItgT/MdaUTyROYtaIhluoCda1AxTxrU8v1P5UYKL
k9UDv4lLCVwwv/ViSQ2q4279vtPXahYNlPyGcbkOF2ZVrmAfq7be7il3oL20fd2n
Hy0U/kRbLzPQ5lq2xrwHwlzC/nY2N4aWa84E+6IBAFUlco8iyYtR4enfxBru6fwW
XDcqW1xmRwyxiVk6jq9sJ0CFoz7vrwpWIgLQ7N2Ow/8/X3HqtsdvQ1I8kAF9Kbxa
Ej+X0qSa4but5nI5dRsqElv9Hobo2Nyp4Ox84hBmZQY1rlbwca6pYFaAz8SEJez8
YoYsC+HGn98gimbUaYsoui4qeT4CypZKPm0ay7eQsRjU3FBQ2ASzue6LpQoaYN1X
6xh9O4uAJNXQ8vnQZJfM3uLZw7FMapDJl1aM88dw24YLnQ/9DG7/r5F3h7mTtHGq
iONIHLf54lZW9cZtT2bMfLspPIKP5QcbQEEmU1S3A5MtmzezIwjKTyQtZQxrqNo5
6iWTsz9G06f/BD7yu40WqeeZ6xCKTieE1AFXUn/ITtHo17CNgbMrCT5BHo4P4TmG
bJOza9gMTrENBUqD4aXOTM1FGt37weLe3BkJ9wxLKziN3GYA1S8=
=owvY
-----END PGP SIGNATURE-----
--=-=-=--
