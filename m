Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:45453 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752673Ab3LRMlb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Dec 2013 07:41:31 -0500
Date: Wed, 18 Dec 2013 04:41:26 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Zach Brown <zab@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Bryan Schumaker <bjschuma@netapp.com>,
        "Martin K. Petersen" <mkp@mkp.net>, Jens Axboe <axboe@kernel.dk>,
        Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>,
        Eric Wong <normalperson@yhbt.net>
Subject: Re: [RFC] extending splice for copy offloading
Message-ID: <20131218124126.GA15328@infradead.org>
References: <1378919210-10372-1-git-send-email-zab@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1378919210-10372-1-git-send-email-zab@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 11, 2013 at 10:06:47AM -0700, Zach Brown wrote:
> When I first started on this stuff I followed the lead of previous
> work and added a new syscall for the copy operation:
> 
> https://lkml.org/lkml/2013/5/14/618
> 
> Towards the end of that thread Eric Wong asked why we didn't just
> extend splice.  I immediately replied with some dumb dismissive
> answer.  Once I sat down and looked at it, though, it does make a
> lot of sense.  So good job, Eric.  +10 Dummie points for me.
> 
> Extending splice avoids all the noise of adding a new syscall and
> naturally falls back to buffered copying as that's what the direct
> splice path does for sendfile() today.

Given the convolute mess that the splice code already is I'd rather
prefer not overloading it even further.

Instead I'd make the sendfile code path that already works different
in practice separate first, and then generalize it to a copy chunk
syscall using the same code path.

We can still fall back to the splice code as a fallback if no option
is provided as a last resort, but I think making the splice code handle
even more totally different cases is the wrong direction.

