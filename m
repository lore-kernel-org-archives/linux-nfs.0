Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:28728 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755431AbZDQP60 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Apr 2009 11:58:26 -0400
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-Id: <52A6E4A3-F155-4F7A-85B1-DB2366708003@oracle.com>
From: Chuck Lever <chuck.lever@oracle.com>
To: Kevin Constantine <Kevin.Constantine@disneyanimation.com>
In-Reply-To: <49E7CE3E.8020006@disney.com>
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Subject: Re: Exposing cache statistics
Date: Fri, 17 Apr 2009 11:58:02 -0400
References: <49E643CD.9070809@disney.com> <1239828092.5177.139.camel@heimdal.trondhjem.org> <49E7CE3E.8020006@disney.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Apr 16, 2009, at 8:33 PM, Kevin Constantine wrote:

> Trond Myklebust wrote:
>> On Wed, 2009-04-15 at 13:30 -0700, Kevin Constantine wrote:
>>> Has there been any effort to expose caching statistics to the end  
>>> user?   On the client-side, it would be useful to see how much  
>>> data is being re-used from cache vs data that gets retrieved over  
>>> the wire.  Similarly on the server side, it would be nice to see  
>>> how much data is being served from cache vs having to pull the  
>>> data from disk.
>>>
>>> Just wondering if anyone started anything to expose this sort of  
>>> information.
>> See the nfs-iostat tool in the nfs-utils package:
>>   http://git.linux-nfs.org/?p=steved/nfs-utils.git;a=tree;f=tools/nfs-iostat;h=929e303cc762a68dfd01546f5150eb294274164e;hb=refs/heads/master
>> Note that you need a 2.6.17 kernel or newer.
>> Cheers
>>  Trond
>
> Thanks Trond-
>
> It seems like nfs-iostat is displaying the number of pages that are  
> being written to the read/write caches (i'm only looking at the  
> client-side at the moment), and what I'm interested in is the ratio  
> of pages being read from cache vs data being fetched from the server.
>
> Is there any documentation on the layout of /proc/self/mountstats?


Take a look at the python code in nfs-iostat or mountstats.  Besides  
documenting the layout of /proc/self/mountstats, there may also be  
some code in there that shows how to compute cache hit ratios.

The __print_data_cache_stats function in nfs-iostat does just this for  
the page cache, but I don't see it called anywhere.

Note these scripts are not finished, which is why they are currently  
not installed by default.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
