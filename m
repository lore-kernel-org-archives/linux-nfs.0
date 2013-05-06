Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:38219 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754177Ab3EFPy4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 May 2013 11:54:56 -0400
Subject: re: SUNRPC: Add RPC based upcall mechanism for RPCGSS auth
From: Simo Sorce <simo@redhat.com>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: linux-nfs@vger.kernel.org, Bruce Fields <bfields@redhat.com>
In-Reply-To: <20130506154435.GA14732@elgon.mountain>
References: <20130506154435.GA14732@elgon.mountain>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 06 May 2013 11:54:53 -0400
Message-ID: <1367855693.2976.205.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2013-05-06 at 18:44 +0300, Dan Carpenter wrote:
> Hello Simo Sorce,
> 
> The patch 1d658336b05f: "SUNRPC: Add RPC based upcall mechanism for 
> RPCGSS auth" from May 25, 2012, leads to the following warning:
> "net/sunrpc/auth_gss/gss_rpc_xdr.c:30 gssx_check_pointer()
> 	 warn: signedness bug returning '(-28)'"
> 
> net/sunrpc/auth_gss/gss_rpc_xdr.c
>     24  static bool gssx_check_pointer(struct xdr_stream *xdr)
>     25  {
>     26          __be32 *p;
>     27  
>     28          p = xdr_reserve_space(xdr, 4);
>     29          if (unlikely(p == NULL))
>     30                  return -ENOSPC;
>                                ^^^^^^^
> This is casted implicitly to "true".  Functions named "check" are a bad
> idea anyways because it's not clear what the return value will be.  It's
> better to use "gssx_pointer_ok()" or "valid" where obviously true means
> that the pointer is ok.
> 
>     31          return *p?true:false;
> 
> We just reserved "*p" so doesn't this point to uninitialized data?  It
> points to a __be32.  So we're not really checking a pointer we're
> checking that __be32 is non-zero.
> 
>     32  }
> 
> regards,
> dan carpenter

Dan,
thanks a lot for pointing this one out.

Bruce,
we should fix it in 3.10 if we can make it.

probably easiest way is to kill lines 29/30 and do:
return (p && *p) ? true : false;

It would be also ok to change the name to gssx_pointer_is_valid() I
guess.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

