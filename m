Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51644 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932687AbdBVRjG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 22 Feb 2017 12:39:06 -0500
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Trond Myklebust" <trondmy@primarydata.com>
Cc: "jlayton@redhat.com" <jlayton@redhat.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 4/4] NFS: Always send an unlock for FL_CLOSE
Date: Wed, 22 Feb 2017 12:39:03 -0500
Message-ID: <3D0E5D1B-CB46-40B3-AE36-2D7D7B4B9AD1@redhat.com>
In-Reply-To: <1487780839.4863.4.camel@primarydata.com>
References: <cover.1487691345.git.bcodding@redhat.com>
 <72fa3f2a37146d153722d842e9b0d166fe11f1ad.1487691345.git.bcodding@redhat.com>
 <1487769602.2886.15.camel@redhat.com>
 <09B7C044-3622-4898-BEED-0B516BB54FE2@redhat.com>
 <1487778136.5497.1.camel@redhat.com>
 <1487780839.4863.4.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 22 Feb 2017, at 11:27, Trond Myklebust wrote:

> On Wed, 2017-02-22 at 10:42 -0500, Jeff Layton wrote:
>> On Wed, 2017-02-22 at 09:10 -0500, Benjamin Coddington wrote:
>>> On 22 Feb 2017, at 8:20, Jeff Layton wrote:
>>>
>>>> On Tue, 2017-02-21 at 10:39 -0500, Benjamin Coddington wrote:
>>>>> NFS attempts to wait for read and write completion before
>>>>> unlocking 
>>>>> in
>>>>> order to ensure that the data returned was protected by the
>>>>> lock.  
>>>>> When
>>>>> this waiting is interrupted by a signal, the unlock may be
>>>>> skipped, 
>>>>> and
>>>>> messages similar to the following are seen in the kernel ring
>>>>> buffer:
>>>>>
>>>>> [20.167876] Leaked locks on dev=0x0:0x2b ino=0x8dd4c3:
>>>>> [20.168286] POSIX: fl_owner=ffff880078b06940 fl_flags=0x1
>>>>> fl_type=0x0 
>>>>> fl_pid=20183
>>>>> [20.168727] POSIX: fl_owner=ffff880078b06680 fl_flags=0x1
>>>>> fl_type=0x0 
>>>>> fl_pid=20185
>>>>>
>>>>> For NFSv3, the missing unlock will cause the server to refuse 
>>>>> conflicting
>>>>> locks indefinitely.  For NFSv4, the leftover lock will be
>>>>> removed by 
>>>>> the
>>>>> server after the lease timeout.
>>>>>
>>>>> This patch fixes this issue by skipping the wait in order to 
>>>>> immediately send
>>>>> the unlock if the FL_CLOSE flag is set when signaled.
>>>>>
>>>>> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
>>>>> ---
>>>>>  fs/nfs/file.c | 10 +++++-----
>>>>>  1 file changed, 5 insertions(+), 5 deletions(-)
>>>>>
>>>>> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
>>>>> index a490f45df4db..df695f52bb9d 100644
>>>>> --- a/fs/nfs/file.c
>>>>> +++ b/fs/nfs/file.c
>>>>> @@ -697,14 +697,14 @@ do_unlk(struct file *filp, int cmd,
>>>>> struct 
>>>>> file_lock *fl, int is_local)
>>>>>  	if (!IS_ERR(l_ctx)) {
>>>>>  		status = nfs_iocounter_wait(l_ctx);
>>>>>  		nfs_put_lock_context(l_ctx);
>>>>> -		if (status < 0)
>>>>> +		/*  NOTE: special case
>>>>> +		 * 	If we're signalled while cleaning
>>>>> up locks on process exit, we
>>>>> +		 * 	still need to complete the unlock.
>>>>> +		 */
>>>>> +		if (status < 0 && !(fl->fl_flags & FL_CLOSE))
>>>>>  			return status;
>>>>
>>>>
>>>> Hmm, I don't know if this is safe...
>>>>
>>>> Suppose we have a bunch of buffered writeback going on, and we're
>>>> sitting here waiting for it so we can do the unlock. The task catches 
>>>> a signal, and then issues the unlock while writeback is still going on.
>>>> Another client then grabs the lock, and starts doing reads and writes
>>>> while this one is still writing back.
>>>>
>>>> I think the unlock really needs to wait until writeback is done,
>>>> regardless of whether you catch a signal or not.
>>>
>>> The only other way to do this is as you've sugggested many times -- by
>>> putting the LOCKU on a rpc_wait_queue.  But that won't work for NFSv3.
>>>
>>
>> IDGI -- why doesn't that (or something similar) not work for v3?

Because of the layering, as discussed further on.

>>> For NFSv4, the other thing to do might be to look up the lock state and 
>>> set NFS_LOCK_LOST, then unlock.  That will cause subsequent writes to
>>> not attempt recovery.
>>>
>>
>> No! LOCK_LOST is really for the case where we've lost contact with the
>> server. We don't want to get kicked into recovery just because of a
>> SIGKILL.

True, it was added for the case where contact is lost, but it does exactly
what we'd want.

If we're coming through do_unlk() with FL_CLOSE, then we've just done a
vfs_fsync() and I believe that all dirty data are now in requests queued up
and being transmitted.  The signal has had us bail out of the wait for those
pages to writeback, and I don't think new pages can be dirtied under this
lock.  So, an unlock at this point will at worst cause some of that I/O to
fail with BAD_STATEID (or OLD_STATEID?).  What we want to prevent then is
the client retrying those writes under another stateid, which is what
NFS_LOCK_LOST does.

> I suggest we add a new lock state: NFS_LOCK_UNLOCKED to allow the client
> to recognise that the failed operation should not be retried.
>
> In fact, we might want to have nfs4_set_rw_stateid() scan for that, and
> return an error that could be made to fail the operation.  Furthermore,
> maybe __nfs4_find_lock_state() should also ignore lock structures in this
> state so that once the lock is in this state, we always ignore new
> attempts.  This could also be made to work with pNFS; although for most
> layout types, the locking will not be enforced by the server, we can at
> least prevent new I/O requests from being generated after the
> NFS_LOCK_UNLOCKED state has been declared.
>
> You can't do any of the above with NFSv3, since the locking is decoupled
> from the actual I/O. Is anyone actually using NLM for mission critical
> applications that need this kind of protection? (followup question: is
> there a good reason why they are doing so instead of using NFSv4?)

Yes, people are using it.  And I don't think those people care much about
whether or not their I/O completes under the lock after a signal.  They care
that when their job on a cluster gets hung up and their scheduler kills it,
they can't submit the job again anywhere else on the cluster because the
server thinks the job's file is locked.  The only fix is to restart the
server, which is very disruptive.

So, I'm happy to work on a NFS_LOCK_UNLOCKED approach for v4 and I'd also be
happy to just leave v3 to always unlock.

Ben
