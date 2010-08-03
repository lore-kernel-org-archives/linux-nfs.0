Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:49949 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750957Ab0HCBo3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Aug 2010 21:44:29 -0400
Date: Tue, 3 Aug 2010 11:44:10 +1000
From: Neil Brown <neilb@suse.de>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Xiaotian Feng <dfeng@redhat.com>, linux-mm@kvack.org,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org, riel@redhat.com,
        cl@linux-foundation.org, a.p.zijlstra@chello.nl,
        linux-kernel@vger.kernel.org, lwang@redhat.com,
        akpm@linux-foundation.org, davem@davemloft.net
Subject: Re: [PATCH -mmotm 05/30] mm: sl[au]b: add knowledge of reserve
 pages
Message-ID: <20100803114410.420ae7ba@notabene>
In-Reply-To: <AANLkTilj5GrhbRJZfSsfXP1v9cQSRlARFmxpys1vUelr@mail.gmail.com>
References: <20100713101650.2835.15245.sendpatchset@danny.redhat>
	<20100713101747.2835.45722.sendpatchset@danny.redhat>
	<AANLkTilj5GrhbRJZfSsfXP1v9cQSRlARFmxpys1vUelr@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 13 Jul 2010 23:33:14 +0300
Pekka Enberg <penberg@cs.helsinki.fi> wrote:

