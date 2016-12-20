Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:36709 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1762151AbcLTP0H (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Dec 2016 10:26:07 -0500
Received: by mail-qk0-f196.google.com with SMTP id h201so4033203qke.3
        for <linux-nfs@vger.kernel.org>; Tue, 20 Dec 2016 07:26:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <87a8brtff9.fsf@notabene.neil.brown.name>
References: <1482192030-19219-1-git-send-email-andros@netapp.com>
 <1482192030-19219-2-git-send-email-andros@netapp.com> <87a8brtff9.fsf@notabene.neil.brown.name>
From: Andy Adamson <androsadamson@gmail.com>
Date: Tue, 20 Dec 2016 10:26:05 -0500
Message-ID: <CAHVgHyWmi_jJgVS2aord3-+E9QYhcTc8XgLqOYh3UmwikUexrg@mail.gmail.com>
Subject: Re: [PATCH Version 3] SVCAUTH update the rsc cache on RPC_GSS_PROC_DESTROY
To: NeilBrown <neilb@suse.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 19, 2016 at 11:03 PM, NeilBrown <neilb@suse.com> wrote:
> On Tue, Dec 20 2016, andros@netapp.com wrote:
>
>> From: Andy Adamson <andros@netapp.com>
>>
>> The rsc cache code operates in a read_lock/write_lock environment.
>> Changes to a cache entry should use the provided rsc_update
>> routine which takes the write_lock.
>>
>> The current code sets the expiry_time and the CACHE_NEGATIVE flag
>> without taking the write_lock as it does not call rsc_update.
>> Without this patch, while cache_clean sees the entries to be
>> removed, it does not remove the rsc_entries. This is because
>> rsc_update sets other fields in the entry to properly trigger
>> cache_clean.
>>
>> Cache_clean takes the write_lock to remove expired or invalid
>> entries from the cache_list and calls cache_put on the entry.
>>
>> Looking at sunrpc_cache_update, what we want is to invalidate the
>> cache entry, so that it is direclty replaced which means that
>> update_rsc is called. We pass in a new zero'ed rsc cache entry
>> to rsc_update with an expiry_time set to 0 along with the
>> invalidatedcache entry to be destroyed.
>>
>> The cache_put at the end of svcauth_gss_accept processing drops
>> the reference count to 1 which allows the cache_put called by
>> cache_clean to result in a call to rsc_put and rsc_free
>> to reap the entry after it has been removed from the cache_list
>> under the write_lock.
>>
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>>  net/sunrpc/auth_gss/svcauth_gss.c | 18 +++++++++++++++---
>>  1 file changed, 15 insertions(+), 3 deletions(-)
>>
>> diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
>> index 45662d7..b8093da 100644
>> --- a/net/sunrpc/auth_gss/svcauth_gss.c
>> +++ b/net/sunrpc/auth_gss/svcauth_gss.c
>> @@ -1409,7 +1409,9 @@ static void destroy_use_gss_proxy_proc_entry(struct net *net) {}
>>       u32             crlen;
>>       struct gss_svc_data *svcdata = rqstp->rq_auth_data;
>>       struct rpc_gss_wire_cred *gc;
>> -     struct rsc      *rsci = NULL;
>> +     struct rsc      *rsci = NULL, new = {
>> +             .mechctx = 0,
>> +     };
>>       __be32          *rpcstart;
>>       __be32          *reject_stat = resv->iov_base + resv->iov_len;
>>       int             ret;
>> @@ -1489,10 +1491,20 @@ static void destroy_use_gss_proxy_proc_entry(struct net *net) {}
>>       case RPC_GSS_PROC_DESTROY:
>>               if (gss_write_verf(rqstp, rsci->mechctx, gc->gc_seq))
>>                       goto auth_err;
>> -             rsci->h.expiry_time = get_seconds();
>> -             set_bit(CACHE_NEGATIVE, &rsci->h.flags);
>> +
>> +             /** Invalidate the cache entry so sunrpc_update_cache
>> +              * direclty updates rsci. new->h.expiry_time is zero,
>> +              * so rsci->h.expiry_time will be set to zero and
>> +              * cache_clean will properly remove rsci.
>> +              */
>> +             clear_bit(CACHE_VALID, &rsci->h.flags);
>
> I think this is poor form.  It might work in this particular case, but
> in general, clearing CACHE_VALID is the wrong thing to do.

Why? That is exactly what an RPC_GSS_PROC_DESTROY message means - the
GSS context is invalid and needs be immediately destroyed.

What other mechanism does your cache design provide for this very
common AUTH_GSS case?

>
> What is the goal here?  Do we want to make sure future lookups for this
> entry find a negative entry, or would we be happy for them to fail?

No future lookups. No future use. Destroyed. Immediately, and all
resources freed.

Clearing the CACHE_VALID flag and not setting the CACHE_NEGATIVE flag
on the does this by updating the entry with a new entry that has a
zero expiry_time.

sunrpc_cache_update (called by rsc_update)
       /* The 'old' entry is to be replaced by 'new'.
         * If 'old' is not VALID, we update it directly,
         * otherwise we need to replace it
         */

        struct cache_head *tmp;

        if (!test_bit(CACHE_VALID, &old->flags)) {
                write_lock(&detail->hash_lock);
                if (!test_bit(CACHE_VALID, &old->flags)) {
                        if (test_bit(CACHE_NEGATIVE, &new->flags))
                                set_bit(CACHE_NEGATIVE, &old->flags);
                        else
                                detail->update(old, new);
<<<<<<<<<<<<<<<<<<<< goal is to hit this.
                        cache_fresh_locked(old, new->expiry_time, detail);
                        write_unlock(&detail->hash_lock);
                        cache_fresh_unlocked(old, detail);
                        return old;

                }
                write_unlock(&detail->hash_lock);
        }

This also leaves the refcount alone so that at the end of
svcauth_gss_processing, the refcount is 1 and cache_clean can properly
reap the entry.

--Andy

>
> If they should find a negative entry, then just do the update without
> messing with the CACHE_VALID flag.  It will require an allocation, but
> that shouldn't be a big cost.
>
> If you are happy for them to find nothing, the we should write a
> sunrpc_cache_unhash() or similar which unlinks an entry from the cache
> and decrements its refcount.
>
> NeilBrown
>
>
>> +             rsci = rsc_update(sn->rsc_cache, &new, rsci);
>> +             if (!rsci)
>> +                     goto drop;
>> +
>>               if (resv->iov_len + 4 > PAGE_SIZE)
>>                       goto drop;
>> +
>>               svc_putnl(resv, RPC_SUCCESS);
>>               goto complete;
>>       case RPC_GSS_PROC_DATA:
>> --
>> 1.8.3.1
