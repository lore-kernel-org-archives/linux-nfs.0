Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35783 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751101AbdBEMls (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 5 Feb 2017 07:41:48 -0500
Received: by mail-it0-f65.google.com with SMTP id 203so5867333ith.2
        for <linux-nfs@vger.kernel.org>; Sun, 05 Feb 2017 04:41:47 -0800 (PST)
Subject: Re: [PATCH] sunrpc/cache: skip checking the pending cache expired
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
References: <cb2a552c-51ec-f230-0b39-0bd4002e351d@gmail.com>
 <4471ba20-2677-f9f4-dc27-c53b50c72066@gmail.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        NeilBrown <neilb@suse.com>, Kinglong Mee <kinglongmee@gmail.com>
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <e87e2700-3eb3-19cc-a2ca-675ff1219aa8@gmail.com>
Date: Sun, 5 Feb 2017 20:41:06 +0800
MIME-Version: 1.0
In-Reply-To: <4471ba20-2677-f9f4-dc27-c53b50c72066@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2/5/2017 18:37, Kinglong Mee wrote:
> On 2/4/2017 13:41, Kinglong Mee wrote:
>> When the first time pynfs runs after rpc/nfsd startup, always get the warning, 
>>
>> Got error: Connection closed
>>
>> Commit 778620364ef5 "sunrpc/cache: make cache flushing more reliable." lets
>> cache_is_expired() checking expired as, 
>>
>> return (h->expiry_time < seconds_since_boot()) ||
>>         (detail->flush_time >= h->last_refresh);
>>
>> The detail->flush_time is equal to h->last_refresh time, when the cache is
>> new created and then do the upcall immediately. So that, the cache will be
>> treated as expired and be cleaned when write_flush().

I found the problem is caused by, 
1. A new startup of nfsd, rpc.mountd, etc,
2. A rpc request from client (pynfs test, or normal mounting),
3. An ip_map cache is created but invalid, so upcall to rpc.mountd, 
4. rpc.mountd process the ip_map upcall, before write the valid data to nfsd,
   do auth_reload(), and check_useipaddr(),
5. For the first time, old_use_ipaddr = -1, that cause a cache_flush,
6. The ip_map cache will be treat as expired and clean,
7. When rpc.mountd write the valid data to nfsd, a new ip_map is created
   and updated, the cache_check of old ip_map(doing the upcall) will
   return -ETIMEDOUT.
8. RPC layer return SVC_CLOSE and close the xprt after commit 4d712ef1db05
   "svcauth_gss: Close connection when dropping an incoming message"

Although it is exist only one time, but I don't like the noise.
Is the cache_flush for old_use_ipaddr = -1 necessary in step 5?
I have no idea about how to fix it, any suggests?

thanks,
Kinglong Mee

>>
>> This patch skips checking the pending cache expired when doing upcall.
>>
>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>> ---
>>  include/linux/sunrpc/cache.h | 5 ++++-
>>  1 file changed, 4 insertions(+), 1 deletion(-)
>>
>> diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
>> index 62a60ee..9961c1f 100644
>> --- a/include/linux/sunrpc/cache.h
>> +++ b/include/linux/sunrpc/cache.h
>> @@ -204,8 +204,11 @@ static inline void cache_put(struct cache_head *h, struct cache_detail *cd)
>>  	kref_put(&h->ref, cd->cache_put);
>>  }
>>  
>> -static inline int cache_is_expired(struct cache_detail *detail, struct cache_head *h)
>> +static inline bool cache_is_expired(struct cache_detail *detail, struct cache_head *h)
>>  {
>> +	if (test_bit(CACHE_PENDING, &h->flags))
>> +		return false;
>> +
> 
> Sorry, with this patch there is a bug exist,
> When a pending cache exist, sunrpc_destroy_cache_detail() cann't
> cleanup the cache_detail, but user always free it later, 
> that will cause a NULL reference.
> 
> Please ignore this patch, maybe another patch for the above problem
>  will be sent.
> 
> thanks,
> Kinglong Mee
> 
>>  	return  (h->expiry_time < seconds_since_boot()) ||
>>  		(detail->flush_time >= h->last_refresh);
>>  }
>>
> 
