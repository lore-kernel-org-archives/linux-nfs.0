From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 07/33] NFS: Ensure that rpc_run_task() errors are propagated back to the caller
Date: Mon, 21 Apr 2008 15:55:33 -0400
Message-ID: <BE4F0130-A492-4229-83E4-E7C912B0ABF0@oracle.com>
References: <20080419204047.14124.49490.stgit@c-69-242-210-120.hsd1.mi.comcast.net> <20080419204048.14124.4335.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:56100 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760263AbYDUTz4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Apr 2008 15:55:56 -0400
In-Reply-To: <20080419204048.14124.4335.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

On Apr 19, 2008, at 4:40 PM, Trond Myklebust wrote:
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>
> fs/nfs/direct.c |   10 ++++++----
> fs/nfs/read.c   |   23 +++++++++++++++--------
> fs/nfs/write.c  |   33 +++++++++++++++++++--------------
> 3 files changed, 40 insertions(+), 26 deletions(-)
>
> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
> index abf8e02..4757a2b 100644
> --- a/fs/nfs/direct.c
> +++ b/fs/nfs/direct.c
> @@ -347,8 +347,9 @@ static ssize_t  
> nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
> 		NFS_PROTO(inode)->read_setup(data, &msg);
>
> 		task = rpc_run_task(&task_setup_data);
> -		if (!IS_ERR(task))
> -			rpc_put_task(task);
> +		if (IS_ERR(task))
> +			break;
> +		rpc_put_task(task);
>
> 		dprintk("NFS: %5u initiated direct read call "
> 			"(req %s/%Ld, %zu bytes @ offset %Lu)\n",

My reading of this logic suggests that if the very first  
rpc_run_task() call in the loop fails, we'll return -EFAULT instead of  
something sensible, like -ENOMEM.

> @@ -763,8 +764,9 @@ static ssize_t  
> nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
> 		NFS_PROTO(inode)->write_setup(data, &msg);
>
> 		task = rpc_run_task(&task_setup_data);
> -		if (!IS_ERR(task))
> -			rpc_put_task(task);
> +		if (IS_ERR(task))
> +			break;
> +		rpc_put_task(task);
>
> 		dprintk("NFS: %5u initiated direct write call "
> 			"(req %s/%Ld, %zu bytes @ offset %Lu)\n",

Likewise.

> diff --git a/fs/nfs/read.c b/fs/nfs/read.c
> index 6f9208a..16f57e0 100644
> --- a/fs/nfs/read.c
> +++ b/fs/nfs/read.c
> @@ -153,7 +153,7 @@ static void nfs_readpage_release(struct nfs_page  
> *req)
> /*
>  * Set up the NFS read request struct
>  */
> -static void nfs_read_rpcsetup(struct nfs_page *req, struct  
> nfs_read_data *data,
> +static int nfs_read_rpcsetup(struct nfs_page *req, struct  
> nfs_read_data *data,
> 		const struct rpc_call_ops *call_ops,
> 		unsigned int count, unsigned int offset)
> {
> @@ -202,8 +202,10 @@ static void nfs_read_rpcsetup(struct nfs_page  
> *req, struct nfs_read_data *data,
> 			(unsigned long long)data->args.offset);
>
> 	task = rpc_run_task(&task_setup_data);
> -	if (!IS_ERR(task))
> -		rpc_put_task(task);
> +	if (IS_ERR(task))
> +		return PTR_ERR(task);
> +	rpc_put_task(task);
> +	return 0;
> }
>
> static void
> @@ -240,6 +242,7 @@ static int nfs_pagein_multi(struct inode *inode,  
> struct list_head *head, unsigne
> 	size_t rsize = NFS_SERVER(inode)->rsize, nbytes;
> 	unsigned int offset;
> 	int requests = 0;
> +	int ret = 0;
> 	LIST_HEAD(list);
>
> 	nfs_list_remove_request(req);
> @@ -261,6 +264,8 @@ static int nfs_pagein_multi(struct inode *inode,  
> struct list_head *head, unsigne
> 	offset = 0;
> 	nbytes = count;
> 	do {
> +		int ret2;
> +
> 		data = list_entry(list.next, struct nfs_read_data, pages);
> 		list_del_init(&data->pages);
>
> @@ -268,13 +273,15 @@ static int nfs_pagein_multi(struct inode  
> *inode, struct list_head *head, unsigne
>
> 		if (nbytes < rsize)
> 			rsize = nbytes;
> -		nfs_read_rpcsetup(req, data, &nfs_read_partial_ops,
> +		ret2 = nfs_read_rpcsetup(req, data, &nfs_read_partial_ops,
> 				  rsize, offset);
> +		if (ret == 0)
> +			ret = ret2;
> 		offset += rsize;
> 		nbytes -= rsize;
> 	} while (nbytes != 0);
>
> -	return 0;
> +	return ret;
>
> out_bad:
> 	while (!list_empty(&list)) {
> @@ -292,6 +299,7 @@ static int nfs_pagein_one(struct inode *inode,  
> struct list_head *head, unsigned
> 	struct nfs_page		*req;
> 	struct page		**pages;
> 	struct nfs_read_data	*data;
> +	int ret = -ENOMEM;
>
> 	data = nfs_readdata_alloc(npages);
> 	if (!data)
> @@ -307,11 +315,10 @@ static int nfs_pagein_one(struct inode *inode,  
> struct list_head *head, unsigned
> 	}
> 	req = nfs_list_entry(data->pages.next);
>
> -	nfs_read_rpcsetup(req, data, &nfs_read_full_ops, count, 0);
> -	return 0;
> +	return nfs_read_rpcsetup(req, data, &nfs_read_full_ops, count, 0);
> out_bad:
> 	nfs_async_read_error(head);
> -	return -ENOMEM;
> +	return ret;
> }
>
> /*
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 31681bb..1ade11d 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -778,7 +778,7 @@ static int flush_task_priority(int how)
> /*
>  * Set up the argument/result storage required for the RPC call.
>  */
> -static void nfs_write_rpcsetup(struct nfs_page *req,
> +static int nfs_write_rpcsetup(struct nfs_page *req,
> 		struct nfs_write_data *data,
> 		const struct rpc_call_ops *call_ops,
> 		unsigned int count, unsigned int offset,
> @@ -841,8 +841,10 @@ static void nfs_write_rpcsetup(struct nfs_page  
> *req,
> 		(unsigned long long)data->args.offset);
>
> 	task = rpc_run_task(&task_setup_data);
> -	if (!IS_ERR(task))
> -		rpc_put_task(task);
> +	if (IS_ERR(task))
> +		return PTR_ERR(task);
> +	rpc_put_task(task);
> +	return 0;
> }
>
> /* If a nfs_flush_* function fails, it should remove reqs from @head  
> and
> @@ -868,6 +870,7 @@ static int nfs_flush_multi(struct inode *inode,  
> struct list_head *head, unsigned
> 	size_t wsize = NFS_SERVER(inode)->wsize, nbytes;
> 	unsigned int offset;
> 	int requests = 0;
> +	int ret = 0;
> 	LIST_HEAD(list);
>
> 	nfs_list_remove_request(req);
> @@ -889,6 +892,8 @@ static int nfs_flush_multi(struct inode *inode,  
> struct list_head *head, unsigned
> 	offset = 0;
> 	nbytes = count;
> 	do {
> +		int ret2;
> +
> 		data = list_entry(list.next, struct nfs_write_data, pages);
> 		list_del_init(&data->pages);
>
> @@ -896,13 +901,15 @@ static int nfs_flush_multi(struct inode  
> *inode, struct list_head *head, unsigned
>
> 		if (nbytes < wsize)
> 			wsize = nbytes;
> -		nfs_write_rpcsetup(req, data, &nfs_write_partial_ops,
> +		ret2 = nfs_write_rpcsetup(req, data, &nfs_write_partial_ops,
> 				   wsize, offset, how);
> +		if (ret == 0)
> +			ret = ret2;
> 		offset += wsize;
> 		nbytes -= wsize;
> 	} while (nbytes != 0);
>
> -	return 0;
> +	return ret;
>
> out_bad:
> 	while (!list_empty(&list)) {
> @@ -943,9 +950,7 @@ static int nfs_flush_one(struct inode *inode,  
> struct list_head *head, unsigned i
> 	req = nfs_list_entry(data->pages.next);
>
> 	/* Set up the argument struct */
> -	nfs_write_rpcsetup(req, data, &nfs_write_full_ops, count, 0, how);
> -
> -	return 0;
> +	return nfs_write_rpcsetup(req, data, &nfs_write_full_ops, count,  
> 0, how);
>  out_bad:
> 	while (!list_empty(head)) {
> 		req = nfs_list_entry(head->next);
> @@ -1183,7 +1188,7 @@ void nfs_commitdata_release(void *data)
> /*
>  * Set up the argument/result storage required for the RPC call.
>  */
> -static void nfs_commit_rpcsetup(struct list_head *head,
> +static int nfs_commit_rpcsetup(struct list_head *head,
> 		struct nfs_write_data *data,
> 		int how)
> {
> @@ -1232,8 +1237,10 @@ static void nfs_commit_rpcsetup(struct  
> list_head *head,
> 	dprintk("NFS: %5u initiated commit call\n", data->task.tk_pid);
>
> 	task = rpc_run_task(&task_setup_data);
> -	if (!IS_ERR(task))
> -		rpc_put_task(task);
> +	if (IS_ERR(task))
> +		return PTR_ERR(task);
> +	rpc_put_task(task);
> +	return 0;
> }
>
> /*
> @@ -1251,9 +1258,7 @@ nfs_commit_list(struct inode *inode, struct  
> list_head *head, int how)
> 		goto out_bad;
>
> 	/* Set up the argument struct */
> -	nfs_commit_rpcsetup(head, data, how);
> -
> -	return 0;
> +	return nfs_commit_rpcsetup(head, data, how);
>  out_bad:
> 	while (!list_empty(head)) {
> 		req = nfs_list_entry(head->next);
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



