Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:44690 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754980Ab3EHMj6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 May 2013 08:39:58 -0400
Subject: Re: SUNRPC: Add RPC based upcall mechanism for RPCGSS auth
From: Simo Sorce <simo@redhat.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Dan Carpenter <dan.carpenter@oracle.com>, linux-nfs@vger.kernel.org
In-Reply-To: <20130507214950.GD27004@pad.fieldses.org>
References: <20130506154435.GA14732@elgon.mountain>
	 <1367855693.2976.205.camel@willson.li.ssimo.org>
	 <20130507214950.GD27004@pad.fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 07 May 2013 17:57:08 -0400
Message-ID: <1367963828.20220.63.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-05-07 at 17:49 -0400, J. Bruce Fields wrote:
> On Mon, May 06, 2013 at 11:54:53AM -0400, Simo Sorce wrote:
> > On Mon, 2013-05-06 at 18:44 +0300, Dan Carpenter wrote:
> > > Hello Simo Sorce,
> > > 
> > > The patch 1d658336b05f: "SUNRPC: Add RPC based upcall mechanism for 
> > > RPCGSS auth" from May 25, 2012, leads to the following warning:
> > > "net/sunrpc/auth_gss/gss_rpc_xdr.c:30 gssx_check_pointer()
> > > 	 warn: signedness bug returning '(-28)'"
> > > 
> > > net/sunrpc/auth_gss/gss_rpc_xdr.c
> > >     24  static bool gssx_check_pointer(struct xdr_stream *xdr)
> > >     25  {
> > >     26          __be32 *p;
> > >     27  
> > >     28          p = xdr_reserve_space(xdr, 4);
> > >     29          if (unlikely(p == NULL))
> > >     30                  return -ENOSPC;
> > >                                ^^^^^^^
> > > This is casted implicitly to "true".  Functions named "check" are a bad
> > > idea anyways because it's not clear what the return value will be.  It's
> > > better to use "gssx_pointer_ok()" or "valid" where obviously true means
> > > that the pointer is ok.
> > > 
> > >     31          return *p?true:false;
> > > 
> > > We just reserved "*p" so doesn't this point to uninitialized data?  It
> > > points to a __be32.  So we're not really checking a pointer we're
> > > checking that __be32 is non-zero.
> > > 
> > >     32  }
> > > 
> > > regards,
> > > dan carpenter
> > 
> > Dan,
> > thanks a lot for pointing this one out.
> 
> Yes, thanks!
> 
> > Bruce,
> > we should fix it in 3.10 if we can make it.
> 
> Agreed.  Probably the following attempt to decode will fail with an
> -ENOSPC anyway, but this is ugly at least.
> 
> > probably easiest way is to kill lines 29/30 and do:
> > return (p && *p) ? true : false;
> > 
> > It would be also ok to change the name to gssx_pointer_is_valid() I
> > guess.
> 
> It still seems a little yuch to lump a decoding failure with a succesful
> decode of a particular value....
> 
> How about just killing gssx_check_pointer, as follows.  Admittedly it's
> a bit verbose, but it's straightforward.  Any objections?

none if it works the same.

Simo.

> --b.
> 
> commit fb43f11c666a4f99f23f0be4fa528dcd288c0da2
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Tue May 7 17:45:20 2013 -0400
> 
>     SUNRPC: fix decoding of optional gss-proxy xdr fields
>     
>     The current code works, but sort of by accident: it obviously didn't
>     intend the error return to be interpreted as "true".
>     
>     Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> diff --git a/net/sunrpc/auth_gss/gss_rpc_xdr.c b/net/sunrpc/auth_gss/gss_rpc_xdr.c
> index a1e1b1a..357f613 100644
> --- a/net/sunrpc/auth_gss/gss_rpc_xdr.c
> +++ b/net/sunrpc/auth_gss/gss_rpc_xdr.c
> @@ -21,16 +21,6 @@
>  #include <linux/sunrpc/svcauth.h>
>  #include "gss_rpc_xdr.h"
>  
> -static bool gssx_check_pointer(struct xdr_stream *xdr)
> -{
> -	__be32 *p;
> -
> -	p = xdr_reserve_space(xdr, 4);
> -	if (unlikely(p == NULL))
> -		return -ENOSPC;
> -	return *p?true:false;
> -}
> -
>  static int gssx_enc_bool(struct xdr_stream *xdr, int v)
>  {
>  	__be32 *p;
> @@ -802,6 +792,7 @@ int gssx_dec_accept_sec_context(struct rpc_rqst *rqstp,
>  				struct xdr_stream *xdr,
>  				struct gssx_res_accept_sec_context *res)
>  {
> +	u32 value_follows;
>  	int err;
>  
>  	/* res->status */
> @@ -810,7 +801,10 @@ int gssx_dec_accept_sec_context(struct rpc_rqst *rqstp,
>  		return err;
>  
>  	/* res->context_handle */
> -	if (gssx_check_pointer(xdr)) {
> +	err = gssx_dec_bool(xdr, &value_follows);
> +	if (err)
> +		return err;
> +	if (value_follows) {
>  		err = gssx_dec_ctx(xdr, res->context_handle);
>  		if (err)
>  			return err;
> @@ -819,7 +813,10 @@ int gssx_dec_accept_sec_context(struct rpc_rqst *rqstp,
>  	}
>  
>  	/* res->output_token */
> -	if (gssx_check_pointer(xdr)) {
> +	err = gssx_dec_bool(xdr, &value_follows);
> +	if (err)
> +		return err;
> +	if (value_follows) {
>  		err = gssx_dec_buffer(xdr, res->output_token);
>  		if (err)
>  			return err;
> @@ -828,7 +825,10 @@ int gssx_dec_accept_sec_context(struct rpc_rqst *rqstp,
>  	}
>  
>  	/* res->delegated_cred_handle */
> -	if (gssx_check_pointer(xdr)) {
> +	err = gssx_dec_bool(xdr, &value_follows);
> +	if (err)
> +		return err;
> +	if (value_follows) {
>  		/* we do not support upcall servers sending this data. */
>  		return -EINVAL;
>  	}


-- 
Simo Sorce * Red Hat, Inc * New York

