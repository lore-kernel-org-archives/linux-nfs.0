From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 02/12] SQUASHME: Bug in new global-device-cache code
Date: Tue, 24 May 2011 20:02:44 +0300
Message-ID: <4DDBE4B4.4050906@panasas.com>
References: <4DDBC611.3050202@panasas.com> <1306249480-23212-1-git-send-email-bharrosh@panasas.com> <4DDBE265.7000101@panasas.com> <4DDBE43E.60104@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:54669 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753774Ab1EXRCs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 May 2011 13:02:48 -0400
In-Reply-To: <4DDBE43E.60104@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-05-24 20:00, Boaz Harrosh wrote:
> On 05/24/2011 07:52 PM, Benny Halevy wrote:
>> On 2011-05-24 18:04, Boaz Harrosh wrote:
>>> NULL deref on first ever call. (When device is not found)
>>>
>>> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
>>> ---
>>>  fs/nfs/pnfs_dev.c |    2 +-
>>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>>
>>> diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
>>> index 7997899..7e5542c 100644
>>> --- a/fs/nfs/pnfs_dev.c
>>> +++ b/fs/nfs/pnfs_dev.c
>>> @@ -100,7 +100,7 @@ _find_get_deviceid(const struct pnfs_layoutdriver_type *ld,
>>>  
>>>  	rcu_read_lock();
>>>  	d = _lookup_deviceid(ld, clp, id, hash);
>>> -	if (!atomic_inc_not_zero(&d->ref))
>>> +	if (!d || !atomic_inc_not_zero(&d->ref))
>>
>> This makes more sense, no?
>> +	if (d && !atomic_inc_not_zero(&d->ref))
>>
>> Benny
>>
>>>  		d = NULL;
> 
> Sure, since then d is already set to NULL, I guess
> 

Right.

>>>  	rcu_read_unlock();
>>>  	return d;
>>
> 
> Boaz

