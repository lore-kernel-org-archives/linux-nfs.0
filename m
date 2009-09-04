From: Ben Greear <greearb@candelatech.com>
Subject: Re: Reading NFS file without copying to user-space?
Date: Fri, 04 Sep 2009 13:49:38 -0700
Message-ID: <4AA17D62.9020404@candelatech.com>
References: <4AA16F25.6050700@candelatech.com> <1252096543.2402.4.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:53155 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933903AbZIDUto (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Sep 2009 16:49:44 -0400
In-Reply-To: <1252096543.2402.4.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/04/2009 01:35 PM, Trond Myklebust wrote:
> On Fri, 2009-09-04 at 12:48 -0700, Ben Greear wrote:
>> I'm trying to optimize a tool that should do NFS reads as fast as possible
>> from a server in order to stress test the server.
>>
>> Currently, I open the file as normal and read into a pre-allocated buffer.
>>
>> This causes a copy of the data to user-space.
>>
>> Is there any way to cause the nfs client logic to still request the file-read,
>> but not actually copy anything to user-space?
>>
>> Maybe some trick with mmap would do this?
>
> How about using O_DIRECT? That just copies the data directly into user
> pages and avoids all the overhead of using the page cache?
>
> Note that you can combine O_DIRECT with aio in order to further increase
> the speeds.

I'm using O_DIRECT (so that the server is continually stressed even if
the file would have otherwise been cached locally on the client).

This still causes a copy of the contents to user-space when I do a
read() call though, as far as I can tell.  Since I'm normally not looking
at this data at all, the memory copy from kernel to user is wasted
effort in my case.

I haven't looked into aio yet..will go do some googling...

Thanks,
Ben


>
> Cheers
>    Trond


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

