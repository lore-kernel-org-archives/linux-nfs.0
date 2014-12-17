Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:60126 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751673AbaLQIGP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Dec 2014 03:06:15 -0500
Date: Wed, 17 Dec 2014 00:06:10 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Omar Sandoval <osandov@osandov.com>
Cc: Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Andrew Morton <akpm@linux-foundation.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        David Sterba <dsterba@suse.cz>, linux-fsdevel@vger.kernel.org,
        linux-mm@kvack.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/8] swap: lock i_mutex for swap_writepage direct_IO
Message-ID: <20141217080610.GA20335@infradead.org>
References: <cover.1418618044.git.osandov@osandov.com>
 <a59510f4552a5d3557958cdb0ce1b23b3abfc75b.1418618044.git.osandov@osandov.com>
 <20141215162705.GA23887@quack.suse.cz>
 <20141215165615.GA19041@infradead.org>
 <20141215221100.GA4637@mew>
 <20141216083543.GA32425@infradead.org>
 <20141216085624.GA25256@mew>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141216085624.GA25256@mew>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 16, 2014 at 12:56:24AM -0800, Omar Sandoval wrote:
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -1728,6 +1728,9 @@ static int setup_swap_extents(struct swap_info_struct *sis, sector_t *span)
>         }
>  
>         if (mapping->a_ops->swap_activate) {
> +               if (!mapping->a_ops->direct_IO)
> +                       return -EINVAL;
> +               swap_file->f_flags |= O_DIRECT;
>                 ret = mapping->a_ops->swap_activate(sis, swap_file, span);
>                 if (!ret) {
>                         sis->flags |= SWP_FILE;

This needs to hold swap_file->f_lock, but otherwise looks good.

> This seems to be more or less equivalent to doing a fcntl(F_SETFL) to
> add the O_DIRECT flag to swap_file (which is a struct file *). Swapoff
> calls filp_close on swap_file, so I don't see why it's necessary to
> clear the flag.

filp_lose doesn't nessecarily destroy the file structure, there might be
other reference to it, e.g. from dup() or descriptor passing.
