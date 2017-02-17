Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59738 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752588AbdBQTPY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 17 Feb 2017 14:15:24 -0500
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Trond Myklebust" <trondmy@primarydata.com>
Cc: "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 4/4] NFS: Always wait for I/O completion before unlock
Date: Fri, 17 Feb 2017 14:15:21 -0500
Message-ID: <46DADA84-BE1F-43A6-8196-2A097435829A@redhat.com>
In-Reply-To: <1487358041.11929.7.camel@primarydata.com>
References: <cover.1487356965.git.bcodding@redhat.com>
 <d81a853ea1ee4ba1294c85bbed7aa7298852b180.1487356965.git.bcodding@redhat.com>
 <1487358041.11929.7.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 17 Feb 2017, at 14:00, Trond Myklebust wrote:

> On Fri, 2017-02-17 at 13:46 -0500, Benjamin Coddington wrote:
>> NFS attempts to wait for read and write completion before unlocking
>> in
>> order to ensure that the data returned was protected by the
>> lock.  When
>> this waiting is interrupted by a signal, the unlock may never be
>> sent, and
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
>> locks indefinitely.  For NFSv4, the leftover lock will be removed by
>> the
>> server after the lease timeout.
>>
>> This patch fixes this for NFSv3 by skipping the wait in order to
>> immediately send the unlock if the FL_CLOSE flag is set when
>> signaled.  For
>> NFSv4, this approach may cause the server to see the I/O as arriving
>> with
>> an old stateid, so, for the v4 case the fix is different: the wait on
>> I/O
>> completion is moved into nfs4_locku_ops' rpc_call_prepare().  This
>> will
>> cause the sleep to happen in rpciod context, and a signal to the
>> originally
>> waiting process will not cause the unlock to be skipped.
>
> NACK. I/O waits in rpciod contexts are NOT acceptable. rpciod is part
> of the memory reclaim chain, so having it sleep on I/O is deadlock
> prone.
>
> Why is there a need to wait for I/O completion in the first place if
> the user has killed the task that held the lock? 'kill -9' will cause
> corruption; that's a fact that no amount of paper will cover over.

To avoid an unnecessary recovery situation where the server asks us to resend
I/O due to an invalid stateid.

I'm fine with skipping the wait on signaled FL_CLOSE if the that's an
acceptable trade-off.  I can send a v3.

Ben

