From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH] NLM: hold BKL when clearing global lockd task and serv
	vars
Date: Mon, 07 Apr 2008 14:08:30 -0500
Message-ID: <1207595310.9447.18.camel@trinity.ogc.int>
References: <1207575514-6703-1-git-send-email-jlayton@redhat.com>
	 <1207575514-6703-2-git-send-email-jlayton@redhat.com>
	 <20080407164500.GA17728@infradead.org> <20080407175615.GD3305@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Christoph Hellwig <hch@infradead.org>,
	Jeff Layton <jlayton@redhat.com>, trond.myklebust@fys.uio.no,
	nfsv4@linux-nfs.org, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:40939 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751972AbYDGTIG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Apr 2008 15:08:06 -0400
In-Reply-To: <20080407175615.GD3305@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mon, 2008-04-07 at 13:56 -0400, J. Bruce Fields wrote:
> On Mon, Apr 07, 2008 at 12:45:01PM -0400, Christoph Hellwig wrote:
> > On Mon, Apr 07, 2008 at 09:38:34AM -0400, Jeff Layton wrote:
> > > The global task and serv pointers for lockd are normally protected by
> > > the nlmsvc_mutex. The exception is when the lockd exits abnormally. When
> > > this occurs, these variables are cleared without any locking.
> > 
> > Shouldn't we get rid of the case where it exits abnormally instead?
> 
> I tried to figure out when this could actually occur (when can
> svc_recv() return an error other than -EINTR or -EAGAIN?), and got lost
> in sock_recvmsg():
> 
> 	- svc_recv() itself returns only -EAGAIN or the return from
> 	  ->xpo_recvfrom().
> 	- the only xpo_recvfrom() that's interesting is
> 	  svc_tcp_recvfrom(), which can return the error it gets from
> 	  svc_recvfrom(), which can return the error from
> 	  kernel_recvmsg(), which gets its return from sock_recvmsg().
> 
> Since __sock_recvmsg() has a security hook, it looks like we can end up
> with an -EACCES from selinux?

FWIW: I believe that if svc_recv returns anything other then -EINTR or
-EAGAIN, the service thread exits. I believe that the current design
(could be broken) is that if the transport finds an error, the action is
to set the XPT_CLOSE bit, enqueue the transport and return -EAGAIN. This
will cause the service thread to call svc_recv again and close
processing to occur.

> 
> So one case would be selinux deciding we weren't allowed to receive
> packets from this socket.  Huh.
> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

