Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:24863 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753539AbaA0SDg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Jan 2014 13:03:36 -0500
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: linuxnfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] NFSv4.1 Do not preallocate session slots in
 nfs4_end_drain_slot_tbl
Date: Mon, 27 Jan 2014 18:03:35 +0000
Message-ID: <3D1477D3-5EA4-4166-B21C-37F801D22C9E@netapp.com>
References: <1390843555-3498-1-git-send-email-andros@netapp.com>
 <6EB54911-838A-4E42-AA4B-B276DD52F439@primarydata.com>
In-Reply-To: <6EB54911-838A-4E42-AA4B-B276DD52F439@primarydata.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 27, 2014, at 12:40 PM, Trond Myklebust <trond.myklebust@primarydata.com>
 wrote:

> 
> On Jan 27, 2014, at 12:25, andros@netapp.com wrote:
> 
>> From: Andy Adamson <andros@netapp.com>
>> 
>> Pre-allocating session slots for RPC tasks waking up from a wait queue provides
>> a shorter slot allocation code path and can help performance.
>> 
>> Durring multiple server reboots (interface moves), the pre-allocated
>> slot can be held and not freed as a task is transferred to various slot table
>> wait queues and the state manager is draining these queues.  Not freeing the
>> slots results in a  state manager hang waiting for completion on the slot
>> table draining.  In this case, performance is not a consideration as the
>> client is in recovery of a session or a clientid.
>> 
> 
> I’m not understanding this reasoning. If the slot table is drained, then the slots must be returned to the session manager by all outstanding RPC calls so that the state manager thread can go about its business. By what mechanism are these slots being held and not freed here?

AFAICS this is the scenario.

The slot table is being drained multiple times, once for each interface move.  The first time draining "ends" with pre-allocated slot tasks placed on the forechannel slot table waitq - not yet run. Then the second draining occurs prior to them being run, and the state manager sets the draining flag again, and then "waits for completion" e.g. waits for nfs4_free_slot to call nfs4_slot_table_drain_complete. The tasks with the pre-allocated slots that are left on the slot table waitq, still haven't run and can't until the draining flag is unset,  nfs4_free_slot has not been called on their allocated slots and the state manager hangs.

> 
>> Prevent this state manager hang by not pre-allocating session slots, but
>> just wake up the tasks and let them grab a sessions slot in the
>> nfs4_alloc_slot call in nfs41-setup_sequence.
> 
> If the slots are already held, then how does this help?


The slots are pre-allocated in the nfs4_wake_slot_table call in the first draining, which sets them up to be orphaned if a second draing occurs with the right timing.

The call to rpc_wake_up fixes  the hang as it move the allocation of the slots to the time when the tasks are actually ready to run - they can hang out on a waitq without preventing a draining completion call.

-->Andy 
> 
> --
> Trond Myklebust
> Linux NFS client maintainer
> 

