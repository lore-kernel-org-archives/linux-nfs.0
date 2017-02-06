Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35241 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750946AbdBFBAn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 5 Feb 2017 20:00:43 -0500
Received: by mail-it0-f66.google.com with SMTP id 203so7128636ith.2
        for <linux-nfs@vger.kernel.org>; Sun, 05 Feb 2017 17:00:43 -0800 (PST)
Subject: Re: [PATCH] sunrpc/cache: skip checking the pending cache expired
To: NeilBrown <neilb@suse.com>, "J. Bruce Fields" <bfields@fieldses.org>,
        linux-nfs@vger.kernel.org
References: <cb2a552c-51ec-f230-0b39-0bd4002e351d@gmail.com>
 <4471ba20-2677-f9f4-dc27-c53b50c72066@gmail.com>
 <e87e2700-3eb3-19cc-a2ca-675ff1219aa8@gmail.com>
 <871svcxoew.fsf@notabene.neil.brown.name>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Kinglong Mee <kinglongmee@gmail.com>
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <91f7dd89-9867-ea0a-92a8-4bfcda6087c2@gmail.com>
Date: Mon, 6 Feb 2017 08:59:25 +0800
MIME-Version: 1.0
In-Reply-To: <871svcxoew.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2/6/2017 06:28, NeilBrown wrote:
> On Sun, Feb 05 2017, Kinglong Mee wrote:
> 
>> On 2/5/2017 18:37, Kinglong Mee wrote:
>>> On 2/4/2017 13:41, Kinglong Mee wrote:
>>>> When the first time pynfs runs after rpc/nfsd startup, always get the warning, 
>>>>
>>>> Got error: Connection closed
>>>>
>>>> Commit 778620364ef5 "sunrpc/cache: make cache flushing more reliable." lets
>>>> cache_is_expired() checking expired as, 
>>>>
>>>> return (h->expiry_time < seconds_since_boot()) ||
>>>>         (detail->flush_time >= h->last_refresh);
>>>>
>>>> The detail->flush_time is equal to h->last_refresh time, when the cache is
>>>> new created and then do the upcall immediately. So that, the cache will be
>>>> treated as expired and be cleaned when write_flush().
>>
>> I found the problem is caused by, 
>> 1. A new startup of nfsd, rpc.mountd, etc,
>> 2. A rpc request from client (pynfs test, or normal mounting),
>> 3. An ip_map cache is created but invalid, so upcall to rpc.mountd, 
>> 4. rpc.mountd process the ip_map upcall, before write the valid data to nfsd,
>>    do auth_reload(), and check_useipaddr(),
>> 5. For the first time, old_use_ipaddr = -1, that cause a cache_flush,
>> 6. The ip_map cache will be treat as expired and clean,
>> 7. When rpc.mountd write the valid data to nfsd, a new ip_map is created
>>    and updated, the cache_check of old ip_map(doing the upcall) will
>>    return -ETIMEDOUT.
>> 8. RPC layer return SVC_CLOSE and close the xprt after commit 4d712ef1db05
>>    "svcauth_gss: Close connection when dropping an incoming message"
>>
>> Although it is exist only one time, but I don't like the noise.
>> Is the cache_flush for old_use_ipaddr = -1 necessary in step 5?
>> I have no idea about how to fix it, any suggests?
>>
> 
> Hi,
>  I think that your idea that CACHE_PENDING cache entries shouldn't be
>  treated as expired make some sense.
>  I would actually focus on CACHE_VALID.  If CACHE_VALID is not set, then
>  there is no data in the cache item, so there is nothing to expire.
>  So it would be nice if cache items that don't have CACHE_VALID are
>  never treated as expired.
>  However, as you discovered, that causes a problem for cache_purge().
>  It purges a cache by setting the ->flush_time, and calling
>  cache_clean(), which only removes expired entries.  For that to work,
>  Even non-CACHE_VALID entries need to be seen as expired.

rpc.mountd do a write_flush() that cause the cache_flush,
but, it's the same as cache_purge() which setting the ->flush_time.

> 
>  I think the best thing to do is to write a stand-alone cache_purge().
>  Rather than using cache_flush(), explicitly free every item on every
>  hash chain.

The stand-alone cache_purge() as following make sure cleanup all
cache entries it the cache_detail.
It's better than my another patch for the NULL reference bugfix.

Don't treat non-CACHE_VALID entries as expired make sense, 
it's needed also.

thanks,
Kinglong Mee

> 
>  Something like this?
> 
> static int cache_purge(struct cache_detail *cd)
> {
> 	int rv = 0;
> 	struct list_head *next;
> 	int i;
> 
> 	write_lock(&cd->hash_lock);
> 
> 	for (i = 0; i < cd->hash_size; i++) {
> 		struct cache_head *ch = NULL;
> 		struct cache_detail *d;
> 		struct hlist_head *head;
> 		struct hlist_node *tmp;
> 
> 		head = &cd->hash_table[i];
> 		hlist_for_each_entry_safe(ch, tmp, head, cache_list) {
> 			hlist_del_init(&ch->cache_list);
> 			cd->entries--;
> 
> 			set_bit(CACHE_CLEANED, &ch->flags);
> 			write_unlock(&cd->hash_lock);
> 			cache_fresh_unlocked(ch, d);
> 			cache_put(ch, d);
> 			write_lock(&cd->hash_lock);
> 		}
> 	}
> 	write_unlock(&cd->hash_lock);
> 
> 	return rv;
> }
> 
> Thanks,
> NeilBrown
> 
> 
>> thanks,
>> Kinglong Mee
>>
>>>>
>>>> This patch skips checking the pending cache expired when doing upcall.
>>>>
>>>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>>>> ---
>>>>  include/linux/sunrpc/cache.h | 5 ++++-
>>>>  1 file changed, 4 insertions(+), 1 deletion(-)
>>>>
>>>> diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
>>>> index 62a60ee..9961c1f 100644
>>>> --- a/include/linux/sunrpc/cache.h
>>>> +++ b/include/linux/sunrpc/cache.h
>>>> @@ -204,8 +204,11 @@ static inline void cache_put(struct cache_head *h, struct cache_detail *cd)
>>>>  	kref_put(&h->ref, cd->cache_put);
>>>>  }
>>>>  
>>>> -static inline int cache_is_expired(struct cache_detail *detail, struct cache_head *h)
>>>> +static inline bool cache_is_expired(struct cache_detail *detail, struct cache_head *h)
>>>>  {
>>>> +	if (test_bit(CACHE_PENDING, &h->flags))
>>>> +		return false;
>>>> +
>>>
>>> Sorry, with this patch there is a bug exist,
>>> When a pending cache exist, sunrpc_destroy_cache_detail() cann't
>>> cleanup the cache_detail, but user always free it later, 
>>> that will cause a NULL reference.
>>>
>>> Please ignore this patch, maybe another patch for the above problem
>>>  will be sent.
>>>
>>> thanks,
>>> Kinglong Mee
>>>
>>>>  	return  (h->expiry_time < seconds_since_boot()) ||
>>>>  		(detail->flush_time >= h->last_refresh);
>>>>  }
>>>>
>>>
