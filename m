Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f53.google.com ([209.85.192.53]:41828 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751091AbaLCP4x (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Dec 2014 10:56:53 -0500
Date: Wed, 3 Dec 2014 10:56:49 -0500
From: Tejun Heo <tj@kernel.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: NeilBrown <neilb@suse.de>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: [RFC PATCH 00/14] nfsd/sunrpc: add support for a workqueue-based
 nfsd
Message-ID: <20141203155649.GB5013@htj.dyndns.org>
References: <1417544663-13299-1-git-send-email-jlayton@primarydata.com>
 <20141203121118.21a32fe1@notabene.brown>
 <20141202202946.1e0f399b@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141202202946.1e0f399b@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello, Neil, Jeff.

On Tue, Dec 02, 2014 at 08:29:46PM -0500, Jeff Layton wrote:
> That's a good point. I had originally thought that max_active on an
> unbound workqueue would be the number of concurrent jobs that could run
> across all the CPUs, but now that I look I'm not sure that's really
> the case.

@max_active is a per-pool number.  By default, unbound wqs use
per-node pools, so @max_active would be per-node.  Currently,
@max_active is mostly meant as a protection against run-away
workqueues creating crazy number of workers, which has been enough for
the existing wq users.  *Maybe* it makes sense to make it actually
mean maximum concurrency which would prolly involve aggregated per-cpu
distribution mechanism so that we don't end up inc'ing and dec'ing the
same counter from all CPUs on each work item execution.

However, I do agree with Neil that making it user configurable is
almost always painful.  It's usually a question without a good answer
and the same value may behave differently depending on a lot of
implementation details and a better approach, probably, is to use
@max_active as the last resort protection mechanism while providing
automatic throttling of in-flight work items which is meaningful for
the specific use cases.

> I've heard random grumblings from various people in the past that
> workqueues have significant latency, but this is the first time I've
> really hit it in practice. If we can get this fixed, then that may be a
> significant perf win for all workqueue users. For instance, rpciod in
> the NFS client is all workqueue-based. Getting that latency down could
> really help things.
> 
> I'm currently trying to roll up a kernel module for benchmarking the
> workqueue dispatching code in the hopes that we can use that to help
> nail it down.

Definitely, there were some reportings but nothing really got tracked
down properly.  It'd be awesome to actually find out where the latency
is coming from.

Thanks!

-- 
tejun
