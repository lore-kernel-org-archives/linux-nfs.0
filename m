Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 972C7C77B70
	for <linux-nfs@archiver.kernel.org>; Fri, 14 Apr 2023 11:05:49 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229752AbjDNLFs (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 14 Apr 2023 07:05:48 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:40336 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S230092AbjDNLFq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Apr 2023 07:05:46 -0400
Received: from 167-179-156-38.a7b39c.syd.nbn.aussiebb.net (167-179-156-38.a7b39c.syd.nbn.aussiebb.net [167.179.156.38])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id DB6664C2D;
        Fri, 14 Apr 2023 04:05:29 -0700 (PDT)
Received: from loth.rohan.me.apana.org.au ([192.168.167.2])
        by formenos.hmeau.com with smtp (Exim 4.94.2 #2 (Debian))
        id 1pnHEc-00FqgN-A2; Fri, 14 Apr 2023 19:04:55 +0800
Received: by loth.rohan.me.apana.org.au (sSMTP sendmail emulation); Fri, 14 Apr 2023 19:04:54 +0800
Date:   Fri, 14 Apr 2023 19:04:54 +0800
From:   Herbert Xu <herbert@gondor.apana.org.au>
To:     David Howells <dhowells@redhat.com>
Cc:     Chuck Lever III <chuck.lever@oracle.com>,
        Scott Mayhew <smayhew@redhat.com>,
        Ard Biesheuvel <ardb@kernel.org>,
        Jeff Layton <jlayton@kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>
Subject: Re: Did the in-kernel Camellia or CMAC crypto implementation break?
Message-ID: <ZDkzVmO2eUbcuy9E@gondor.apana.org.au>
References: <ZDkoiqPXwIRYmeF3@gondor.apana.org.au>
 <ZDkUSESImVSUX0RW@gondor.apana.org.au>
 <ZDi1qjVpcpr2BZfN@gondor.apana.org.au>
 <48886D84-1A04-4B07-A666-BB56684E759F@oracle.com>
 <380323.1681314997@warthog.procyon.org.uk>
 <1078650.1681394138@warthog.procyon.org.uk>
 <1235770.1681462057@warthog.procyon.org.uk>
 <1239035.1681467430@warthog.procyon.org.uk>
 <1239686.1681468477@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1239686.1681468477@warthog.procyon.org.uk>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Apr 14, 2023 at 11:34:37AM +0100, David Howells wrote:
>
> In krb5, for encryption, there are two keys, not one, and no IV to be passed
> in.  The code I have will insert a confounder and a checksum, which must have
> space allowed for it.

Two keys is not an issue.  Authenc for example supports two keys
by encoding them into a single byte-stream.  AEAD also supports
having no IVs by providing IV generators (see seqiv, eseqiv, etc.).

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
