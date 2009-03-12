From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: nfsstat --sleep=#
Date: Thu, 12 Mar 2009 12:34:33 -0400
Message-ID: <8ABAC880-1972-4E0A-8666-59443E80B942@oracle.com>
References: <49B86744.6060105@disney.com> <ADDF97BC-8B6A-4EFC-9242-C1454B8F423C@oracle.com> <20090312155055.GB2081@fieldses.org> <65B488F7-A902-4126-8E05-65622991D78C@oracle.com> <20090312162459.GC2081@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:51989 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754770AbZCLQev (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Mar 2009 12:34:51 -0400
In-Reply-To: <20090312162459.GC2081@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar 12, 2009, at Mar 12, 2009, 12:24 PM, J. Bruce Fields wrote:
> On Thu, Mar 12, 2009 at 12:08:57PM -0400, Chuck Lever wrote:
>> On Mar 12, 2009, at Mar 12, 2009, 11:50 AM, J. Bruce Fields wrote:
>>> On Thu, Mar 12, 2009 at 10:00:34AM -0400, Chuck Lever wrote:
>>>> Hi Kevin-
>>>>
>>>> man watch(1)
>>>
>>> What would you watch?
>>
>> For example:
>>
>>  watch -n3 nfsstat -c
>>
>> You can also use the "-d" option to highlight the differences between
>> the current sample and the previous sample.
>
> He was asking for deltas; the above only gives cumulative totals.

In that case, he might try one of the Python scripts I wrote that  
report NFS and RPC metrics.  mountstats and nfs-iostat are included in  
the latest nfs-utils tarball.  If they don't do exactly what is  
needed, it should be easy to hack them.

> There's no accurate one-line solution using the existing nfsstat
> commandline, but it should be easy to add.
>
> --b.
>
>>
>>> --b.
>>>
>>>>
>>>> On Mar 11, 2009, at Mar 11, 2009, 9:37 PM, Kevin Constantine wrote:
>>>>
>>>>> I'd really like to have a way to output the nfsstat counters at
>>>>> regular intervals (every 3 seconds) where the output is the
>>>>> difference
>>>>> between 3 seconds ago and now.  Frequently I'll run a test and
>>>>> want to
>>>>> watch the nfs call profile throughout the course of the test.
>>>>>
>>>>> Does something like this already exist?
>>>>> Are there objections to seeing a feature like this?
>>>>>
>>>>> I'm thinking something like:
>>>>> nfsstat --sleep=1
>>>>>
>>>>> nfs v3 call:   Server   Client
>>>>>     total:        0     3476
>>>>>      null:        0        0
>>>>>   getattr:        0     1679
>>>>>   setattr:        0        0
>>>>>    lookup:        0      839
>>>>>    access:        0      839
>>>>>  readlink:        0        0
>>>>>      read:        0        0
>>>>>     write:        0        0
>>>>>    create:        0        0
>>>>>     mkdir:        0        0
>>>>>   symlink:        0        0
>>>>>     mknod:        0        0
>>>>>    remove:        0        0
>>>>>     rmdir:        0        0
>>>>>    rename:        0        0
>>>>>      link:        0        0
>>>>>   readdir:        0        0
>>>>> readdirplus:        0        0
>>>>>    fsstat:        0      119
>>>>>    fsinfo:        0        0
>>>>>  pathconf:        0        0
>>>>>    commit:        0        0
>>>>>
>>>>> --
>>>>> To unsubscribe from this list: send the line "unsubscribe linux- 
>>>>> nfs"
>>>>> in
>>>>> the body of a message to majordomo@vger.kernel.org
>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>
>>>> -- 
>>>> Chuck Lever
>>>> chuck[dot]lever[at]oracle[dot]com
>>>>
>>>>
>>>>
>>>>
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux- 
>>>> nfs"
>>>> in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>> -- 
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com
>>
>>
>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux- 
>> nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




