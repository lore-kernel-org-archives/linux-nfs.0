From: Neil Brown <neilb@suse.de>
Subject: Re: Strange lockup during unmount in 2.6.22 - maybe rpciod
	deadlock?
Date: Thu, 21 Feb 2008 16:16:09 +1100
Message-ID: <18365.2329.495660.107605@notabene.brown>
References: <1203449166.8156.85.camel@heimdal.trondhjem.org>
	<1203463105.21343.20.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:57222 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751111AbYBUFQF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Feb 2008 00:16:05 -0500
In-Reply-To: message from Trond Myklebust on Tuesday February 19
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tuesday February 19, Trond.Myklebust@netapp.com wrote:
> How about moving the offending mntput calls off rpciod altogether? That
> way we can avoid both the deadlock with rpc_shutdown_client() and the
> deadlock with nfs_put_super().
> The other advantage of doing this is that we move all those deadlocky
> little malloc() calls from the NFSv4 open(), close(), lock(), and
> locku() out of rpciod too. Ditto for the delegation return stuff that
> may result from the dput() calls...

Yes, that sounds like a reasonable approach.

Adding extra threads is not something I would want to do too lightly,
but it does seem reasonably justified here.

> 
> The way I'm attempting to do this, is to add something like the
> following patch series (which has been compile tested, but not
> run-tested quite yet). It basically creates an 'nfsiod' workqueue, and
> allows the NFS read/write/... code to specify that the
> tk_ops->rpc_release() callback should be run on that particular
> workqueue. It then moves all the mntput()/dput() stuff into the
> rpc_release() call...

Seems to make sense, but I'm not really familiar enough with the code
to be sure.


Thanks,
NeilBrown
