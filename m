Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2120.oracle.com ([141.146.126.78]:45004 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934965AbeF2TTp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jun 2018 15:19:45 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.4 \(3445.8.2\))
Subject: Re: [Libtirpc-devel] [PATCH V2] xdrstdio_create buffers do not output
 encoded values on ppc
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20180629184256.20532-1-steved@redhat.com>
Date: Fri, 29 Jun 2018 15:19:14 -0400
Cc: libtirpc List <libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <E0ED4A20-1E4F-4DD8-A410-AFD63F2B4DE6@oracle.com>
References: <20180629184256.20532-1-steved@redhat.com>
To: Steve Dickson <steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Jun 29, 2018, at 2:42 PM, Steve Dickson <steved@redhat.com> wrote:
>=20
> From: Daniel Sands <dnsands@sandia.gov>
>=20
> The cause is that the xdr_putlong uses a long to store the
> converted value, then passes it to fwrite as a byte buffer.
> Only the first 4 bytes are written, which is okay for a LE
> system after byteswapping, but writes all zeroes on BE systems.
>=20
> Fixes: https://bugzilla.redhat.com/show_bug.cgi?id=3D1261738
>=20
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
> v2: Added bounds checking
>    Changed from unsigned to signed
>=20
> src/xdr_stdio.c | 14 +++++++++++---
> 1 file changed, 11 insertions(+), 3 deletions(-)
>=20
> diff --git a/src/xdr_stdio.c b/src/xdr_stdio.c
> index 4410262..b902acd 100644
> --- a/src/xdr_stdio.c
> +++ b/src/xdr_stdio.c
> @@ -103,10 +103,12 @@ xdrstdio_getlong(xdrs, lp)
> 	XDR *xdrs;
> 	long *lp;
> {
> +	int32_t mycopy;
>=20
> -	if (fread(lp, sizeof(int32_t), 1, (FILE *)xdrs->x_private) !=3D =
1)
> +	if (fread(&mycopy, sizeof(int32_t), 1, (FILE *)xdrs->x_private) =
!=3D 1)
> 		return (FALSE);
> -	*lp =3D (long)ntohl((u_int32_t)*lp);
> +
> +	*lp =3D (long)ntohl(mycopy);
> 	return (TRUE);
> }
>=20
> @@ -115,8 +117,14 @@ xdrstdio_putlong(xdrs, lp)
> 	XDR *xdrs;
> 	const long *lp;
> {
> -	long mycopy =3D (long)htonl((u_int32_t)*lp);
> +	int32_t mycopy;
> +
> +#if defined(_LP64)

I don't find an _LP64 macro defined within libtirpc or the C libraries
on my RHEL 7 system. The test really should look something like this:

#if __BITS_PER_LONG =3D=3D 64

though I'm sure that's not right either.


> +	if ((*lp > INT32_MAX) || (*lp < INT32_MIN))
> +		return (FALSE);
> +#endif
>=20
> +	mycopy =3D (int32_t)htonl((int32_t)*lp);
> 	if (fwrite(&mycopy, sizeof(int32_t), 1, (FILE *)xdrs->x_private) =
!=3D 1)
> 		return (FALSE);
> 	return (TRUE);
> --=20
> 2.17.1
>=20
>=20
> =
--------------------------------------------------------------------------=
----
> Check out the vibrant tech community on one of the world's most
> engaging tech sites, Slashdot.org! http://sdm.link/slashdot
> _______________________________________________
> Libtirpc-devel mailing list
> Libtirpc-devel@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/libtirpc-devel

--
Chuck Lever



