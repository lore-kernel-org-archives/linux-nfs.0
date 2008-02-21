From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: Strange lockup during unmount in 2.6.22 - maybe rpciod
	deadlock?
Date: Thu, 21 Feb 2008 08:34:14 -0500
Message-ID: <1203600855.8839.4.camel@heimdal.trondhjem.org>
References: <1203449166.8156.85.camel@heimdal.trondhjem.org>
	 <1203463105.21343.20.camel@heimdal.trondhjem.org>
	 <18365.2329.495660.107605@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52797 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933007AbYBUNeR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Feb 2008 08:34:17 -0500
In-Reply-To: <18365.2329.495660.107605-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Thu, 2008-02-21 at 16:16 +1100, Neil Brown wrote:
> On Tuesday February 19, Trond.Myklebust@netapp.com wrote:
> > How about moving the offending mntput calls off rpciod altogether? That
> > way we can avoid both the deadlock with rpc_shutdown_client() and the
> > deadlock with nfs_put_super().
> > The other advantage of doing this is that we move all those deadlocky
> > little malloc() calls from the NFSv4 open(), close(), lock(), and
> > locku() out of rpciod too. Ditto for the delegation return stuff that
> > may result from the dput() calls...
> 
> Yes, that sounds like a reasonable approach.
> 
> Adding extra threads is not something I would want to do too lightly,
> but it does seem reasonably justified here.

I did some performance tests, and found that it appears to be acceptable
to replace the multi-threaded workqueue with a single-threaded one, so
I've baked this into the third patch.

I also did some tests with running iozone and lazy-umounting the
partition before killing the iozone threads. That appears to work fine
now...

