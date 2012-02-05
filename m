Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:46852 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754762Ab2BELEN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 5 Feb 2012 06:04:13 -0500
Message-ID: <4F2E620F.5090100@panasas.com>
Date: Sun, 5 Feb 2012 13:03:43 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Check for beginning '/' in the mount path
References: <1328233332-26020-1-git-send-email-malahal@us.ibm.com> <4F2BC1C0.8070900@panasas.com> <20120203231623.442fefde@notabene.brown> <20120203142945.GA31805@us.ibm.com>
In-Reply-To: <20120203142945.GA31805@us.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/03/2012 04:29 PM, Malahal Naineni wrote:
> NeilBrown [neilb@suse.de] wrote:
>> On Fri, 3 Feb 2012 13:15:12 +0200 Boaz Harrosh <bharrosh@panasas.com> wrote:
>>
>>> On 02/03/2012 03:42 AM, Malahal Naineni wrote:
>>>> NFSv4 gladly accepts and mounts "hostname:path" instead of
>>>> "hostname:/path". This causes mount entry mistmatch between /etc/mtab
>>>> and /proc/mounts files. The former will have "hostname:path" but the
>>>> latter will have "hostname:/path". This causes umount not work at all.
>>>>
>>>
>>> NACK
>>>
>>> like it or not you are changing ABI. Bunch of systems will not work now.
>>>
>>> Also some other NFS servers/clients support it fine. Actually some servers
>>> make it a special case. (It's called mount by tag)
>>>
>>> The bug is else where fix it there. Either add the preceding '/' to
>>> /etc/mtab or remove it from /proc/mounts (I prefer the later). Or
>>                                             ^^^^^^^^^^^^^^^^^^
>>> fix umount to work with that case.
>>
>> Agreed.  And while we are at it we should remove the trailing '/' too.
>> If you
>>   mount host:/path /somewhere
>> /proc/mounts will show
>>     host:/path/
>>
>> which also confused mount.
> 
> Thank you Neil and Boaz. Since there is already a fix in umount to take
> care of trailing slash, I will post a patch to take care of leading
> slash.
> 
> Any reason(s) why trailing slash is fixed in umount rather than in
> /proc/mounts?
> 

Thank you Malahal.

I think that both fixes to umount are important for future/backward compatibility
with Kernel, And general code resilience. 

But some kind sole should fix both breakages in /proc/mounts, for sure.
Would you know how to fix it?

> Thanks, Malahal.
> 

Thanks
Boaz
