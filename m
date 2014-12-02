Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f172.google.com ([209.85.216.172]:43423 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933696AbaLBT0a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Dec 2014 14:26:30 -0500
Received: by mail-qc0-f172.google.com with SMTP id m20so9854444qcx.17
        for <linux-nfs@vger.kernel.org>; Tue, 02 Dec 2014 11:26:29 -0800 (PST)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 2 Dec 2014 14:26:27 -0500
To: Tejun Heo <tj@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: [RFC PATCH 00/14] nfsd/sunrpc: add support for a
 workqueue-based nfsd
Message-ID: <20141202142627.6f59f693@tlielax.poochiereds.net>
In-Reply-To: <20141202191814.GK10918@htj.dyndns.org>
References: <1417544663-13299-1-git-send-email-jlayton@primarydata.com>
	<20141202191814.GK10918@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2 Dec 2014 14:18:14 -0500
Tejun Heo <tj@kernel.org> wrote:

> Hello, Jeff.
> 
> On Tue, Dec 02, 2014 at 01:24:09PM -0500, Jeff Layton wrote:
> > 2) get some insight about the latency from those with a better
> > understanding of the CMWQ code. Any thoughts as to why we might be
> > seeing such high latency here? Any ideas of what we can do about it?
> 
> The latency is prolly from concurrency management.  Work items which
> participate in concurrency management (the ones on per-cpu workqueues
> w/o WQ_CPU_INTENSIVE set) tend to get penalized on latency side quite
> a bit as the "run" durations for all such work items end up being
> serialized on the cpu.  Setting WQ_CPU_INTENSIVE on the workqueue
> disables concurrency management and so does making the workqueue
> unbound.  If strict cpu locality is likely to be beneficial and each
> work item isn't likely to consume huge amount of cpu cycles,
> WQ_CPU_INTENSIVE would fit better; otherwise, WQ_UNBOUND to let the
> scheduler do its thing.
> 
> Thanks.
> 

Thanks Tejun,

I'm already using WQ_UNBOUND workqueues. If that exempts this code from
the concurrency management, then that's probably not the problem. The
jobs here aren't terribly CPU intensive, but they can sleep for a long
time while waiting on I/O, etc...

I don't think we necessarily need CPU locality (though that's nice to
have of course), but NUMA affinity will likely be important. It looked
like you had done some work a year or so ago to make unbound workqueues
prefer to queue work on the same NUMA node which meshes nicely with
what I think we want for this.

I'll keep looking at it -- let me know if you have any other thoughts
on the latency...

Cheers!
-- 
Jeff Layton <jlayton@primarydata.com>
