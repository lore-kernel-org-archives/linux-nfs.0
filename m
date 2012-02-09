Return-Path: linux-nfs-owner@vger.kernel.org
Received: from trumpkin.cc.andrews.edu ([143.207.1.81]:50984 "EHLO
	trumpkin.cc.andrews.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754163Ab2BISSK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Feb 2012 13:18:10 -0500
Message-ID: <4F340DD9.7070402@andrews.edu>
Date: Thu, 09 Feb 2012 13:18:01 -0500
From: Todd Freeman <freeman@andrews.edu>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: nfsd4_stateowners eating memory like candy... sometimes....
References: <4F32F726.4060704@andrews.edu> <20120209180531.GA22168@fieldses.org>
In-Reply-To: <20120209180531.GA22168@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks!  I'll try a kernel update and see what sticks :)



On 02/09/2012 01:05 PM, J. Bruce Fields wrote:
> On Wed, Feb 08, 2012 at 05:28:54PM -0500, Todd Freeman wrote:
>> Good day all!
>>
>> I have a nfs server handling the load for a shared file system for 5
>> web servers...  some relevant info:
>>    libnfsidmap2
>> 0.23-2
>>    nfs-common
>> 1:1.2.2-1ubuntu1.1
>>    nfs-kernel-server
>> 1:1.2.2-1ubuntu1.1
>>
>>    Linux webnfs 2.6.35-31-server #63-Ubuntu SMP Mon Nov 28 21:03:37
>> UTC 2011 x86_64 GNU/Linux
>>
>> On this server everything runs great for a couple weeks to a month
>> and then we start getting sluggish performance... and within a
>> couple days it seizes up (at least all nfs services stop... console
>> is still accessible)
>>
>> In trying to debug this we have been taking a snap shot every 5
>> minutes of the slabinfo...   we got a totally clean capture this
>> time and I see nfsd4_stateowners running away with memory. When we
>> start the server and for the first several days the most memory it
>> uses is 200MB or so...  over time though there come points were it
>> suddenly starts munching more...  sometimes slowly... other times
>> instantly. It finally kills the machine when it reaches the 1.7-1.8
>> GB level (just under the memory size of the machine). oom-killer is
>> killing everything left and right at the end and we end up with a
>> machine that is comatose NFS wise till we do a full reboot.
>>
>> You can see a graph of this usage pattern at: http://imgur.com/ecLPh
>>
>> I see mentions of a problem along this line back in the 2.6.16-18
>> types days... but supposedly it was fixed.
> There have been a number of stateowner leaks fixed since 2.6.35.  I
> think all the ones I know of were fixes as of 3.1 or so.
>
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Todd Freeman  Ext 6103                   .^.    Don't fear the penguins!
Programming Department                   /V\
Andrews University                      // \\    http://www.linux.org/
http://www.andrews.edu/~freeman/       /(   )\   http://www.debian.org/
                                         ^^ ^^

