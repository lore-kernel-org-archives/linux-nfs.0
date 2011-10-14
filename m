Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:39318 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932472Ab1JNXAz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Oct 2011 19:00:55 -0400
Message-ID: <4E98BD9F.2090503@panasas.com>
Date: Sat, 15 Oct 2011 00:54:23 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Michal Marek <mmarek@suse.cz>
CC: Paul Bolle <pebolle@tiscali.nl>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: Problems with Kconfig select across directories
References: <4E9848C1.8040306@panasas.com> <4E98B19B.6020107@suse.cz> <4E98B751.5070006@panasas.com> <4E98BB9B.2080203@suse.cz>
In-Reply-To: <4E98BB9B.2080203@suse.cz>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/15/2011 12:45 AM, Michal Marek wrote:
> On 15.10.2011 00:27, Boaz Harrosh wrote:
>> On 10/15/2011 12:03 AM, Michal Marek wrote:
>>> On 14.10.2011 16:35, Boaz Harrosh wrote:
>>>> This does not work. The ORE is not compiled and MODPOST complains.
>>>> (Given EXOFS_FS is not selected since then it will work)
>>>
>>> fs/Makefile only visits fs/exofs if CONFIG_EXOFS_FS is set.
>>
>> Bingo. Right on the money. With below patch it works. I'll think
>> about it some more and submit.
>>
>> Thanks
>> ---
>> exofs/ore: Select fs/exofs/ folder in Makefile also for ORE only compilation
>>
>> If any thing from fs/exofs is set the ORE will be selected. So conditionally
>> include fs/exofs in fs/Makefile on ORE set and not EXOFS_FS
> ...
>> --- a/fs/Makefile
>> +++ b/fs/Makefile
>> @@ -120,6 +120,6 @@ obj-$(CONFIG_DEBUG_FS)		+= debugfs/
>>  obj-$(CONFIG_OCFS2_FS)		+= ocfs2/
>>  obj-$(CONFIG_BTRFS_FS)		+= btrfs/
>>  obj-$(CONFIG_GFS2_FS)           += gfs2/
>> -obj-$(CONFIG_EXOFS_FS)          += exofs/
>> +obj-$(CONFIG_ORE)		+= exofs/
> 
> Note that changing it to obj-y is also valid. And perhaps more obvious.
> 
> Michal

Thanks. You read my thoughts. The naming would be off with my change.
I'll take your advise and send a patch to Al on Monday.

Cheers
Boaz
