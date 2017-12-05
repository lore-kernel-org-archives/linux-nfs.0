Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:35904 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752553AbdLEXX2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Dec 2017 18:23:28 -0500
Date: Tue, 5 Dec 2017 15:23:26 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Thiago Rafael Becker <thiago.becker@gmail.com>
Cc: NeilBrown <neilb@suse.com>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/3, V2] kernel: Move groups_sort to the caller of
 set_groups.
Message-ID: <20171205232326.GH26021@bombadil.infradead.org>
References: <20171130130457.11429-1-thiago.becker@gmail.com>
 <20171130130457.11429-3-thiago.becker@gmail.com>
 <87mv2ztgix.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1712041049280.1738@tbecker-rhat>
 <87efoatfsb.fsf@notabene.neil.brown.name>
 <20171205212847.GF26021@bombadil.infradead.org>
 <alpine.LFD.2.21.1712052010280.15244@tbecker-rhat>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <alpine.LFD.2.21.1712052010280.15244@tbecker-rhat>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 05, 2017 at 09:03:02PM -0200, Thiago Rafael Becker wrote:
> On Tue, 5 Dec 2017, Matthew Wilcox wrote:
> > It must be relatively common to sort an already-sorted array.  I wonder
> > if something like this patch would be worthwhile?
> 
> The bug happens when two threads enter sort_groups for the same group info
> in parallel, and one thread starts overwriting values that another thread
> may already have "heapified" or sorted.
> 
> Thread A                  Thread B
> Enter groups_sort
>                           Enter groups_sort
> .
> .
> .
> Return from groups_sort
>                           .
>                           .
>                           .
>                           Return from groups_sort
> 
> Wouldn't this patch just make both threads see the structure as unsorted and
> sort them?

I'm sorry, I wasn't clear.  I wasn't commenting on the original bug (and
I believe your analysis to be correct unless there's some locking which
prevents two calls to group_sort from happening at the same time).

I was wondering about whether our sort() implementation is the best that
it could possibly be, and whether having the trait of not modifying an
already-sorted array is worthwhile (eg it would not cause cachelines to
enter the dirty state if they were already clean).
