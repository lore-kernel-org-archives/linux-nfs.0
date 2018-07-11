Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2120.oracle.com ([156.151.31.85]:50824 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726508AbeGKUtR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Jul 2018 16:49:17 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.4 \(3445.8.2\))
Subject: Re: [Libtirpc-devel] [PATCH V4] xdrstdio_create buffers do not output
 encoded values on ppc
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1c16109cdc64e1bfa6703ddcfae7cf9968102275.camel@hammerspace.com>
Date: Wed, 11 Jul 2018 16:42:40 -0400
Cc: Steve Dickson <SteveD@RedHat.com>,
        libtirpc List <libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <A7E3BF4E-9354-41F6-BE82-6E54F7346848@oracle.com>
References: <20180711152521.8238-1-steved@redhat.com>
 <b4a310ec-0e91-9aca-f91e-d5efeb391e59@RedHat.com>
 <0953d758440850222bab04aaf3822b396bd736c6.camel@hammer.space>
 <760B43CD-1561-414E-B186-DB7974707C0E@oracle.com>
 <1c16109cdc64e1bfa6703ddcfae7cf9968102275.camel@hammerspace.com>
To: Trond Myklebust <trondmy@hammerspace.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Jul 11, 2018, at 2:19 PM, Trond Myklebust <trondmy@hammerspace.com> =
wrote:
>=20
> On Wed, 2018-07-11 at 14:06 -0400, Chuck Lever wrote:
>>> On Jul 11, 2018, at 12:38 PM, Trond Myklebust <trondmy@hammerspace.
>>> com> wrote:
>>>=20
>>> On Wed, 2018-07-11 at 12:05 -0400, Steve Dickson wrote:
>>>> Hey Trond,
>>>>=20
>>>> On 07/11/2018 11:25 AM, Steve Dickson wrote:
>>>>> The cause is that the xdr_putlong uses a long to store the
>>>>> converted value, then passes it to fwrite as a byte buffer.
>>>>> Only the first 4 bytes are written, which is okay for a LE
>>>>> system after byteswapping, but writes all zeroes on BE systems.
>>>>>=20
>>>>> Fixes: https://bugzilla.redhat.com/show_bug.cgi?id=3D1261738
>>>>>=20
>>>>> Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
>>>>> Signed-off-by: Steve Dickson <steved@redhat.com>
>>>>> ---
>>>>> v4: Use UINT32_MAX instead of INT32_MAX in boundary check.
>>>>=20
>>>> Talking with some old crusty types ;-) they pointed out
>>>> that all these routines use a signed arguments and
>>>> always have... So again why is using an unsigned max
>>>> the right thing to do?=20
>>>=20
>>> As I said earlier, you are casting from a larger type to a smaller
>>> type, and you want it to work for both signed and unsigned 32-bit
>>> values. Consider this kind of code:
>>>=20
>>>       int32_t foo =3D 0xFFFF0000;
>>>       ret =3D xdrstdio_putlong(xdr, foo);

I doubt that will compile everywhere, since the second parameter
is supposed to be a pointer. Even if we add "&" the C compiler
will likely not allow an implicit typecast and an "address of".

Let's call the API portably:

     long foo =3D 0xFFFF0000;
     ret =3D xdrstdio_putlong(xdr, &foo);

On a system with 32-bit longs, foo contains a negative value.

On a system with 64-bit longs, foo contains a positive value. My
narrow range check will fail, but a UINT32_MAX check would allow
xdrstdio_putlong to proceed.

My desired outcome is that the API works for the same range of
values on platforms with 32-bit longs and 64-bit longs. If this
API is to work the same on both classes of platform, I guess we
do want "*lp > UINT32_MAX || *lp < INT32_MIN".


>>> Since foo is signed, then (long)foo ends up getting cast to
>>> 0xFFFFFFFFFFFF0000L, which is negative, but is > (long)INT32_MIN.
>>> So
>>> ret =3D=3D TRUE;


>> On 32-bit systems, xdrstdio_putlong() cannot work for values
>> between INT32_MAX and UINT32_MAX. It should return FALSE for
>> these values on 64-bit systems. In fact, that is the way this
>> API behaves for other 64-bit aware libtirpc implementations.
>=20
> On a 32-bit system there is no need to check anything, because
> sizeof(long) =3D=3D sizeof(int) =3D=3D 4.

> The problems occur once you start casting from a smaller sized integer
> to a larger one because the unsigned cast will behave differently to
> the signed cast and result in a bitwise very different value.

I'm confused. The patch _removes_ unsigned typecasts. We're no
longer converting between signed and unsigned integers in these
two API functions.

xdrstdio_putlong converts a (potentially) larger signed integer
to a (potentially) smaller signed integer. If a larger integer
cannot fit in a smaller destination, the only thing that can
happen is that the most-significant bits of the larger integer
are discarded, IIUC.


