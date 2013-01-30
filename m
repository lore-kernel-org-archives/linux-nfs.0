Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39570 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753098Ab3A3OXN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Jan 2013 09:23:13 -0500
Date: Wed, 30 Jan 2013 09:23:08 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Subject: Re: [RFC PATCH] SUNRPC: protect transport processing with rw sem
Message-ID: <20130130142308.GC12306@fieldses.org>
References: <20130129110317.29541.51920.stgit@localhost.localdomain>
 <20130129225736.GC6219@fieldses.org>
 <5108B2B6.7010807@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <5108B2B6.7010807@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 30, 2013 at 09:42:14AM +0400, Stanislav Kinsbursky wrote:
> 30.01.2013 02:57, J. Bruce Fields пишет:
> >On Tue, Jan 29, 2013 at 02:03:30PM +0300, Stanislav Kinsbursky wrote:
> >>There could be a service transport, which is processed by service thread and
> >>racing in the same time with per-net service shutdown like listed below:
> >>
> >>CPU#0:                            CPU#1:
> >>
> >>svc_recv                        svc_close_net
> >>svc_get_next_xprt (list_del_init(xpt_ready))
> >>                             svc_close_list (set XPT_BUSY and XPT_CLOSE)
> >>                             svc_clear_pools(xprt was gained on CPU#0 already)
> >>                             svc_delete_xprt (set XPT_DEAD)
> >>svc_handle_xprt (is XPT_CLOSE => svc_delete_xprt()
> >>BUG()
> >>
> >>There could be different solutions of the problem.
> >>Probably, the patch doesn't implement the best one, but I hope the simple one.
> >>IOW, it protects critical section (dequeuing of pending transport and
> >>enqueuing  it back to the pool) by per-service rw semaphore,
> >
> >It's actually per-thread (per-struct svc_rqst) here.
> >
> 
> Yes, sure.
> 
> >>taken for read.
> >>On per-net transports shutdown, this semaphore have to be taken for write.
> >
> >There's no down_write in this patch.  Did you forget this part?
> >
> 
> See "fs/nfs/callback.c" part

Whoops, sorry; got it.--b.

> 
> >The server rpc code goes to some care not to write to any global
> >structure, to prevent server threads running on multiple cores from
> >bouncing cache lines between them.
> >
> 
> This is just an idea. I.e. I wasn't trying to polish the patch - just to share the vision.
> 
> >But my understanding is that even down_read() does modify the semaphore.
> >So we might want something like the percpu semaphore describe in
> >Documentation/percpu-rw-semaphore.txt.
> >
> 
> Sure, I'll have a look.
> 
> 
> -- 
> Best regards,
> Stanislav Kinsbursky
