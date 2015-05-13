Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34771 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754611AbbEMMaN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 May 2015 08:30:13 -0400
Message-ID: <555343CA.6010307@gmail.com>
Date: Wed, 13 May 2015 20:30:02 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: "J. Bruce Fields" <bfields@fieldses.org>, linux-fsdevel@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
Subject: Re: [PATCH 4/4] nfsd: Pin to vfsmnt instead of mntget
References: <554A149B.5060102@gmail.com>	<554A154B.6040103@gmail.com>	<20150508144031.6f0d3cda@notabene.brown>	<20150508134744.GA23753@fieldses.org>	<5550A9DF.1070908@gmail.com> <20150513142515.6bd881c8@notabene.brown>
In-Reply-To: <20150513142515.6bd881c8@notabene.brown>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 5/13/2015 12:25 PM, NeilBrown wrote:
> On Mon, 11 May 2015 21:08:47 +0800 Kinglong Mee <kinglongmee@gmail.com> wrote:
> 
>> On 5/8/2015 9:47 PM, J. Bruce Fields wrote:
>>> On Fri, May 08, 2015 at 02:40:31PM +1000, NeilBrown wrote:
>>>> Thanks for this patch.  It looks good!
>>>>
>>>> My only comment on the code is that I would really like to see a
>>>> "path_get_pin()" and "path_put_unpin()" rather than open coding:
>>>>
>>>>> +	dget(item->ek_path.dentry);
>>>>> +	pin_insert_group(&new->ek_pin, item->ek_path.mnt, NULL);
>>>>
>>>> and 
>>>>
>>>>> +		dput(key->ek_path.dentry);
>>>>> +		pin_remove(&key->ek_pin);
>>>>
>>>>
>>>> But the question you raise is an important one:  Exactly which filesystems
>>>> should be allowed to be unmounted?
>>>> This is a change in behaviour - is it one that people uniformly would want?
>>>>
>>>> The kernel doesn't currently know which file systems were explicitly listed
>>>> in /etc/exports, and which were found by following a 'crossmnt'.
>>>> It could guess and allow the unmounting of anything below a 'crossmnt', but I
>>>> wouldn't be comfortable with that - it is error prone.
>>>>
>>>> mountd does know what is in /etc/exports, and could tell the kernel.
>>>> For the expkey cache, we could always use path_get_pin.
>>>> For the export cache (where flags are available) we could use path_get
>>>> or path_get_pin depending on some new flag.
>>>>
>>>> I'm not really sure it is worth it.  I would rather the filesystems could
>>>> always be unmounted.  But doing that could possibly break someone's work
>>>> flow.  Maybe.
>>>>
>>>> Or maybe I'm seeing problems where there aren't any.
>>>>
>>>> Anyone else have an opinion?
>>>
>>> The undisputed bug here was negative cache entries preventing unmount.
>>> So most conservative might be just to purge negative entries.
>>
>> I'd like this,
>> if the cache is valid, user should not be allowed to umount the filesystem.
>>
>>>
>>> Otherwise, the only guarantees I think we've really had is that we won't
>>> allow unmount if you hold any actual state on the filesystem (NLM locks,
>>> NFSv4 locks, opens, or delegations).
>>
>> Those resources hold the reference of vfsmnt.
>>
>>>
>>> If a filesystem is exported but no clients hold state on it, then it's
>>> currently mostly chance whether the unmount succeeds or not.  So we're
>>> probably free to change the behavior in this case.  I'd be inclined to
>>> allow the unmount, but haven't thought this through carefully.
>>
>> If client mount a nfsserver succeed without holds state, 
>> nfs server umounts the exported filesystem, 
>> client also think the filesystem is valid, but it is umounted.
> 
> This is no different from "exportfs -au" being run on the server, thus
> unexporting the filesystem and making in unavailable to the client, even
> though the client has it mounted.

No, I don't think so.
If user using "exportfs -au" to flush caches, I think he known
what the influence of he does, but an umount of filesystem, 
maybe he doesn't known that contains flushing nfsd's exports cache.

For an using of nfsd exports, I'd like an error of an umount,
because I don't realize the exports for nfsd.

I also think nfsd should allowing umount of unexported filesystem,
because user has the right to umount it.

> 
> I think we need to give the server admin control of their filesystems, and
> assume they won't do something that they don't really want to do.
> 
>>>
>>> It could also be useful to have the ability to force an unmount even in
>>> the presence of locks.  That's not a safe default, but an
>>> "allow_force_unmount" export option might be useful.
> 
> We already have a mechanism to forcibly drop any locks by writing some magic
> to /proc/fs/nfsd/unlock_{ip,filesystem}.  I don't think we need any more.

No, I don't agree.
If there are locks (eg, LOCKs/DELEGATIONs/LAYOUTs) exist, nfsd should not allows
user umounting of the filesystem, maybe client is process those files.
We shouldn't clean those information for they are controlled by expire time.

thanks,
Kinglong Mee
