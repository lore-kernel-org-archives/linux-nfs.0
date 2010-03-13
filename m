From: Brandon Simmons <brandon.m.simmons@gmail.com>
Subject: Re: Very Slow Sequential Reads over NFS from an XFS disk in Amazon
	EC2
Date: Fri, 12 Mar 2010 19:23:56 -0500
Message-ID: <e2c9b7261003121623n3e6697cay664ccb1c1d978d5@mail.gmail.com>
References: <e2c9b7261003111340i4aeff44dye0c5e9928ca13dc6@mail.gmail.com>
	<e2c9b7261003121022p40a5c382r3b0ca65e91d02622@mail.gmail.com>
	<1268418808.8154.7.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f176.google.com ([209.85.223.176]:58021 "EHLO
	mail-iw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935109Ab0CMAYQ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Mar 2010 19:24:16 -0500
Received: by iwn6 with SMTP id 6so195843iwn.4
        for <linux-nfs@vger.kernel.org>; Fri, 12 Mar 2010 16:24:16 -0800 (PST)
In-Reply-To: <1268418808.8154.7.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 12, 2010 at 1:33 PM, Trond Myklebust
<trond.myklebust@fys.uio.no> wrote:
> On Fri, 2010-03-12 at 13:22 -0500, Brandon Simmons wrote:
>> I am using tiobench to test performance of an NFS mounted volume, an=
d
>> notice that Sequential Reads are much slower than Random Reads. This
>> isn't the behavior when I run the same test on the disk mounted
>> locally.
>>
>> For random reads I'm getting:
>>
>> =A0 =A050 MB/s =A0over NFS
>>
>> v.s
>>
>> =A0 =A0384 MB/s =A0when mounted locally
>>
>> This is in comparison to the benchmark for _Random Reads_, in which =
I get:
>>
>> =A0 =A0288 MB/s both over NFS _and_ when directly mounted
>>
>> The other benchmarks seem to be in line with what I would expect, bu=
t
>> I'm fairly new to NFS. Why would sequential reads over NFS be sooo
>> much slower than random reads over NFS?
>
> They're not usually. My guess is that this is an artifact of your tes=
t.
> What is tiobench doing prior to the sequential read?
>
> Trond
>
>

I'm wondering if this is caused by caching. my benchmark does
Sequential Reads first, then it does Random Reads. Is it possible that
the random reads could be working on cached data?

That would mean my sequential reads aren't too slow, rather the random
reads are extraordinarily fast because of caching. Looking at running
some different benchmarks.
