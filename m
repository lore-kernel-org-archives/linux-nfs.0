Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:60792 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780AbaLTGNm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 20 Dec 2014 01:13:42 -0500
Date: Sat, 20 Dec 2014 06:13:37 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Omar Sandoval <osandov@osandov.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org,
        linux-mm@kvack.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v2 4/5] swapfile: use ->read_iter and ->write_iter
Message-ID: <20141220061337.GB22149@ZenIV.linux.org.uk>
References: <cover.1419044605.git.osandov@osandov.com>
 <d8819b57849221b3db7c479f070067808912f0d5.1419044605.git.osandov@osandov.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <d8819b57849221b3db7c479f070067808912f0d5.1419044605.git.osandov@osandov.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 19, 2014 at 07:18:28PM -0800, Omar Sandoval wrote:

> +		ret = swap_file->f_op->read_iter(&kiocb, &to);
> +		if (ret == PAGE_SIZE) {
> +			SetPageUptodate(page);
>  			count_vm_event(PSWPIN);
> +			ret = 0;
> +		} else {
> +			ClearPageUptodate(page);
> +			SetPageError(page);
> +		}
> +		unlock_page(page);

Umm...  What's to guarantee that ->read_iter() won't try lock_page() on what
turns out to be equal to page?
