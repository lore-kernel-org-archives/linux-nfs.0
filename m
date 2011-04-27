Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:3111 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756898Ab1D0UZK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Apr 2011 16:25:10 -0400
Message-ID: <4DB87B96.8090400@panasas.com>
Date: Wed, 27 Apr 2011 23:24:54 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Chuck Lever <chuck.lever@oracle.com>, steved@redhat.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsstat: reorder nfs4 stats for 2.6.38 and up
References: <1303461980-6731-1-git-send-email-bhalevy@panasas.com>	 <23EF6F61-46F2-431B-8A44-A3E941688D65@oracle.com>	 <4DB7A084.2060009@panasas.com>	 <1303913806.13195.3.camel@lade.trondhjem.org>	 <4DB86605.3000304@panasas.com> <1303930718.23640.6.camel@lade.trondhjem.org>
In-Reply-To: <1303930718.23640.6.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-04-27 21:58, Trond Myklebust wrote:
> On Wed, 2011-04-27 at 21:52 +0300, Benny Halevy wrote:
>> On 2011-04-27 17:16, Trond Myklebust wrote:
>>> On Wed, 2011-04-27 at 07:50 +0300, Benny Halevy wrote:
>>>> On 2011-04-25 17:11, Chuck Lever wrote:
>>>>> Hey all-
>>>>>
>>>>> So what are we going to do when adding NFSv4.2 to this mix?  Will we
>>>>> then have to freeze both the NFSv4.1 and NFSv4.0 procedure API in the
>>>>> kernel?  Seems painful.
>>>>
>>>> Good question.
>>>> How about changing the stat pseudo-file format to include an op
>>>> identifier along with its respective counter, printing a line per op?
>>>
>>> We already have that in /proc/self/mountstats
>>>
>>>
>>
>> You mean /proc/self/status?
> 
> No.

So can you please explain what you meant by the /proc/self/mountstats
example?

This is what I see:

$ head -3 /proc/self/mountstats
device rootfs mounted on / with fstype rootfs
device /proc mounted on /proc with fstype proc
device /sys mounted on /sys with fstype sysfs

Benny

