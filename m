Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:50877 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754784Ab0LAUeF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Dec 2010 15:34:05 -0500
Date: Wed, 1 Dec 2010 12:33:41 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Nick Bowler <nbowler@elliptictech.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, Hugh Dickins <hughd@google.com>,
        Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@lst.de>,
        Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH v2 3/3] NFS: Fix a memory leak in nfs_readdir
Message-Id: <20101201123341.d12ef362.akpm@linux-foundation.org>
In-Reply-To: <1291234251.6609.39.camel@heimdal.trondhjem.org>
References: <1291217804-11257-1-git-send-email-Trond.Myklebust@netapp.com>
	<1291217804-11257-2-git-send-email-Trond.Myklebust@netapp.com>
	<20101201150428.GA2879@elliptictech.com>
	<1291217804-11257-3-git-send-email-Trond.Myklebust@netapp.com>
	<1291217804-11257-4-git-send-email-Trond.Myklebust@netapp.com>
	<AANLkTi=C8UtWwctEgBY2584d8fDV3OHpf+mGNnQO8ZJt@mail.gmail.com>
	<1291229669.6609.24.camel@heimdal.trondhjem.org>
	<AANLkTinsEeKK9LykVAVq60Lsb3caLDJasnKH8kcgSFVp@mail.gmail.com>
	<1291234251.6609.39.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 01 Dec 2010 15:10:50 -0500
Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -602,6 +602,7 @@ struct address_space_operations {
>  	sector_t (*bmap)(struct address_space *, sector_t);
>  	void (*invalidatepage) (struct page *, unsigned long);
>  	int (*releasepage) (struct page *, gfp_t);
> +	void (*freepage)(struct page *);
>  	ssize_t (*direct_IO)(int, struct kiocb *, const struct iovec *iov,
>  			loff_t offset, unsigned long nr_segs);
>  	int (*get_xip_mem)(struct address_space *, pgoff_t, int,

It would be good to think about and then clearly spell out exactly what
state the page is in here.  It is locked, and I assume clean and not
under writeback.  What about its refcount, freezedness status and
eligibility for lookups?

And as Hugh pointed out, some callees might needs the address_space*
although we can perhaps defer that until such a callee turns up. 
If/when that happens we might have a problem though: if this locked
page is no longer attached to the address_space then what now pins the
address_space, protecting it from inode reclaim?
