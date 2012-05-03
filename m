Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:43520 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756215Ab2ECO5T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 May 2012 10:57:19 -0400
Date: Thu, 3 May 2012 15:57:14 +0100
From: Mel Gorman <mgorman@suse.de>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>,
        Linux-NFS <linux-nfs@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>,
        Peter Zijlstra <a.p.zijlstra@chello.nl>,
        Mike Christie <michaelc@cs.wisc.edu>,
        Eric B Munson <emunson@mgebm.net>
Subject: Re: [PATCH 05/11] mm: swap: Implement generic handler for
 swap_activate
Message-ID: <20120503145714.GH11435@suse.de>
References: <1334578675-23445-1-git-send-email-mgorman@suse.de>
 <1334578675-23445-6-git-send-email-mgorman@suse.de>
 <20120501155747.368a1d36.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
In-Reply-To: <20120501155747.368a1d36.akpm@linux-foundation.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 01, 2012 at 03:57:47PM -0700, Andrew Morton wrote:
> On Mon, 16 Apr 2012 13:17:49 +0100
> Mel Gorman <mgorman@suse.de> wrote:
> 
> > The version of swap_activate introduced is sufficient for swap-over-NFS
> > but would not provide enough information to implement a generic handler.
> > This patch shuffles things slightly to ensure the same information is
> > available for aops->swap_activate() as is available to the core.
> > 
> > No functionality change.
> > 
> > ...
> >
> > --- a/include/linux/fs.h
> > +++ b/include/linux/fs.h
> > @@ -587,6 +587,8 @@ typedef struct {
> >  typedef int (*read_actor_t)(read_descriptor_t *, struct page *,
> >  		unsigned long, unsigned long);
> >  
> > +struct swap_info_struct;
> 
> Please put forward declarations at top-of-file.  To prevent accidental
> duplication later on.
> 

Done.

> >  struct address_space_operations {
> >  	int (*writepage)(struct page *page, struct writeback_control *wbc);
> >  	int (*readpage)(struct file *, struct page *);
> >
> > ...
> >
> > --- a/mm/page_io.c
> > +++ b/mm/page_io.c
> 
> Have you tested all this code with CONFIG_SWAP=n?
> 

Emm, it builds. That counts, right?

> Have you sought to minimise additional new code when CONFIG_SWAP=n?
> 

Not specifically, but generic_swapfile_activate() is defined in page_io.c
and that is built only if CONFIG_SWAP=y. Similarly swapon is in
swapfile.c which is only build when swap is enabled.

-- 
Mel Gorman
SUSE Labs
