From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] sunrpc: make warning in svc_check_conn_limits() more
	generic
Date: Wed, 15 Oct 2008 16:21:02 -0400
Message-ID: <20081015202102.GC5038@fieldses.org>
References: <1221225127-6042-1-git-send-email-jlayton@redhat.com> <20080924215742.GG10841@fieldses.org> <20080925162315.6f29d092@tleilax.poochiereds.net> <20081015081457.56ef3778@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, neilb@suse.de
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:59125 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753325AbYJOUVG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Oct 2008 16:21:06 -0400
In-Reply-To: <20081015081457.56ef3778-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 15, 2008 at 08:14:57AM -0400, Jeff Layton wrote:
> From the descriptions in those commits, it looks like the check
> in svc_check_conn_limits was intended to prevent messages from too
> many sockets overloading the receive buffers.

Aren't the receive buffers per-connection?

--b.

> We size the UDP receive buffers by the number of threads:
> 
>     (serv->sv_nrthreads+3) * serv->sv_max_mesg
> 
> TCP receive buffers are statically sized fairly small and don't ever
> seem to change since sv_max_mesg is pretty much set at server
> creation time:
> 
>      3 * serv->sv_max_mesg
> 
> ...the comments in svc_tcp_recvfrom explain the reason for it.
> 
> Given all of this, it seems reasonable to eliminate the check
> entirely for TCP. For UDP, it looks like we expect that 1 buffer
> can handle up to 20 connections. I'm not sure where this ratio
> comes from though...
> 
> Anyone else have thoughts on this?
> 
> -- 
> Jeff Layton <jlayton@redhat.com>
