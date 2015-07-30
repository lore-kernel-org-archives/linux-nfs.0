Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:32818 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752127AbbG3NCP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jul 2015 09:02:15 -0400
Message-ID: <55BA203B.908@gmail.com>
Date: Thu, 30 Jul 2015 21:01:47 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>, NeilBrown <neilb@suse.com>
CC: Al Viro <viro@zeniv.linux.org.uk>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
Subject: Re: [PATCH 7/9 v8] sunrpc: Switch to using hash list instead single
 list
References: <55B5A012.1030006@gmail.com> <55B5A117.1020902@gmail.com> <20150729121939.517008f4@noble> <20150729195151.GD21949@fieldses.org>
In-Reply-To: <20150729195151.GD21949@fieldses.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/30/2015 03:51, J. Bruce Fields wrote:
> On Wed, Jul 29, 2015 at 12:19:39PM +1000, NeilBrown wrote:
>> On Mon, 27 Jul 2015 11:10:15 +0800 Kinglong Mee <kinglongmee@gmail.com>
>> wrote:
>>
>>> Switch using list_head for cache_head in cache_detail,
>>> it is useful of remove an cache_head entry directly from cache_detail.
>>>
>>> v8, using hash list, not head list
>>>
>>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>>
>> Reviewed-by: NeilBrown <neilb@suse.com>
> 
> Thanks, applying this and previous 2 patches.

Thanks, I see them in your tree.
I will not include those 3 patches in the next version.

thanks,
Kinglong Mee

