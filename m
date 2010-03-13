From: Wendy Cheng <s.wendy.cheng@gmail.com>
Subject: Re: Very Slow Sequential Reads over NFS from an XFS disk in Amazon
 EC2
Date: Fri, 12 Mar 2010 18:25:41 -0800
Message-ID: <4B9AF7A5.6020100@gmail.com>
References: <e2c9b7261003111340i4aeff44dye0c5e9928ca13dc6@mail.gmail.com> 	<e2c9b7261003121022p40a5c382r3b0ca65e91d02622@mail.gmail.com> 	<1268418808.8154.7.camel@localhost.localdomain> <e2c9b7261003121623n3e6697cay664ccb1c1d978d5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
To: Brandon Simmons <brandon.m.simmons@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13012 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756393Ab0CMC0U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Mar 2010 21:26:20 -0500
In-Reply-To: <e2c9b7261003121623n3e6697cay664ccb1c1d978d5-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Brandon Simmons wrote:
> On Fri, Mar 12, 2010 at 1:33 PM, Trond Myklebust
> <trond.myklebust@fys.uio.no> wrote:
>   
>> On Fri, 2010-03-12 at 13:22 -0500, Brandon Simmons wrote:
>>     
>>> I am using tiobench to test performance of an NFS mounted volume, and
>>> notice that Sequential Reads are much slower than Random Reads. This
>>> isn't the behavior when I run the same test on the disk mounted
>>> locally.
>>>
>>> For random reads I'm getting:
>>>
>>>    50 MB/s  over NFS
>>>
>>> v.s
>>>
>>>    384 MB/s  when mounted locally
>>>
>>> This is in comparison to the benchmark for _Random Reads_, in which I get:
>>>
>>>    288 MB/s both over NFS _and_ when directly mounted
>>>
>>> The other benchmarks seem to be in line with what I would expect, but
>>> I'm fairly new to NFS. Why would sequential reads over NFS be sooo
>>> much slower than random reads over NFS?
>>>       
>> They're not usually. My guess is that this is an artifact of your test.
>> What is tiobench doing prior to the sequential read?
>>
>> Trond
>>     
>
> I'm wondering if this is caused by caching. my benchmark does
> Sequential Reads first, then it does Random Reads. Is it possible that
> the random reads could be working on cached data?
>
> That would mean my sequential reads aren't too slow, rather the random
> reads are extraordinarily fast because of caching. Looking at running
> some different benchmarks.
>
>   

I think so too - since your throughput are way too good (when compared 
with other I/O-bound numbers). Using simple benchmark(s) such as 
tiobench can generate very misleading results if you don't know how to 
steer away from cache effects. For NFS workload, SPECsfs is a much 
better benchmark but it is cumbersome to run (and you have to pay for 
it, I think).

In general, however, I find sequential read performance hard to predict 
in a virtual environment. This is because the data can be (physically) 
scattered around. It takes non-trivial efforts for system software to 
get its pre-fetch logic right.

-- Wendy

