Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:50541 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751018AbcDDBWH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Apr 2016 21:22:07 -0400
Date: Mon, 4 Apr 2016 09:22:02 +0800
From: Herbert Xu <herbert@gondor.apana.org.au>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, linux-crypto@vger.kernel.org
Subject: Re: [PATCH v2] sunrpc: Fix skcipher/shash conversion
Message-ID: <20160404012202.GA31970@gondor.apana.org.au>
References: <20160403001319.GB12588@fieldses.org>
 <20160403010952.GA25687@gondor.apana.org.au>
 <20160403035900.GB14318@fieldses.org>
 <20160403043715.GA26722@gondor.apana.org.au>
 <20160403221543.GB19744@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160403221543.GB19744@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Apr 03, 2016 at 06:15:43PM -0400, J. Bruce Fields wrote:
>
> OK, I did get a chance to run this, and so far it looks good--it got
> faszter than the last time, anyway.  Thanks!

Thanks!

> For some reason, the original didn't appear to get cc'd to the linux-nfs
> list.  Or did it, and I missed it?  I do get lazy sometimes, but in
> general something like this I'd at least grab and run some tests on.
> Especially if there's a git tree I can grab, then it just takes me a
> minute to kick off.

I'm pretty sure it did get to linux-nfs, or at least the archive :)

https://www.spinics.net/lists/linux-nfs/msg56240.html

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
