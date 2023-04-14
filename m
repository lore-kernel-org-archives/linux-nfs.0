Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A28D2C77B70
	for <linux-nfs@archiver.kernel.org>; Fri, 14 Apr 2023 08:52:44 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230182AbjDNIwn (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 14 Apr 2023 04:52:43 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:33282 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S230046AbjDNIwm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Apr 2023 04:52:42 -0400
Received: from 167-179-156-38.a7b39c.syd.nbn.aussiebb.net (167-179-156-38.a7b39c.syd.nbn.aussiebb.net [167.179.156.38])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 24BA626BE;
        Fri, 14 Apr 2023 01:52:40 -0700 (PDT)
Received: from loth.rohan.me.apana.org.au ([192.168.167.2])
        by formenos.hmeau.com with smtp (Exim 4.94.2 #2 (Debian))
        id 1pnFAO-00Fo8l-Jf; Fri, 14 Apr 2023 16:52:25 +0800
Received: by loth.rohan.me.apana.org.au (sSMTP sendmail emulation); Fri, 14 Apr 2023 16:52:24 +0800
Date:   Fri, 14 Apr 2023 16:52:24 +0800
From:   Herbert Xu <herbert@gondor.apana.org.au>
To:     David Howells <dhowells@redhat.com>
Cc:     Chuck Lever III <chuck.lever@oracle.com>,
        Scott Mayhew <smayhew@redhat.com>,
        Ard Biesheuvel <ardb@kernel.org>,
        Jeff Layton <jlayton@kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>
Subject: Re: Did the in-kernel Camellia or CMAC crypto implementation break?
Message-ID: <ZDkUSESImVSUX0RW@gondor.apana.org.au>
References: <ZDi1qjVpcpr2BZfN@gondor.apana.org.au>
 <48886D84-1A04-4B07-A666-BB56684E759F@oracle.com>
 <380323.1681314997@warthog.procyon.org.uk>
 <1078650.1681394138@warthog.procyon.org.uk>
 <1235770.1681462057@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1235770.1681462057@warthog.procyon.org.uk>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Apr 14, 2023 at 09:47:37AM +0100, David Howells wrote:
>
> Actually, I was wondering about that.  I see that all the testing data seems
> to be statically loaded in testmgr.[ch], even if the algorithms to be tested
> are resident in modules that aren't loaded yet (so it's kind of test "on
> demand").  I guess it can't be split up amongst the algorithm modules as some
> of the tests require stuff from multiple modules (eg. aes + cbs + cts).

Yes I've been meaning to split this up so they're colocated with
the generic implementation.

> If I'm going to do that, I presume I'd need to create an API akin to the
> skcipher API or the hash API, say, to do autoload/create krb5 crypto.  Maybe
> loading with something like:
> 
> 	struct crypto_krb5 *alg;
> 
> 	alg = crypto_alloc_krb5("aes256-cts-hmac-sha384-192", 0,
> 				CRYPTO_ALG_ASYNC);
> 
> and split the algorithms into separate modules?  Much of the code would still
> end up in a common module, though.

Unless this code has at least two users it's probably not worth
it (but there are exceptions, e.g. we did a one-user algorithm
for dm-crypt).

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
