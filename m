Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:38609 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751332Ab0HTJTJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Aug 2010 05:19:09 -0400
Date: Fri, 20 Aug 2010 05:19:04 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Wu Fengguang <fengguang.wu@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>, Jeff Layton <jlayton@redhat.com>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>,
        Jens Axboe <jens.axboe@oracle.com>
Subject: Re: why are WB_SYNC_NONE COMMITs being done with FLUSH_SYNC set ?
Message-ID: <20100820091904.GB20138@infradead.org>
References: <20100819101525.076831ad@barsoom.rdu.redhat.com>
 <20100819143710.GA4752@infradead.org>
 <20100819235553.GB22747@localhost>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100819235553.GB22747@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Aug 20, 2010 at 07:55:53AM +0800, Wu Fengguang wrote:
> Since migration and pageout still set nonblocking for ->writepage, we
> may keep them in the near future, until VM does not start IO on itself.

Why does pageout() and memory migration need to be even more
non-blocking than the already non-blockig WB_SYNC_NONE writeout?