> 
> --b.
> 
>>
>> Thanks,
>> NeilBrown
>>
>>> ---
>>>  include/linux/sunrpc/cache.h |  4 +--
>>>  net/sunrpc/cache.c           | 60 +++++++++++++++++++++++---------------------
>>>  2 files changed, 33 insertions(+), 31 deletions(-)
>>>
>>> diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
>>> index 04ee5a2..03d3b4c 100644
>>> --- a/include/linux/sunrpc/cache.h
>>> +++ b/include/linux/sunrpc/cache.h
>>> @@ -46,7 +46,7 @@
>>>   * 
>>>   */
>>>  struct cache_head {
>>> -	struct cache_head * next;
>>> +	struct hlist_node	cache_list;
>>>  	time_t		expiry_time;	/* After time time, don't use the data */
>>>  	time_t		last_refresh;   /* If CACHE_PENDING, this is when upcall 
>>>  					 * was sent, else this is when update was received
>>> @@ -73,7 +73,7 @@ struct cache_detail_pipefs {
>>>  struct cache_detail {
>>>  	struct module *		owner;
>>>  	int			hash_size;
>>> -	struct cache_head **	hash_table;
>>> +	struct hlist_head *	hash_table;
>>>  	rwlock_t		hash_lock;
>>>  
>>>  	atomic_t		inuse; /* active user-space update or lookup */
>>> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
>>> index 673c2fa..4a2340a 100644
>>> --- a/net/sunrpc/cache.c
>>> +++ b/net/sunrpc/cache.c
>>> @@ -44,7 +44,7 @@ static void cache_revisit_request(struct cache_head *item);
>>>  static void cache_init(struct cache_head *h)
>>>  {
>>>  	time_t now = seconds_since_boot();
>>> -	h->next = NULL;
>>> +	INIT_HLIST_NODE(&h->cache_list);
>>>  	h->flags = 0;
>>>  	kref_init(&h->ref);
>>>  	h->expiry_time = now + CACHE_NEW_EXPIRY;
>>> @@ -54,15 +54,14 @@ static void cache_init(struct cache_head *h)
>>>  struct cache_head *sunrpc_cache_lookup(struct cache_detail *detail,
>>>  				       struct cache_head *key, int hash)
>>>  {
>>> -	struct cache_head **head,  **hp;
>>> -	struct cache_head *new = NULL, *freeme = NULL;
>>> +	struct cache_head *new = NULL, *freeme = NULL, *tmp = NULL;
>>> +	struct hlist_head *head;
>>>  
>>>  	head = &detail->hash_table[hash];
>>>  
>>>  	read_lock(&detail->hash_lock);
>>>  
>>> -	for (hp=head; *hp != NULL ; hp = &(*hp)->next) {
>>> -		struct cache_head *tmp = *hp;
>>> +	hlist_for_each_entry(tmp, head, cache_list) {
>>>  		if (detail->match(tmp, key)) {
>>>  			if (cache_is_expired(detail, tmp))
>>>  				/* This entry is expired, we will discard it. */
>>> @@ -88,12 +87,10 @@ struct cache_head *sunrpc_cache_lookup(struct cache_detail *detail,
>>>  	write_lock(&detail->hash_lock);
>>>  
>>>  	/* check if entry appeared while we slept */
>>> -	for (hp=head; *hp != NULL ; hp = &(*hp)->next) {
>>> -		struct cache_head *tmp = *hp;
>>> +	hlist_for_each_entry(tmp, head, cache_list) {
>>>  		if (detail->match(tmp, key)) {
>>>  			if (cache_is_expired(detail, tmp)) {
>>> -				*hp = tmp->next;
>>> -				tmp->next = NULL;
>>> +				hlist_del_init(&tmp->cache_list);
>>>  				detail->entries --;
>>>  				freeme = tmp;
>>>  				break;
>>> @@ -104,8 +101,8 @@ struct cache_head *sunrpc_cache_lookup(struct cache_detail *detail,
>>>  			return tmp;
>>>  		}
>>>  	}
>>> -	new->next = *head;
>>> -	*head = new;
>>> +
>>> +	hlist_add_head(&new->cache_list, head);
>>>  	detail->entries++;
>>>  	cache_get(new);
>>>  	write_unlock(&detail->hash_lock);
>>> @@ -143,7 +140,6 @@ struct cache_head *sunrpc_cache_update(struct cache_detail *detail,
>>>  	 * If 'old' is not VALID, we update it directly,
>>>  	 * otherwise we need to replace it
>>>  	 */
>>> -	struct cache_head **head;
>>>  	struct cache_head *tmp;
>>>  
>>>  	if (!test_bit(CACHE_VALID, &old->flags)) {
>>> @@ -168,15 +164,13 @@ struct cache_head *sunrpc_cache_update(struct cache_detail *detail,
>>>  	}
>>>  	cache_init(tmp);
>>>  	detail->init(tmp, old);
>>> -	head = &detail->hash_table[hash];
>>>  
>>>  	write_lock(&detail->hash_lock);
>>>  	if (test_bit(CACHE_NEGATIVE, &new->flags))
>>>  		set_bit(CACHE_NEGATIVE, &tmp->flags);
>>>  	else
>>>  		detail->update(tmp, new);
>>> -	tmp->next = *head;
>>> -	*head = tmp;
>>> +	hlist_add_head(&tmp->cache_list, &detail->hash_table[hash]);
>>>  	detail->entries++;
>>>  	cache_get(tmp);
>>>  	cache_fresh_locked(tmp, new->expiry_time);
>>> @@ -416,28 +410,29 @@ static int cache_clean(void)
>>>  	/* find a non-empty bucket in the table */
>>>  	while (current_detail &&
>>>  	       current_index < current_detail->hash_size &&
>>> -	       current_detail->hash_table[current_index] == NULL)
>>> +	       hlist_empty(&current_detail->hash_table[current_index]))
>>>  		current_index++;
>>>  
>>>  	/* find a cleanable entry in the bucket and clean it, or set to next bucket */
>>>  
>>>  	if (current_detail && current_index < current_detail->hash_size) {
>>> -		struct cache_head *ch, **cp;
>>> +		struct cache_head *ch = NULL;
>>>  		struct cache_detail *d;
>>> +		struct hlist_head *head;
>>> +		struct hlist_node *tmp;
>>>  
>>>  		write_lock(&current_detail->hash_lock);
>>>  
>>>  		/* Ok, now to clean this strand */
>>>  
>>> -		cp = & current_detail->hash_table[current_index];
>>> -		for (ch = *cp ; ch ; cp = & ch->next, ch = *cp) {
>>> +		head = &current_detail->hash_table[current_index];
>>> +		hlist_for_each_entry_safe(ch, tmp, head, cache_list) {
>>>  			if (current_detail->nextcheck > ch->expiry_time)
>>>  				current_detail->nextcheck = ch->expiry_time+1;
>>>  			if (!cache_is_expired(current_detail, ch))
>>>  				continue;
>>>  
>>> -			*cp = ch->next;
>>> -			ch->next = NULL;
>>> +			hlist_del_init(&ch->cache_list);
>>>  			current_detail->entries--;
>>>  			rv = 1;
>>>  			break;
>>> @@ -1284,7 +1279,7 @@ void *cache_seq_start(struct seq_file *m, loff_t *pos)
>>>  	hash = n >> 32;
>>>  	entry = n & ((1LL<<32) - 1);
>>>  
>>> -	for (ch=cd->hash_table[hash]; ch; ch=ch->next)
>>> +	hlist_for_each_entry(ch, &cd->hash_table[hash], cache_list)
>>>  		if (!entry--)
>>>  			return ch;
>>>  	n &= ~((1LL<<32) - 1);
>>> @@ -1292,11 +1287,12 @@ void *cache_seq_start(struct seq_file *m, loff_t *pos)
>>>  		hash++;
>>>  		n += 1LL<<32;
>>>  	} while(hash < cd->hash_size &&
>>> -		cd->hash_table[hash]==NULL);
>>> +		hlist_empty(&cd->hash_table[hash]));
>>>  	if (hash >= cd->hash_size)
>>>  		return NULL;
>>>  	*pos = n+1;
>>> -	return cd->hash_table[hash];
>>> +	return hlist_entry_safe(cd->hash_table[hash].first,
>>> +				struct cache_head, cache_list);
>>>  }
>>>  EXPORT_SYMBOL_GPL(cache_seq_start);
>>>  
>>> @@ -1308,23 +1304,25 @@ void *cache_seq_next(struct seq_file *m, void *p, loff_t *pos)
>>>  
>>>  	if (p == SEQ_START_TOKEN)
>>>  		hash = 0;
>>> -	else if (ch->next == NULL) {
>>> +	else if (ch->cache_list.next == NULL) {
>>>  		hash++;
>>>  		*pos += 1LL<<32;
>>>  	} else {
>>>  		++*pos;
>>> -		return ch->next;
>>> +		return hlist_entry_safe(ch->cache_list.next,
>>> +					struct cache_head, cache_list);
>>>  	}
>>>  	*pos &= ~((1LL<<32) - 1);
>>>  	while (hash < cd->hash_size &&
>>> -	       cd->hash_table[hash] == NULL) {
>>> +	       hlist_empty(&cd->hash_table[hash])) {
>>>  		hash++;
>>>  		*pos += 1LL<<32;
>>>  	}
>>>  	if (hash >= cd->hash_size)
>>>  		return NULL;
>>>  	++*pos;
>>> -	return cd->hash_table[hash];
>>> +	return hlist_entry_safe(cd->hash_table[hash].first,
>>> +				struct cache_head, cache_list);
>>>  }
>>>  EXPORT_SYMBOL_GPL(cache_seq_next);
>>>  
>>> @@ -1666,17 +1664,21 @@ EXPORT_SYMBOL_GPL(cache_unregister_net);
>>>  struct cache_detail *cache_create_net(struct cache_detail *tmpl, struct net *net)
>>>  {
>>>  	struct cache_detail *cd;
>>> +	int i;
>>>  
>>>  	cd = kmemdup(tmpl, sizeof(struct cache_detail), GFP_KERNEL);
>>>  	if (cd == NULL)
>>>  		return ERR_PTR(-ENOMEM);
>>>  
>>> -	cd->hash_table = kzalloc(cd->hash_size * sizeof(struct cache_head *),
>>> +	cd->hash_table = kzalloc(cd->hash_size * sizeof(struct hlist_head),
>>>  				 GFP_KERNEL);
>>>  	if (cd->hash_table == NULL) {
>>>  		kfree(cd);
>>>  		return ERR_PTR(-ENOMEM);
>>>  	}
>>> +
>>> +	for (i = 0; i < cd->hash_size; i++)
>>> +		INIT_HLIST_HEAD(&cd->hash_table[i]);
>>>  	cd->net = net;
>>>  	return cd;
>>>  }
> 
