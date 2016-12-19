Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:33307 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754342AbcLSQan (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Dec 2016 11:30:43 -0500
Received: by mail-qk0-f194.google.com with SMTP id n21so716026qka.0
        for <linux-nfs@vger.kernel.org>; Mon, 19 Dec 2016 08:30:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAHVgHyXz+HCwC7GZjn70G4FvtE2Tr_6NXnUakF6ySLioyLP8VQ@mail.gmail.com>
References: <1481562529-4488-1-git-send-email-andros@netapp.com>
 <20161212215804.GB6002@fieldses.org> <4608493E-D422-437C-B7B8-D2E74E4F75CE@netapp.com>
 <20161213160029.GB19985@fieldses.org> <CAHVgHyX+0SpOf5JXz57P=5W9OC9ESnCghj3EHngUB4X84ASoNA@mail.gmail.com>
 <20161214210427.GC2212@fieldses.org> <CAHVgHyXz+HCwC7GZjn70G4FvtE2Tr_6NXnUakF6ySLioyLP8VQ@mail.gmail.com>
From: Andy Adamson <androsadamson@gmail.com>
Date: Mon, 19 Dec 2016 11:30:40 -0500
Message-ID: <CAHVgHyXDjjRxW=dh0eDOJzHL6Ms+fxR1hxs_ap3oPh6sQLYjrQ@mail.gmail.com>
Subject: Re: [PATCH Version 2] SVCAUTH update the rsc cache on RPC_GSS_PROC_DESTROY
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Oh - and all I do to reproduce this is:

mount -o sec=3Dkrb <server>:<export>

then ls the mountpoint, and umount.

-->Andy

On Mon, Dec 19, 2016 at 11:19 AM, Andy Adamson <androsadamson@gmail.com> wr=
ote:
> On Wed, Dec 14, 2016 at 4:04 PM, J. Bruce Fields <bfields@fieldses.org> w=
rote:
>> On Tue, Dec 13, 2016 at 11:36:11AM -0500, Andy Adamson wrote:
>>> On Tue, Dec 13, 2016 at 11:00 AM, J. Bruce Fields <bfields@fieldses.org=
> wrote:
>>> > On Mon, Dec 12, 2016 at 10:54:33PM +0000, Adamson, Andy wrote:
>>> >> The bug is setting new values on an rsc cache entry without calling
>>> >> rsc_update. When you do this, the =E2=80=9Clocal copy=E2=80=9D of th=
e rsc cache entry
>>> >> (e.g. the one returned by gss_svc_searchbyctx ) gets the new values
>>> >> (expiry_time and CACHE_NEGATIVE bit set) but the new values are not
>>> >> propagated back to the cache.
>>> >
>>> > gss_svc_searchbyctx:
>>> >
>>> >         found =3D rsc_lookup(cd, &rsci);
>>> >         ...
>>> >         return found;
>>> >
>>> > rsc_lookup:
>>> >
>>> >         ch =3D sunrpc_cache_lookup(cd, &item->h, hash);
>>> >         if (ch)
>>> >                 return container_of(ch, struct rsc, h);
>>> >
>>> > sunrpc_cache_lookup:
>>> >
>>> >         head =3D &detail->hash_table[hash];
>>> >         ...
>>> >         hlist_for_each_entry(tmp, head, cache_list) {
>>> >                 ...
>>> >                 return tmp;
>>> >
>>> > Definitely looks to me like it's returning a cache entry, not a copy.
>>>
>>> Thats right. What I call a "local copy". Guess that is wrong. I should
>>> say that sunrpc_cache_lookup returns a cache entry under the
>>> read_lock() and so writing that cache entry does not save the changes.
>>
>> Writes still happen normally, there's just the hypothetical possibility
>> of races if two processes are writing at the same time.  (Don't know if
>> that's a risk here, I haven't thought it through.)
>
> Why have a read_lock/write_lock architecture and then not follow it?
> It seems to me that the hypothetical possibility equals a bug.
>
>>
>> Maybe it would be easiest for me to understand if you could start with a
>> description of your reproducer?  What do you do, and what results do you
>> see?
>
> Sure. I'm coding the GSSv3 Full Mode labeling prototype, where I add
> more bookkeeping to the rsc cache which needs to be freed. So I
> instrumented rsc_put calling rsc_free to ensure that my additions were
> being freed correctly. Then I found that rsc_put was not called. I am
> assuming that the reason for setting the expiry_time to get_seconds()
> and setting the CACHE_NEGATIVE bit is to destroy the context. But it
> was not happening.
>
> So I instrumented cache_get, cache_put, cache_clean,
> svcauth_cache_lookup, cache_check. I also instrumented all other users
> of the sunrpc cache put routines to see what they do.
>
> Here is a long log of the current code with printk output. At the end
> I have comments. Then a shorter log of the patched coded with printk
> output and some final comments.
>
> -----------   Current Code Behavior -------
>
> Case 1) Current code with writing rsci not using the write_lock:
>
>
>         case RPC_GSS_PROC_DESTROY:
>                 printk("%s RPC_GSS_PROC_DESTROY h %p ref %d expiry %lu\n"=
,
>                         __func__, &rsci->h, atomic_read(&rsci->h.ref.refc=
ount),
>                         rsci->h.expiry_time);
>                 if (gss_write_verf(rqstp, rsci->mechctx, gc->gc_seq))
>                         goto auth_err;
>
>                 rsci->h.expiry_time =3D get_seconds();
>                 set_bit(CACHE_NEGATIVE, &rsci->h.flags);
>
>                 printk("%s AFTER SETTING h %p expiry %lu\n\n", __func__,
>                         &rsci->h, rsci->h.expiry_time);
>
>                 if (resv->iov_len + 4 > PAGE_SIZE)
>                         goto drop;
>
>                 svc_putnl(resv, RPC_SUCCESS);
>                 goto complete;
>
>         case RPC_GSS_PROC_DATA:
>
>
>
>
> svcauth_gss_accept gc_proc 3 rq_proc 0    (one of two
> RPC_GSS_PROC_DESTROY requests)
>
>  --> sunrpc_cache_lookup from rsc_lookup key ffffc90002b9bc58 hash 940
> Note: hash 940. Lookup is from gss_write_verf.
>
> sunrpc_cache_lookup 1 calling cache_get key ffffc90002b9bc58 tmp
> ffff880079b3f500
> --> cache_get h ffff880079b3f500 refcount 1
> Note: refcount is one before cache get, so ends up as 2.
>
> sunrpc_cache_lookup RETURN 1  key ffffc90002b9bc58 tmp ffff880079b3f500
> --> rsc_free h ffffc90002b9bc58
> Note: the above rsc_free is for the temporary entry created by
> sunrpc_cache_lookup
>
> cache_check h ffff880079b3f500 rv 0 h->expiry_time 1481823331
> cache_check rqstp NULL rv 0 h ffff880079b3f500
> <-- cache_check returns 0 h ffff880079b3f500
>
> svcauth_gss_accept RPC_GSS_PROC_DESTROY h ffff880079b3f500 ref 2
> expiry 1481823331 <<<<<
> svcauth_gss_accept AFTER SETTING h ffff880079b3f500 expiry 1481819736   <=
<<<<<<
>
> Note: expiry_time (and CACHE_NEGATIVE) are set.
>
> svcauth_gss_accept calling cache_put h ffff880079b3f500
> --> cache_put h ffff880079b3f500 refcount 2 cd->cache_put ffffffffa045c18=
0
> Dec 15 11:35:36 rhel7-2-ga-2 kernel: <-- cache_put h ffff880079b3f500 ref=
count 1
>
> Note: this is the cache_put at the end of svcauth_gss_accept.
>
> Dec 15 11:53:21 rhel7-2-ga-2 kernel: cache_clean CLEAN h
> ffff880079b3f500 h->expiry_time 1481819736 hash 940
> Dec 15 11:53:21 rhel7-2-ga-2 kernel: cache_clean CLEAN h
> ffff880079b3e540 h->expiry_time 1481819736 hash 982
>
> Note: The first cache_clean ran approximately 18 minutes later and
> shows the two RPC_GSS_PROC_DESTROY'ed rsc entries with the reset
> expiry_time, but does not call cache_put.
>
> ....
>
> Dec 15 12:00:33 rhel7-2-ga-2 kernel: cache_clean CLEAN h
> ffff88002666dc80 h->expiry_time 665664692 hash 189
> Dec 15 12:00:33 rhel7-2-ga-2 kernel: cache_clean CLEAN h
> ffff880075e4aa00 h->expiry_time 665664692 hash 210
> Dec 15 12:00:33 rhel7-2-ga-2 kernel: cache_clean CLEAN h
> ffff880077995660 h->expiry_time 2576 hash 165
>
> Note: The second cache_clean comes approximately 8 minutes later.
> Still no cach_put on the rsc entries.
>
> ....
>
>
> Dec 15 12:05:38 rhel7-2-ga-2 kernel: cache_clean CLEAN h
> ffff880076fcd700 h->expiry_time 2576 hash 18
> Dec 15 12:05:38 rhel7-2-ga-2 kernel: cache_clean DELETE h
> ffff880076fcd700 from cache_list
> Dec 15 12:05:38 rhel7-2-ga-2 kernel: cache_clean CLEANED calling
> cache_put h ffff880076fcd700
> Dec 15 12:05:38 rhel7-2-ga-2 kernel: --> cache_put h ffff880076fcd700
> refcount 1 cd->cache_put ffffffffa03f3690
> Dec 15 12:05:38 rhel7-2-ga-2 kernel: cache_put h ffff880076fcd700
> expiry_time 2576 nextcheck 2576
> Dec 15 12:05:38 rhel7-2-ga-2 kernel: svc_export_put PUT h ffff880076fcd70=
0
> Dec 15 12:05:38 rhel7-2-ga-2 kernel: <-- cache_put h ffff880076fcd700 ref=
count 0
>
> Note: approximately 5 minutes later svc_export_put is called by cache_cle=
an
>
> Dec 15 12:05:38 rhel7-2-ga-2 kernel: cache_clean CLEAN h
> ffff880076fcf400 h->expiry_time 2576 hash 78
> Dec 15 12:05:38 rhel7-2-ga-2 kernel: cache_clean DELETE h
> ffff880076fcf400 from cache_list
> Dec 15 12:05:38 rhel7-2-ga-2 kernel: cache_clean CLEANED calling
> cache_put h ffff880076fcf400
> Dec 15 12:05:38 rhel7-2-ga-2 kernel: --> cache_put h ffff880076fcf400
> refcount 1 cd->cache_put ffffffffa03f3690
> Dec 15 12:05:38 rhel7-2-ga-2 kernel: svc_export_put PUT h ffff880076fcf40=
0
> Dec 15 12:05:38 rhel7-2-ga-2 kernel: <-- cache_put h ffff880076fcf400 ref=
count 0
>
> Note: another svc_export_put being called:
>
> Dec 15 12:05:38 rhel7-2-ga-2 kernel: cache_clean CLEAN h
> ffff880077995660 h->expiry_time 2576 hash 165
> Dec 15 12:05:38 rhel7-2-ga-2 kernel: cache_clean DELETE h
> ffff880077995660 from cache_list
> Dec 15 12:05:38 rhel7-2-ga-2 kernel: cache_clean CLEANED calling
> cache_put h ffff880077995660
> Dec 15 12:05:38 rhel7-2-ga-2 kernel: --> cache_put h ffff880077995660
> refcount 1 cd->cache_put ffffffffa0390ff0
> Dec 15 12:05:38 rhel7-2-ga-2 kernel: cache_put h ffff880077995660
> expiry_time 2576 nextcheck 2576
> Dec 15 12:05:38 rhel7-2-ga-2 kernel: ip_map_put PUT h ffff880077995660
> Dec 15 12:05:38 rhel7-2-ga-2 kernel: <-- cache_put h ffff880077995660 ref=
count 0
>
> Note: And ip_map_put is called.
>
> Still no rsc_put.
>
> shut down NFSD:
>
>
> Dec 15 12:16:12 rhel7-2-ga-2 kernel: cache_clean CLEAN h
> ffff88002666dc80 h->expiry_time 665664692 hash 189
> Dec 15 12:16:12 rhel7-2-ga-2 kernel: cache_clean DELETE h
> ffff88002666dc80 from cache_list
> Dec 15 12:16:12 rhel7-2-ga-2 kernel: cache_clean CLEANED calling
> cache_put h ffff88002666dc80
> Dec 15 12:16:12 rhel7-2-ga-2 kernel: --> cache_put h ffff88002666dc80
> refcount 1 cd->cache_put ffffffffa03f3390
> Dec 15 12:16:12 rhel7-2-ga-2 kernel: expkey_put PUT h ffff88002666dc80
> Dec 15 12:16:12 rhel7-2-ga-2 kernel: <-- cache_put h ffff88002666dc80 ref=
count 0
> Dec 15 12:16:12 rhel7-2-ga-2 kernel: cache_clean CLEAN h
> ffff880075e4aa00 h->expiry_time 665664692 hash 210
> Dec 15 12:16:12 rhel7-2-ga-2 kernel: cache_clean DELETE h
> ffff880075e4aa00 from cache_list
> Dec 15 12:16:12 rhel7-2-ga-2 kernel: cache_clean CLEANED calling
> cache_put h ffff880075e4aa00
> Dec 15 12:16:12 rhel7-2-ga-2 kernel: --> cache_put h ffff880075e4aa00
> refcount 1 cd->cache_put ffffffffa03f3390
> Dec 15 12:16:12 rhel7-2-ga-2 kernel: expkey_put PUT h ffff880075e4aa00
> Dec 15 12:16:12 rhel7-2-ga-2 kernel: <-- cache_put h ffff880075e4aa00 ref=
count 0
> Dec 15 12:16:12 rhel7-2-ga-2 systemd: Stopped NFS server and services.
> Dec 15 12:16:12 rhel7-2-ga-2 systemd: Stopping NFS Mount Daemon...
> Dec 15 12:16:12 rhel7-2-ga-2 systemd: Stopping NFSv4 ID-name mapping serv=
ice...
> Dec 15 12:16:12 rhel7-2-ga-2 systemd: Stopped NFSv4 ID-name mapping servi=
ce.
> Dec 15 12:16:12 rhel7-2-ga-2 rpc.mountd[13897]: Caught signal 15,
> un-registering and exiting.
> Dec 15 12:16:12 rhel7-2-ga-2 systemd: Stopped NFS Mount Daemon.
>
>
> NOTE: both svcauth rsc cache entries =3D hash 940 and hash 982 are still
> not reaped. cache_clean continues to be run, the expiry time is way in
> the past.
>
>
> Dec 15 12:23:39 rhel7-2-ga-2 kernel: cache_clean CLEAN h
> ffff880079b3f500 h->expiry_time 1481819736 hash 940
> Dec 15 12:23:39 rhel7-2-ga-2 kernel: cache_clean CLEAN h
> ffff880079b3e540 h->expiry_time 1481819736 hash 982
>
> ....
>
>
> Dec 15 12:53:49 rhel7-2-ga-2 kernel: cache_clean CLEAN h
> ffff880079b3f500 h->expiry_time 1481819736 hash 940
> Dec 15 12:53:49 rhel7-2-ga-2 kernel: cache_clean CLEAN h
> ffff880079b3e540 h->expiry_time 1481819736 hash 982
>
> ...
>
> Dec 15 13:24:00 rhel7-2-ga-2 kernel: cache_clean CLEAN h
> ffff880079b3f500 h->expiry_time 1481819736 hash 940
> Dec 15 13:24:00 rhel7-2-ga-2 kernel: cache_clean CLEAN h
> ffff880079b3e540 h->expiry_time 1481819736 hash 982
>
>
> I don't know if it ever gets reaped.
>
>    13:24.00 =3D time last cache_clean did not reap hash 940
>  - 11:35:36 =3D time hash 940 expiry_time set to get_seconds()
>  -----------
>     1:59:24 not reaped.
>
>
> -----------   End of Current Code Behavior -------
>
> I see that:
>
> 1) cache_clean is what takes the write_lock and deletes entries from
> the cache_list.
> 2) no cache_detail->cache_put routine deletes the cache entry from the
> cache_list, including rsc_put.
>
> so, either I need to figure out how to properly trigger cache_clean to
> be called or I add grabbing the write_lock and call hlist_del_init()
> to remove the cache entries in the rsc_put routine.
>
> I wrote the rsc_destroy patch to do the first: set up the rsc cache
> entry to be destroyed by the first call to cache_clean.
>
> The disputed cache_get (after rsc_destroy in the code below) leaves
> the cache entry with a refcount of 1 which allows cache clean to not
> only call rsc_put, but to remove the entry from the cache_list.
>
> Without the disputed cache_get, the cache_put at the end of
> svcauth_gss_accept would call rsc_put and rsc_free which would free
> the cache entry without removing it from the cache_list. (here I would
> need to take the write_lock in rsc_put to delete it).
>
> -----------   Start of my patch Code Behavior -------
>
>
> 2) Case 2 with the rsc_destroy patch:
> static int rsc_destroy(struct sunrpc_net *sn, struct rsc *rscp)
> {
>    struct rsc new;
>    int ret =3D -ENOMEM;
>
>    memset(&new, 0, sizeof(struct rsc));
>    if (dup_netobj(&new.handle, &rscp->handle))
>            goto out;
>    new.h.expiry_time =3D get_seconds();
>    set_bit(CACHE_NEGATIVE, &new.h.flags);
>
>    rscp =3D rsc_update(sn->rsc_cache, &new, rscp);
>    if (!rscp)
>            goto out;
>    ret =3D 0;
> out:
>    rsc_free(&new);
>    return ret;
> }
>
>        case RPC_GSS_PROC_DESTROY:
>                 printk("%s RPC_GSS_PROC_DESTROY h %p ref %d expiry %lu\n"=
,
>                         __func__, &rsci->h, atomic_read(&rsci->h.ref.refc=
ount),
>                         rsci->h.expiry_time);
>                 if (gss_write_verf(rqstp, rsci->mechctx, gc->gc_seq))
>                         goto auth_err;
>
>                 if (!rsc_destroy(sn, rsci))
>                         goto drop;
>                 /**
>                  * Balance the cache_put at the end of svcauth_gss_accept=
.This
>                  * will leave the refcount =3D 1 after the DESTROY
> request has been
>                  * processed so that the cache_clean cache_put will
> call rsc_put.
>                  */
>                 printk("%s calling cache_get h %p ref %d\n", __func__, &r=
sci->h,
>                         atomic_read(&rsci->h.ref.refcount));
>
>                cache_get(&rsci->h);    <<<<<<<<<<<<<<< disputed cache_get
>
>                 if (resv->iov_len + 4 > PAGE_SIZE)
>                         goto drop;
>
>                 svc_putnl(resv, RPC_SUCCESS);
>                 goto complete;
>           case RPC_GSS_PROC_DATA:
>
>
>
>
> svcauth_gss_accept gc_proc 3 rq_proc 0 (one of two
> RPC_GSS_PROC_DESTROY requests)
>
> --> sunrpc_cache_lookup from rsc_lookup key ffffc90002603c58 hash 940
> Note hase 940
>
>  sunrpc_cache_lookup 1 calling cache_get key ffffc90002603c58 tmp
> ffff880073596240
>  --> cache_get h ffff880073596240 refcount 1
>
>  sunrpc_cache_lookup RETURN 1  key ffffc90002603c58 tmp ffff880073596240
>  --> rsc_free h ffffc90002603c58
> cache_check h ffff880073596240 rv 0 h->expiry_time 1481810443
> cache_check rqstp NULL rv 0 h ffff880073596240
> <-- cache_check returns 0 h ffff880073596240
>
>
> Dec 15 08:00:47 rhel7-2-ga-2 kernel: svcauth_gss_accept
> RPC_GSS_PROC_DESTROY h ffff880073596240 ref 2 expiry 1481810443
> Note expiry_time
>
> Dec 15 08:00:47 rhel7-2-ga-2 kernel: --> rsc_destroy rsci->h
> ffff880073596240 ref 2
>
> Dec 15 08:00:47 rhel7-2-ga-2 kernel: sunrpc_cache_update calling
> cache_put h ffff880073596240
> Dec 15 08:00:47 rhel7-2-ga-2 kernel: --> cache_put h ffff880073596240
> refcount 2 cd->cache_put ffffffffa03d3180
> Dec 15 08:00:47 rhel7-2-ga-2 kernel: cache_put h ffff880073596240
> expiry_time 0 nextcheck 0
> Dec 15 08:00:47 rhel7-2-ga-2 kernel: <-- cache_put h ffff880073596240 ref=
count 1
>
> Dec 15 08:00:47 rhel7-2-ga-2 kernel: <-- rsc_destroy rsci->h
> ffff880073596240 ref 1
>
>
> Dec 15 08:00:47 rhel7-2-ga-2 kernel: svcauth_gss_accept calling
> cache_get h ffff880073596240 ref 1
> Dec 15 08:00:47 rhel7-2-ga-2 kernel: --> cache_get h ffff880073596240 ref=
count 1
> Dec 15 08:00:47 rhel7-2-ga-2 kernel: svcauth_gss_accept calling
> cache_put h ffff880073596240
> Dec 15 08:00:47 rhel7-2-ga-2 kernel: --> cache_put h ffff880073596240
> refcount 2 cd->cache_put ffffffffa03d3180
> Dec 15 08:00:47 rhel7-2-ga-2 kernel: <-- cache_put h ffff880073596240 ref=
count 1
>
> Note: this is the cache_put at the end of svcauth_gss_accept.
>
>
> Dec 15 08:01:03 rhel7-2-ga-2 kernel: cache_clean CLEAN h
> ffff8800705ae000 h->expiry_time 1481806847 hash 940
> Note: the expiry_time has been set (used to be 1481810443)
>
> Dec 15 08:01:03 rhel7-2-ga-2 kernel: cache_clean CLEAN h
> ffff880073596240 h->expiry_time 0 hash 940
> Dec 15 08:01:03 rhel7-2-ga-2 kernel: cache_clean DELETE h
> ffff880073596240 from cache_list
> Dec 15 08:01:03 rhel7-2-ga-2 kernel: cache_clean CLEANED calling
> cache_put h ffff880073596240
> Dec 15 08:01:03 rhel7-2-ga-2 kernel: --> cache_put h ffff880073596240
> refcount 1 cd->cache_put ffffffffa03d3180
> Dec 15 08:01:03 rhel7-2-ga-2 kernel: cache_put h ffff880073596240
> expiry_time 0 nextcheck 0
> Dec 15 08:01:03 rhel7-2-ga-2 kernel: --> rsc_put PUT h ffff880073596240
> Dec 15 08:01:03 rhel7-2-ga-2 kernel: --> rsc_free h ffff880073596240
> Dec 15 08:01:03 rhel7-2-ga-2 kernel: RPC:       gss_delete_sec_context
> deleting ffff880071288f40
> Dec 15 08:01:03 rhel7-2-ga-2 kernel: <-- cache_put h ffff880073596240 ref=
count 0
>
> Note: AFAICS this is the way the code is supposed to work.
>
>
> -->Andy
>
>
>
>
>>
>> --b.
>>
>>>
>>> >
>>> > Maybe there's some other reason we need to use rsc_update, but that's
>>> > not it.
>>>
>>> OK - rsc_update calls sunrpc_cache_update which takes the write_lock
>>> on the cache entry, and so allows changes to be saved.
>>>
>>> --Andy
>>>
>>> >
>>> > --b.
>>> >
>>> >> So the next time the cache entry is
>>> >> looked up, e.g. when cache_clean() is called to clean up, the
>>> >> expiry_time and CACHE_NEGATIVE are not set to the new values on the
>>> >> cache entry to be destroyed, and cache_clean does not reap the cache
>>> >> entry.
>>> >
>>> >>
>>> >> The fix is to do what this patch does, and call rsc_update on the rs=
c entry. With this patch, cache_clean is called and reaps the cache entries=
.
>>> >>
>>> >> BTW: just look at all the other uses of the cache and you will note =
that they all call update after setting new values.
>>> >>
>>> >> It=E2=80=99s just how Neil=E2=80=99s cache code works.
>>> >>
>>> >> e.g. dns_resolve.c
>>> >>        key.h.expiry_time =3D ttl + seconds_since_boot();
>>> >> =E2=80=A6
>>> >>        if (key.addrlen =3D=3D 0)
>>> >>                 set_bit(CACHE_NEGATIVE, &key.h.flags);
>>> >>
>>> >>         item =3D nfs_dns_update(cd, &key, item);
>>> >>
>>> >>
>>> >>
>>> >> I also just found a bug, I need a local rsc cache pointer for the rs=
c_update return. That plus Anna=E2=80=99s comments will be addressed in ver=
sion 3. I=E2=80=99ll explain more in the patch comments.
>>> >>
>>> >> =E2=86=92Andy
>>> >>
>>> >> On 12/12/16, 4:58 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote=
:
>>> >>
>>> >> On Mon, Dec 12, 2016 at 12:08:49PM -0500, andros@netapp.com wrote:
>>> >> > From: Andy Adamson <andros@netapp.com>
>>> >> >
>>> >> > The current code sets the expiry_time on the local copy of the rsc
>>> >> > cache entry - but not on the actual cache entry.
>>> >>
>>> >> I'm not following.  It looks to me like "rsci" in the below was retu=
rned
>>> >> from gss_svc_searchbyctx(), which was returned in turn from
>>> >> sunrpc_cache_lookup(), which is returning an item from the rsc cache=
--I
>>> >> don't see any copying.
>>> >>
>>> >> > Note that currently, the rsc cache entries are not cleaned up even
>>> >> > when nfsd is stopped.
>>> >>
>>> >> So, that sounds like a bug, but I don't understand this explanation =
yet.
>>> >>
>>> >> > Update the cache with the new expiry_time of now so that cache_cle=
an will
>>> >> > clean up (free) the context to be destroyed.
>>> >> >
>>> >> > Signed-off-by: Andy Adamson <andros@netapp.com>
>>> >> > ---
>>> >> >  net/sunrpc/auth_gss/svcauth_gss.c | 32 ++++++++++++++++++++++++++=
++++--
>>> >> >  1 file changed, 30 insertions(+), 2 deletions(-)
>>> >> >
>>> >> > diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_g=
ss/svcauth_gss.c
>>> >> > index 45662d7..6033389 100644
>>> >> > --- a/net/sunrpc/auth_gss/svcauth_gss.c
>>> >> > +++ b/net/sunrpc/auth_gss/svcauth_gss.c
>>> >> > @@ -1393,6 +1393,26 @@ static void destroy_use_gss_proxy_proc_entr=
y(struct net *net) {}
>>> >> >
>>> >> >  #endif /* CONFIG_PROC_FS */
>>> >> >
>>> >> > +static int rsc_destroy(struct sunrpc_net *sn, struct rsc *rscp)
>>> >> > +{
>>> >> > +   struct rsc new;
>>> >> > +   int ret =3D -ENOMEM;
>>> >> > +
>>> >> > +   memset(&new, 0, sizeof(struct rsc));
>>> >> > +   if (dup_netobj(&new.handle, &rscp->handle))
>>> >> > +           goto out;
>>> >> > +   new.h.expiry_time =3D get_seconds();
>>> >> > +   set_bit(CACHE_NEGATIVE, &new.h.flags);
>>> >> > +
>>> >> > +   rscp =3D rsc_update(sn->rsc_cache, &new, rscp);
>>> >> > +   if (!rscp)
>>> >> > +           goto out;
>>> >> > +   ret =3D 0;
>>> >> > +out:
>>> >> > +   rsc_free(&new);
>>> >> > +   return ret;
>>> >> > +}
>>> >> > +
>>> >> >  /*
>>> >> >   * Accept an rpcsec packet.
>>> >> >   * If context establishment, punt to user space
>>> >> > @@ -1489,10 +1509,18 @@ static void destroy_use_gss_proxy_proc_ent=
ry(struct net *net) {}
>>> >> >     case RPC_GSS_PROC_DESTROY:
>>> >> >             if (gss_write_verf(rqstp, rsci->mechctx, gc->gc_seq))
>>> >> >                     goto auth_err;
>>> >> > -           rsci->h.expiry_time =3D get_seconds();
>>> >> > -           set_bit(CACHE_NEGATIVE, &rsci->h.flags);
>>> >> > +           if (rsc_destroy(sn, rsci))
>>> >> > +                   goto drop;
>>> >> > +           /**
>>> >> > +            * Balance the cache_put at the end of svcauth_gss_acc=
ept.This
>>> >> > +            * will leave the refcount =3D 1 so that the cache_cle=
an cache_put
>>> >> > +            * will call rsc_put.
>>> >> > +            */
>>> >>
>>> >> I'm confused by that comment.  If it's right, then it means the refc=
ount
>>> >> is currently zero, in which case the following line is unsafe.
>>> >>
>>> >> --b.
>>> >>
>>> >> > +           cache_get(&rsci->h);
>>> >> > +
>>> >> >             if (resv->iov_len + 4 > PAGE_SIZE)
>>> >> >                     goto drop;
>>> >> > +
>>> >> >             svc_putnl(resv, RPC_SUCCESS);
>>> >> >             goto complete;
>>> >> >     case RPC_GSS_PROC_DATA:
>>> >> > --
>>> >> > 1.8.3.1
>>> >>
>>> >>
>>> > --
>>> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
>>> > the body of a message to majordomo@vger.kernel.org
>>> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
