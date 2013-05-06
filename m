Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:43936 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755188Ab3EFPol (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 May 2013 11:44:41 -0400
Date: Mon, 6 May 2013 18:44:35 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: simo@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: re: SUNRPC: Add RPC based upcall mechanism for RPCGSS auth
Message-ID: <20130506154435.GA14732@elgon.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello Simo Sorce,

The patch 1d658336b05f: "SUNRPC: Add RPC based upcall mechanism for 
RPCGSS auth" from May 25, 2012, leads to the following warning:
"net/sunrpc/auth_gss/gss_rpc_xdr.c:30 gssx_check_pointer()
	 warn: signedness bug returning '(-28)'"

net/sunrpc/auth_gss/gss_rpc_xdr.c
    24  static bool gssx_check_pointer(struct xdr_stream *xdr)
    25  {
    26          __be32 *p;
    27  
    28          p = xdr_reserve_space(xdr, 4);
    29          if (unlikely(p == NULL))
    30                  return -ENOSPC;
                               ^^^^^^^
This is casted implicitly to "true".  Functions named "check" are a bad
idea anyways because it's not clear what the return value will be.  It's
better to use "gssx_pointer_ok()" or "valid" where obviously true means
that the pointer is ok.

    31          return *p?true:false;

We just reserved "*p" so doesn't this point to uninitialized data?  It
points to a __be32.  So we're not really checking a pointer we're
checking that __be32 is non-zero.

    32  }

regards,
dan carpenter

