From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] sunrpc: make warning in svc_check_conn_limits() more
 generic
Date: Wed, 15 Oct 2008 20:51:18 -0400
Message-ID: <20081015205118.14de4611@tleilax.poochiereds.net>
References: <1221225127-6042-1-git-send-email-jlayton@redhat.com>
	<20080924215742.GG10841@fieldses.org>
	<20080925162315.6f29d092@tleilax.poochiereds.net>
	<20081015081457.56ef3778@tleilax.poochiereds.net>
	<20081015202102.GC5038@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, neilb@suse.de
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:50488 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752348AbYJPAwG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Oct 2008 20:52:06 -0400
In-Reply-To: <20081015202102.GC5038@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 15 Oct 2008 16:21:02 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Wed, Oct 15, 2008 at 08:14:57AM -0400, Jeff Layton wrote:
> > From the descriptions in those commits, it looks like the check
> > in svc_check_conn_limits was intended to prevent messages from too
> > many sockets overloading the receive buffers.
> 
> Aren't the receive buffers per-connection?
> 
> --b.
> 

Oof...you're quite right. I misunderstood the code earlier. Thinking
this through a bit more...

I suppose the main worry is that we have a service with too few
threads and a ton of sockets. We end up in a situation where the
receive buffers aren't getting processed quickly enough and connections
start stalling out.

I suppose the only real remedy for that is to increase the number of
threads, but that's not an option for services like lockd. So maybe
ignoring this check on single-threaded services is the way to go after
all? I don't see a way to make this auto-tuning based on memory since
that doesn't seem to be what the check is intended to help...

-- 
Jeff Layton <jlayton@redhat.com>
