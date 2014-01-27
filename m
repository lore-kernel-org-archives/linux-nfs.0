Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f180.google.com ([209.85.223.180]:60967 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753651AbaA0SjX convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Jan 2014 13:39:23 -0500
Received: by mail-ie0-f180.google.com with SMTP id at1so6301595iec.39
        for <linux-nfs@vger.kernel.org>; Mon, 27 Jan 2014 10:39:23 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [PATCH 1/1] NFSv4.1 Do not preallocate session slots in nfs4_end_drain_slot_tbl
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <3D1477D3-5EA4-4166-B21C-37F801D22C9E@netapp.com>
Date: Mon, 27 Jan 2014 13:39:20 -0500
Cc: linuxnfs <linux-nfs@vger.kernel.org>
Message-Id: <8D1EE956-DC7A-4929-8B15-DE7C6A4515EA@primarydata.com>
References: <1390843555-3498-1-git-send-email-andros@netapp.com> <6EB54911-838A-4E42-AA4B-B276DD52F439@primarydata.com> <3D1477D3-5EA4-4166-B21C-37F801D22C9E@netapp.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 27, 2014, at 13:03, Adamson, Andy <William.Adamson@netapp.com> wrote:

> 
> On Jan 27, 2014, at 12:40 PM, Trond Myklebust <trond.myklebust@primarydata.com>
> wrote:
> 
>> 
>> On Jan 27, 2014, at 12:25, andros@netapp.com wrote:
>> 
>>> From: Andy Adamson <andros@netapp.com>
>>> 
>>> Pre-allocating session slots for RPC tasks waking up from a wait queue provides
>>> a shorter slot allocation code path and can help performance.
>>> 
>>> Durring multiple server reboots (interface moves), the pre-allocated
>>> slot can be held and not freed as a task is transferred to various slot table
>>> wait queues and the state manager is draining these queues.  Not freeing the
>>> slots results in a  state manager hang waiting for completion on the slot
>>> table draining.  In this case, performance is not a consideration as the
>>> client is in recovery of a session or a clientid.
>>> 
>> 
>> I’m not understanding this reasoning. If the slot table is drained, then the slots must be returned to the session manager by all outstanding RPC calls so that the state manager thread can go about its business. By what mechanism are these slots being held and not freed here?
> 
> AFAICS this is the scenario.
> 
> The slot table is being drained multiple times, once for each interface move.  The first time draining "ends" with pre-allocated slot tasks placed on the forechannel slot table waitq - not yet run. Then the second draining occurs prior to them being run, and the state manager sets the draining flag again, and then "waits for completion" e.g. waits for nfs4_free_slot to call nfs4_slot_table_drain_complete. The tasks with the pre-allocated slots that are left on the slot table waitq, still haven't run and can't until the draining flag is unset,  nfs4_free_slot has not been called on their allocated slots and the state manager hangs.

That isn’t supposed to be possible, though. Nothing should be sleeping on slot_tbl_waitq while holding a slot, and any subsequent slot assignment is supposed to be done as part of the RPC task wake-up (see __nfs41_wake_and_assign_slot).

Question: is it possible for nfs41_setup_sequence() to be called while the rpc_task is still sleeping on slot_tbl_waitq? That could cause a race, since the test for res->sr_slot is done before we grab the slot_tbl_lock.

>> 
>>> Prevent this state manager hang by not pre-allocating session slots, but
>>> just wake up the tasks and let them grab a sessions slot in the
>>> nfs4_alloc_slot call in nfs41-setup_sequence.
>> 
>> If the slots are already held, then how does this help?
> 
> 
> The slots are pre-allocated in the nfs4_wake_slot_table call in the first draining, which sets them up to be orphaned if a second draing occurs with the right timing.
> 
> The call to rpc_wake_up fixes  the hang as it move the allocation of the slots to the time when the tasks are actually ready to run - they can hang out on a waitq without preventing a draining completion call.

See above: nothing is allowed to sleep on slot_tbl_waitq while holding a slot.

--
Trond Myklebust
Linux NFS client maintainer

