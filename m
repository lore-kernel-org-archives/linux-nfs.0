Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56410 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726586AbeGKQK2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 11 Jul 2018 12:10:28 -0400
Subject: Re: [PATCH V4] xdrstdio_create buffers do not output encoded values
 on ppc
To: Libtirpc-devel Mailing List
        <libtirpc-devel@lists.sourceforge.net>,
        Trond Myklebust <trondmy@gmail.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <20180711152521.8238-1-steved@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <b4a310ec-0e91-9aca-f91e-d5efeb391e59@RedHat.com>
Date: Wed, 11 Jul 2018 12:05:26 -0400
MIME-Version: 1.0
In-Reply-To: <20180711152521.8238-1-steved@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Trond,

On 07/11/2018 11:25 AM, Steve Dickson wrote:
> The cause is that the xdr_putlong uses a long to store the
> converted value, then passes it to fwrite as a byte buffer.
> Only the first 4 bytes are written, which is okay for a LE
> system after byteswapping, but writes all zeroes on BE systems.
> 
> Fixes: https://bugzilla.redhat.com/show_bug.cgi?id=1261738
> 
> Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
> v4: Use UINT32_MAX instead of INT32_MAX in boundary check.
Talking with some old crusty types ;-) they pointed out
that all these routines use a signed arguments and
always have... So again why is using an unsigned max
the right thing to do? 

steved.
  
> 
> v3: Reworked the bounds checking
> 
> v2: Added bounds checking
>     Changed from unsigned to signed
> 
>  src/xdr_stdio.c | 15 ++++++++++++---
>  1 file changed, 12 insertions(+), 3 deletions(-)
> 
> diff --git a/src/xdr_stdio.c b/src/xdr_stdio.c
> index 4410262..846c7bf 100644
> --- a/src/xdr_stdio.c
> +++ b/src/xdr_stdio.c
> @@ -38,6 +38,7 @@
>   */
>  
>  #include <stdio.h>
> +#include <stdint.h>
>  
>  #include <arpa/inet.h>
>  #include <rpc/types.h>
> @@ -103,10 +104,12 @@ xdrstdio_getlong(xdrs, lp)
>  	XDR *xdrs;
>  	long *lp;
>  {
> +	int32_t mycopy;
>  
> -	if (fread(lp, sizeof(int32_t), 1, (FILE *)xdrs->x_private) != 1)
> +	if (fread(&mycopy, sizeof(int32_t), 1, (FILE *)xdrs->x_private) != 1)
>  		return (FALSE);
> -	*lp = (long)ntohl((u_int32_t)*lp);
> +
> +	*lp = (long)ntohl(mycopy);
>  	return (TRUE);
>  }
>  
> @@ -115,8 +118,14 @@ xdrstdio_putlong(xdrs, lp)
>  	XDR *xdrs;
>  	const long *lp;
>  {
> -	long mycopy = (long)htonl((u_int32_t)*lp);
> +	int32_t mycopy;
> +
> +#if defined(_LP64)
> +	if ((*lp > UINT32_MAX) || (*lp < INT32_MIN))
> +		return (FALSE);
> +#endif
>  
> +	mycopy = (int32_t)htonl((int32_t)*lp);
>  	if (fwrite(&mycopy, sizeof(int32_t), 1, (FILE *)xdrs->x_private) != 1)
>  		return (FALSE);
>  	return (TRUE);
> 
