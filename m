Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:47521 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756072Ab2DQMlD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Apr 2012 08:41:03 -0400
Date: Tue, 17 Apr 2012 13:40:56 +0100
From: Mel Gorman <mgorman@suse.de>
To: Fred Isaman <iisaman@netapp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>,
        Linux-Netdev <netdev@vger.kernel.org>,
        Linux-NFS <linux-nfs@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>,
        Peter Zijlstra <a.p.zijlstra@chello.nl>,
        Mike Christie <michaelc@cs.wisc.edu>,
        Eric B Munson <emunson@mgebm.net>
Subject: Re: [PATCH 08/11] nfs: disable data cache revalidation for swapfiles
Message-ID: <20120417124056.GI2359@suse.de>
References: <1334578675-23445-1-git-send-email-mgorman@suse.de>
 <1334578675-23445-9-git-send-email-mgorman@suse.de>
 <CADnza444dTr=JEtqpL5wxHRNkEc7vBz1qq9TL7Z+5h749vNawg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
In-Reply-To: <CADnza444dTr=JEtqpL5wxHRNkEc7vBz1qq9TL7Z+5h749vNawg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> On Mon, Apr 16, 2012 at 9:44 AM, Mel Gorman <mgorman@suse.de> wrote:
> > On Mon, Apr 16, 2012 at 09:10:04AM -0400, Fred Isaman wrote:
> >> > <SNIP>
> >> > -static struct nfs_page *nfs_page_find_request_locked(struct page *page)
> >> > +static struct nfs_page *
> >> > +nfs_page_find_request_locked(struct nfs_inode *nfsi, struct page *page)
> >> >  {
> >> >        struct nfs_page *req = NULL;
> >> >
> >> > -       if (PagePrivate(page)) {
> >> > +       if (PagePrivate(page))
> >> >                req = (struct nfs_page *)page_private(page);
> >> > -               if (req != NULL)
> >> > -                       kref_get(&req->wb_kref);
> >> > +       else if (unlikely(PageSwapCache(page))) {
> >> > +               struct nfs_page *freq, *t;
> >> > +
> >> > +               /* Linearly search the commit list for the correct req */
> >> > +               list_for_each_entry_safe(freq, t, &nfsi->commit_list, wb_list) {
> >> > +                       if (freq->wb_page == page) {
> >> > +                               req = freq;
> >> > +                               break;
> >> > +                       }
> >> > +               }
> >> > +
> >> > +               BUG_ON(req == NULL);
> >>
> >> I suspect I am missing something, but why is it guaranteed that the
> >> req is on the commit list?
> >>
> >
> > It's a fair question and a statement about what I expected to happen.
> > The commit list replaces the nfs_page_tree radix tree that used to exist
> > and my understanding was that the req would exist in the radix tree until
> > the swap IO was completed. I expected it to be the same for the commit
> > list and the BUG_ON was based on that expectation. Are there cases where
> > the req would not be found?
> >
> 
> A req is on the commit list only if it actually needs to be scheduled
> for COMMIT. In other words, only after it has been sent via WRITE and
> the server did not return NFS_FILE_SYNC.
> 
> Thus dirtying a page, then trying to touch it again before the WRITE
> is sent will not find the corresponding req on the commit_list.

Thanks for the explanation. I'll remove the BUG_ON

-- 
Mel Gorman
SUSE Labs
