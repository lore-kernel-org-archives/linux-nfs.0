From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [PATCH 1/2]pnfs: replace lease_bitmap to length 3, instead
 	of 2.
Date: Mon, 29 Jun 2009 11:02:07 +0300
Message-ID: <4A4874FF.5020702@panasas.com>
References: <318b7ac70906281916q317b1c4fkb50096679beebfba@mail.gmail.com>	 <4A485B7C.2000809@desy.de> <318b7ac70906282350u71c641dbu584b4e84cd39d59d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
	Fredric Isaman <iisaman@citi.umich.edu>,
	bfields@citi.umich.edu, linux-nfs@vger.kernel.org,
	pnfs@linux-nfs.org
To: Tao Guo <glorioustao@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:30596
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751019AbZF2ICJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Jun 2009 04:02:09 -0400
In-Reply-To: <318b7ac70906282350u71c641dbu584b4e84cd39d59d-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun. 29, 2009, 9:50 +0300, Tao Guo <glorioustao@gmail.com> wrote:
> I think you are right, thanks.

Thanks for catching and fixing this!
Note that the compiler does print a warning about it though:

fs/nfs/nfs4xdr.c: In function =E2=80=98nfs4_xdr_enc_get_lease_time=E2=80=
=99:
fs/nfs/nfs4xdr.c:2715: warning: excess elements in array initializer
fs/nfs/nfs4xdr.c:2715: warning: (near initialization for =E2=80=98lease=
_bitmap=E2=80=99)

> shame to make such a mistake -_-|||

>=20
> But I think giving the explicit size will  make the code much more cl=
ear.
> what about other gurus' ideas?

I'm fine with that.
Especially since it was previously initialized with an explicit length.

> ---
>=20
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index b1e3ce2..8cdccc0 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -2619,7 +2619,7 @@ static int
> nfs4_xdr_enc_setclientid_confirm(struct rpc_rqst *req, __be32 *p, str

Hmm, this patch is still malformatted.
(lines wrapped, tabs expanded to spaces)
I've fixed it manually.

Benny

>  	struct compound_hdr hdr =3D {
>  		.nops	=3D 0,
>  	};
> -	const u32 lease_bitmap[2] =3D { FATTR4_WORD0_LEASE_TIME, 0 };
> +	const u32 lease_bitmap[3] =3D { FATTR4_WORD0_LEASE_TIME, 0, 0 };
>=20
>  	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
>  	encode_compound_hdr(&xdr, req, &hdr);
> @@ -2770,7 +2770,7 @@ static int nfs4_xdr_enc_get_lease_time(struct
> rpc_rqst *req, uint32_t *p,
>  	struct compound_hdr hdr =3D {
>  		.minorversion =3D clp->cl_minorversion,
>  	};
> -	const u32 lease_bitmap[2] =3D { FATTR4_WORD0_LEASE_TIME, 0 };
> +	const u32 lease_bitmap[3] =3D { FATTR4_WORD0_LEASE_TIME, 0, 0 };
>=20
>  	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
>  	encode_compound_hdr(&xdr, req, &hdr);
>=20
>=20
> On Mon, Jun 29, 2009 at 2:13 PM, Tigran
> Mkrtchyan<tigran.mkrtchyan@desy.de> wrote:
>>
>> On 06/29/2009 04:16 AM, Tao Guo wrote:
>>> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
>>> index b1e3ce2..231ad24 100644
>>> --- a/fs/nfs/nfs4xdr.c
>>> +++ b/fs/nfs/nfs4xdr.c
>>> @@ -2619,7 +2619,7 @@ static int
>>> nfs4_xdr_enc_setclientid_confirm(struct rpc_rqst *req, __be32 *p, s=
tr
>>>         struct compound_hdr hdr =3D {
>>>                 .nops   =3D 0,
>>>         };
>>> -       const u32 lease_bitmap[2] =3D { FATTR4_WORD0_LEASE_TIME, 0 =
};
>>> +       const u32 lease_bitmap[3] =3D { FATTR4_WORD0_LEASE_TIME, 0,=
 0 };
>>>
>>>         xdr_init_encode(&xdr,&req->rq_snd_buf, p);
>>>         encode_compound_hdr(&xdr, req,&hdr);
>>> @@ -2770,7 +2770,7 @@ static int nfs4_xdr_enc_get_lease_time(struct
>>> rpc_rqst *req, uint32_t *p,
>>>         struct compound_hdr hdr =3D {
>>>                 .minorversion =3D clp->cl_minorversion,
>>>         };
>>> -       const u32 lease_bitmap[2] =3D { FATTR4_WORD0_LEASE_TIME, 0 =
};
>>> +       const u32 lease_bitmap[2] =3D { FATTR4_WORD0_LEASE_TIME, 0,=
 0 };
>> probably you have to increase array size as well. In general there i=
s no
>> need to do it twice :
>>
>> const u32 lease_bitmap[] =3D { FATTR4_WORD0_LEASE_TIME, 0, 0 };
>>
>> will do the right think.
>>
>> Kernel gurus may correct me if I am wrong.
>>
>> Regards,
>>        Tigran.
>>
>>>         xdr_init_encode(&xdr,&req->rq_snd_buf, p);
>>>         encode_compound_hdr(&xdr, req,&hdr);
>>>
>> --
>> ____________________________________________________________________=
____
>> Tigran Mkrtchyan                               DESY, IT,
>> tigran.mkrtchyan@desy.de                       Notkestrasse 85,
>> Tel: + 49 40 89983946                          Hamburg 22607,
>> Fax: + 49 40 89984429                          Germany.
>>
>=20
>=20
>=20
