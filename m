From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/2] NLM: Convert lockd to use kthreads
Date: Thu, 7 Feb 2008 03:50:05 -0500
Message-ID: <20080207085005.GB21720@infradead.org>
References: <1202240277-24437-1-git-send-email-jlayton@redhat.com> <1202240277-24437-2-git-send-email-jlayton@redhat.com> <1202240277-24437-3-git-send-email-jlayton@redhat.com> <20080206043548.GA9747@infradead.org> <20080206073428.33bfd8d4@barsoom.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>, bfields@citi.umich.edu,
	neilb@suse.de, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:39302 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755435AbYBGIuM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Feb 2008 03:50:12 -0500
In-Reply-To: <20080206073428.33bfd8d4-xSBYVWDuneFaJnirhKH9O4GKTjYczspe@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 06, 2008 at 07:34:28AM -0500, Jeff Layton wrote:
> Yes. Perhaps we should consider a kthread_stop_with_signal() function
> that does a kthread_stop and sends a signal before waiting for
> completion? Most users of kthread_stop won't need it, but it would be
> nice here. CIFS could also probably use something like that.

Yes, it'd be useful for everythign that calls socket functions from
a kernel thread.

