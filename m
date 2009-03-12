From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: nfsstat --sleep=#
Date: Thu, 12 Mar 2009 13:22:32 -0400
Message-ID: <82886FA0-DF61-4979-B914-3CC59BAA2493@oracle.com>
References: <49B86744.6060105@disney.com> <ADDF97BC-8B6A-4EFC-9242-C1454B8F423C@oracle.com> <20090312155055.GB2081@fieldses.org> <65B488F7-A902-4126-8E05-65622991D78C@oracle.com> <20090312162459.GC2081@fieldses.org> <49B93C10.5020208@disney.com> <20090312164818.GF2081@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:27842 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753155AbZCLRWr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Mar 2009 13:22:47 -0400
In-Reply-To: <20090312164818.GF2081@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar 12, 2009, at Mar 12, 2009, 12:48 PM, J. Bruce Fields wrote:
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
>>>>  watch -n3 nfsstat -c
>>>>
>>>> You can also use the "-d" option to highlight the differences  
>>>> between
>>>> the current sample and the previous sample.
>>>
>>> He was asking for deltas; the above only gives cumulative totals.
>>>
>>> There's no accurate one-line solution using the existing nfsstat
>>> commandline, but it should be easy to add.
>>>
>>
>> Something like this sort of works:
>> watch -n 1 'nfsstat --since /tmp/stats; nfsstat >/tmp/stats', but it
>> feels more like a workaround than a feature.
>
> It's also slightly inaccurate, since it misses any activity that
> happened in the brief time between the two invocations.
>
>> Using watch doesn't allow you to see what happened in the past  
>> either.
>>
>> Moving to a listed output format instead of the traditional nfsstat
>> output (as seen below) makes it trivial with a simple grep to watch  
>> the
>> stats that you really care about and ignore the rest.
>
> I think we'd all be happy to take patches.--b.

Actually I would rather see the performance metrics scripts improved.   
These tools give a lot more information than nfsstat ever will be able  
to.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
