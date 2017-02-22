Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60060 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932360AbdBVOK4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 22 Feb 2017 09:10:56 -0500
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Jeff Layton" <jlayton@redhat.com>
Cc: "Trond Myklebust" <trond.myklebust@primarydata.com>,
        "Anna Schumaker" <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/4] NFS: Always send an unlock for FL_CLOSE
Date: Wed, 22 Feb 2017 09:10:54 -0500
Message-ID: <09B7C044-3622-4898-BEED-0B516BB54FE2@redhat.com>
In-Reply-To: <1487769602.2886.15.camel@redhat.com>
References: <cover.1487691345.git.bcodding@redhat.com>
 <72fa3f2a37146d153722d842e9b0d166fe11f1ad.1487691345.git.bcodding@redhat.com>
 <1487769602.2886.15.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 22 Feb 2017, at 8:20, Jeff Layton wrote:

> On Tue, 2017-02-21 at 10:39 -0500, Benjamin Coddington wrote:
>> NFS attempts to wait for read and write completion before unlocking 
>> in
>> order to ensure that the data returned was protected by the lock.  
>> When
>> this waiting is interrupted by a signal, the unlock may be skipped, 
>> and
>> messages similar to the following are seen in the kernel ring buffer:
>>
>> [20.167876] Leaked locks on dev=0x0:0x2b ino=0x8dd4c3:
>> [20.168286] POSIX: fl_owner=ffff880078b06940 fl_flags=0x1 fl_type=0x0 
>> fl_pid=20183
>> [20.168727] POSIX: fl_owner=ffff880078b06680 fl_flags=0x1 fl_type=0x0 
>> fl_pid=20185
>>
>> For NFSv3, the missing unlock will cause the server to refuse 
>> conflicting
>> locks indefinitely.  For NFSv4, the leftover lock will be removed by 
>> the
>> server after the lease timeout.
>>
>> This patch fixes this issue by skipping the wait in order to 
>> immediately send
>> the unlock if the FL_CLOSE flag is set when signaled.
>>
>> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
>> ---
>>  fs/nfs/file.c | 10 +++++-----
>>  1 file changed, 5 insertions(+), 5 deletions(-)
>>
>> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
>> index a490f45df4db..df695f52bb9d 100644
>> --- a/fs/nfs/file.c
>> +++ b/fs/nfs/file.c
>> @@ -697,14 +697,14 @@ do_unlk(struct file *filp, int cmd, struct 
>> file_lock *fl, int is_local)
>>  	if (!IS_ERR(l_ctx)) {
>>  		status = nfs_iocounter_wait(l_ctx);
>>  		nfs_put_lock_context(l_ctx);
>> -		if (status < 0)
>> +		/*  NOTE: special case
>> +		 * 	If we're signalled while cleaning up locks on process exit, we
>> +		 * 	still need to complete the unlock.
>> +		 */
>> +		if (status < 0 && !(fl->fl_flags & FL_CLOSE))
>>  			return status;
>
>
> Hmm, I don't know if this is safe...
>
> Suppose we have a bunch of buffered writeback going on, and we're
> sitting here waiting for it so we can do the unlock. The task catches 
> a
> signal, and then issues the unlock while writeback is still going on.
> Another client then grabs the lock, and starts doing reads and writes
> while this one is still writing back.
>
> I think the unlock really needs to wait until writeback is done,
> regardless of whether you catch a signal or not.

The only other way to do this is as you've sugggested many times -- by
putting the LOCKU on a rpc_wait_queue.  But that won't work for NFSv3.

For NFSv4, the other thing to do might be to look up the lock state and 
set
NFS_LOCK_LOST, then unlock.  That will cause subsequent writes to not
attempt recovery.

How can this be fixed for NFSv3 without voilating the NLM layers?

Ben
