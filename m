Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:39282 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932331AbaE2Q6V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 May 2014 12:58:21 -0400
Message-ID: <5387672A.5050307@netapp.com>
Date: Thu, 29 May 2014 12:58:18 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [nfs:devel 21/48] fs/nfs/pagelist.c:453: warning: unused variable
 'inode'
References: <538676fe.74/Y9ZfdJIRe5CAC%fengguang.wu@intel.com> <1401376022.6543.3.camel@leira.trondhjem.org>
In-Reply-To: <1401376022.6543.3.camel@leira.trondhjem.org>
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks good to me.  Thanks, Trond!

On 05/29/2014 11:07 AM, Trond Myklebust wrote:
> On Thu, 2014-05-29 at 07:53 +0800, kbuild test robot wrote:
>> tree:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git devel
>> head:   c75c3b0bfffdb21daecb7dadbd30eb2e353fe66d
>> commit: 5aea6ba186d825973a1c3daf88dece597b8b54e3 [21/48] NFS: Create a common initiate_pgio() function
>> config: make ARCH=avr32 atngw100_defconfig
>>
>> All warnings:
>>
>>    fs/nfs/pagelist.c: In function 'nfs_initiate_pgio':
>>>> fs/nfs/pagelist.c:453: warning: unused variable 'inode'
>> vim +/inode +453 fs/nfs/pagelist.c
>>
>>    437	 * nfs_pgio_prepare - Prepare pageio data to go over the wire
>>    438	 * @task: The current task
>>    439	 * @calldata: pageio data to prepare
>>    440	 */
>>    441	static void nfs_pgio_prepare(struct rpc_task *task, void *calldata)
>>    442	{
>>    443		struct nfs_pgio_data *data = calldata;
>>    444		int err;
>>    445		err = NFS_PROTO(data->header->inode)->pgio_rpc_prepare(task, data);
>>    446		if (err)
>>    447			rpc_exit(task, err);
>>    448	}
>>    449	
>>    450	int nfs_initiate_pgio(struct rpc_clnt *clnt, struct nfs_pgio_data *data,
>>    451			      const struct rpc_call_ops *call_ops, int how, int flags)
>>    452	{
>>  > 453		struct inode *inode = data->header->inode;
>>    454		struct rpc_task *task;
>>    455		struct rpc_message msg = {
>>    456			.rpc_argp = &data->args,
>>    457			.rpc_resp = &data->res,
>>    458			.rpc_cred = data->header->cred,
>>    459		};
>>    460		struct rpc_task_setup task_setup_data = {
>>    461			.rpc_client = clnt,
>>
>> ---
>> 0-DAY kernel build testing backend              Open Source Technology Center
>> http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation
> Fixing this up using:
>
> From 86e52bd318d0fda06c6c9829ec54f693bd669b30 Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> Date: Thu, 29 May 2014 11:04:51 -0400
> Subject: [PATCH] fixup! NFS: Create a common initiate_pgio() function
>
> ---
>  fs/nfs/pagelist.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
>
> diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
> index 0c4aac4c7ad9..fab78d13ee14 100644
> --- a/fs/nfs/pagelist.c
> +++ b/fs/nfs/pagelist.c
> @@ -604,7 +604,6 @@ static void nfs_pgio_prepare(struct rpc_task *task, void *calldata)
>  int nfs_initiate_pgio(struct rpc_clnt *clnt, struct nfs_pgio_data *data,
>  		      const struct rpc_call_ops *call_ops, int how, int flags)
>  {
> -	struct inode *inode = data->header->inode;
>  	struct rpc_task *task;
>  	struct rpc_message msg = {
>  		.rpc_argp = &data->args,
> @@ -627,8 +626,8 @@ int nfs_initiate_pgio(struct rpc_clnt *clnt, struct nfs_pgio_data *data,
>  	dprintk("NFS: %5u initiated pgio call "
>  		"(req %s/%llu, %u bytes @ offset %llu)\n",
>  		data->task.tk_pid,
> -		inode->i_sb->s_id,
> -		(unsigned long long)NFS_FILEID(inode),
> +		data->header->inode->i_sb->s_id,
> +		(unsigned long long)NFS_FILEID(data->header->inode),
>  		data->args.count,
>  		(unsigned long long)data->args.offset);
>  

