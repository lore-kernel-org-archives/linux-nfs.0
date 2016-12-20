Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:60642 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752020AbcLTVHH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Dec 2016 16:07:07 -0500
From: NeilBrown <neilb@suse.com>
To: Andy Adamson <androsadamson@gmail.com>
Date: Wed, 21 Dec 2016 08:06:56 +1100
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH Version 3] SVCAUTH update the rsc cache on RPC_GSS_PROC_DESTROY
In-Reply-To: <CAHVgHyWmi_jJgVS2aord3-+E9QYhcTc8XgLqOYh3UmwikUexrg@mail.gmail.com>
References: <1482192030-19219-1-git-send-email-andros@netapp.com> <1482192030-19219-2-git-send-email-andros@netapp.com> <87a8brtff9.fsf@notabene.neil.brown.name> <CAHVgHyWmi_jJgVS2aord3-+E9QYhcTc8XgLqOYh3UmwikUexrg@mail.gmail.com>
Message-ID: <877f6utimn.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Wed, Dec 21 2016, Andy Adamson wrote:

> On Mon, Dec 19, 2016 at 11:03 PM, NeilBrown <neilb@suse.com> wrote:
>> On Tue, Dec 20 2016, andros@netapp.com wrote:
>>
>>> From: Andy Adamson <andros@netapp.com>
>>>
>>> The rsc cache code operates in a read_lock/write_lock environment.
>>> Changes to a cache entry should use the provided rsc_update
>>> routine which takes the write_lock.
>>>
>>> The current code sets the expiry_time and the CACHE_NEGATIVE flag
>>> without taking the write_lock as it does not call rsc_update.
>>> Without this patch, while cache_clean sees the entries to be
>>> removed, it does not remove the rsc_entries. This is because
>>> rsc_update sets other fields in the entry to properly trigger
>>> cache_clean.
>>>
>>> Cache_clean takes the write_lock to remove expired or invalid
>>> entries from the cache_list and calls cache_put on the entry.
>>>
>>> Looking at sunrpc_cache_update, what we want is to invalidate the
>>> cache entry, so that it is direclty replaced which means that
>>> update_rsc is called. We pass in a new zero'ed rsc cache entry
>>> to rsc_update with an expiry_time set to 0 along with the
>>> invalidatedcache entry to be destroyed.
>>>
>>> The cache_put at the end of svcauth_gss_accept processing drops
>>> the reference count to 1 which allows the cache_put called by
>>> cache_clean to result in a call to rsc_put and rsc_free
>>> to reap the entry after it has been removed from the cache_list
>>> under the write_lock.
>>>
>>> Signed-off-by: Andy Adamson <andros@netapp.com>
>>> ---
>>>  net/sunrpc/auth_gss/svcauth_gss.c | 18 +++++++++++++++---
>>>  1 file changed, 15 insertions(+), 3 deletions(-)
>>>
>>> diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
>>> index 45662d7..b8093da 100644
>>> --- a/net/sunrpc/auth_gss/svcauth_gss.c
>>> +++ b/net/sunrpc/auth_gss/svcauth_gss.c
>>> @@ -1409,7 +1409,9 @@ static void destroy_use_gss_proxy_proc_entry(struct net *net) {}
>>>       u32             crlen;
>>>       struct gss_svc_data *svcdata = rqstp->rq_auth_data;
>>>       struct rpc_gss_wire_cred *gc;
>>> -     struct rsc      *rsci = NULL;
>>> +     struct rsc      *rsci = NULL, new = {
>>> +             .mechctx = 0,
>>> +     };
>>>       __be32          *rpcstart;
>>>       __be32          *reject_stat = resv->iov_base + resv->iov_len;
>>>       int             ret;
>>> @@ -1489,10 +1491,20 @@ static void destroy_use_gss_proxy_proc_entry(struct net *net) {}
>>>       case RPC_GSS_PROC_DESTROY:
>>>               if (gss_write_verf(rqstp, rsci->mechctx, gc->gc_seq))
>>>                       goto auth_err;
>>> -             rsci->h.expiry_time = get_seconds();
>>> -             set_bit(CACHE_NEGATIVE, &rsci->h.flags);
>>> +
>>> +             /** Invalidate the cache entry so sunrpc_update_cache
>>> +              * direclty updates rsci. new->h.expiry_time is zero,
>>> +              * so rsci->h.expiry_time will be set to zero and
>>> +              * cache_clean will properly remove rsci.
>>> +              */
>>> +             clear_bit(CACHE_VALID, &rsci->h.flags);
>>
>> I think this is poor form.  It might work in this particular case, but
>> in general, clearing CACHE_VALID is the wrong thing to do.
>
> Why? That is exactly what an RPC_GSS_PROC_DESTROY message means - the
> GSS context is invalid and needs be immediately destroyed.

But that isn't what CACHE_VALID means.
If a cache item doesn't have CACHE_VALID set, then it represents
a question that hasn't been answered.
When it is answered, CACHE_VALID is set, and either CACHE_NEGATIVE is
set, or the 'content' fields are filled in.
In general, the .cache_put doesn't free the 'content' fields unless
CACHE_VALID is set, and CACHE_NEGATIVE is clear.  Consequently setting
or clearing these fields needs to be paired with setting or freeing the
content.
auth_gss doesn't make that distinction and sets or frees everything
together so just clearing the flag would probably work.  On other
caches it wouldn't, so I'd rather not see it done at all.

