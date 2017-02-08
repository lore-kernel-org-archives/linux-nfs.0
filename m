Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:34851 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932758AbdBHB4Z (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Feb 2017 20:56:25 -0500
Received: by mail-it0-f68.google.com with SMTP id 203so14163953ith.2
        for <linux-nfs@vger.kernel.org>; Tue, 07 Feb 2017 17:56:25 -0800 (PST)
Subject: Re: [PATCH 2/2] SUNRPC: Drop all entries from cache_detail when
 cache_purge()
To: NeilBrown <neilb@suse.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
References: <400d714e-3e4c-74b0-6734-96dbf491b9d9@gmail.com>
 <87vaslv97i.fsf@notabene.neil.brown.name>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Kinglong Mee <kinglongmee@gmail.com>
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <063edaac-50b1-7288-4721-db3fc1bf3da2@gmail.com>
Date: Wed, 8 Feb 2017 09:48:20 +0800
MIME-Version: 1.0
In-Reply-To: <87vaslv97i.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2/8/2017 08:04, NeilBrown wrote:
> On Mon, Feb 06 2017, Kinglong Mee wrote:
> 
>> User always free the cache_detail after sunrpc_destroy_cache_detail(),
>> so, it must cleanup up entries that left in the cache_detail,
>> otherwise, NULL reference may be caused when using the left entries.
>>
>> Also, NeriBrown suggests "write a stand-alone cache_purge()."
>>
>> v2, a stand-alone cache_purge(), not only for sunrpc_destroy_cache_detail
>>
>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>> ---
>>  net/sunrpc/cache.c | 39 ++++++++++++++++++++++++---------------
>>  1 file changed, 24 insertions(+), 15 deletions(-)
>>
>> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
>> index 8147e8d..bd6ee79 100644
>> --- a/net/sunrpc/cache.c
>> +++ b/net/sunrpc/cache.c
>> @@ -362,11 +362,6 @@ void sunrpc_destroy_cache_detail(struct cache_detail *cd)
>>  	cache_purge(cd);
>>  	spin_lock(&cache_list_lock);
>>  	write_lock(&cd->hash_lock);
>> -	if (cd->entries) {
>> -		write_unlock(&cd->hash_lock);
>> -		spin_unlock(&cache_list_lock);
>> -		goto out;
>> -	}
>>  	if (current_detail == cd)
>>  		current_detail = NULL;
>>  	list_del_init(&cd->others);
>> @@ -376,9 +371,6 @@ void sunrpc_destroy_cache_detail(struct cache_detail *cd)
>>  		/* module must be being unloaded so its safe to kill the worker */
>>  		cancel_delayed_work_sync(&cache_cleaner);
>>  	}
>> -	return;
>> -out:
>> -	printk(KERN_ERR "RPC: failed to unregister %s cache\n", cd->name);
>>  }
>>  EXPORT_SYMBOL_GPL(sunrpc_destroy_cache_detail);
>>  
>> @@ -497,13 +489,30 @@ EXPORT_SYMBOL_GPL(cache_flush);
>>  
>>  void cache_purge(struct cache_detail *detail)
>>  {
>> -	time_t now = seconds_since_boot();
>> -	if (detail->flush_time >= now)
>> -		now = detail->flush_time + 1;
>> -	/* 'now' is the maximum value any 'last_refresh' can have */
>> -	detail->flush_time = now;
>> -	detail->nextcheck = seconds_since_boot();
>> -	cache_flush();
>> +	struct cache_head *ch = NULL;
>> +	struct hlist_head *head = NULL;
>> +	struct hlist_node *tmp = NULL;
>> +	int i = 0;
>> +
>> +	write_lock(&detail->hash_lock);
>> +	if (!detail->entries) {
>> +		write_unlock(&detail->hash_lock);
>> +		return;
>> +	}
>> +
>> +	dprintk("RPC: %d entries in %s cache\n", detail->entries, detail->name);
>> +	for (i = 0; i < detail->hash_size; i++) {
>> +		head = &detail->hash_table[i];
>> +		hlist_for_each_entry_safe(ch, tmp, head, cache_list) {
>> +			hlist_del_init(&ch->cache_list);
>> +			detail->entries--;
>> +
>> +			set_bit(CACHE_CLEANED, &ch->flags);
>> +			cache_fresh_unlocked(ch, detail);
>> +			cache_put(ch, detail);
> 
> I'm a little bothered by calling cache_fresh_unlocked() while holding
> ->hash_lock.  No other code does that.
> You could probably argue that we don't need ->hash_lock at all here
> because by the time we call cache_purge(), there cannot safely be any
> other users.  Should we just drop the write_lock() call?

No, we can't.

We call cache_purge() without remove the cache_detail from cache_list,
so that, if we drop the write_lock(), cache_clean may access the
cache_detail at the same time, a double free may happen.

Just move the cache_fresh_unlocked() out of write_lock().

thanks,
Kinglong Mee

> 
> NeilBrown
> 
> 
>> +		}
>> +	}
>> +	write_unlock(&detail->hash_lock);
>>  }
>>  EXPORT_SYMBOL_GPL(cache_purge);
>>  
>> -- 
>> 2.9.3
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
