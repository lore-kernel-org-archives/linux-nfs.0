From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Strange lockup during unmount in 2.6.22 - maybe rpciod
	deadlock?
Date: Thu, 21 Feb 2008 10:27:33 -0500
Message-ID: <1203607653.10477.22.camel@heimdal.trondhjem.org>
References: <18310.37731.29874.582772@notabene.brown>
	 <1200004896.13775.27.camel@heimdal.trondhjem.org>
	 <18362.27251.619125.502340@notabene.brown>
	 <1203449166.8156.85.camel@heimdal.trondhjem.org>
	 <18365.1274.387629.944796@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:53655 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754221AbYBUP1i (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Feb 2008 10:27:38 -0500
In-Reply-To: <18365.1274.387629.944796-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Thu, 2008-02-21 at 15:58 +1100, Neil Brown wrote:

> My question is:  *why* cannot rpc_shutdown_client complete until all
> active rpc_tasks complete?  The use of reference counting ensure that
> once they do all complete, the client will be finally released and any
> relevant modules will also be released.
> 
> Is there really any need to wait for completion?

Looking at the code, I suspect that you can probably get rid of the
rpc_shutdown_client() without creating too much trouble (since we now
hold a reference to the vfsmount in most of the asynchronous
operations).

However the asynchronous sillyrenames are still a problem: if you don't
wait for the sillyrename RPC call to complete, then you end up with the
famous "Self-destruct in 5 seconds" message on umount (because we have
to hold a reference to the directory inode for the duration of the RPC
call if we want to avoid lookup races and cache consistency issues
during normal operation).
Hence, I think the extra workqueue is justified by the fact that rpciod
cannot ever wait for the sillyrename calls to complete.



