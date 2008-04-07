From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] NLM: hold BKL when clearing global lockd task and serv
	vars
Date: Mon, 7 Apr 2008 13:56:15 -0400
Message-ID: <20080407175615.GD3305@fieldses.org>
References: <1207575514-6703-1-git-send-email-jlayton@redhat.com> <1207575514-6703-2-git-send-email-jlayton@redhat.com> <20080407164500.GA17728@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Layton <jlayton@redhat.com>, trond.myklebust@fys.uio.no,
	nfsv4@linux-nfs.org, linux-nfs@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:34085 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751719AbYDGR4b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Apr 2008 13:56:31 -0400
In-Reply-To: <20080407164500.GA17728@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 07, 2008 at 12:45:01PM -0400, Christoph Hellwig wrote:
> On Mon, Apr 07, 2008 at 09:38:34AM -0400, Jeff Layton wrote:
> > The global task and serv pointers for lockd are normally protected by
> > the nlmsvc_mutex. The exception is when the lockd exits abnormally. When
> > this occurs, these variables are cleared without any locking.
> 
> Shouldn't we get rid of the case where it exits abnormally instead?

I tried to figure out when this could actually occur (when can
svc_recv() return an error other than -EINTR or -EAGAIN?), and got lost
in sock_recvmsg():

	- svc_recv() itself returns only -EAGAIN or the return from
	  ->xpo_recvfrom().
	- the only xpo_recvfrom() that's interesting is
	  svc_tcp_recvfrom(), which can return the error it gets from
	  svc_recvfrom(), which can return the error from
	  kernel_recvmsg(), which gets its return from sock_recvmsg().

Since __sock_recvmsg() has a security hook, it looks like we can end up
with an -EACCES from selinux?

So one case would be selinux deciding we weren't allowed to receive
packets from this socket.  Huh.

--b.
