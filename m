Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43746 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759661Ab2EIOfS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 May 2012 10:35:18 -0400
Date: Wed, 9 May 2012 10:35:18 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: per-net rpc shutdown
Message-ID: <20120509143518.GB24233@fieldses.org>
References: <20120509142617.GA24233@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120509142617.GA24233@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 09, 2012 at 10:26:17AM -0400, J. Bruce Fields wrote:
> Reviewing your more recent patches I think we have a problem with some
> of the code that's already merged.  See the comment in svc_shutdown_net:
> 
> 	void svc_shutdown_net(struct svc_serv *serv, struct net *net)
> 	{               

By the way, note there's some preexisting trouble here:

> 		/*      
> 		 * The set of xprts (contained in the sv_tempsocks and
> 		 * sv_permsocks lists) is now constant, since it is modified
> 		 * only by accepting new sockets (done by service threads in
> 		 * svc_recv) or aging old ones (done by sv_temptimer), or
> 		 * configuration changes (excluded by whatever locking the
> 		 * caller is using--nfsd_mutex in the case of nfsd).

I don't think the callers are as careful about this as they should be,
so I think there may be some cases where we could crash if there are
multiple processes concurrently trying to start, stop, and/or modify the
listening sockets of a server.

We need to fix that too.

(I haven't actually seen that bug in practice.  We *did* see people hit
bugs on shutdown of a busy server before fixing the receive/shutdown
races, though.)

--b.

>		   So it's
> 		 * safe to traverse those lists and shut everything down:
> 		 */       
> 		svc_close_net(serv, net);
> 	
> 		if (serv->sv_shutdown)
> 			serv->sv_shutdown(serv, net);
> 	}
> 
> So we depend on the fact that neither the server threads nor
> sv_temptimer are running here to be able to safely traverse those lists
> of sockets.
> 
> But it looks to me like that's no longer true--we're shutting down just
> one namespace here, and others may still be running.  If so and if they
> modify sv_tempsocks or sv_permsocks while we're running through them
> then we're going to get a crash.
> 
> --b.
