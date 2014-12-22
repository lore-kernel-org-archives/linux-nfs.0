Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f42.google.com ([209.85.220.42]:57808 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753602AbaLVHci (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Dec 2014 02:32:38 -0500
Received: by mail-pa0-f42.google.com with SMTP id et14so5435839pad.1
        for <linux-nfs@vger.kernel.org>; Sun, 21 Dec 2014 23:32:38 -0800 (PST)
Date: Sun, 21 Dec 2014 23:32:34 -0800
From: Omar Sandoval <osandov@osandov.com>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org,
        linux-mm@kvack.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v2 4/5] swapfile: use ->read_iter and ->write_iter
Message-ID: <20141222073234.GA14207@mew>
References: <cover.1419044605.git.osandov@osandov.com>
 <d8819b57849221b3db7c479f070067808912f0d5.1419044605.git.osandov@osandov.com>
 <20141220061337.GB22149@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141220061337.GB22149@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Dec 20, 2014 at 06:13:37AM +0000, Al Viro wrote:
> On Fri, Dec 19, 2014 at 07:18:28PM -0800, Omar Sandoval wrote:
> 
> > +		ret = swap_file->f_op->read_iter(&kiocb, &to);
> > +		if (ret == PAGE_SIZE) {
> > +			SetPageUptodate(page);
> >  			count_vm_event(PSWPIN);
> > +			ret = 0;
> > +		} else {
> > +			ClearPageUptodate(page);
> > +			SetPageError(page);
> > +		}
> > +		unlock_page(page);
> 
> Umm...  What's to guarantee that ->read_iter() won't try lock_page() on what
> turns out to be equal to page?

Ergh. I don't see why ->read_iter would be screwing around in the swap
cache or with the pages in the iterator, anything in particular you can
see happening?

-- 
Omar
