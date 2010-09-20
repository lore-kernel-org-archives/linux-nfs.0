Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:46552 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753322Ab0ITSkW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Sep 2010 14:40:22 -0400
Message-ID: <4C97AAA6.30501@panasas.com>
Date: Mon, 20 Sep 2010 20:40:38 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Boaz Harrosh <bharrosh@panasas.com>
CC: Fred Isaman <iisaman@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 11/12] RFC: pnfs: add LAYOUTGET and GETDEVICEINFO infrastructure
References: <1284779874-10499-1-git-send-email-iisaman@netapp.com>	<1284779874-10499-12-git-send-email-iisaman@netapp.com>	<4C965F66.7000200@panasas.com> <AANLkTinFLgys9T-JX-fU_y5KUzHiW2QBscm9EpS7D+19@mail.gmail.com> <4C9789BF.4090303@panasas.com>
In-Reply-To: <4C9789BF.4090303@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-09-20 18:20, Boaz Harrosh wrote:
> On 09/20/2010 04:56 PM, Fred Isaman wrote:
>> On Sun, Sep 19, 2010 at 3:07 PM, Boaz Harrosh <bharrosh@panasas.com> wrote:
>>> On 09/18/2010 05:17 AM, Fred Isaman wrote:
>>
>> I agree.  The original deviceid code had an issue where nothing was
>> ever deallocated until shutdown.  The code as given here ties the
>> deviceid lifetime to existing references.  This is not ideal, because
>> a brief loss of reference to a deviceid will cause an unnecessary
>> GETDEVICEINFO.  However, for the current submission, it has the
>> advantage that it is simple and correct.  Adding the machinery to do
>> as you suggest above is indeed a (fairly high) priority goal, but was
>> intentionally deferred.
>>
> 
> I would like to please return it. That is deallocate it only at shut down.
> Otherwise we are for a lot of trouble. We are not yet in a situation of
> 1000nd of devices where it might matter. Even up to 100rd it is still fine
> to never de-allocate. (Currently on the planet Panasas is the only one with
> 1000nd of devices in a single installation)
> 
> Look at it this way. Before we mounted all the NFS servers in our domain
> prior to usage, and/or as part of auto-mount which never got unmounted
> until shotdown/unmount. So we do the same with pNFS only we have the
> privilege of doing a single mount and have everything dynamically logged
> in for us. So we are just as before.
> 
> For all pNFS filesystems today the first IOs will GETDEVICEINFO for the
> 10s of devices deploid and keep them allocated. If we free them then
> what will happen if we need to GETDEVICEINFO when all memory is dirty
> and we need it for cleaning that dirty memory. We don't have any
> forward progress provision for that yet.

Devices are no different than layouts for this matter.
To flush your cache under low memory conditions using pnfs you'll need
both a layout and the corresponding devices. So why do you want to
keep the devices forever but not the layouts?

> 
> The simple thing to do is keep them allocated for ever (until unmount)
> by adding a single did_get() call in the did_add() function.
> (And did_put() in cache deallocation). That's more simple then hardening
> the code.
> 
> And If we don't the pNFS performance will suck big time specially for
> that humongous files-layout get_device_info. Because it will be done
> for every get_layout. A regular bash script opens a file then closes it.
> Most of the time we are not parallel as we think.
> 

I'd like to see the actual numbers for a given benchmark.
Keep in mind that typically for the files layout the server won't
ask for return_on_close so the layout will actually be kept around
(and the associated devices) while the inode is resident, right?

>>>
>>> So in effect if [optional] code above is not yet implemented then a
>>> getdeviceinfo is never preformed twice for the same deviceid
>>> (Assuming no device recall). This is what I had in osd, and is cardinal
>>> for it's performance. Is that what we are aiming at?
>>
>> Yes, that is the goal.  Right now, if a layout is still around that
>> references a deviceid, a second GETDEVICEINFO will not be sent.
>> However, if all layouts referencing a specific deviceid have been
>> returned, then yes, a second GETDEVICEINFO will be called.
>>
> 
> Then sure when we come to the situation that we need proper support
> for more then 100 machines in a cluster, then we can add the clean
> on add stage where if we are higher then x devices we start to replace
> entries.
> 
> What you guys think?

It's hard to tell without the actual numbers.

Keeping a reference count on the device from the layout makes sure
you'll have the devices to use the layout and that you don't issue
multiple GETDEVICEINFOs in case a device is shared between more than
one layout.

Ideally, a laundromat service could clean up unused client state once
in a while so to keep it around for a short while so it can be reused
if possible.

Benny

> 
> Boaz
> 
