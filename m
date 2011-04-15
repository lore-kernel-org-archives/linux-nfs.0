Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:50105 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754568Ab1DON3W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Apr 2011 09:29:22 -0400
Subject: Re: [BUG] sec=krb5 mount problem with nfs-utils 1.2.3 on client
 side
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Michael Guntsche <mike@it-loops.com>, Kevin Coffman <kwc@citi.umich.edu>,
        "Dr. J. Bruce Fields" <bfields@fieldses.org>
Cc: "Finney, Sean" <Sean.Finney@sonyericsson.com>,
        "vovan@vovan.nl" <vovan@vovan.nl>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <20110415120934@it-loops.com>
References: <20110415010913@it-loops.com>
	 <1302840158.2447.5.camel@vovan.net.home>
	 <A50602A820F61543B29992A418BB321B66E18F8A71@seldmbx01.corpusers.net>
	 <20110415120934@it-loops.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 15 Apr 2011 09:29:10 -0400
Message-ID: <1302874150.29239.12.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2011-04-15 at 12:16 +0200, Michael Guntsche wrote:
> Thank you for the information, but I got it working in the meantime.
> The main problem still is that the code for some reason tries to use AES
> although I tried specifying a different enctype in my kerberos config.
> Nevertheless it should just work with AES as well, so where was the
> problem? 
> Quite simple....missing kernel support. I enabled AES support but I DID
> NOT enable CTS support which is of course needed as well. So after
> compiling the server and client kernels with BOTH AES and CTS support I
> can no mount the NFS4 export without any issues.

Sigh. We really should not allow that kind of config. It just creates
confusion.

Kevin, what are the dependencies for the kerberos V module today? Am I
missing something in the following list?

        depends on SUNRPC && CRYPTO
        depends on CRYPTO_MD5 && CRYPTO_DES && CRYPTO_CBC && CRYPTO_CTS
        depends on CRYPTO_ECB && CRYPTO_HMAC && CRYPTO_MD5 &&
        CRYPTO_SHA1
        depends on CRYPTO_AES

Cheers
 Trond

