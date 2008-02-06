From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/2] NLM: Convert lockd to use kthreads
Date: Tue, 5 Feb 2008 23:35:48 -0500
Message-ID: <20080206043548.GA9747@infradead.org>
References: <1202240277-24437-1-git-send-email-jlayton@redhat.com> <1202240277-24437-2-git-send-email-jlayton@redhat.com> <1202240277-24437-3-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bfields@citi.umich.edu, neilb@suse.de, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:38659 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757677AbYBFEfv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Feb 2008 23:35:51 -0500
In-Reply-To: <1202240277-24437-3-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 05, 2008 at 02:37:57PM -0500, Jeff Layton wrote:
> Because kthread_stop blocks until the kthread actually goes down,
> we have to send the signal before calling it. This means that there
> is a very small race window like this where lockd_down could block
> for a long time:
> 
> lockd_down signals lockd
> 				lockd invalidates locks
> 				lockd flushes signals
> 				lockd checks kthread_should_stop
> lockd_down calls kthread_stop
> 				lockd calls svc_recv
> 
> ...and lockd blocks until recvmsg returns. I think this is a
> pretty unlikely scenario though. We could probably ensure it
> doesn't happen with some locking but I'm not sure that it would be
> worth the trouble.

This is not avoidable unless we take sending the signal into the kthread
machinery.  

You should probably add a comment similar to your patch description
above the place where the signal is sent.
