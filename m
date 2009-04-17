From: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Subject: Re: Exposing cache statistics
Date: Thu, 16 Apr 2009 17:33:02 -0700
Message-ID: <49E7CE3E.8020006@disney.com>
References: <49E643CD.9070809@disney.com> <1239828092.5177.139.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgate2.disneyanimation.com ([12.188.26.102]:18776 "EHLO
	mailgate2.disneyanimation.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759329AbZDQAdD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Apr 2009 20:33:03 -0400
In-Reply-To: <1239828092.5177.139.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Wed, 2009-04-15 at 13:30 -0700, Kevin Constantine wrote:
>> Has there been any effort to expose caching statistics to the end user? 
>>   On the client-side, it would be useful to see how much data is being 
>> re-used from cache vs data that gets retrieved over the wire.  Similarly 
>> on the server side, it would be nice to see how much data is being 
>> served from cache vs having to pull the data from disk.
>>
>> Just wondering if anyone started anything to expose this sort of 
>> information.
> 
> See the nfs-iostat tool in the nfs-utils package:
> 
>    http://git.linux-nfs.org/?p=steved/nfs-utils.git;a=tree;f=tools/nfs-iostat;h=929e303cc762a68dfd01546f5150eb294274164e;hb=refs/heads/master
> 
> Note that you need a 2.6.17 kernel or newer.
> 
> Cheers
>   Trond

Thanks Trond-

It seems like nfs-iostat is displaying the number of pages that are 
being written to the read/write caches (i'm only looking at the 
client-side at the moment), and what I'm interested in is the ratio of 
pages being read from cache vs data being fetched from the server.

Is there any documentation on the layout of /proc/self/mountstats?

-kevin
