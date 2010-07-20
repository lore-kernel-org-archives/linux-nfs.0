Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:32884 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758407Ab0GTO4V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Jul 2010 10:56:21 -0400
Date: Tue, 20 Jul 2010 10:55:40 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/5] nfsd: fix error handling in write_ports interfaces
 (resend)
Message-ID: <20100720145540.GA28972@fieldses.org>
References: <1279572608-7234-1-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1279572608-7234-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Jul 19, 2010 at 04:50:03PM -0400, Jeff Layton wrote:
> This patchset is a resend of the set I sent a month or so ago, with
> a couple of other patches to fix related problems that came to light
> as we were discussing them.

So, rpc.nfsd starts the nfs server by more or less:

	1. write nfs versions to /proc/fs/nfsd/versions
	2. write tcp socket fd to /proc/fs/nfsd/portlist
	3. write udp socket fd to /proc/fs/nfsd/portlist
	4. write number of threads to /proc/fs/nfsd/threads

A failure anywhere between step 2 and 4 leaves the server in an odd
state: it's created, but not really running yet.

Your patches help when it's step 2 that fails.  Probably that's the most
common case, so good.

But what if we step 3 fails?  Or rpc.nfsd encounters some other error
between steps 2 and 4?  Does it have any way to clean up?  (Is starting
a single thread and then stopping it the only way to destroy the server
at that point?)  And what if rpc.nfsd is interrupted before it gets to
step 4?

The whole interface seems strange and fragile.

The correct thing may be to apply your patches anyway, as long as they
solve a problem and don't make things any worse.

But I fear we'll be spending more time on corner cases in the future.

As a first exercise, maybe we should figure out how the interface would
look if we had the opportunity to start over from scratch.

--b.

> It's changed a bit from the original set by virtue of the fact that
> patch #5 simplifies the lockd_up/down handling. Let me know if you
> see any problems with the set and I'll work on addressing them.
> 
> Thanks,
> 
> Jeff Layton (5):
>   nfsd: don't try to shut down nfs4 state handling unless it's up
>   nfsd: fix error handling when starting nfsd with rpcbind down
>   nfsd: fix error handling in __write_ports_addxprt
>   nfsd: shut down NFSv4 state when nfsd_svc encounters an error
>   nfsd: just keep single lockd reference for nfsd
> 
>  fs/nfsd/nfs4state.c |    2 ++
>  fs/nfsd/nfsctl.c    |   20 ++++++++------------
>  fs/nfsd/nfssvc.c    |   36 +++++++++++++++++-------------------
>  3 files changed, 27 insertions(+), 31 deletions(-)
> 
