Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:51470 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751674Ab0HTNXU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Aug 2010 09:23:20 -0400
Date: Fri, 20 Aug 2010 21:23:09 +0800
From: Wu Fengguang <fengguang.wu@gmail.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Jeff Layton <jlayton@redhat.com>, Christoph Hellwig <hch@infradead.org>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-mm@kvack.org
Subject: Re: why are WB_SYNC_NONE COMMITs being done with FLUSH_SYNC set ?
Message-ID: <20100820132309.GB20126@localhost>
References: <20100819101525.076831ad@barsoom.rdu.redhat.com>
 <20100819143710.GA4752@infradead.org>
 <1282229905.6199.19.camel@heimdal.trondhjem.org>
 <20100819151618.5f769dc9@tlielax.poochiereds.net>
 <1282246999.7799.66.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1282246999.7799.66.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> > Here's a lightly tested patch that turns the check for the two flags
> > into a check for WB_SYNC_NONE. It seems to do the right thing, but I
> > don't have a clear testcase for it. Does this look reasonable?
> 
> Looks fine to me. I'll queue it up for the post-2.6.36 merge window...

Trond, I just created a patch that removes the wbc->nonblocking
definition and all its references except NFS. So there will be merge
dependencies. What should we do?  To push both patches to Andrew's -mm
tree?

Thanks,
Fengguang
