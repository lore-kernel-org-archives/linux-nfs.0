Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.pingtimeout.net ([87.108.18.35]:50997 "EHLO
        mx1.pingtimeout.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752070AbeC1QtH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Mar 2018 12:49:07 -0400
Subject: Re: Regarding client fairness
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
References: <f9c6c1c493d0dde6c4a24afeca00fa5b@pingtimeout.net>
 <20180328145406.GA2641@fieldses.org> <20180328145930.GB2641@fieldses.org>
 <4abd5e4f-2992-730b-8d44-5e611a3a2451@pingtimeout.net>
 <20180328155801.GA3354@fieldses.org>
From: =?UTF-8?B?QW50dGkgVMO2bmt5csOk?= <daedalus@pingtimeout.net>
Message-ID: <29dabd12-aa86-0be2-133a-71611f42a735@pingtimeout.net>
Date: Wed, 28 Mar 2018 19:49:01 +0300
MIME-Version: 1.0
In-Reply-To: <20180328155801.GA3354@fieldses.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2018-03-28 18:58, J. Bruce Fields wrote:
> On Wed, Mar 28, 2018 at 06:35:53PM +0300, Antti Tönkyrä wrote:
>> On 2018-03-28 17:59, J. Bruce Fields wrote:
>>> On Wed, Mar 28, 2018 at 10:54:06AM -0400, bfields wrote:
>>>> On Wed, Mar 28, 2018 at 02:04:57PM +0300, daedalus@pingtimeout.net wrote:
>>>>> I came across a rather annoying issue where a single NFS client
>>>>> caused resource starvation for NFS server. The server has several
>>>>> storage pools which are used, in this particular case a single
>>>>> client did fairly large read requests and effectively ate all nfsd
>>>>> threads on the server and during that other clients were getting
>>>>> hardly any I/O through to the other storage pool which was
>>>>> completely idle.
>>>> What version of the kernel are you running on your server?
>> 4.15.10 on the system I am testing on.
>>> I'm thinking that if it includes upstream 637600f3ffbf "SUNRPC: Change
>>> TCP socket space reservation" (in upstream 4.8), then you may want to
>>> experiment setting the sunrpc.svc_rpc_per_connection_limit module
>>> parameter added in ff3ac5c3dc23 "SUNRPC: Add a server side
>>> per-connection limit".
>>>
>>> You probably want to experiment with values greater than 0 (the default,
>>> no limit) and the number of server threads.
>> That helps for the client slowing down the whole server, thanks for
>> the tip!
> We should probably revisit 637600f3ffbf "SUNRPC: Change TCP socket space
> reservation".  There's got to be some way to keep high bandwidth pipes
> filled with read data without introducing this problem where a single
> client can tie up every server thread.
>
> Just out of curiosity, do you know (approximately) the network and disk
> bandwidth in this case?
>
> --b.

Locally I can read at about 150-200MB/s (two spindles in mirror). 
Additionally I have another mount which is a NVMe drive which performs 
 >500MB/s which I used to verify that I was not bottlenecked when 
running the dd read test which tied up the server threads. Network 
bandwidth is 10Gbps.
