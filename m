From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] NFS: Use GFP_NOFS in nfs_direct_req_alloc
Date: Tue, 8 Sep 2009 18:43:02 -0400
Message-ID: <931F30AB-DC64-4A02-A96C-FABF0DD4059A@oracle.com>
References: <20090908220230.7590.69833.stgit@matisse.1015granger.net> <1252449178.8099.64.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:26984 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751089AbZIHWnG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Sep 2009 18:43:06 -0400
In-Reply-To: <1252449178.8099.64.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep 8, 2009, at 6:32 PM, Trond Myklebust wrote:
> On Tue, 2009-09-08 at 18:05 -0400, Chuck Lever wrote:
>> Don't dive into memory reclaim in the NFS direct I/O paths, otherwise
>> we can deadlock.
>>
>> Reported by: Wengang Wang <wen.gang.wang@oracle.com>
>> Fix-suggested-by: Zach Brown <zach.brown@oracle.com>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>
> Wait... What??? How does an O_DIRECT read or write allocation deadlock
> with memory reclaim? Both the read and the write path call
> nfs_direct_req_alloc() before they pin any user pages in memory.

This may be an issue only for loopback mounts where the backing device  
is an NFS O_DIRECT file.  This type of deadlock may not be able to  
happen in upstream kernels at this point.

Even so, it makes sense for this allocation to be consistent with  
similar allocations in the other NFS I/O paths.

> Trond
>
>> ---
>>
>> Trond-
>>
>> Thoughts?
>>
>> fs/nfs/direct.c |    2 +-
>> 1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
>> index e4e089a..00f06b8 100644
>> --- a/fs/nfs/direct.c
>> +++ b/fs/nfs/direct.c
>> @@ -149,7 +149,7 @@ static inline struct nfs_direct_req  
>> *nfs_direct_req_alloc(void)
>> {
>> 	struct nfs_direct_req *dreq;
>>
>> -	dreq = kmem_cache_alloc(nfs_direct_cachep, GFP_KERNEL);
>> +	dreq = kmem_cache_alloc(nfs_direct_cachep, GFP_NOFS);
>> 	if (!dreq)
>> 		return NULL;
>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux- 
>> nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> -- 
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



