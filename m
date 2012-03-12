Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gy0-f174.google.com ([209.85.160.174]:43360 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755943Ab2CLPNy convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Mar 2012 11:13:54 -0400
Received: by ghrr11 with SMTP id r11so2656745ghr.19
        for <linux-nfs@vger.kernel.org>; Mon, 12 Mar 2012 08:13:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120311230249.GA1305@fieldses.org>
References: <1331504084.2792.7.camel@lade.trondhjem.org>
	<20120311230249.GA1305@fieldses.org>
Date: Mon, 12 Mar 2012 11:13:53 -0400
Message-ID: <CAKnQG+fCO83KTjQZoqW7RqUn7NerhudEUPD+5-WBEQe=9RSZzg@mail.gmail.com>
Subject: Re: Bug in gss_krb5_crypto.c
From: Kevin Coffman <kwc@citi.umich.edu>
To: Dr James Bruce Fields <bfields@fieldses.org>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Mar 11, 2012 at 7:02 PM, Dr James Bruce Fields
<bfields@fieldses.org> wrote:
> On Sun, Mar 11, 2012 at 10:14:44PM +0000, Myklebust, Trond wrote:
>> Hi Kevin & Bruce,
>>
>> When running sparse on the sunrpc code, I'm seeing the following error
>> message:
>> "net/sunrpc/auth_gss/gss_krb5_crypto.c:603:52: error: bad constant
>> expression"
>>
>> This boils down to the line:
>>         u8 data[crypto_blkcipher_blocksize(cipher) * 2];
>
> Oops.
>
>> which is using a GNU Cc-ism in order to do dynamic allocation on the
>> stack. This is not acceptable in kernel code, and really needs to be
>> changed. How should we move forward with this? Is there an upper limit
>> on the value of crypto_blkcipher_blocksize(cipher) that we can use?
>
> I think it's always either 8 or 16.
>
> --b.
>

Yes, I think 16 is currently the upper blocksize limit.  I was
thinking there was a constant defined in a header for the
maxblocksize, but I'm not able to get to my machine to grep for it
right now.

K.C.
