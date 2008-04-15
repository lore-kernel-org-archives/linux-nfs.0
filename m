From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH] nfs: handle nfs_{read,write,commit}_rpcsetup errors
Date: Tue, 15 Apr 2008 10:09:50 +0300
Message-ID: <480454BE.30500@panasas.com>
References: <1208194278-6165-1-git-send-email-bhalevy@panasas.com> <1208195681.11223.18.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bzq-219-195-70.pop.bezeqint.net ([62.219.195.70]:38556 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752937AbYDOHKS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Apr 2008 03:10:18 -0400
In-Reply-To: <1208195681.11223.18.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr. 14, 2008, 20:54 +0300, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> On Mon, 2008-04-14 at 20:31 +0300, Benny Halevy wrote:
>> Currently, nfs_{read,write,commit}_rpcsetup return no errors.
>> All three call rpc_run_task that can fail when out of memory.
>> Ignoring these failures leads to hangs.
> 
> How?

I've seen this with instrumentation I've put in the rpc_run_task path.
However, I reexamined the call sites and I agree that since we pass
both task_setup_data.task and task_setup_data.rpc_message.rpc_cred
rpc_run_task will never fail in the current implementation.

How about adding the following BUG()s instead?

Benny

diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 5a70be5..9db9db1 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -206,6 +206,8 @@ static void nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
 	task = rpc_run_task(&task_setup_data);
 	if (!IS_ERR(task))
 		rpc_put_task(task);
+	else
+		BUG();
 }
 
 static void
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index bed6341..06e6363 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -849,6 +849,8 @@ static void nfs_write_rpcsetup(struct nfs_page *req,
 	task = rpc_run_task(&task_setup_data);
 	if (!IS_ERR(task))
 		rpc_put_task(task);
+	else
+		BUG();
 }
 
 /*
@@ -1216,6 +1218,8 @@ static void nfs_commit_rpcsetup(struct list_head *head,
 	task = rpc_run_task(&task_setup_data);
 	if (!IS_ERR(task))
 		rpc_put_task(task);
+	else
+		BUG();
 }
 
 /*

> 
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  fs/nfs/read.c  |   35 +++++++++++++++++++++--------
>>  fs/nfs/write.c |   66 ++++++++++++++++++++++++++++++++++++-------------------
>>  2 files changed, 68 insertions(+), 33 deletions(-)
>>
>> diff --git a/fs/nfs/read.c b/fs/nfs/read.c
>> index 5a70be5..85df148 100644
>> --- a/fs/nfs/read.c
>> +++ b/fs/nfs/read.c
>> @@ -156,7 +156,7 @@ static void nfs_readpage_release(struct nfs_page *req)
>>  /*
>>   * Set up the NFS read request struct
>>   */
>> -static void nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
>> +static int nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
>>  		const struct rpc_call_ops *call_ops,
>>  		unsigned int count, unsigned int offset)
>>  {
>> @@ -204,8 +204,10 @@ static void nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
>>  			(unsigned long long)data->args.offset);
>>  
>>  	task = rpc_run_task(&task_setup_data);
>> -	if (!IS_ERR(task))
>> -		rpc_put_task(task);
>> +	if (unlikely(IS_ERR(task)))
>> +		return PTR_ERR(task);
>> +	rpc_put_task(task);
>> +	return 0;
>>  }
>>  
>>  static void
>> @@ -242,6 +244,7 @@ static int nfs_pagein_multi(struct inode *inode, struct list_head *head, unsigne
>>  	size_t rsize = NFS_SERVER(inode)->rsize, nbytes;
>>  	unsigned int offset;
>>  	int requests = 0;
>> +	int ret = -ENOMEM;
>>  	LIST_HEAD(list);
>>  
>>  	nfs_list_remove_request(req);
>> @@ -271,8 +274,12 @@ static int nfs_pagein_multi(struct inode *inode, struct list_head *head, unsigne
>>  
>>  		if (nbytes < rsize)
>>  			rsize = nbytes;
>> -		nfs_read_rpcsetup(req, data, &nfs_read_partial_ops,
>> -				  rsize, offset);
>> +		ret = nfs_read_rpcsetup(req, data, &nfs_read_partial_ops,
>> +					rsize, offset);
>> +		if (unlikely(ret)) {
>> +			list_add(&data->pages, &list);
> 
> NACK. This is a use-after-free case.
> 
> The call to rpc_run_task() is _guaranteed_ to always call
> nfs_readpage_release(). You therefore no longer hold the page lock, nor
> can you rely on 'data' still being around.
> 
> The same applies to all the other "fixes".

Agreed. I missed that.

Benny

> 
> Trond
> 

