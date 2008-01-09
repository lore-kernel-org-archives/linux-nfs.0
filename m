From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 6/6] NLM: Add reference counting to lockd
Date: Wed, 9 Jan 2008 17:47:07 +0000
Message-ID: <20080109174707.GC30523@infradead.org>
References: <1199820798-5289-1-git-send-email-jlayton@redhat.com> <1199820798-5289-2-git-send-email-jlayton@redhat.com> <1199820798-5289-3-git-send-email-jlayton@redhat.com> <1199820798-5289-4-git-send-email-jlayton@redhat.com> <1199820798-5289-5-git-send-email-jlayton@redhat.com> <1199820798-5289-6-git-send-email-jlayton@redhat.com> <1199820798-5289-7-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, neilb@suse.de,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:53342 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753953AbYAIRrM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jan 2008 12:47:12 -0500
In-Reply-To: <1199820798-5289-7-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 08, 2008 at 02:33:18PM -0500, Jeff Layton wrote:
> ...and only have lockd exit when the last reference is dropped.
> 
> The problem is this:
> 
> When a lock that a client is blocking on comes free, lockd does this in
> nlmsvc_grant_blocked():
> 
>     nlm_async_call(block->b_call, NLMPROC_GRANTED_MSG, &nlmsvc_grant_ops);
> 
> the callback from this call is nlmsvc_grant_callback(). That function
> does this at the end to wake up lockd:
> 
>     svc_wake_up(block->b_daemon);
> 
> However there is no guarantee that lockd will be up when this happens.
> If someone shuts down or restarts lockd before the async call completes,
> then the b_daemon pointer will point to freed memory and the kernel may
> oops.
> 
> I first noticed this on older kernels and had mistakenly thought that
> newer kernels weren't susceptible, but that's not correct. There's a bit
> of a race to make sure that the nlm_host is bound when the async call is
> done, but I can now reproduce this at will on current kernels.
> 
> This patch is based on Trond's suggestion to add a new reference counter
> to lockd, and only allows lockd to go down when it reaches 0. With this
> change we can't use kthread_stop here. nlmsvc_unlink_block is called by
> lockd and a kthread can't call kthread_stop on itself. So the patch
> changes lockd to check the refcount itself and to return if it goes to
> 0. We do the checking and exit while holding the nlmsvc_mutex to make
> sure that a new lockd is not started until the old one is down.

I don't like this signals/kthread mixture at all.  Why can't we simply
call kthread_stop when the refcount hits zero and keep all the nice
kthread helpers?

