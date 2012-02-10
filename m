Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ww0-f44.google.com ([74.125.82.44]:63885 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759461Ab2BJQGb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Feb 2012 11:06:31 -0500
Received: by wgbdt10 with SMTP id dt10so2943724wgb.1
        for <linux-nfs@vger.kernel.org>; Fri, 10 Feb 2012 08:06:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120209183911.GB22168@fieldses.org>
References: <1328576237-7362-1-git-send-email-Trond.Myklebust@netapp.com>
	<20120208162322.GA13315@fieldses.org>
	<1328722042.3234.13.camel@lade.trondhjem.org>
	<20120208174901.GA28564@umich.edu>
	<20120208183151.GA14316@fieldses.org>
	<20120208203140.GA29238@umich.edu>
	<1328734255.3234.32.camel@lade.trondhjem.org>
	<20120208210150.GB29238@umich.edu>
	<CAGue13qU7OJ+Obnc0vtGt8_2BsydeOXmwhHNzctJbWitV4AVvA@mail.gmail.com>
	<20120209183911.GB22168@fieldses.org>
Date: Fri, 10 Feb 2012 11:06:30 -0500
Message-ID: <CAHVgHyVQpT9xwhud=j47f+uDR3UBrQ32YKGq0chtc1bDirARwg@mail.gmail.com>
Subject: Re: [RFC PATCH 1/2] NFSv4.1: Convert slotid from u8 to u32
From: Andy Adamson <androsadamson@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>, Jim Rees <rees@umich.edu>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 9, 2012 at 1:39 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Thu, Feb 09, 2012 at 09:37:22AM +0100, Tigran Mkrtchyan wrote:
>> Putting my 'high energy physics community' hat on let me comment on it.
>>
>> As soon as we trying to use nfs over high latency networks the
>
> How high is the latency?
>
>> application efficiency rapidly drops. Efficiency is wallTIme/cpuTime.
>> We have solve this in our home grown protocols by adding vector read
>> and vector write. Vector is set of offset_length. As most of the our
>> files has DB like structure, after reading header (something like
>> index) we knew where data is located. This allows us to perform in
>> some work loads 100 times better than NFS.
>>
>> Posix does not provides such interface. But we can simulate that with
>> fadvise calls (and we do). Since nfs-4.0 we got compound  operations.
>> And you can (in theory) build a compound with multiple READ or WRITE
>> ops. Nevertheless this does not work for several reasons: maximal
>> reply size and you still have to wait for full reply. and some reply
>> may be up 100MB in size.
>>
>> The solution here is to issue multiple requests in parallel. And this
>> is possible only if you have enough session slots. Server can reply
>> out of order and populate clients file system cache.
>
> Yep.
>
> I'm just curious whether Andy or someone's beeing doing experiments with
> these patches, and if so, what they look like.
>
> (The numbers I can find from the one case we worked on at citi (UM to
> CERN), were 10 gig * 120ms latency for a 143MB bandwidth-delay product,
> so in theory 143 slots would suffice if they were all doing maximum-size

The net I tested with has a 127ms delay (~152MB bandwitdth-delay
product) - the same ballpark as 120ms.
As you mention, you are assuming an rsize/wsize of 1 MB. Think of a
server that only supports 64k and you need a lot more slots (143 * 16
= 2288 slots) to fill the 143MB bandwidth-delay product. A 64K r/wsize
server with 255 slots on a 10G net could only fill a 13ms latency 10G
net.

Plus - 10GB nets are old tech! The CERN/UMICH machines I was working
with had 40GB NICs.  100GB nets are on the way...

-->Andy

> IO--but I can't find any results from NFS tests over that link (only
> results for a lower-latency 10gig network).
>
> And, of course, if you're doing smaller operations or have an even
> higher-latency network, etc., you could need more slots--I just wondered
> abuot the details.)
>
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
