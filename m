From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] NLM: Add lockd reference counting and clean up lockd
 startup and shutdown
Date: Sat, 8 Dec 2007 09:17:54 -0500
Message-ID: <20071208091754.47ccc377@tleilax.poochiereds.net>
References: <1197118932-4512-1-git-send-email-jlayton@redhat.com>
	<20071208140747.GA11675@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	linux-kernel@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:33510 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751163AbXLHOSK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 8 Dec 2007 09:18:10 -0500
In-Reply-To: <20071208140747.GA11675@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 8 Dec 2007 14:07:47 +0000
Christoph Hellwig <hch@infradead.org> wrote:

> > +	mutex_lock(&nlmsvc_mutex);
> > +	while (atomic_read(&nlmsvc_ref) != 0) {
> 
> might be better to do the refcounting outside the thread and use the
> kthread api, which is something we still need to do for lockd anyway.
> 

Currently sending a SIGKILL to lockd tells it to drop all of its locks
without exiting. If we change lockd to use kthreads, will we have to
change that to use a different mechanism?

-- 
Jeff Layton <jlayton@redhat.com>
