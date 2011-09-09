Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:35139
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758817Ab1IINAS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Sep 2011 09:00:18 -0400
Date: Fri, 9 Sep 2011 09:00:08 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>,
        Linux-NFS <linux-nfs@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        David Miller <davem@davemloft.net>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH 03/10] mm: Add support for a filesystem to control swap
 files
Message-ID: <20110909130007.GA11810@infradead.org>
References: <1315566054-17209-1-git-send-email-mgorman@suse.de>
 <1315566054-17209-4-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1315566054-17209-4-git-send-email-mgorman@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Sep 09, 2011 at 12:00:47PM +0100, Mel Gorman wrote:
> Currently swapfiles are managed entirely by the core VM by using
> ->bmap to allocate space and write to the blocks directly. This
> patch adds address_space_operations methods that allow a filesystem
> to optionally control the swapfile.
> 
>   int swap_activate(struct file *);
>   int swap_deactivate(struct file *);
>   int swap_writepage(struct file *, struct page *, struct writeback_control *);
>   int swap_readpage(struct file *, struct page *);

Just as the last two dozen times this came up:

NAK

The right fix is to add a filesystem method to support direct-I/O on
arbitrary kernel pages, instead of letting the wap abstraction leak into
the filesystem.