>
> What other mechanism does your cache design provide for this very
> common AUTH_GSS case?

There is none.  No other cache requires entries to be individually
deleted.
That is why I suggested that we could add sunrpc_cache_unhash().

>
>>
>> What is the goal here?  Do we want to make sure future lookups for this
>> entry find a negative entry, or would we be happy for them to fail?
>
> No future lookups. No future use. Destroyed. Immediately, and all
> resources freed.

In that case, sunrpc_cache_unhash() sounds like something we should do.

void sunrpc_cache_unhash(struct cache_detail *cd, struct cache_head *h)
{
	write_lock(&detail->hash_lock);
	if (!hlist_unhashed(&h->cache_list)) {
		hlist_del_init(&h->cache_list);
		cd->entries--;
		write_unlock(&detail->hash_lock);
		cache_put(h, cd);
	} else
		write_unlock(&detail->hash_lock);
}

Can you confirm that this does what you need?

Thanks,
NeilBrown

>
> Clearing the CACHE_VALID flag and not setting the CACHE_NEGATIVE flag
> on the does this by updating the entry with a new entry that has a
> zero expiry_time.
>
> sunrpc_cache_update (called by rsc_update)
>        /* The 'old' entry is to be replaced by 'new'.
>          * If 'old' is not VALID, we update it directly,
>          * otherwise we need to replace it
>          */
>
>         struct cache_head *tmp;
>
>         if (!test_bit(CACHE_VALID, &old->flags)) {
>                 write_lock(&detail->hash_lock);
>                 if (!test_bit(CACHE_VALID, &old->flags)) {
>                         if (test_bit(CACHE_NEGATIVE, &new->flags))
>                                 set_bit(CACHE_NEGATIVE, &old->flags);
>                         else
>                                 detail->update(old, new);
> <<<<<<<<<<<<<<<<<<<< goal is to hit this.
>                         cache_fresh_locked(old, new->expiry_time, detail);
>                         write_unlock(&detail->hash_lock);
>                         cache_fresh_unlocked(old, detail);
>                         return old;
>
>                 }
>                 write_unlock(&detail->hash_lock);
>         }
>
> This also leaves the refcount alone so that at the end of
> svcauth_gss_processing, the refcount is 1 and cache_clean can properly
> reap the entry.
>
> --Andy
>
>>
>> If they should find a negative entry, then just do the update without
>> messing with the CACHE_VALID flag.  It will require an allocation, but
>> that shouldn't be a big cost.
>>
>> If you are happy for them to find nothing, the we should write a
>> sunrpc_cache_unhash() or similar which unlinks an entry from the cache
>> and decrements its refcount.
>>
>> NeilBrown
>>
>>
>>> +             rsci = rsc_update(sn->rsc_cache, &new, rsci);
>>> +             if (!rsci)
>>> +                     goto drop;
>>> +
>>>               if (resv->iov_len + 4 > PAGE_SIZE)
>>>                       goto drop;
>>> +
>>>               svc_putnl(resv, RPC_SUCCESS);
>>>               goto complete;
>>>       case RPC_GSS_PROC_DATA:
>>> --
>>> 1.8.3.1

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlhZnXAACgkQOeye3VZi
gbmHWxAAiFz2WwGUo0FuY+miTuzRsi3V5V0I+Ent+QX5IvSgcUNyRQ5dxzmJZRik
C/5o6feHn21c4n4UB0NonVvxkJPdTxqvIGEv10n7A+d2sIp815Wrc16KDjrzkOy7
euLFWPz1wznN4SEBoyK3yi0yDNbbzrdzMygI/+lwlv1D790vNiahQ0GXIW/NCvvc
WgwiW9oXf2wVo/bT1tbTPtsPx4mdn552oVqrwbbLyYEdFI4GPjwQzPLJqltW2m77
vwipps6qBPzZssqyV9u8X24+mNshMi0tCol7XnnFnAqzqEeANZfM3RDl43M5APfl
OYJCMmoBSkrw007BVu3Ld35WqM7HlNTQJlrP0xvA1urwB1+z6NStQ2CUqbXrT/qZ
kiyRN/m36fcI2rf8QKY7nyg/8fK9NrQMcIkXH/s2iPWnHS4818TJ/DjUAtrbVopM
Tt/9CuVU+HMMMBGkhGvsno29ckUyWGPy5ktBxGmXrbTaLSHlr9W+MIgiOMHKDFTc
13SZcYqagpgjzGXxT+YgIb43CQDfk152VryWU1rvwzVHG9qZtOGuOFhSicn+SH7z
7iRlAnHltuf3RMYiyG/Jvi66LPAqULePRfU3c6HYyeuQA35aA+WdHghwHHJ3+uLq
DgnbscEMEayMHT6UJB8nXWkxe7NH1tGhWKd2W7NKdtxnIWezXcc=
=e+bp
-----END PGP SIGNATURE-----
--=-=-=--
