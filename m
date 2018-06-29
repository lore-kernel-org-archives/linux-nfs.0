Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2130.oracle.com ([141.146.126.79]:51366 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932312AbeF2UCo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jun 2018 16:02:44 -0400
Content-Type: text/plain;
        charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 11.4 \(3445.8.2\))
Subject: Re: [PATCH V2] xdrstdio_create buffers do not output encoded values
 on ppc
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <e8af0b57cfe3d9932470e2b6aa3f30fa45c189a0.camel@hammerspace.com>
Date: Fri, 29 Jun 2018 16:02:18 -0400
Cc: Steve Dickson <steved@redhat.com>,
        libtirpc List <libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <B56D996C-7BC6-47B2-807B-D4915286FBCB@oracle.com>
References: <20180629184256.20532-1-steved@redhat.com>
 <6ce6dd9fe59250132029e42acd03807a83b2f2d9.camel@hammerspace.com>
 <D1BA743A-4D18-45CE-919D-F832D8001497@oracle.com>
 <e8af0b57cfe3d9932470e2b6aa3f30fa45c189a0.camel@hammerspace.com>
To: Trond Myklebust <trondmy@hammerspace.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Jun 29, 2018, at 3:48 PM, Trond Myklebust <trondmy@hammerspace.com> =
wrote:
>=20
> On Fri, 2018-06-29 at 15:33 -0400, Chuck Lever wrote:
>>> On Jun 29, 2018, at 3:29 PM, Trond Myklebust <trondmy@hammerspace.c
>>> om> wrote:
>>>=20
>>> On Fri, 2018-06-29 at 14:42 -0400, Steve Dickson wrote:
>>>> From: Daniel Sands <dnsands@sandia.gov>
>>>>=20
>>>> The cause is that the xdr_putlong uses a long to store the
>>>> converted value, then passes it to fwrite as a byte buffer.
>>>> Only the first 4 bytes are written, which is okay for a LE
>>>> system after byteswapping, but writes all zeroes on BE systems.
>>>>=20
>>>> Fixes: https://bugzilla.redhat.com/show_bug.cgi?id=3D1261738
>>>>=20
>>>> Signed-off-by: Steve Dickson <steved@redhat.com>
>>>> ---
>>>> v2: Added bounds checking
>>>>   Changed from unsigned to signed
>>>>=20
>>>> src/xdr_stdio.c | 14 +++++++++++---
>>>> 1 file changed, 11 insertions(+), 3 deletions(-)
>>>>=20
>>>> diff --git a/src/xdr_stdio.c b/src/xdr_stdio.c
>>>> index 4410262..b902acd 100644
>>>> --- a/src/xdr_stdio.c
>>>> +++ b/src/xdr_stdio.c
>>>> @@ -103,10 +103,12 @@ xdrstdio_getlong(xdrs, lp)
>>>> 	XDR *xdrs;
>>>> 	long *lp;
>>>> {
>>>> +	int32_t mycopy;
>>>>=20
>>>> -	if (fread(lp, sizeof(int32_t), 1, (FILE *)xdrs-
>>>>> x_private)
>>>> !=3D 1)
>>>> +	if (fread(&mycopy, sizeof(int32_t), 1, (FILE *)xdrs-
>>>>> x_private) !=3D 1)
>>>>=20
>>>> 		return (FALSE);
>>>> -	*lp =3D (long)ntohl((u_int32_t)*lp);
>>>> +
>>>> +	*lp =3D (long)ntohl(mycopy);
>>>> 	return (TRUE);
>>>> }
>>>>=20
>>>> @@ -115,8 +117,14 @@ xdrstdio_putlong(xdrs, lp)
>>>> 	XDR *xdrs;
>>>> 	const long *lp;
>>>> {
>>>> -	long mycopy =3D (long)htonl((u_int32_t)*lp);
>>>> +	int32_t mycopy;
>>>> +
>>>> +#if defined(_LP64)
>>>> +	if ((*lp > INT32_MAX) || (*lp < INT32_MIN))
>>>> +		return (FALSE);
>>>=20
>>> The will work just fine if your cast is:
>>> 	int a;
>>>=20
>>> 	lp =3D (long)a;
>>>=20
>>> ...but it won't do the right thing for
>>>=20
>>> 	unsigned int b =3D UINT32_MAX;
>>>=20
>>> 	lp =3D (long)b;	/* set lp to UINT32_MAX */
>>=20
>> mycopy is an int32_t now. Does that help?
>=20
> Not really. 'mycopy' isn't involved in the check above, and *lp =3D=3D
> UINT32_MAX should in either case get cast to the same 32-bit bit
> pattern whether mycopy is an int32_t or a u_int32_t.

> It's when you try to cast back from 'mycopy' to a long type that the
> two can end up differing (an int32_t might get sign extended).

AFAICT we are casting *lp to an int32_t in this function. mycopy
is not being cast to a long here.

Do you mean xdrstdio_GETlong needs further protection? Could be,
there is a cast of an int32_t to a long there.

I agree that we should vet xdrstdio_getlong and xdrstdio_putlong for
sign-extension issues very carefully.


>>> Since there us no dedicated xdrstdio_putulong() to use for unsigned
>>> integers, we need the check to work for both cases.
>>> For that reason, I think the above check either has to be:
>>>=20
>>> 	if (*lp =3D=3D (long)((u_int32_t)*lp))
>>> 		return (FALSE);
>>>=20
>>> ...or something uglier like
>>>=20
>>> 	if (*lp > UINT32_MAX || *lp < INT32_MIN)
>>> 		return (FALSE);
>>>=20
>>>> +#endif
>>>>=20
>>>> +	mycopy =3D (int32_t)htonl((int32_t)*lp);
>>>> 	if (fwrite(&mycopy, sizeof(int32_t), 1, (FILE *)xdrs-
>>>>> x_private) !=3D 1)
>>>>=20
>>>> 		return (FALSE);
>>>> 	return (TRUE);
>>>=20
>>> --=20
>>> Trond Myklebust
>>> CTO, Hammerspace Inc
>>> 4300 El Camino Real, Suite 105
>>> Los Altos, CA 94022
>>> www.hammer.space
>>>=20
>>> =
N=E2=80=B9=C2=A7=C4=93=C3=A6=C4=97r=C4=BC=E2=80=BAy=C3=BA=C4=8D=C5=A1=C3=98=
b=C4=93X=C5=BD=C4=B7=C4=AE=C2=A7v=C3=98^=E2=80=93)=C3=9E=C5=A1{.n=C4=AE+=E2=
=80=B0=C2=B7=C4=A8=C5=A0{=C4=85=C2=9D=C3=BB"=C5=BE=C3=98^n=E2=80=A1r=C4=84=
=C3=B6=C4=B6z=C3=8B=1A=C2=81=C3=ABh=E2=84=A2=C4=BB=C4=8D=C2=AD=C3=9A&=C4=92=
=C3=B8=1E=C5=AA
>>> =
G=C5=A6=C2=9D=C3=A9h=C5=AA=03(=C2=AD=C3=A9=C5=A1=C5=BD=C5=A0=C3=9D=C4=92j"=
=C2=9D=C3=BA=1A=C4=B7=1Bm=C2=A7=C4=B8=C3=AF=C2=81=C4=99=C3=A4z=C4=91=C3=9E=
=E2=80=93=C5=A0=C4=81=C3=BEf=C4=A2=C4=92=C2=B7h=C5=A1=CB=86=C2=A7~=CB=86m
>>=20
>> --
>> Chuck Lever
>>=20
>>=20
>>=20
> --=20
> Trond Myklebust
> Linux NFS client maintainer, Hammerspace
> trond.myklebust@hammerspace.com

--
Chuck Lever



