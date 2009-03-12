From: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Subject: Re: nfsstat --sleep=#
Date: Thu, 12 Mar 2009 10:09:33 -0700
Message-ID: <49B941CD.6070807@disney.com>
References: <49B86744.6060105@disney.com> <ADDF97BC-8B6A-4EFC-9242-C1454B8F423C@oracle.com> <20090312155055.GB2081@fieldses.org> <65B488F7-A902-4126-8E05-65622991D78C@oracle.com> <20090312162459.GC2081@fieldses.org> <49B93C10.5020208@disney.com> <20090312164818.GF2081@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgate1.disneyanimation.com ([12.188.26.101]:60919 "EHLO
	mailgate1.disneyanimation.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752637AbZCLRJf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Mar 2009 13:09:35 -0400
In-Reply-To: <20090312164818.GF2081@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Thu, Mar 12, 2009 at 09:45:04AM -0700, Kevin Constantine wrote:
>> J. Bruce Fields wrote:
>>> On Thu, Mar 12, 2009 at 12:08:57PM -0400, Chuck Lever wrote:
>>>> On Mar 12, 2009, at Mar 12, 2009, 11:50 AM, J. Bruce Fields wrote:
>>>>> On Thu, Mar 12, 2009 at 10:00:34AM -0400, Chuck Lever wrote:
>>>>>> Hi Kevin-
>>>>>>
>>>>>> man watch(1)
>>>>> What would you watch?
>>>> For example:
>>>>
>>>>   watch -n3 nfsstat -c
>>>>
>>>> You can also use the "-d" option to highlight the differences between 
>>>>  the current sample and the previous sample.
>>> He was asking for deltas; the above only gives cumulative totals.
>>>
>>> There's no accurate one-line solution using the existing nfsstat
>>> commandline, but it should be easy to add.
>>>
>> Something like this sort of works:
>> watch -n 1 'nfsstat --since /tmp/stats; nfsstat >/tmp/stats', but it  
>> feels more like a workaround than a feature.
> 
> It's also slightly inaccurate, since it misses any activity that
> happened in the brief time between the two invocations.
> 
>> Using watch doesn't allow you to see what happened in the past either.
>>
>> Moving to a listed output format instead of the traditional nfsstat  
>> output (as seen below) makes it trivial with a simple grep to watch the  
>> stats that you really care about and ignore the rest.
> 
> I think we'd all be happy to take patches.--b.
> 
Cool.  I'll spend some time today then.


> 
>> -kevin
>>
>>
>>> --b.
>>>
>>>>> --b.
>>>>>
>>>>>> On Mar 11, 2009, at Mar 11, 2009, 9:37 PM, Kevin Constantine wrote:
>>>>>>
>>>>>>> I'd really like to have a way to output the nfsstat counters at
>>>>>>> regular intervals (every 3 seconds) where the output is the   
>>>>>>> difference
>>>>>>> between 3 seconds ago and now.  Frequently I'll run a test and  
>>>>>>> want to
>>>>>>> watch the nfs call profile throughout the course of the test.
>>>>>>>
>>>>>>> Does something like this already exist?
>>>>>>> Are there objections to seeing a feature like this?
>>>>>>>
>>>>>>> I'm thinking something like:
>>>>>>> nfsstat --sleep=1
>>>>>>>
>>>>>>> nfs v3 call:   Server   Client
>>>>>>>      total:        0     3476
>>>>>>>       null:        0        0
>>>>>>>    getattr:        0     1679
>>>>>>>    setattr:        0        0
>>>>>>>     lookup:        0      839
>>>>>>>     access:        0      839
>>>>>>>   readlink:        0        0
>>>>>>>       read:        0        0
>>>>>>>      write:        0        0
>>>>>>>     create:        0        0
>>>>>>>      mkdir:        0        0
>>>>>>>    symlink:        0        0
>>>>>>>      mknod:        0        0
>>>>>>>     remove:        0        0
>>>>>>>      rmdir:        0        0
>>>>>>>     rename:        0        0
>>>>>>>       link:        0        0
>>>>>>>    readdir:        0        0
>>>>>>> readdirplus:        0        0
>>>>>>>     fsstat:        0      119
>>>>>>>     fsinfo:        0        0
>>>>>>>   pathconf:        0        0
>>>>>>>     commit:        0        0
>>>>>>>
>>>>>>> --
>>>>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs"
>>>>>>> in
>>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>>> -- 
>>>>>> Chuck Lever
>>>>>> chuck[dot]lever[at]oracle[dot]com
>>>>>>
>>>>>>
>>>>>>
>>>>>>
>>>>>> --
>>>>>> To unsubscribe from this list: send the line "unsubscribe 
>>>>>> linux-nfs" in
>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>> -- 
>>>> Chuck Lever
>>>> chuck[dot]lever[at]oracle[dot]com
>>>>
>>>>
>>>>
>>>>
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
------------------------------------------------------------
Kevin Constantine

Systems Engineer		t: 818.460.8221
Walt Disney Animation Studios	e: kevin.constantine-P5ys19MLBK/QT0dZR+AlfA@public.gmane.org

Any sufficiently advanced technology is indistinguishable from magic.
     - Arthur C. Clarke
