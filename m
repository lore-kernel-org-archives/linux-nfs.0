Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:35899 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755089Ab1DOOVJ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Apr 2011 10:21:09 -0400
Received: by qwk3 with SMTP id 3so1452754qwk.19
        for <linux-nfs@vger.kernel.org>; Fri, 15 Apr 2011 07:21:08 -0700 (PDT)
In-Reply-To: <1302874150.29239.12.camel@lade.trondhjem.org>
References: <20110415010913@it-loops.com>
	<1302840158.2447.5.camel@vovan.net.home>
	<A50602A820F61543B29992A418BB321B66E18F8A71@seldmbx01.corpusers.net>
	<20110415120934@it-loops.com>
	<1302874150.29239.12.camel@lade.trondhjem.org>
Date: Fri, 15 Apr 2011 10:21:08 -0400
Message-ID: <BANLkTinUvdAsikun83=Bx3ssNM=m3zMEdw@mail.gmail.com>
Subject: Re: [BUG] sec=krb5 mount problem with nfs-utils 1.2.3 on client side
From: Kevin Coffman <kwc@citi.umich.edu>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Michael Guntsche <mike@it-loops.com>,
        "Dr. J. Bruce Fields" <bfields@fieldses.org>,
        "Finney, Sean" <Sean.Finney@sonyericsson.com>,
        "vovan@vovan.nl" <vovan@vovan.nl>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Apr 15, 2011 at 9:29 AM, Trond Myklebust
<trond.myklebust@fys.uio.no> wrote:
> On Fri, 2011-04-15 at 12:16 +0200, Michael Guntsche wrote:
>> Thank you for the information, but I got it working in the meantime.
>> The main problem still is that the code for some reason tries to use AES
>> although I tried specifying a different enctype in my kerberos config.
>> Nevertheless it should just work with AES as well, so where was the
>> problem?
>> Quite simple....missing kernel support. I enabled AES support but I DID
>> NOT enable CTS support which is of course needed as well. So after
>> compiling the server and client kernels with BOTH AES and CTS support I
>> can no mount the NFS4 export without any issues.
>
> Sigh. We really should not allow that kind of config. It just creates
> confusion.
>
> Kevin, what are the dependencies for the kerberos V module today? Am I
> missing something in the following list?
>
>        depends on SUNRPC && CRYPTO
>        depends on CRYPTO_MD5 && CRYPTO_DES && CRYPTO_CBC && CRYPTO_CTS
>        depends on CRYPTO_ECB && CRYPTO_HMAC && CRYPTO_MD5 &&
>        CRYPTO_SHA1
>        depends on CRYPTO_AES
>
> Cheers
>  Trond

Yeah, I think that stuff got left out of the final patches.

DES3 needs (in addition to the stuff already there for DES) HMAC and SHA1
AES needs SHA1 AES CTS
RC4 needs ECB ARC4 MD5

So I think you are only missing CRYPTO_ARC4.
