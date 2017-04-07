Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48492 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755611AbdDGL1A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Apr 2017 07:27:00 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Jeff Layton" <jlayton@redhat.com>
Cc: "Trond Myklebust" <trond.myklebust@primarydata.com>,
        "Anna Schumaker" <anna.schumaker@netapp.com>, bfields@fieldses.org,
        "Miklos Szeredi" <miklos@szeredi.hu>,
        "Alexander Viro" <viro@zeniv.linux.org.uk>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 4/6] NFS: Add an iocounter wait function for async RPC
 tasks
Date: Fri, 07 Apr 2017 07:26:56 -0400
Message-ID: <A1ECED32-1304-4C36-A97E-8BCED565BDEB@redhat.com>
In-Reply-To: <1491561891.2745.2.camel@redhat.com>
References: <cover.1491477181.git.bcodding@redhat.com>
 <ed1c4fdb8d3c2c8434c53d4c851c31ffac9d93a4.1491477181.git.bcodding@redhat.com>
 <1491561891.2745.2.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7 Apr 2017, at 6:44, Jeff Layton wrote:

> On Thu, 2017-04-06 at 07:23 -0400, Benjamin Coddington wrote:
>> By sleeping on a new NFS Unlock-On-Close waitqueue, rpc tasks may 
>> wait for
>> a lock context's iocounter to reach zero.  The rpc waitqueue is only 
>> woken
>> when the open_context has the NFS_CONTEXT_UNLOCK flag set in order to
>> mitigate spurious wake-ups for any iocounter reaching zero.
>>
>> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
>> ---
>>  fs/nfs/client.c           |  1 +
>>  fs/nfs/pagelist.c         | 26 +++++++++++++++++++++++++-
>>  include/linux/nfs_fs.h    |  1 +
>>  include/linux/nfs_fs_sb.h |  1 +
>>  include/linux/nfs_page.h  |  1 +
>>  5 files changed, 29 insertions(+), 1 deletion(-)
>>
>> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
>> index 91a8d610ba0f..c335c6dce285 100644
>> --- a/fs/nfs/client.c
>> +++ b/fs/nfs/client.c
>> @@ -218,6 +218,7 @@ static void nfs_cb_idr_remove_locked(struct 
>> nfs_client *clp)
>>  static void pnfs_init_server(struct nfs_server *server)
>>  {
>>  	rpc_init_wait_queue(&server->roc_rpcwaitq, "pNFS ROC");
>> +	rpc_init_wait_queue(&server->uoc_rpcwaitq, "NFS UOC");
>>  }
>>
>>  #else
>> diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
>> index 6e629b856a00..d163819e4416 100644
>> --- a/fs/nfs/pagelist.c
>> +++ b/fs/nfs/pagelist.c
>> @@ -115,6 +115,27 @@ nfs_iocounter_wait(struct nfs_lock_context 
>> *l_ctx)
>>  			TASK_KILLABLE);
>>  }
>>
>> +bool
>> +nfs_async_iocounter_wait(struct rpc_task *task, void *data)
>> +{
>> +	struct nfs_lock_context *l_ctx = data;
>> +	struct inode *inode = d_inode(l_ctx->open_context->dentry);
>> +	bool ret = false;
>> +
>> +	if (atomic_read(&l_ctx->io_count) > 0) {
>> +		rpc_sleep_on(&NFS_SERVER(inode)->uoc_rpcwaitq, task, NULL);
>> +		ret = true;
>> +	}
>> +
>> +	if (atomic_read(&l_ctx->io_count) == 0) {
>> +		rpc_wake_up_queued_task(&NFS_SERVER(inode)->uoc_rpcwaitq, task);
>> +		ret = false;
>> +	}
>> +
>
> nit: Would it be better to do the atomic read once into a local 
> variable
> and then compare it afterward?

Reading it twice catches the race where we are about to put the task on 
the
wait queue, but then the iocounter goes to zero and the queue wakes.

>
>> +	return ret;
>> +}
>> +EXPORT_SYMBOL_GPL(nfs_async_iocounter_wait);
>> +
>>  /*
>>   * nfs_page_group_lock - lock the head of the page group
>>   * @req - request in group that is to be locked
>> @@ -398,8 +419,11 @@ static void nfs_clear_request(struct nfs_page 
>> *req)
>>  		req->wb_page = NULL;
>>  	}
>>  	if (l_ctx != NULL) {
>> -		if (atomic_dec_and_test(&l_ctx->io_count))
>> +		if (atomic_dec_and_test(&l_ctx->io_count)) {
>>  			wake_up_atomic_t(&l_ctx->io_count);
>> +			if (test_bit(NFS_CONTEXT_UNLOCK, &ctx->flags))
>> +				rpc_wake_up(&NFS_SERVER(d_inode(ctx->dentry))->uoc_rpcwaitq);
>> +		}
>>  		nfs_put_lock_context(l_ctx);
>>  		req->wb_lock_context = NULL;
>>  	}
>> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
>> index f1da8c8dd473..3ce3e42beead 100644
>> --- a/include/linux/nfs_fs.h
>> +++ b/include/linux/nfs_fs.h
>> @@ -76,6 +76,7 @@ struct nfs_open_context {
>>  #define NFS_CONTEXT_ERROR_WRITE		(0)
>>  #define NFS_CONTEXT_RESEND_WRITES	(1)
>>  #define NFS_CONTEXT_BAD			(2)
>> +#define NFS_CONTEXT_UNLOCK	(3)
>>  	int error;
>>
>>  	struct list_head list;
>> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
>> index b34097c67848..2a70f34dffe8 100644
>> --- a/include/linux/nfs_fs_sb.h
>> +++ b/include/linux/nfs_fs_sb.h
>> @@ -222,6 +222,7 @@ struct nfs_server {
>>  	u32			mountd_version;
>>  	unsigned short		mountd_port;
>>  	unsigned short		mountd_protocol;
>> +	struct rpc_wait_queue	uoc_rpcwaitq;
>>  };
>>
>>  /* Server capabilities */
>> diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
>> index 957049f72290..d39ebcba52c8 100644
>> --- a/include/linux/nfs_page.h
>> +++ b/include/linux/nfs_page.h
>> @@ -141,6 +141,7 @@ extern int nfs_page_group_lock(struct nfs_page *, 
>> bool);
>>  extern void nfs_page_group_lock_wait(struct nfs_page *);
>>  extern void nfs_page_group_unlock(struct nfs_page *);
>>  extern bool nfs_page_group_sync_on_bit(struct nfs_page *, unsigned 
>> int);
>> +extern bool nfs_async_iocounter_wait(struct rpc_task *, void *);
>>
>>  /*
>>   * Lock the page of an asynchronous request
>
> Looks reasonable otherwise:
>
> Reviewed-by: Jeff Layton <jlayton@redhat.com>

Thanks for the review, and all the help..

Ben
