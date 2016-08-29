Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f170.google.com ([209.85.216.170]:35295 "EHLO
        mail-qt0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751195AbcH2Rws (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Aug 2016 13:52:48 -0400
Received: by mail-qt0-f170.google.com with SMTP id 93so72360173qtg.2
        for <linux-nfs@vger.kernel.org>; Mon, 29 Aug 2016 10:52:48 -0700 (PDT)
Message-ID: <1472493162.16070.10.camel@poochiereds.net>
Subject: Re: OOM detection regressions since 4.7
From: Jeff Layton <jlayton@poochiereds.net>
To: Linus Torvalds <torvalds@linux-foundation.org>,
        Olaf Hering <olaf@aepfle.de>, Bruce Fields <bfields@fieldses.org>
Cc: Michal Hocko <mhocko@kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Markus Trippelsdorf <markus@trippelsdorf.de>,
        Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>,
        Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>,
        Jiri Slaby <jslaby@suse.com>, Greg KH <gregkh@linuxfoundation.org>,
        Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>,
        linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date: Mon, 29 Aug 2016 13:52:42 -0400
In-Reply-To: <CA+55aFxbBszp+O9=9MrwXxp_fNw6xzNjQ0Kktm-8ipgqbido8w@mail.gmail.com>
References: <20160822093249.GA14916@dhcp22.suse.cz>
         <20160822093707.GG13596@dhcp22.suse.cz> <20160822100528.GB11890@kroah.com>
         <20160822105441.GH13596@dhcp22.suse.cz> <20160822133114.GA15302@kroah.com>
         <20160822134227.GM13596@dhcp22.suse.cz>
         <20160822150517.62dc7cce74f1af6c1f204549@linux-foundation.org>
         <20160823074339.GB23577@dhcp22.suse.cz>
         <20160825071103.GC4230@dhcp22.suse.cz> <20160825071728.GA3169@aepfle.de>
         <20160829145203.GA30660@aepfle.de>
         <CA+55aFxbBszp+O9=9MrwXxp_fNw6xzNjQ0Kktm-8ipgqbido8w@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2016-08-29 at 10:28 -0700, Linus Torvalds wrote:
> > On Mon, Aug 29, 2016 at 7:52 AM, Olaf Hering <olaf@aepfle.de> wrote:
> > 
> > 
> > Today I noticed the nfsserver was disabled, probably since months already.
> > Starting it gives a OOM, not sure if this is new with 4.7+.
> 
> That's not an oom, that's just an allocation failure.
> 
> And with order-4, that's actually pretty normal. Nobody should use
> order-4 (that's 16 contiguous pages, fragmentation can easily make
> that hard - *much* harder than the small order-2 or order-2 cases that
> we should largely be able to rely on).
> 
> In fact, people who do multi-order allocations should always have a
> fallback, and use __GFP_NOWARN.
> 
> > 
> > [93348.306406] Call Trace:
> > [93348.306490]  [<ffffffff81198cef>] __alloc_pages_slowpath+0x1af/0xa10
> > [93348.306501]  [<ffffffff811997a0>] __alloc_pages_nodemask+0x250/0x290
> > [93348.306511]  [<ffffffff811f1c3d>] cache_grow_begin+0x8d/0x540
> > [93348.306520]  [<ffffffff811f23d1>] fallback_alloc+0x161/0x200
> > [93348.306530]  [<ffffffff811f43f2>] __kmalloc+0x1d2/0x570
> > [93348.306589]  [<ffffffffa08f025a>] nfsd_reply_cache_init+0xaa/0x110 [nfsd]
> 
> Hmm. That's kmalloc itself falling back after already failing to grow
> the slab cache earlier (the earlier allocations *were* done with
> NOWARN afaik).
> 
> It does look like nfsdstarts out by allocating the hash table with one
> single fairly big allocation, and has no fallback position.
> 
> I suspect the code expects to be started at boot time, when this just
> isn't an issue. The fact that you loaded the nfsd kernel module with
> memory already fragmented after heavy use is likely why nobody else
> has seen this.
> 
> Adding the nfsd people to the cc, because just from a robustness
> standpoint I suspect it would be better if the code did something like
> 
>  (a) shrink the hash table if the allocation fails (we've got some
> examples of that elsewhere)
> 
> or
> 
>  (b) fall back on a vmalloc allocation (that's certainly the simpler model)
> 
> We do have a "kvfree()" helper function for the "free either a kmalloc
> or vmalloc allocation" but we don't actually have a good helper
> pattern for the allocation side. People just do it by hand, at least
> partly because we have so many different ways to allocate things -
> zeroing, non-zeroing, node-specific or not, atomic or not (atomic
> cannot fall back to vmalloc, obviously) etc etc.
> 
> Bruce, Jeff, comments?
> 
>              Linus

Yeah, that makes total sense.

Hmm...we _do_ already auto-size the hash at init time already, so
shrinking it downward and retrying if the allocation fails wouldn't be
hard to do. Maybe I can just cut it in half and throw a pr_warn to tell
the admin in that case.

In any case...I'll take a look at how we can improve it.

Thanks for the heads-up!
-- 
Jeff Layton <jlayton@poochiereds.net>
