Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:55546 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751022AbcDDDie (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 3 Apr 2016 23:38:34 -0400
Date: Sun, 3 Apr 2016 23:38:33 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Cc: linux-nfs@vger.kernel.org, linux-crypto@vger.kernel.org
Subject: Re: [PATCH v2] sunrpc: Fix skcipher/shash conversion
Message-ID: <20160404033833.GA22637@fieldses.org>
References: <20160403001319.GB12588@fieldses.org>
 <20160403010952.GA25687@gondor.apana.org.au>
 <20160403035900.GB14318@fieldses.org>
 <20160403043715.GA26722@gondor.apana.org.au>
 <20160403221543.GB19744@fieldses.org>
 <20160404012202.GA31970@gondor.apana.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160404012202.GA31970@gondor.apana.org.au>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 04, 2016 at 09:22:02AM +0800, Herbert Xu wrote:
> On Sun, Apr 03, 2016 at 06:15:43PM -0400, J. Bruce Fields wrote:
> > For some reason, the original didn't appear to get cc'd to the linux-nfs
> > list.  Or did it, and I missed it?  I do get lazy sometimes, but in
> > general something like this I'd at least grab and run some tests on.
> > Especially if there's a git tree I can grab, then it just takes me a
> > minute to kick off.
> 
> I'm pretty sure it did get to linux-nfs, or at least the archive :)
> 
> https://www.spinics.net/lists/linux-nfs/msg56240.html

D'oh.  I was probably just lame, then.  Thanks for the fix.  Feel free
to add my tested-by: if you want.

Hm, now I'm seeing list corruption in the rpc code on callbacks....
That's almost certainly unrelated to this, though.

--b.
