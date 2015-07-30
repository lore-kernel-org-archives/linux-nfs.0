Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:34242 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775AbbG3NOY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jul 2015 09:14:24 -0400
Message-ID: <55BA231E.7060109@gmail.com>
Date: Thu, 30 Jul 2015 21:14:06 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 8/9 v8] sunrpc: New helper cache_delete_entry for deleting
 cache_head directly
References: <55B5A012.1030006@gmail.com>	<55B5A135.9050800@gmail.com> <20150729122927.5c891998@noble>
In-Reply-To: <20150729122927.5c891998@noble>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/29/2015 10:29, NeilBrown wrote:
> On Mon, 27 Jul 2015 11:10:45 +0800 Kinglong Mee <kinglongmee@gmail.com>
> wrote:
> 
>> A new helper cache_delete_entry() for delete cache_head from
>> cache_detail directly.
>>
>> It will be used by pin_kill, so make sure the cache_detail is valid
>> before deleting is needed.
> 
> I cannot see any justification for validating the cache_detail.
> 
> When this gets called, the cache_head has not yet been freed (though it
> probably will be soon) so the cache_detail must still be around.
> 
> However it is possible for this to race with cache_clean() which could
> have already removed the cache_head from the list (and decremented
> ->entries), but which hasn't called cache_put() yet.

Yes, that's right.
I will drop the checking of cache_detail here.

> 
> The use of cache_list_lock is not enough to protect against that race.
> 
> So I think you should drop the use of cache_list_lock, drop the check
> that detail is still in the list, and after getting ->hash_lock, check
> hlist_unhash() and only unhash if that failed.

Thanks again for your comments.

thanks,
Kinglong Mee

> 
> Thanks,
> NeilBrown
> 
>>
>> Because pin_kill is not many times, so the influence of performance
>> is accepted.
>>
>> v8, same as v6.
>>
>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>> ---
>>  include/linux/sunrpc/cache.h |  1 +
>>  net/sunrpc/cache.c           | 30 ++++++++++++++++++++++++++++++
>>  2 files changed, 31 insertions(+)
>>
>> diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
>> index 03d3b4c..2824db5 100644
>> --- a/include/linux/sunrpc/cache.h
>> +++ b/include/linux/sunrpc/cache.h
>> @@ -210,6 +210,7 @@ extern int cache_check(struct cache_detail *detail,
>>  		       struct cache_head *h, struct cache_req *rqstp);
>>  extern void cache_flush(void);
>>  extern void cache_purge(struct cache_detail *detail);
>> +extern void cache_delete_entry(struct cache_detail *cd, struct cache_head *h);
>>  #define NEVER (0x7FFFFFFF)
>>  extern void __init cache_initialize(void);
>>  extern int cache_register_net(struct cache_detail *cd, struct net *net);
>> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
>> index 4a2340a..b722aea 100644
>> --- a/net/sunrpc/cache.c
>> +++ b/net/sunrpc/cache.c
>> @@ -454,6 +454,36 @@ static int cache_clean(void)
>>  	return rv;
>>  }
>>  
>> +void cache_delete_entry(struct cache_detail *detail, struct cache_head *h)
>> +{
>> +	struct cache_detail *tmp;
>> +
>> +	if (!detail || !h)
>> +		return;
>> +
>> +	spin_lock(&cache_list_lock);
>> +	list_for_each_entry(tmp, &cache_list, others) {
>> +		if (tmp == detail)
>> +			goto found;
>> +	}
>> +	spin_unlock(&cache_list_lock);
>> +	printk(KERN_WARNING "%s: Deleted cache detail %p\n", __func__, detail);
>> +	return ;
>> +
>> +found:
>> +	write_lock(&detail->hash_lock);
>> +
>> +	hlist_del_init(&h->cache_list);
>> +	detail->entries--;
>> +	set_bit(CACHE_CLEANED, &h->flags);
>> +
>> +	write_unlock(&detail->hash_lock);
>> +	spin_unlock(&cache_list_lock);
>> +
>> +	cache_put(h, detail);
>> +}
>> +EXPORT_SYMBOL_GPL(cache_delete_entry);
>> +
>>  /*
>>   * We want to regularly clean the cache, so we need to schedule some work ...
>>   */
> 
> 
