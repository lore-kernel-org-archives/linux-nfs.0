From: Neil Brown <neilb@suse.de>
Subject: Re: Strange lockup during unmount in 2.6.22 - maybe rpciod
	deadlock?
Date: Fri, 22 Feb 2008 11:31:57 +1100
Message-ID: <18366.6141.122127.181304@notabene.brown>
References: <18310.37731.29874.582772@notabene.brown>
	<1200004896.13775.27.camel@heimdal.trondhjem.org>
	<18362.27251.619125.502340@notabene.brown>
	<1203449166.8156.85.camel@heimdal.trondhjem.org>
	<18365.1274.387629.944796@notabene.brown>
	<1203607653.10477.22.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:57035 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936322AbYBVAbz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Feb 2008 19:31:55 -0500
In-Reply-To: message from Trond Myklebust on Thursday February 21
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thursday February 21, trond.myklebust@fys.uio.no wrote:
> 
> On Thu, 2008-02-21 at 15:58 +1100, Neil Brown wrote:
> 
> > My question is:  *why* cannot rpc_shutdown_client complete until all
> > active rpc_tasks complete?  The use of reference counting ensure that
> > once they do all complete, the client will be finally released and any
> > relevant modules will also be released.
> > 
> > Is there really any need to wait for completion?
> 
> Looking at the code, I suspect that you can probably get rid of the
> rpc_shutdown_client() without creating too much trouble (since we now
> hold a reference to the vfsmount in most of the asynchronous
> operations).
> 
> However the asynchronous sillyrenames are still a problem: if you don't
> wait for the sillyrename RPC call to complete, then you end up with the
> famous "Self-destruct in 5 seconds" message on umount (because we have
> to hold a reference to the directory inode for the duration of the RPC
> call if we want to avoid lookup races and cache consistency issues
> during normal operation).

Could the sillyrename call hold a reference to the vfsmount???

I guess that would mean that an unmount could fail with EBUSY when you
don't expect it...

Presumably the sillyrename delete happens on close... could the close
wait for the sillyrename delete to finish?  That would hold everything
busy in a sensible way.

But I suspect there are good answers, you've doubtless thought about
it more than me :-)

> Hence, I think the extra workqueue is justified by the fact that rpciod
> cannot ever wait for the sillyrename calls to complete.
> 

Sounds like we've arrived at a good solution - thanks!

Now I just have to decide which bits, if any, to bother back-porting
to OpenSUSE before I close the bug that started all of this :-)

NeilBrown
