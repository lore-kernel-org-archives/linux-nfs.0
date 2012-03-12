Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gy0-f174.google.com ([209.85.160.174]:64373 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755700Ab2CLRNR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Mar 2012 13:13:17 -0400
Received: by ghrr11 with SMTP id r11so2791282ghr.19
        for <linux-nfs@vger.kernel.org>; Mon, 12 Mar 2012 10:13:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1331571865.8219.23.camel@lade.trondhjem.org>
References: <1331504084.2792.7.camel@lade.trondhjem.org>
	<20120311230249.GA1305@fieldses.org>
	<CAKnQG+fCO83KTjQZoqW7RqUn7NerhudEUPD+5-WBEQe=9RSZzg@mail.gmail.com>
	<1331571865.8219.23.camel@lade.trondhjem.org>
Date: Mon, 12 Mar 2012 13:13:16 -0400
Message-ID: <CAKnQG+f5VcD6OENTw=Lg_kquLYiyMtgjNtj8i28uMJ+Y6t1KeA@mail.gmail.com>
Subject: Re: Bug in gss_krb5_crypto.c
From: Kevin Coffman <kwc@citi.umich.edu>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Dr James Bruce Fields <bfields@fieldses.org>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 12, 2012 at 1:04 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> On Mon, 2012-03-12 at 11:13 -0400, Kevin Coffman wrote:
>> On Sun, Mar 11, 2012 at 7:02 PM, Dr James Bruce Fields
>> <bfields@fieldses.org> wrote:
>> > On Sun, Mar 11, 2012 at 10:14:44PM +0000, Myklebust, Trond wrote:
>> >> Hi Kevin & Bruce,
>> >>
>> >> When running sparse on the sunrpc code, I'm seeing the following error
>> >> message:
>> >> "net/sunrpc/auth_gss/gss_krb5_crypto.c:603:52: error: bad constant
>> >> expression"
>> >>
>> >> This boils down to the line:
>> >>         u8 data[crypto_blkcipher_blocksize(cipher) * 2];
>> >
>> > Oops.
>> >
>> >> which is using a GNU Cc-ism in order to do dynamic allocation on the
>> >> stack. This is not acceptable in kernel code, and really needs to be
>> >> changed. How should we move forward with this? Is there an upper limit
>> >> on the value of crypto_blkcipher_blocksize(cipher) that we can use?
>> >
>> > I think it's always either 8 or 16.
>> >
>> > --b.
>> >
>>
>> Yes, I think 16 is currently the upper blocksize limit.  I was
>> thinking there was a constant defined in a header for the
>> maxblocksize, but I'm not able to get to my machine to grep for it
>> right now.
>
> I can't see an absolute maximum for the blocksize. The biggest blocksize
> that I can find in the sources now is SHA512_BLOCK_SIZE, with the value
> 128. That looks a little large to be using in a stack variable.
>
> --
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
>

Olga got my machine back online :-)

GSS_KRB5_MAX_BLOCKSIZE is defined in include/linux/sunrpc/gss_krb5.h

The value above is in bytes (16).

K.C.
