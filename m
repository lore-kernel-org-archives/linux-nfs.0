Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:36183 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934094AbcLTPGY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Dec 2016 10:06:24 -0500
Received: by mail-qk0-f194.google.com with SMTP id h201so3951462qke.3
        for <linux-nfs@vger.kernel.org>; Tue, 20 Dec 2016 07:06:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <87d1gntfq1.fsf@notabene.neil.brown.name>
References: <1482192030-19219-1-git-send-email-andros@netapp.com> <87d1gntfq1.fsf@notabene.neil.brown.name>
From: Andy Adamson <androsadamson@gmail.com>
Date: Tue, 20 Dec 2016 10:06:22 -0500
Message-ID: <CAHVgHyXDDS41EvWxM9imVtQ=Xkqa8GzC9uNaccf492Dj70MOLg@mail.gmail.com>
Subject: Re: [PATCH Version 3] SVCAUTH update the rsc cacue on RPC_GSS_PROC_DESTROY
To: NeilBrown <neilb@suse.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 19, 2016 at 10:57 PM, NeilBrown <neilb@suse.com> wrote:
> On Tue, Dec 20 2016, andros@netapp.com wrote:
>
>> From: Andy Adamson <andros@netapp.com>
>>
>> I instrumented cache_get, cache_put, cache_clean, svcauth_cache_lookup
>> and svcauth_gss_accept.
>>
>> Then I mounted -o sec=krb5, listed the mount directory, and umounted.
>>
>> CASE 1: Here is the instrumented output without the patch:
>>
>> svcauth_gss_accept gc_proc 3 rq_proc 0  (process RPC_GSS_PROC_DESTROY)
>> --> sunrpc_cache_lookup from rsc_lookup key ffffc90002b9bc58 hash 940
>> sunrpc_cache_lookup 1 calling cache_get key ffffc90002b9bc58 tmp
>> ffff880079b3f500
>> --> cache_get h ffff880079b3f500 refcount 1
>> sunrpc_cache_lookup RETURN 1  key ffffc90002b9bc58 tmp ffff880079b3f500
>> --> rsc_free h ffffc90002b9bc58
>>
>> &rsci->h is ffff880079b3f500, which identifies the cache entry we want
>> destroyed.
>>
>> Case: RPC_GSS_PROC_DESTROY:
>> svcauth_gss_accept RPC_GSS_PROC_DESTROY h ffff880079b3f500 ref 2
>> expiry 1481823331 <<<<<
>> svcauth_gss_accept AFTER SETTING h ffff880079b3f500 expiry 1481819736   <<<<<<<
>>
>> Note: expiry_time (and CACHE_NEGATIVE) are set.
>>
>> END of svcauth_gss_accept:
>> svcauth_gss_accept END calling cache_put h ffff880079b3f500
>> --> cache_put h ffff880079b3f500 refcount 2 cd->cache_put ffffffffa045c180
>> Dec 15 11:35:36 rhel7-2-ga-2 kernel: <-- cache_put h ffff880079b3f500 refcount 1
>>
>> refcount is 1, but cache_clean is not setup to reap the entry as
>> rsc_update was not called.
>
> What exactly do you mean by "cache_clean is not setup to reap the entry"?
>
> I think the problem is that detail->flush_time hasn't been updated to
> match the new (reduced) ->expiry_time.  If that is what you meant by the
> above, I completely agree.

Here is the code that prevents cache_clean from reaping the entry:

cache_clean:

               hlist_for_each_entry_safe(ch, tmp, head, cache_list) {
                        if (current_detail->nextcheck > ch->expiry_time)
                                current_detail->nextcheck = ch->expiry_time+1;
                        if (!cache_is_expired(current_detail, ch))
                                continue;
<<<<<<<<<<<<<<<<<<<<<<<<<<<<< does not make it past this continue.

                        hlist_del_init(&ch->cache_list);
                        current_detail->entries--;
                        rv = 1;
                        break;

                }


static inline int cache_is_expired(struct cache_detail *detail, struct
cache_head *h)
{
        return  (h->expiry_time < seconds_since_boot()) ||
                (detail->flush_time >= h->last_refresh);
}

so either setting the expiry_time < seconds_since_boot or ensuring
that the flush_time is greater than the last_refresh is what I mean.
The current code does neither, and so the rsc entry is _never_ reaped.

>
>
>>                             Besides using the write_lock (which should
>> be used for entry changes) rsc_update also sets other fields to
>> trigger cache_clean to remove the entry from the cache_list under
>> the write_lock and do a final cache_put.
>
> The write_lock is needed for some changes, but not necessarily all.
> e.g. just clearing a bit is already atomic, so doesn't need a lock.
> Decreasing ->flush_time to match a new ->expiry_time does need the lock
> as it needs to be atomic.


And as I pointed out above, the write_lock is needed to remove the
cache entry from the cache_list.

Note that if a cache_put is called with an input refcount of 1 and so
calls rsc_put/rsc_free without first removing the entry from the
cache_list, the next time cache_clean walks the list, it encounters
the hole left by the freed entry and produces a kernel oops. So either
we

1) set it up so that the cache_is_expired() test passes and the refcount is 1
or
2) take the write_lock in rsc_put, and delete the entry from the
cache_list prior to freeing the entry.

This patch chooses #1.

I'm confused as to why the architecture is not clear.  Why is it not
obvious, or well documented, as to what needs to be called to expire
an entry?

-->Andy

>
> I'll comment on the patch separately.
>
> Thanks,
> NeilBrown
