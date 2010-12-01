Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:32983 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755632Ab0LAUTs convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Dec 2010 15:19:48 -0500
In-Reply-To: <1291234251.6609.39.camel@heimdal.trondhjem.org>
References: <1291217804-11257-1-git-send-email-Trond.Myklebust@netapp.com>
 <1291217804-11257-2-git-send-email-Trond.Myklebust@netapp.com>
 <20101201150428.GA2879@elliptictech.com> <1291217804-11257-3-git-send-email-Trond.Myklebust@netapp.com>
 <1291217804-11257-4-git-send-email-Trond.Myklebust@netapp.com>
 <AANLkTi=C8UtWwctEgBY2584d8fDV3OHpf+mGNnQO8ZJt@mail.gmail.com>
 <1291229669.6609.24.camel@heimdal.trondhjem.org> <AANLkTinsEeKK9LykVAVq60Lsb3caLDJasnKH8kcgSFVp@mail.gmail.com>
 <1291234251.6609.39.camel@heimdal.trondhjem.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 1 Dec 2010 12:18:58 -0800
Message-ID: <AANLkTi=Spd1OvdijN7kEJBBdYdTRuVnwPUqZvAUUiaKF@mail.gmail.com>
Subject: Re: [PATCH v2 3/3] NFS: Fix a memory leak in nfs_readdir
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Nick Bowler <nbowler@elliptictech.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
        Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>,
        Christoph Hellwig <hch@lst.de>, Al Viro <viro@zeniv.linux.org.uk>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Dec 1, 2010 at 12:10 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
>
> Something like the following then?
> diff --git a/mm/truncate.c b/mm/truncate.c
> index ba887bf..76ab2a8 100644
> --- a/mm/truncate.c
> +++ b/mm/truncate.c
> @@ -108,6 +108,10 @@ truncate_complete_page(struct address_space *mapping, struct page *page)
>        clear_page_mlock(page);
>        remove_from_page_cache(page);
>        ClearPageMappedToDisk(page);
> +
> +       if (mapping->a_ops->freepage)
> +               mapping->a_ops->freepage(page);
> +
>        page_cache_release(page);       /* pagecache ref */
>        return 0;
>  }

I'd do this in "remove_from_page_cache()" instead of in
"truncate_complete_page()". Otherwise it will miss any other callers
that use "remove_from_page_cache()" (not that there are many, and I
doubt NFS cares about the ones that do exists, but..)

                 Linus
