Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f173.google.com ([209.85.216.173]:62944 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753619AbaGOOvO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2014 10:51:14 -0400
Received: by mail-qc0-f173.google.com with SMTP id c9so5065432qcz.32
        for <linux-nfs@vger.kernel.org>; Tue, 15 Jul 2014 07:51:14 -0700 (PDT)
Date: Tue, 15 Jul 2014 10:51:11 -0400
From: Tejun Heo <tj@kernel.org>
To: NeilBrown <neilb@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH/RFC] NFS: state manager thread must start running.
Message-ID: <20140715145111.GA18661@htj.dyndns.org>
References: <20140715163942.1d94304f@notabene.brown>
 <20140715074942.GA6166@infradead.org>
 <20140715181317.2de14c51@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140715181317.2de14c51@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello, Neil.

On Tue, Jul 15, 2014 at 06:13:17PM +1000, NeilBrown wrote:
> Could do that (or per-client) but it doesn't really buy us anything does it?

It does buy some.

1. The kworker threads are more likely to be cache-hot than explicit
   kthreads.

2. Workqueue is a lot eaiser to get right in terms of synchronization
   and freezing.

3. Workqueue mandates well-defined boundaries between separate
   execution instances which often makes it a lot easier to implement
   and update kernel-wide features such as like freezer and runtime
   kernel patching.

> The state manager assumes it is single threads, so it would need to be
> a single-threaded workqueue with always at least one thread running.
> That is much the same as a kthread.
> 
> And then there is that fact that the current code explicitly enabled SIGKILL
> and maybe that is important.

If SIGKILL handling is mandatory (really?), kthread_worker can be used
for #2 and #3.

Thanks.

-- 
tejun
