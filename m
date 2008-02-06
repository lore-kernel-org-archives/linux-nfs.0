From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 2/2] NLM: Convert lockd to use kthreads
Date: Wed, 6 Feb 2008 07:34:28 -0500
Message-ID: <20080206073428.33bfd8d4@barsoom.rdu.redhat.com>
References: <1202240277-24437-1-git-send-email-jlayton@redhat.com>
	<1202240277-24437-2-git-send-email-jlayton@redhat.com>
	<1202240277-24437-3-git-send-email-jlayton@redhat.com>
	<20080206043548.GA9747@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: bfields@citi.umich.edu, neilb@suse.de, linux-nfs@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:49530 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761321AbYBFMel (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Feb 2008 07:34:41 -0500
In-Reply-To: <20080206043548.GA9747@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 5 Feb 2008 23:35:48 -0500
Christoph Hellwig <hch@infradead.org> wrote:

> On Tue, Feb 05, 2008 at 02:37:57PM -0500, Jeff Layton wrote:
> > Because kthread_stop blocks until the kthread actually goes down,
> > we have to send the signal before calling it. This means that there
> > is a very small race window like this where lockd_down could block
> > for a long time:
> > 
> > lockd_down signals lockd
> > 				lockd invalidates locks
> > 				lockd flushes signals
> > 				lockd checks kthread_should_stop
> > lockd_down calls kthread_stop
> > 				lockd calls svc_recv
> > 
> > ...and lockd blocks until recvmsg returns. I think this is a
> > pretty unlikely scenario though. We could probably ensure it
> > doesn't happen with some locking but I'm not sure that it would be
> > worth the trouble.
> 
> This is not avoidable unless we take sending the signal into the
> kthread machinery.  
> 

Yes. Perhaps we should consider a kthread_stop_with_signal() function
that does a kthread_stop and sends a signal before waiting for
completion? Most users of kthread_stop won't need it, but it would be
nice here. CIFS could also probably use something like that.

> You should probably add a comment similar to your patch description
> above the place where the signal is sent.

I'll do that and respin...

In the interest of full disclosure, we have some other options besides
sending a signal here:

1) we could call svc_recv with a shorter timeout. This means that lockd
will wake up more frequently, even when it has nothing to do.

2) we could try to ensure that when lockd_down is called that a msg
(maybe a NULL procedure) is sent to lockd's socket to wake it up after
kthread_stop is called. This probably would mean queuing up a task to a
workqueue to do this.

...neither of these seem more palatable than sending a signal.

-- 
Jeff Layton <jlayton@redhat.com>
