Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f170.google.com ([209.85.220.170]:47032 "EHLO
	mail-vc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753179AbaGUWdL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jul 2014 18:33:11 -0400
Received: by mail-vc0-f170.google.com with SMTP id lf12so13356829vcb.29
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jul 2014 15:33:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140721210905.GK8438@fieldses.org>
References: <1405969902-11477-1-git-send-email-trond.myklebust@primarydata.com>
	<20140721210905.GK8438@fieldses.org>
Date: Mon, 21 Jul 2014 18:33:10 -0400
Message-ID: <CAHQdGtTLO0w-wwLtvcuK0_jk9vM5as3NvPuLnBTDqXhprZvSDw@mail.gmail.com>
Subject: Re: [PATCH 1/2] SUNRPC: Enforce an upper limit on the number of
 cached credentials
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 21, 2014 at 5:09 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Mon, Jul 21, 2014 at 03:11:41PM -0400, Trond Myklebust wrote:
>> In some cases where the credentials are not often reused, we may want
>> to limit their total number just in order to make the negative lookups
>> in the hash table more manageable.
>
> Out of curiosity--how would somebody know that might need to set this?

It would have to be for very unusual workloads (which is why we
haven't done it before). Something like a web-server that creates
uids/gids on the fly, uses them for a few transactions and then
doesn't need to use them again for a long while. You would need to use
something like 'perf' or a similar profiler to show you are spending a
lot of time in the rpc_auth lookup code.
Note that we do have the ability already to change the hash table size
to mitigate the above problem, but if the workload really is using
throw-away uid/gids, then this is going to work better.

Cheers
  Trond

> --b.
>
>>
>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>> ---
>>  net/sunrpc/auth.c | 44 +++++++++++++++++++++++++++++++++++---------
>>  1 file changed, 35 insertions(+), 9 deletions(-)
>>
>> diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
>> index 2bc7bb82b162..360decdddc78 100644
>> --- a/net/sunrpc/auth.c
>> +++ b/net/sunrpc/auth.c
>> @@ -80,6 +80,10 @@ static struct kernel_param_ops param_ops_hashtbl_sz = {
>>  module_param_named(auth_hashtable_size, auth_hashbits, hashtbl_sz, 0644);
>>  MODULE_PARM_DESC(auth_hashtable_size, "RPC credential cache hashtable size");
>>
>> +static unsigned long auth_max_cred_cachesize = ULONG_MAX;
>> +module_param(auth_max_cred_cachesize, ulong, 0644);
>> +MODULE_PARM_DESC(auth_max_cred_cachesize, "RPC credential maximum total cache size");
>> +
>>  static u32
>>  pseudoflavor_to_flavor(u32 flavor) {
>>       if (flavor > RPC_AUTH_MAXFLAVOR)
>> @@ -481,6 +485,20 @@ rpcauth_prune_expired(struct list_head *free, int nr_to_scan)
>>       return freed;
>>  }
>>
>> +static unsigned long
>> +rpcauth_cache_do_shrink(int nr_to_scan)
>> +{
>> +     LIST_HEAD(free);
>> +     unsigned long freed;
>> +
>> +     spin_lock(&rpc_credcache_lock);
>> +     freed = rpcauth_prune_expired(&free, nr_to_scan);
>> +     spin_unlock(&rpc_credcache_lock);
>> +     rpcauth_destroy_credlist(&free);
>> +
>> +     return freed;
>> +}
>> +
>>  /*
>>   * Run memory cache shrinker.
>>   */
>> @@ -488,9 +506,6 @@ static unsigned long
>>  rpcauth_cache_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
>>
>>  {
>> -     LIST_HEAD(free);
>> -     unsigned long freed;
>> -
>>       if ((sc->gfp_mask & GFP_KERNEL) != GFP_KERNEL)
>>               return SHRINK_STOP;
>>
>> @@ -498,12 +513,7 @@ rpcauth_cache_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
>>       if (list_empty(&cred_unused))
>>               return SHRINK_STOP;
>>
>> -     spin_lock(&rpc_credcache_lock);
>> -     freed = rpcauth_prune_expired(&free, sc->nr_to_scan);
>> -     spin_unlock(&rpc_credcache_lock);
>> -     rpcauth_destroy_credlist(&free);
>> -
>> -     return freed;
>> +     return rpcauth_cache_do_shrink(sc->nr_to_scan);
>>  }
>>
>>  static unsigned long
>> @@ -513,6 +523,21 @@ rpcauth_cache_shrink_count(struct shrinker *shrink, struct shrink_control *sc)
>>       return (number_cred_unused / 100) * sysctl_vfs_cache_pressure;
>>  }
>>
>> +static void
>> +rpcauth_cache_enforce_limit(void)
>> +{
>> +     unsigned long diff;
>> +     unsigned int nr_to_scan;
>> +
>> +     if (number_cred_unused <= auth_max_cred_cachesize)
>> +             return;
>> +     diff = number_cred_unused - auth_max_cred_cachesize;
>> +     nr_to_scan = 100;
>> +     if (diff < nr_to_scan)
>> +             nr_to_scan = diff;
>> +     rpcauth_cache_do_shrink(nr_to_scan);
>> +}
>> +
>>  /*
>>   * Look up a process' credentials in the authentication cache
>>   */
>> @@ -566,6 +591,7 @@ rpcauth_lookup_credcache(struct rpc_auth *auth, struct auth_cred * acred,
>>       } else
>>               list_add_tail(&new->cr_lru, &free);
>>       spin_unlock(&cache->lock);
>> +     rpcauth_cache_enforce_limit();
>>  found:
>>       if (test_bit(RPCAUTH_CRED_NEW, &cred->cr_flags) &&
>>           cred->cr_ops->cr_init != NULL &&
>> --
>> 1.9.3
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
