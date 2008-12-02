From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH/RFC] svcgssd always sets an infinite expiry on
	authentication tokens etc.
Date: Tue, 2 Dec 2008 18:23:44 -0500
Message-ID: <20081202232344.GM20616@fieldses.org>
References: <18740.50457.981544.21225@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, Kevin Coffman <kwc@citi.umich.edu>,
	Steve Dickson <SteveD@redhat.com>
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:53292 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751027AbYLBXXq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Dec 2008 18:23:46 -0500
In-Reply-To: <18740.50457.981544.21225-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 02, 2008 at 04:18:17PM +1100, Neil Brown wrote:
>  I have a report of an NFS server which runs out of kernel memory when
>  it gets heave rpcsec_gss traffic (auth_sys doesn't trigger the
>  problem so it must be gss related).
> 
>  From looking at /proc/slab_allocators it seems that the main user of
>  memory is the rsc and rsi caches.
>  It appears entries are inserted into these caches with an expiry of
>  'forever' so they grow but never shrink.
>  We should fix this.

Yes, definitely a leak.  But it's funny, I have a strong memory of a
conversation on one of these lists with someone who looked into this
problem and found that even with some silly artificial tests that
established as many contexts per second as possible, they weren't able
to see significant memory consumption--but I can't find the thread now.

Some limit on the size might also be nice depending on what the worst
case looks like with expiries of about a day.

--b.

> 
>  For the rsi (init) cache I assume the entry is only needed once so a
>  short expiry of (say) one minute should be plenty.
>  For the rsc (context) cache, the entry could be needed repeatedly
>  during the lifetime of a 'session'.  However eventually it will
>  become stale and should be allowed to expire.
> 
>  I assume that if the kernel requests a particular entry a second
>  time, an hour later, it will get the same answer - is that correct?
> 
>  In that case, setting the expiry to something largish seems
>  appropriate.
> 
>  Hence the following patch (untested yet - but I will get it tested in
>  due course).
> 
>  Does this seem reasonable?
