From: Jeff Layton <jlayton@redhat.com>
Subject: Re: Strange lockup during unmount in 2.6.22 - maybe rpciod
 deadlock?
Date: Thu, 21 Feb 2008 07:16:30 -0500
Message-ID: <20080221071630.225b9473@tleilax.poochiereds.net>
References: <18310.37731.29874.582772@notabene.brown>
	<1200004896.13775.27.camel@heimdal.trondhjem.org>
	<18362.27251.619125.502340@notabene.brown>
	<1203449166.8156.85.camel@heimdal.trondhjem.org>
	<18365.1274.387629.944796@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54234 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750959AbYBUMQo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Feb 2008 07:16:44 -0500
In-Reply-To: <18365.1274.387629.944796-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 21 Feb 2008 15:58:34 +1100
Neil Brown <neilb@suse.de> wrote:

> My question is:  *why* cannot rpc_shutdown_client complete until all
> active rpc_tasks complete?  The use of reference counting ensure that
> once they do all complete, the client will be finally released and any
> relevant modules will also be released.
> 
> Is there really any need to wait for completion?
> 

I can't speak for all uses of rpc_shutdown_client, but the fix I sent
up recently for the use after free when taking down lockd depends on
this. If we change the semantics of rpc_shutdown_client this way then
we'll need to fix that in some other way. I need to know that when I'm
taking down lockd that all of the grant callbacks in the RPC queue are
completely dead.

-- 
Jeff Layton <jlayton@redhat.com>
