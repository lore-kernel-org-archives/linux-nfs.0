Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51936 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755571AbdDGNeu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Apr 2017 09:34:50 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Jeff Layton" <jlayton@poochiereds.net>
Cc: "Trond Myklebust" <trond.myklebust@primarydata.com>,
        "Anna Schumaker" <anna.schumaker@netapp.com>, bfields@fieldses.org,
        "Miklos Szeredi" <miklos@szeredi.hu>,
        "Alexander Viro" <viro@zeniv.linux.org.uk>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 6/6] NFS: Always wait for I/O completion before unlock
Date: Fri, 07 Apr 2017 09:34:47 -0400
Message-ID: <9AC811D0-1017-4C27-84A0-0A074571E40A@redhat.com>
In-Reply-To: <1491567742.2745.10.camel@poochiereds.net>
References: <cover.1491477181.git.bcodding@redhat.com>
 <0351835c423970c9171e446e918ac3d3d2fe854e.1491477181.git.bcodding@redhat.com>
 <1491567742.2745.10.camel@poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 7 Apr 2017, at 8:22, Jeff Layton wrote:

> On Thu, 2017-04-06 at 07:23 -0400, Benjamin Coddington wrote:
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
>> This patch fixes this issue by skipping the usual wait in
>> nfs_iocounter_wait if the FL_CLOSE flag is set when signaled.  
>> Instead, the
>> wait happens in the unlock RPC task on the NFS UOC rpc_waitqueue.
>>
>> For NFSv3, use lockd's new nlmclnt_operations along with
>> nfs_async_iocounter_wait to defer NLM's unlock task until the lock
>> context's iocounter reaches zero.
>>
>> For NFSv4, call nfs_async_iocounter_wait() directly from unlock's
>> current rpc_call_prepare.
>>
>
> Dare I ask about v2? :)
>
> Hmm actually, it looks like v2 could use the same operations as v3. I
> don't see anything protocol-specific there.
>
>> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
>> ---
>>  fs/nfs/file.c     | 10 +++++-----
>>  fs/nfs/nfs3proc.c | 38 +++++++++++++++++++++++++++++++++++++-
>>  fs/nfs/nfs4proc.c | 10 +++++++---
>>  3 files changed, 49 insertions(+), 9 deletions(-)
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
>>  	}
>>
>> -	/* NOTE: special case
>> -	 * 	If we're signalled while cleaning up locks on process exit, we
>> -	 * 	still need to complete the unlock.
>> -	 */
>>  	/*
>>  	 * Use local locking if mounted with "-onolock" or with appropriate
>>  	 * "-olocal_lock="
>> diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
>> index 086623ab07b1..0e21306bfed9 100644
>> --- a/fs/nfs/nfs3proc.c
>> +++ b/fs/nfs/nfs3proc.c
>> @@ -865,12 +865,48 @@ static void nfs3_proc_commit_setup(struct 
>> nfs_commit_data *data, struct rpc_mess
>>  	msg->rpc_proc = &nfs3_procedures[NFS3PROC_COMMIT];
>>  }
>>
>> +void nfs3_nlm_alloc_call(void *data)
>> +{
>> +	struct nfs_lock_context *l_ctx = data;
>> +	nfs_get_lock_context(l_ctx->open_context);
>> +}
>> +
>> +void nfs3_nlm_release_call(void *data)
>> +{
>> +	struct nfs_lock_context *l_ctx = data;
>> +	nfs_put_lock_context(l_ctx);
>> +}
>> +
>> +const struct nlmclnt_operations nlmclnt_fl_close_lock_ops = {
>> +	.nlmclnt_alloc_call = nfs3_nlm_alloc_call,
>> +	.nlmclnt_unlock_prepare = nfs_async_iocounter_wait,
>> +	.nlmclnt_release_call = nfs3_nlm_release_call,
>> +};
>> +
>>  static int
>>  nfs3_proc_lock(struct file *filp, int cmd, struct file_lock *fl)
>>  {
>>  	struct inode *inode = file_inode(filp);
>> +	struct nfs_lock_context *l_ctx = NULL;
>> +	const struct nlmclnt_operations *nlmclnt_ops = NULL;
>> +	int status;
>>
>> -	return nlmclnt_proc(NFS_SERVER(inode)->nlm_host, cmd, fl, NULL, 
>> NULL);
>> +	if (fl->fl_flags & FL_CLOSE) {
>> +		l_ctx = nfs_get_lock_context(nfs_file_open_context(filp));
>> +		if (IS_ERR(l_ctx)) {
>> +			l_ctx = NULL;
>> +		} else {
>> +			set_bit(NFS_CONTEXT_UNLOCK, &l_ctx->open_context->flags);
>> +			nlmclnt_ops = &nlmclnt_fl_close_lock_ops;
>
> FWIW, I'm not a huge fan of using the pointer to indicate whether to 
> run
> the operations or not. IMO, it'd be cleaner to:
>
> 1) store the pointer to the operations struct in the nlm_host, pass it 
> a
> pointer to it in the nlmclnt_initdata.
>
> 2) make the decision to do the operations or not based on the setting 
> of
> NFS_CONTEXT_UNLOCK in the callbacks themselves. If it's not set, just
> return quickly without doing anything.

Yes, I can see how that could be a bit neater.  And I can add in the 
same
behavior for v2 while making this change.

I'll work it up that way and send it again.

Ben
