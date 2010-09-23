Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:39528 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755813Ab0IWRyl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Sep 2010 13:54:41 -0400
Message-ID: <4C9B945C.90709@suse.de>
Date: Thu, 23 Sep 2010 23:24:36 +0530
From: Suresh Jayaraman <sjayaraman@suse.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] nfs: introduce mount option '-olocal_lock' to make locks
 local (try++)
References: <4C97416F.7020504@suse.de>	 <1285171602.4811.54.camel@heimdal.trondhjem.org> <4C9AFD56.4090603@suse.de>	 <1285246614.7809.0.camel@heimdal.trondhjem.org> <1285256610.7809.20.camel@heimdal.trondhjem.org>
In-Reply-To: <1285256610.7809.20.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 09/23/2010 09:13 PM, Trond Myklebust wrote:
> On Thu, 2010-09-23 at 08:56 -0400, Trond Myklebust wrote:
>> On Thu, 2010-09-23 at 12:40 +0530, Suresh Jayaraman wrote:
>>> On 09/22/2010 09:36 PM, Trond Myklebust wrote:
>>>> On Mon, 2010-09-20 at 16:41 +0530, Suresh Jayaraman wrote:
>>>>> Changes since last post:
>>>>>
>>>>>    - NFS_MOUNT_NONLM definition remains unmodified as legacy binary mount
>>>>>      interface uses it
>>>>>    - Fixed an Oops in _nfs4_do_setlk() found during NFSv4 reboot recovery
>>>>>    - Rebased against Trond's nfs-2.6.git (nfs-for-2.6.37 branch)
>>>>>
>>>>> Thanks,
>>>>> Suresh Jayaraman
>>>>>
>>>>
>>>> Suresh,
>>>>
>>>> This still appears to break the binary mount interface. You need
>>>> something in nfs_validate_mount_data() to convert the NFS_MOUNT_NONLM
>>>> flag into (NFS_MOUNT_LOCAL_FLOCK | NFS_MOUNT_LOCAL_FCNTL).
>>>>
>>>
>>> Good catch, thanks. Here's the fixed version (haven't tested it as I don't
>>> find a simple way to test it and it looks obvious):
>>
>> Hi Suresh,
>>
>> This one looks good to me.
>>
>> Thanks!
>>   Trond
> 
> Hmm... One thing to note: it would be nice to display the 'local_lock'
> status in /proc/mounts. That can be applied as a separate patch, though.
> 

Sounds good. I sent a separate patch for doing that.

The man page needs to be updated too. I'll write the nfs-utils patch for
doing it and send it.


Thanks,

-- 
Suresh Jayaraman
