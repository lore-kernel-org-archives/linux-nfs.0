Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:41824 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750855AbaLCQup convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Dec 2014 11:50:45 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [RFC PATCH 00/14] nfsd/sunrpc: add support for a workqueue-based nfsd
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20141203155649.GB5013@htj.dyndns.org>
Date: Wed, 3 Dec 2014 11:50:32 -0500
Cc: Jeff Layton <jeff.layton@primarydata.com>, Neil Brown <neilb@suse.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        LKML Kernel <linux-kernel@vger.kernel.org>,
        Al Viro <viro@zeniv.linux.org.uk>
Message-Id: <D84C9E44-84EC-426D-95D7-4A7B2F5663AA@oracle.com>
References: <1417544663-13299-1-git-send-email-jlayton@primarydata.com> <20141203121118.21a32fe1@notabene.brown> <20141202202946.1e0f399b@tlielax.poochiereds.net> <20141203155649.GB5013@htj.dyndns.org>
To: Tejun Heo <tj@kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Dec 3, 2014, at 10:56 AM, Tejun Heo <tj@kernel.org> wrote:

> Hello, Neil, Jeff.
> 
> On Tue, Dec 02, 2014 at 08:29:46PM -0500, Jeff Layton wrote:
>> That's a good point. I had originally thought that max_active on an
>> unbound workqueue would be the number of concurrent jobs that could run
>> across all the CPUs, but now that I look I'm not sure that's really
>> the case.
> 
> @max_active is a per-pool number.  By default, unbound wqs use
> per-node pools, so @max_active would be per-node.  Currently,
> @max_active is mostly meant as a protection against run-away
> workqueues creating crazy number of workers, which has been enough for
> the existing wq users.  *Maybe* it makes sense to make it actually
> mean maximum concurrency which would prolly involve aggregated per-cpu
> distribution mechanism so that we don't end up inc'ing and dec'ing the
> same counter from all CPUs on each work item execution.
> 
> However, I do agree with Neil that making it user configurable is
> almost always painful.  It's usually a question without a good answer
> and the same value may behave differently depending on a lot of
> implementation details and a better approach, probably, is to use
> @max_active as the last resort protection mechanism while providing
> automatic throttling of in-flight work items which is meaningful for
> the specific use cases.
> 
>> I've heard random grumblings from various people in the past that
>> workqueues have significant latency, but this is the first time I've
>> really hit it in practice. If we can get this fixed, then that may be a
>> significant perf win for all workqueue users. For instance, rpciod in
>> the NFS client is all workqueue-based. Getting that latency down could
>> really help things.
>> 
>> I'm currently trying to roll up a kernel module for benchmarking the
>> workqueue dispatching code in the hopes that we can use that to help
>> nail it down.
> 
> Definitely, there were some reportings but nothing really got tracked
> down properly.  It'd be awesome to actually find out where the latency
> is coming from.

I’ve measured some long (>10usec) latencies for queue_workqueue()
and wake_up_bit() calls with CPU-intensive workloads.

Often these APIs are invoked while one or more spinlocks are
held. That makes it easy to back up a lot of work if one of
these calls is slow for any reason.

For wake_up_bit(), this doesn’t include how long it takes before
the awoken process is run. With CPU-intensive workloads, it’s
often the case that hundreds of usecs elapse, and the awoken
process is migrated to another CPU (observed via ftrace).

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