> Hi Xiaotian!
> 
> I would actually prefer that the SLAB, SLOB, and SLUB changes were in
> separate patches to make reviewing easier.
> 
> Looking at SLUB:
> 
> On Tue, Jul 13, 2010 at 1:17 PM, Xiaotian Feng <dfeng@redhat.com> wrote:
> > diff --git a/mm/slub.c b/mm/slub.c
> > index 7bb7940..7a5d6dc 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -27,6 +27,8 @@
> >  #include <linux/memory.h>
> >  #include <linux/math64.h>
> >  #include <linux/fault-inject.h>
> > +#include "internal.h"
> > +
> >
> >  /*
> >  * Lock order:
> > @@ -1139,7 +1141,8 @@ static void setup_object(struct kmem_cache *s, struct page *page,
> >                s->ctor(object);
> >  }
> >
> > -static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
> > +static
> > +struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node, int *reserve)
> >  {
> >        struct page *page;
> >        void *start;
> > @@ -1153,6 +1156,8 @@ static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
> >        if (!page)
> >                goto out;
> >
> > +       *reserve = page->reserve;
> > +
> >        inc_slabs_node(s, page_to_nid(page), page->objects);
> >        page->slab = s;
> >        page->flags |= 1 << PG_slab;
> > @@ -1606,10 +1611,20 @@ static void *__slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
> >  {
> >        void **object;
> >        struct page *new;
> > +       int reserve;
> >
> >        /* We handle __GFP_ZERO in the caller */
> >        gfpflags &= ~__GFP_ZERO;
> >
> > +       if (unlikely(c->reserve)) {
> > +               /*
> > +                * If the current slab is a reserve slab and the current
> > +                * allocation context does not allow access to the reserves we
> > +                * must force an allocation to test the current levels.
> > +                */
> > +               if (!(gfp_to_alloc_flags(gfpflags) & ALLOC_NO_WATERMARKS))
> > +                       goto grow_slab;
> 
> OK, so assume that:
> 
>   (1) c->reserve is set to one
> 
>   (2) GFP flags don't allow dipping into the reserves
> 
>   (3) we've managed to free enough pages so normal
>        allocations are fine
> 
>   (4) the page from reserves is not yet empty
> 
> we will call flush_slab() and put the "emergency page" on partial list
> and clear c->reserve. This effectively means that now some other
> allocation can fetch the partial page and start to use it. Is this OK?
> Who makes sure the emergency reserves are large enough for the next
> out-of-memory condition where we swap over NFS?

Yes, this is OK.  The emergency reserves are maintained at a lower level -
within alloc_page.
The fact that (3) normal allocations are fine means that there are enough
free pages to satisfy any swap-out allocation - so any pages that were
previously allocated as 'emergency' pages can have their emergency status
forgotten (the emergency has passed).

This is a subtle but important aspect of the emergency reservation scheme in
swap-over-NFS.  It is the act-of-allocating that is emergency-or-not.  The
memory itself, once allocated, is not special.

c->reserve means "the last page allocated required an emergency allocation".
This means that parts of that page, or any other page, can only be given as
emergency allocations.  Once the slab succeeds at a non-emergency allocation,
the flag should obviously be cleared.

Similarly the page->reserve flag does not mean "this is a reserve page", but
simply "when this page was allocated, it was an emergency allocation".  The
flag is often soon lost as it is in a union with e.g. freelist.  But that
doesn't matter as it is only really meaningful at the moment of allocation.

I hope that clarifies the situation,

NeilBrown

> 
> > +       }
> >        if (!c->page)
> >                goto new_slab;
> >
> > @@ -1623,8 +1638,8 @@ load_freelist:
> >        object = c->page->freelist;
> >        if (unlikely(!object))
> >                goto another_slab;
> > -       if (unlikely(SLABDEBUG && PageSlubDebug(c->page)))
> > -               goto debug;
> > +       if (unlikely(SLABDEBUG && PageSlubDebug(c->page) || c->reserve))
> > +               goto slow_path;
> >
> >        c->freelist = get_freepointer(s, object);
> >        c->page->inuse = c->page->objects;
> > @@ -1646,16 +1661,18 @@ new_slab:
> >                goto load_freelist;
> >        }
> >
> > +grow_slab:
> >        if (gfpflags & __GFP_WAIT)
> >                local_irq_enable();
> >
> > -       new = new_slab(s, gfpflags, node);
> > +       new = new_slab(s, gfpflags, node, &reserve);
> >
> >        if (gfpflags & __GFP_WAIT)
> >                local_irq_disable();
> >
> >        if (new) {
> >                c = __this_cpu_ptr(s->cpu_slab);
> > +               c->reserve = reserve;
> >                stat(s, ALLOC_SLAB);
> >                if (c->page)
> >                        flush_slab(s, c);
> > @@ -1667,10 +1684,20 @@ new_slab:
> >        if (!(gfpflags & __GFP_NOWARN) && printk_ratelimit())
> >                slab_out_of_memory(s, gfpflags, node);
> >        return NULL;
> > -debug:
> > -       if (!alloc_debug_processing(s, c->page, object, addr))
> > +
> > +slow_path:
> > +       if (!c->reserve && !alloc_debug_processing(s, c->page, object, addr))
> >                goto another_slab;
> >
> > +       /*
> > +        * Avoid the slub fast path in slab_alloc() by not setting
> > +        * c->freelist and the fast path in slab_free() by making
> > +        * node_match() fail by setting c->node to -1.
> > +        *
> > +        * We use this for for debug and reserve checks which need
> > +        * to be done for each allocation.
> > +        */
> > +
> >        c->page->inuse++;
> >        c->page->freelist = get_freepointer(s, object);
> >        c->node = -1;
> > @@ -2095,10 +2122,11 @@ static void early_kmem_cache_node_alloc(gfp_t gfpflags, int node)
> >        struct page *page;
> >        struct kmem_cache_node *n;
> >        unsigned long flags;
> > +       int reserve;
> >
> >        BUG_ON(kmalloc_caches->size < sizeof(struct kmem_cache_node));
> >
> > -       page = new_slab(kmalloc_caches, gfpflags, node);
> > +       page = new_slab(kmalloc_caches, gfpflags, node, &reserve);
> >
> >        BUG_ON(!page);
> >        if (page_to_nid(page) != node) {
> > --
> > 1.7.1.1
> >
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

