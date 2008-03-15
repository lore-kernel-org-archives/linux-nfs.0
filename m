From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: Re: theoretical rpcsec_gss deadlock
Date: Sat, 15 Mar 2008 09:18:12 +0800
Message-ID: <20080315011812.GA24837@gondor.apana.org.au>
References: <4d569c330803141123o23a35f4bm99ea9ca97a26c59d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-crypto@vger.kernel.org, linux-nfs@vger.kernel.org
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42122 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753807AbYCOBSQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Mar 2008 21:18:16 -0400
In-Reply-To: <4d569c330803141123o23a35f4bm99ea9ca97a26c59d-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 14, 2008 at 02:23:20PM -0400, Kevin Coffman wrote:
>
> Herbert, Bruce Fields says you suggested a while back that an
> interface was already there, or was being planned?  Can you give me
> any details?  Could we possibly help?

Have a look at the linux-crypto archive for the async hash patch
that was posted in January/February.  That will eventually allow
the same tfm to be used in parallel.  However, there is much work
to be done as all existing transforms would have to be updated for
this.

> Another question:  The current checksum code deals only with "md5".
> Support for newer Kerberos encryption types uses keyed hashes.  In an
> extreme case, support for the rc4-hmac Kerberos encryption type
> requires a new hash key be derived for each rpc.  Would this interface
> be able to deal with changing keys as well?  In that same case, the
> "rc4" cipher key changes with each rpc as well.

Sorry, but setting the key is an expensive operation in general,
so the rule is one tfm per key to allow simultaneous operations
on the same key.

However, if hmac is the only mode you're ever going to support,
you could consider implementing hmac by hand which would allow you
to share the underlying algorithm tfm object.  This is because
the hmac key just gets hashed into the underlying tfm.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
