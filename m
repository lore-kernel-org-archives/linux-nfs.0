Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgate2.disneyanimation.com ([198.187.190.102]:36231 "EHLO
	mailgate2.disneyanimation.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752188Ab0E1Wv6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 28 May 2010 18:51:58 -0400
From: Kevin Constantine <Kevin.Constantine@disneyanimation.com>
Message-ID: <4C00490E.3030801@disney.com>
Date: Fri, 28 May 2010 15:51:58 -0700
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org, steved@redhat.com
Subject: Re: [PATCH 1/1] nfs-iostat.py: Fixes several Divide by Zero errors
References: <1275004718-1802-1-git-send-email-kevin.constantine@disneyanimation.com> <4BFF0CB9.7010700@oracle.com> <4BFF1345.9070306@disney.com> <4BFFF6A8.2090103@oracle.com>
In-Reply-To: <4BFFF6A8.2090103@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/28/2010 10:00 AM, Chuck Lever wrote:
> On 05/27/10 08:50 PM, Kevin Constantine wrote:
>> The first time through the code sample_time is set to 0.0 on line 588.
>> Eventually we call display_iostats() and check if sample_time == 0. It
>> does, so we set sample_time equal to the mount age on line 368. I'm
>> seeing instances where the age of a mount is 0.
>>
>> cat /proc/self/mountstats | egrep "device|age"
>> device fashome-n1:/vol/home/fahome mounted on /home/fahome with fstype
>> nfs statvers=1.0
>> age: 0
>>
>> All of our storage is automounted, so volumes are frequently getting
>> unmounted and remounted.
>
> Makes sense. When I wrote the script, I wasn't using automounter at all.
> It might be simpler to have one check for a zero age at 368.
>

My only concern with checking and just returning (which is certainly 
easier and a smaller change) is that we end up not printing anything for 
a volume that is technically mounted.  I figured it was better to print 
the volume info and all zeroes than to not print anything.

I'll defer to your opinion on which of those two is best.

-kevin

>> On 05/27/2010 05:22 PM, Chuck Lever wrote:
>>> On 05/27/2010 07:58 PM, Kevin Constantine wrote:
>>>> There was no check to see if sample_time was zero before dividing by
>>>> it.
>>>
>>> I haven't looked at this code in a very long time. Why was sample_time
>>> zero? That seems wrong.
>>>
>>>> This was causing ZeroDivisionError's:
>>>>