>>
>> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
>> ---
>>  fs/nfs/file.c     | 13 -------------
>>  fs/nfs/nfs3proc.c | 13 +++++++++++++
>>  fs/nfs/nfs4proc.c |  7 +++++++
>>  fs/nfs/pagelist.c |  1 +
>>  4 files changed, 21 insertions(+), 13 deletions(-)
>>
>> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
>> index a490f45df4db..adc67fe762e3 100644
>> --- a/fs/nfs/file.c
>> +++ b/fs/nfs/file.c
>> @@ -684,7 +684,6 @@ static int
>>  do_unlk(struct file *filp, int cmd, struct file_lock *fl, int
>> is_local)
>>  {
>>  	struct inode *inode = filp->f_mapping->host;
>> -	struct nfs_lock_context *l_ctx;
>>  	int status;
>>  
>>  	/*
>> @@ -693,18 +692,6 @@ do_unlk(struct file *filp, int cmd, struct
>> file_lock *fl, int is_local)
>>  	 */
>>  	vfs_fsync(filp, 0);
>>  
>> -	l_ctx = nfs_get_lock_context(nfs_file_open_context(filp));
>> -	if (!IS_ERR(l_ctx)) {
>> -		status = nfs_iocounter_wait(l_ctx);
>> -		nfs_put_lock_context(l_ctx);
>> -		if (status < 0)
>> -			return status;
>> -	}
>> -
>> -	/* NOTE: special case
>> -	 * 	If we're signalled while cleaning up locks on
>> process exit, we
>> -	 * 	still need to complete the unlock.
>> -	 */
>>  	/*
>>  	 * Use local locking if mounted with "-onolock" or with
>> appropriate
>>  	 * "-olocal_lock="
>> diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
>> index dc925b531f32..ec3f12571c82 100644
>> --- a/fs/nfs/nfs3proc.c
>> +++ b/fs/nfs/nfs3proc.c
>> @@ -869,6 +869,19 @@ static int
>>  nfs3_proc_lock(struct file *filp, int cmd, struct file_lock *fl)
>>  {
>>  	struct inode *inode = file_inode(filp);
>> +	int status;
>> +	struct nfs_lock_context *l_ctx;
>> +
>> +	/* For v3, always send the unlock on FL_CLOSE */
>> +	if (fl->fl_type == F_UNLCK) {
>> +		l_ctx =
>> nfs_get_lock_context(nfs_file_open_context(filp));
>> +		if (!IS_ERR(l_ctx)) {
>> +			status = nfs_iocounter_wait(l_ctx);
>> +			nfs_put_lock_context(l_ctx);
>> +			if (status < 0 && !(fl->fl_flags &
>> FL_CLOSE))
>> +				return status;
>> +		}
>> +	}
>>  
>>  	return nlmclnt_proc(NFS_SERVER(inode)->nlm_host, cmd, fl);
>>  }
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 91f88bfbbe79..052b97fd653d 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -5906,6 +5906,7 @@ struct nfs4_unlockdata {
>>  	struct nfs_locku_res res;
>>  	struct nfs4_lock_state *lsp;
>>  	struct nfs_open_context *ctx;
>> +	struct nfs_lock_context *l_ctx;
>>  	struct file_lock fl;
>>  	struct nfs_server *server;
>>  	unsigned long timestamp;
>> @@ -5930,6 +5931,7 @@ static struct nfs4_unlockdata
>> *nfs4_alloc_unlockdata(struct file_lock *fl,
>>  	atomic_inc(&lsp->ls_count);
>>  	/* Ensure we don't close file until we're done freeing
>> locks! */
>>  	p->ctx = get_nfs_open_context(ctx);
>> +	p->l_ctx = nfs_get_lock_context(ctx);
>>  	memcpy(&p->fl, fl, sizeof(p->fl));
>>  	p->server = NFS_SERVER(inode);
>>  	return p;
>> @@ -5988,6 +5990,11 @@ static void nfs4_locku_prepare(struct rpc_task
>> *task, void *data)
>>  		/* Note: exit _without_ running nfs4_locku_done */
>>  		goto out_no_action;
>>  	}
>> +
>> +	if (!IS_ERR(calldata->l_ctx)) {
>> +		nfs_iocounter_wait(calldata->l_ctx);
>> +		nfs_put_lock_context(calldata->l_ctx);
>> +	}
>>  	calldata->timestamp = jiffies;
>>  	if (nfs4_setup_sequence(calldata->server,
>>  				&calldata->arg.seq_args,
>> diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
>> index 6e629b856a00..8bf3cefdaa96 100644
>> --- a/fs/nfs/pagelist.c
>> +++ b/fs/nfs/pagelist.c
>> @@ -114,6 +114,7 @@ nfs_iocounter_wait(struct nfs_lock_context
>> *l_ctx)
>>  	return wait_on_atomic_t(&l_ctx->io_count,
>> nfs_wait_atomic_killable,
>>  			TASK_KILLABLE);
>>  }
>> +EXPORT_SYMBOL(nfs_iocounter_wait);
>>  
>>  /*
>>   * nfs_page_group_lock - lock the head of the page group
> -- 
>
>
>
> 	
> 	
>
>
> Trond Myklebust
> Principal System Architect
> 4300 El Camino Real | Suite 100
> Los Altos, CA  94022
> W: 650-422-3800
> C: 801-921-4583 
> www.primarydata.com
