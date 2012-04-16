Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f46.google.com ([209.85.212.46]:63286 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753761Ab2DPPDg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Apr 2012 11:03:36 -0400
MIME-Version: 1.0
In-Reply-To: <20120416134422.GC2359@suse.de>
References: <1334578675-23445-1-git-send-email-mgorman@suse.de>
	<1334578675-23445-9-git-send-email-mgorman@suse.de>
	<CADnza444dTr=JEtqpL5wxHRNkEc7vBz1qq9TL7Z+5h749vNawg@mail.gmail.com>
	<20120416134422.GC2359@suse.de>
Date: Mon, 16 Apr 2012 11:03:35 -0400
Message-ID: <CADnza440ERBNTyQuXaG-MJGGw2u-ADmFdn+w+nvJ1F7cNyreGA@mail.gmail.com>
Subject: Re: [PATCH 08/11] nfs: disable data cache revalidation for swapfiles
From: Fred Isaman <iisaman@netapp.com>
To: Mel Gorman <mgorman@suse.de>
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
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 16, 2012 at 9:44 AM, Mel Gorman <mgorman@suse.de> wrote:
> On Mon, Apr 16, 2012 at 09:10:04AM -0400, Fred Isaman wrote:
>> > <SNIP>
>> > -static struct nfs_page *nfs_page_find_request_locked(struct page *page)
>> > +static struct nfs_page *
>> > +nfs_page_find_request_locked(struct nfs_inode *nfsi, struct page *page)
>> >  {
>> >        struct nfs_page *req = NULL;
>> >
>> > -       if (PagePrivate(page)) {
>> > +       if (PagePrivate(page))
>> >                req = (struct nfs_page *)page_private(page);
>> > -               if (req != NULL)
>> > -                       kref_get(&req->wb_kref);
>> > +       else if (unlikely(PageSwapCache(page))) {
>> > +               struct nfs_page *freq, *t;
>> > +
>> > +               /* Linearly search the commit list for the correct req */
>> > +               list_for_each_entry_safe(freq, t, &nfsi->commit_list, wb_list) {
>> > +                       if (freq->wb_page == page) {
>> > +                               req = freq;
>> > +                               break;
>> > +                       }
>> > +               }
>> > +
>> > +               BUG_ON(req == NULL);
>>
>> I suspect I am missing something, but why is it guaranteed that the
>> req is on the commit list?
>>
>
> It's a fair question and a statement about what I expected to happen.
> The commit list replaces the nfs_page_tree radix tree that used to exist
> and my understanding was that the req would exist in the radix tree until
> the swap IO was completed. I expected it to be the same for the commit
> list and the BUG_ON was based on that expectation. Are there cases where
> the req would not be found?
>
> Thanks.
>
> --
> Mel Gorman
> SUSE Labs
> --

A req is on the commit list only if it actually needs to be scheduled
for COMMIT.  In other words, only after it has been sent via WRITE and
the server did not return NFS_FILE_SYNC.

Thus dirtying a page, then trying to touch it again before the WRITE
is sent will not find the corresponding req on the commit_list.

Fred