>>> Now try:
>>>=20
>>>       uint32_t bar =3D 0xFFFF0000U;
>>>       ret =3D xdrstdio_putlong(xdr, bar);
>>>=20
>>>=20
>>> Since bar is unsigned, then (long)bar gets cast to 0xFFFF0000L.
>>> That is
>>> clearly > (long)INT32_MAX =3D=3D 0x7FFFFFFFL, and so the above fails
>>> with
>>> ret =3D=3D FALSE.
>>>=20
>>>=20
>>> BTW: The above is pretty much exactly how xdr_int32_t() and
>>> xdr_uint32_t() work. The former does a signed cast to long, while
>>> the
>>> latter does an unsigned cast to long.
>>=20
>> If that's the case, we should examine how other 64-bit aware
>> libtirpc implementations work and fix ours to behave the same.
>> Our libtirpc forked in the late 1990s before 64-bit systems
>> were widely deployed, so I have some doubts whether our
>> implementation is correct.
>=20
> Observe:
>=20
> bool_t
> xdr_int32_t(xdrs, int32_p)
>        XDR *xdrs;
>        int32_t *int32_p;
> {
>        long l;
>=20
>        switch (xdrs->x_op) {
>=20
>        case XDR_ENCODE:
>                l =3D (long) *int32_p;
>                return (XDR_PUTLONG(xdrs, &l));
>=20
>        case XDR_DECODE:
>                if (!XDR_GETLONG(xdrs, &l)) {
>                        return (FALSE);
>                }
>                *int32_p =3D (int32_t) l;
>                return (TRUE);
>=20
>        case XDR_FREE:
>                return (TRUE);
>        }
>        /* NOTREACHED */
>        return (FALSE);
> }
>=20
> bool_t
> xdr_u_int32_t(xdrs, u_int32_p)
>        XDR *xdrs;
>        u_int32_t *u_int32_p;
> {
>        u_long l;
>=20
>        switch (xdrs->x_op) {
>=20
>        case XDR_ENCODE:
>                l =3D (u_long) *u_int32_p;
>                return (XDR_PUTLONG(xdrs, (long *)&l));
>=20
>        case XDR_DECODE:
>                if (!XDR_GETLONG(xdrs, (long *)&l)) {
>                        return (FALSE);
>                }
>                *u_int32_p =3D (u_int32_t) l;
>                return (TRUE);
>=20
>        case XDR_FREE:
>                return (TRUE);
>        }
>        /* NOTREACHED */
>        return (FALSE);
> }
>=20
>>>> steved.
>>>>=20
>>>>>=20
>>>>> v3: Reworked the bounds checking
>>>>>=20
>>>>> v2: Added bounds checking
>>>>>   Changed from unsigned to signed
>>>>>=20
>>>>> src/xdr_stdio.c | 15 ++++++++++++---
>>>>> 1 file changed, 12 insertions(+), 3 deletions(-)
>>>>>=20
>>>>> diff --git a/src/xdr_stdio.c b/src/xdr_stdio.c
>>>>> index 4410262..846c7bf 100644
>>>>> --- a/src/xdr_stdio.c
>>>>> +++ b/src/xdr_stdio.c
>>>>> @@ -38,6 +38,7 @@
>>>>> */
>>>>>=20
>>>>> #include <stdio.h>
>>>>> +#include <stdint.h>
>>>>>=20
>>>>> #include <arpa/inet.h>
>>>>> #include <rpc/types.h>
>>>>> @@ -103,10 +104,12 @@ xdrstdio_getlong(xdrs, lp)
>>>>> 	XDR *xdrs;
>>>>> 	long *lp;
>>>>> {
>>>>> +	int32_t mycopy;
>>>>>=20
>>>>> -	if (fread(lp, sizeof(int32_t), 1, (FILE *)xdrs-
>>>>>> x_private)=20
>>>>> !=3D 1)
>>>>> +	if (fread(&mycopy, sizeof(int32_t), 1, (FILE *)xdrs-
>>>>>> x_private) !=3D 1)
>>>>>=20
>>>>> 		return (FALSE);
>>>>> -	*lp =3D (long)ntohl((u_int32_t)*lp);
>>>>> +
>>>>> +	*lp =3D (long)ntohl(mycopy);
>>>>> 	return (TRUE);
>>>>> }
>>>>>=20
>>>>> @@ -115,8 +118,14 @@ xdrstdio_putlong(xdrs, lp)
>>>>> 	XDR *xdrs;
>>>>> 	const long *lp;
>>>>> {
>>>>> -	long mycopy =3D (long)htonl((u_int32_t)*lp);
>>>>> +	int32_t mycopy;
>>>>> +
>>>>> +#if defined(_LP64)
>>>>> +	if ((*lp > UINT32_MAX) || (*lp < INT32_MIN))
>>>>> +		return (FALSE);
>>>>> +#endif
>>>>>=20
>>>>> +	mycopy =3D (int32_t)htonl((int32_t)*lp);
>>>>> 	if (fwrite(&mycopy, sizeof(int32_t), 1, (FILE *)xdrs-
>>>>>> x_private) !=3D 1)
>>>>>=20
>>>>> 		return (FALSE);
>>>>> 	return (TRUE);
>>>>>=20
>>>>=20
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-
>>>> nfs"
>>>> in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.htm
>>>> l
>>>=20
>>> --=20
>>> Trond Myklebust
>>> Linux NFS client maintainer, Hammerspace
>>> trond.myklebust@hammerspace.com
>>>=20
>>> -----------------------------------------------------------------
>>> -------------
>>> Check out the vibrant tech community on one of the world's most
>>> engaging tech sites, Slashdot.org! http://sdm.link/slashdot
>>> _______________________________________________
>>> Libtirpc-devel mailing list
>>> Libtirpc-devel@lists.sourceforge.net
>>> https://lists.sourceforge.net/lists/listinfo/libtirpc-devel
>>=20
>> --
>> Chuck Lever
>>=20
>>=20
>>=20
> --=20
> Trond Myklebust
> CTO, Hammerspace Inc
> 4300 El Camino Real, Suite 105
> Los Altos, CA 94022
> www.hammer.space

--
Chuck Lever



