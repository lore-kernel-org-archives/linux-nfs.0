From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] NFS: flush signals before taking down callback thread
Date: Tue, 19 Feb 2008 17:22:26 -0500
Message-ID: <20080219222226.GA10656@infradead.org>
References: <1203443495-7854-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:49078 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761624AbYBSWWr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Feb 2008 17:22:47 -0500
In-Reply-To: <1203443495-7854-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 19, 2008 at 12:51:35PM -0500, Jeff Layton wrote:
> Now that the reference counting on the callback thread is working as
> expected, it uncovers another problem.  Peter Staubach noticed while
> testing that patch on an older kernel that he would occasionally see
> this printk in rpc_register fire:
> 
>     "RPC: failed to contact portmap (errno -512).
> 
> The NFSv4 callback thread is signaled by nfs_callback_down(), but never
> flushes that signal. All of the shutdown processing is done with that
> signal pending. This makes it fail the call to unregister the port with
> the portmapper.
> 
> In actuality, this rpc_register call isn't necessary at all since the
> port isn't actually registered with the portmapper anymore. Regardless,
> there doesn't seem to be any reason to leave the signal pending while
> the thread is being shut down and flushing it should generally silence
> that printk.

Wouldn't it be better to not allow for signals to this thread at all?
The code really begs for a similar kthread conversion as the lockd one.
