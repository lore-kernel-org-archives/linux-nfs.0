From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 1/4] SUNRPC: spin svc_rqst initialization to its own
 function
Date: Fri, 18 Jan 2008 16:48:44 -0500
Message-ID: <20080118164844.7f91d6ff@tleilax.poochiereds.net>
References: <1200319518-22422-1-git-send-email-jlayton@redhat.com>
	<1200319518-22422-2-git-send-email-jlayton@redhat.com>
	<20080118205943.GL15158@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: neilb@suse.de, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:44192 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761415AbYARVst (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Jan 2008 16:48:49 -0500
In-Reply-To: <20080118205943.GL15158@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 18 Jan 2008 15:59:43 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Jan 14, 2008 at 09:05:15AM -0500, Jeff Layton wrote:
> > Move the initialzation in __svc_create_thread that happens prior to
> > thread creation to a new function. Export the function to allow
> > services to have better control over the svc_rqst structs.
> > 
> > Also rearrange the rqstp initialization to prevent NULL pointer
> > dereferences in svc_exit_thread in case allocations fail.
> 
> Those NULL dereferences are from the
> 
> 	list_del(&rqstp->rq_all);
> 
> ?  OK, make sense.  Thanks!
> 
> --b.
> 

Sorry, I didn't explain that well...

This was the problem that Neil pointed out with the existing code. If
the rqstp kzalloc succeeds, but the later kmallocs in
__svc_create_thread fail, we goto here:

    out_thread:
            svc_exit_thread(rqstp);

svc_exit_thread does this:

    struct svc_pool *pool = rqstp->rq_pool;

...and then later:

   spin_lock_bh(&pool->sp_lock);

...but rq_pool is set after the kmallocs, so if they fail rq_pool will
be NULL, and we'll oops in that spin_lock_bh().

The fix is to move the kmallocs closer to the bottom in the new
svc_prepare_thread function.

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>
