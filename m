From: Tao Guo <glorioustao@gmail.com>
Subject: Re: [pnfs] [PATCH 1/2]pnfs: replace lease_bitmap to length 3, instead
	of 2.
Date: Mon, 29 Jun 2009 14:50:54 +0800
Message-ID: <318b7ac70906282350u71c641dbu584b4e84cd39d59d@mail.gmail.com>
References: <318b7ac70906281916q317b1c4fkb50096679beebfba@mail.gmail.com>
	 <4A485B7C.2000809@desy.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Fredric Isaman <iisaman@citi.umich.edu>, bfields@citi.umich.edu,
	linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
	Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f226.google.com ([209.85.217.226]:34038 "EHLO
	mail-gx0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751019AbZF2Guw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Jun 2009 02:50:52 -0400
Received: by gxk26 with SMTP id 26so3567218gxk.13
        for <linux-nfs@vger.kernel.org>; Sun, 28 Jun 2009 23:50:54 -0700 (PDT)
In-Reply-To: <4A485B7C.2000809@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I think you are right, thanks.
shame to make such a mistake -_-|||

But I think giving the explicit size will  make the code much more clea=
r.
what about other gurus' ideas?
---

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index b1e3ce2..8cdccc0 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2619,7 +2619,7 @@ static int
nfs4_xdr_enc_setclientid_confirm(struct rpc_rqst *req, __be32 *p, str
 	struct compound_hdr hdr =3D {
 		.nops	=3D 0,
 	};
-	const u32 lease_bitmap[2] =3D { FATTR4_WORD0_LEASE_TIME, 0 };
+	const u32 lease_bitmap[3] =3D { FATTR4_WORD0_LEASE_TIME, 0, 0 };

 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
@@ -2770,7 +2770,7 @@ static int nfs4_xdr_enc_get_lease_time(struct
rpc_rqst *req, uint32_t *p,
 	struct compound_hdr hdr =3D {
 		.minorversion =3D clp->cl_minorversion,
 	};
-	const u32 lease_bitmap[2] =3D { FATTR4_WORD0_LEASE_TIME, 0 };
+	const u32 lease_bitmap[3] =3D { FATTR4_WORD0_LEASE_TIME, 0, 0 };

 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);


On Mon, Jun 29, 2009 at 2:13 PM, Tigran
Mkrtchyan<tigran.mkrtchyan@desy.de> wrote:
>
>
> On 06/29/2009 04:16 AM, Tao Guo wrote:
>>
>> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
>> index b1e3ce2..231ad24 100644
>> --- a/fs/nfs/nfs4xdr.c
>> +++ b/fs/nfs/nfs4xdr.c
>> @@ -2619,7 +2619,7 @@ static int
>> nfs4_xdr_enc_setclientid_confirm(struct rpc_rqst *req, __be32 *p, st=
r
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct compound_hdr hdr =3D {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .nops =C2=A0=
 =3D 0,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 };
>> - =C2=A0 =C2=A0 =C2=A0 const u32 lease_bitmap[2] =3D { FATTR4_WORD0_=
LEASE_TIME, 0 };
>> + =C2=A0 =C2=A0 =C2=A0 const u32 lease_bitmap[3] =3D { FATTR4_WORD0_=
LEASE_TIME, 0, 0 };
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 xdr_init_encode(&xdr,&req->rq_snd_buf, p=
);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 encode_compound_hdr(&xdr, req,&hdr);
>> @@ -2770,7 +2770,7 @@ static int nfs4_xdr_enc_get_lease_time(struct
>> rpc_rqst *req, uint32_t *p,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct compound_hdr hdr =3D {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .minorversio=
n =3D clp->cl_minorversion,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 };
>> - =C2=A0 =C2=A0 =C2=A0 const u32 lease_bitmap[2] =3D { FATTR4_WORD0_=
LEASE_TIME, 0 };
>> + =C2=A0 =C2=A0 =C2=A0 const u32 lease_bitmap[2] =3D { FATTR4_WORD0_=
LEASE_TIME, 0, 0 };
>
> probably you have to increase array size as well. In general there is=
 no
> need to do it twice :
>
> const u32 lease_bitmap[] =3D { FATTR4_WORD0_LEASE_TIME, 0, 0 };
>
> will do the right think.
>
> Kernel gurus may correct me if I am wrong.
>
> Regards,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Tigran.
>
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 xdr_init_encode(&xdr,&req->rq_snd_buf, p=
);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 encode_compound_hdr(&xdr, req,&hdr);
>>
>
> --
> _____________________________________________________________________=
___
> Tigran Mkrtchyan =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 DESY, IT,
> tigran.mkrtchyan@desy.de =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Notkestrasse 85,
> Tel: + 49 40 89983946 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Hamburg 22607,
> Fax: + 49 40 89984429 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Germany.
>



--=20
tao.
