From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: Oops in nfs-for-2.6.37
Date: Thu, 23 Sep 2010 18:18:28 +0200
Message-ID: <4C9B7DD4.6070602@panasas.com>
References: <4C9B3E81.8090505@panasas.com> <1285244570.3329.7.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:35452 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753954Ab0IWQSa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Sep 2010 12:18:30 -0400
In-Reply-To: <1285244570.3329.7.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2010-09-23 14:22, Trond Myklebust wrote:
> On Thu, 2010-09-23 at 13:48 +0200, Benny Halevy wrote:
>> How about the following?
>>
>> >From e7019592dae2945ea4091f42ab54f2a1f13465f7 Mon Sep 17 00:00:00 2001
>> From: Benny Halevy <bhalevy@panasas.com>
>> Date: Thu, 23 Sep 2010 13:26:43 +0200
>> Subject: [PATCH] NFS: handle inode==NULL in __put_nfs_open_context
>>
>> inode may be NULL when put_nfs_open_context is called from nfs_atomic_lookup
>> before d_add_unique(dentry, inode)
>>
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  fs/nfs/inode.c |   13 ++++++++-----
>>  1 files changed, 8 insertions(+), 5 deletions(-)
>>
>> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
>> index 2ff8142..a4e579c 100644
>> --- a/fs/nfs/inode.c
>> +++ b/fs/nfs/inode.c
>> @@ -654,11 +654,14 @@ static void __put_nfs_open_context(struct nfs_open_context *ctx, int is_sync)
>>  {
>>  	struct inode *inode = ctx->path.dentry->d_inode;
>>  
>> -	if (!atomic_dec_and_lock(&ctx->lock_context.count, &inode->i_lock))
>> -		return;
>> -	list_del(&ctx->list);
>> -	spin_unlock(&inode->i_lock);
>> -	NFS_PROTO(inode)->close_context(ctx, is_sync);
>> +	if (inode) {
>> +		if (!atomic_dec_and_lock(&ctx->lock_context.count, &inode->i_lock))
>> +			return;
>> +		list_del(&ctx->list);
>> +		spin_unlock(&inode->i_lock);
>> +		NFS_PROTO(inode)->close_context(ctx, is_sync);
>> +	} else
>> +		BUG_ON(atomic_dec_return(&ctx->lock_context.count) != 0);
>>  	if (ctx->cred != NULL)
>>  		put_rpccred(ctx->cred);
>>  	path_put(&ctx->path);
> 
> Hi Benny,
> 
> Let's drop the BUG_ON() and instead use an atomic_dec_and_test() for the
> inode==NULL case. That way the refcounting is guaranteed to just work.

OK.  Patch sent.
Passes cthon over nfs41.

Benny

> 
> Cheers
>   Trond
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
