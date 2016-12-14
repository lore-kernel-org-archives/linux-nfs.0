Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:37690 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753250AbcLNVEg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 14 Dec 2016 16:04:36 -0500
Date: Wed, 14 Dec 2016 16:04:27 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andy Adamson <androsadamson@gmail.com>
Cc: "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH Version 2] SVCAUTH update the rsc cache on
 RPC_GSS_PROC_DESTROY
Message-ID: <20161214210427.GC2212@fieldses.org>
References: <1481562529-4488-1-git-send-email-andros@netapp.com>
 <20161212215804.GB6002@fieldses.org>
 <4608493E-D422-437C-B7B8-D2E74E4F75CE@netapp.com>
 <20161213160029.GB19985@fieldses.org>
 <CAHVgHyX+0SpOf5JXz57P=5W9OC9ESnCghj3EHngUB4X84ASoNA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <CAHVgHyX+0SpOf5JXz57P=5W9OC9ESnCghj3EHngUB4X84ASoNA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 13, 2016 at 11:36:11AM -0500, Andy Adamson wrote:
> On Tue, Dec 13, 2016 at 11:00 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > On Mon, Dec 12, 2016 at 10:54:33PM +0000, Adamson, Andy wrote:
> >> The bug is setting new values on an rsc cache entry without calling
> >> rsc_update. When you do this, the “local copy” of the rsc cache entry
> >> (e.g. the one returned by gss_svc_searchbyctx ) gets the new values
> >> (expiry_time and CACHE_NEGATIVE bit set) but the new values are not
> >> propagated back to the cache.
> >
> > gss_svc_searchbyctx:
> >
> >         found = rsc_lookup(cd, &rsci);
> >         ...
> >         return found;
> >
> > rsc_lookup:
> >
> >         ch = sunrpc_cache_lookup(cd, &item->h, hash);
> >         if (ch)
> >                 return container_of(ch, struct rsc, h);
> >
> > sunrpc_cache_lookup:
> >
> >         head = &detail->hash_table[hash];
> >         ...
> >         hlist_for_each_entry(tmp, head, cache_list) {
> >                 ...
> >                 return tmp;
> >
> > Definitely looks to me like it's returning a cache entry, not a copy.
> 
> Thats right. What I call a "local copy". Guess that is wrong. I should
> say that sunrpc_cache_lookup returns a cache entry under the
> read_lock() and so writing that cache entry does not save the changes.

Writes still happen normally, there's just the hypothetical possibility
of races if two processes are writing at the same time.  (Don't know if
that's a risk here, I haven't thought it through.)

Maybe it would be easiest for me to understand if you could start with a
description of your reproducer?  What do you do, and what results do you
see?

--b.

> 
> >
> > Maybe there's some other reason we need to use rsc_update, but that's
> > not it.
> 
> OK - rsc_update calls sunrpc_cache_update which takes the write_lock
> on the cache entry, and so allows changes to be saved.
> 
> --Andy
> 
> >
> > --b.
> >
> >> So the next time the cache entry is
> >> looked up, e.g. when cache_clean() is called to clean up, the
> >> expiry_time and CACHE_NEGATIVE are not set to the new values on the
> >> cache entry to be destroyed, and cache_clean does not reap the cache
> >> entry.
> >
> >>
> >> The fix is to do what this patch does, and call rsc_update on the rsc entry. With this patch, cache_clean is called and reaps the cache entries.
> >>
> >> BTW: just look at all the other uses of the cache and you will note that they all call update after setting new values.
> >>
> >> It’s just how Neil’s cache code works.
> >>
> >> e.g. dns_resolve.c
> >>        key.h.expiry_time = ttl + seconds_since_boot();
> >> …
> >>        if (key.addrlen == 0)
> >>                 set_bit(CACHE_NEGATIVE, &key.h.flags);
> >>
> >>         item = nfs_dns_update(cd, &key, item);
> >>
> >>
> >>
> >> I also just found a bug, I need a local rsc cache pointer for the rsc_update return. That plus Anna’s comments will be addressed in version 3. I’ll explain more in the patch comments.
> >>
> >> →Andy
> >>
> >> On 12/12/16, 4:58 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> >>
> >> On Mon, Dec 12, 2016 at 12:08:49PM -0500, andros@netapp.com wrote:
> >> > From: Andy Adamson <andros@netapp.com>
> >> >
> >> > The current code sets the expiry_time on the local copy of the rsc
> >> > cache entry - but not on the actual cache entry.
> >>
> >> I'm not following.  It looks to me like "rsci" in the below was returned
> >> from gss_svc_searchbyctx(), which was returned in turn from
> >> sunrpc_cache_lookup(), which is returning an item from the rsc cache--I
> >> don't see any copying.
> >>
> >> > Note that currently, the rsc cache entries are not cleaned up even
> >> > when nfsd is stopped.
> >>
> >> So, that sounds like a bug, but I don't understand this explanation yet.
> >>
> >> > Update the cache with the new expiry_time of now so that cache_clean will
> >> > clean up (free) the context to be destroyed.
> >> >
> >> > Signed-off-by: Andy Adamson <andros@netapp.com>
> >> > ---
> >> >  net/sunrpc/auth_gss/svcauth_gss.c | 32 ++++++++++++++++++++++++++++++--
> >> >  1 file changed, 30 insertions(+), 2 deletions(-)
> >> >
> >> > diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
> >> > index 45662d7..6033389 100644
> >> > --- a/net/sunrpc/auth_gss/svcauth_gss.c
> >> > +++ b/net/sunrpc/auth_gss/svcauth_gss.c
> >> > @@ -1393,6 +1393,26 @@ static void destroy_use_gss_proxy_proc_entry(struct net *net) {}
> >> >
> >> >  #endif /* CONFIG_PROC_FS */
> >> >
> >> > +static int rsc_destroy(struct sunrpc_net *sn, struct rsc *rscp)
> >> > +{
> >> > +   struct rsc new;
> >> > +   int ret = -ENOMEM;
> >> > +
> >> > +   memset(&new, 0, sizeof(struct rsc));
> >> > +   if (dup_netobj(&new.handle, &rscp->handle))
> >> > +           goto out;
> >> > +   new.h.expiry_time = get_seconds();
> >> > +   set_bit(CACHE_NEGATIVE, &new.h.flags);
> >> > +
> >> > +   rscp = rsc_update(sn->rsc_cache, &new, rscp);
> >> > +   if (!rscp)
> >> > +           goto out;
> >> > +   ret = 0;
> >> > +out:
> >> > +   rsc_free(&new);
> >> > +   return ret;
> >> > +}
> >> > +
> >> >  /*
> >> >   * Accept an rpcsec packet.
> >> >   * If context establishment, punt to user space
> >> > @@ -1489,10 +1509,18 @@ static void destroy_use_gss_proxy_proc_entry(struct net *net) {}
> >> >     case RPC_GSS_PROC_DESTROY:
> >> >             if (gss_write_verf(rqstp, rsci->mechctx, gc->gc_seq))
> >> >                     goto auth_err;
> >> > -           rsci->h.expiry_time = get_seconds();
> >> > -           set_bit(CACHE_NEGATIVE, &rsci->h.flags);
> >> > +           if (rsc_destroy(sn, rsci))
> >> > +                   goto drop;
> >> > +           /**
> >> > +            * Balance the cache_put at the end of svcauth_gss_accept.This
> >> > +            * will leave the refcount = 1 so that the cache_clean cache_put
> >> > +            * will call rsc_put.
> >> > +            */
> >>
> >> I'm confused by that comment.  If it's right, then it means the refcount
> >> is currently zero, in which case the following line is unsafe.
> >>
> >> --b.
> >>
> >> > +           cache_get(&rsci->h);
> >> > +
> >> >             if (resv->iov_len + 4 > PAGE_SIZE)
> >> >                     goto drop;
> >> > +
> >> >             svc_putnl(resv, RPC_SUCCESS);
> >> >             goto complete;
> >> >     case RPC_GSS_PROC_DATA:
> >> > --
> >> > 1.8.3.1
> >>
> >>
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
