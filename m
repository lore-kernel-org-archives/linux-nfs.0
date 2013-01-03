Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f180.google.com ([209.85.216.180]:54281 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753941Ab3ACWer (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jan 2013 17:34:47 -0500
Date: Thu, 3 Jan 2013 17:34:44 -0500
From: Tejun Heo <tj@kernel.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "Adamson, Dros" <Weston.Adamson@netapp.com>,
        Dave Jones <davej@redhat.com>,
        Linux Kernel <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: nfsd oops on Linus' current tree.
Message-ID: <20130103223444.GF2753@mtj.dyndns.org>
References: <20121221230849.GB29739@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA911972C73@SACEXCMBX04-PRD.hq.netapp.com>
 <20121221232609.GC29739@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA911972CA1@SACEXCMBX04-PRD.hq.netapp.com>
 <20121221234530.GA30048@fieldses.org>
 <0EC8763B847DB24D9ADF5EBD9CD7B4191259E4A2@SACEXCMBX02-PRD.hq.netapp.com>
 <20130103201120.GA2096@fieldses.org>
 <20130103220814.GB2753@mtj.dyndns.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9119886EE@SACEXCMBX04-PRD.hq.netapp.com>
 <20130103222639.GE2753@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130103222639.GE2753@mtj.dyndns.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 03, 2013 at 05:26:39PM -0500, Tejun Heo wrote:
> Hello, Trond.
> 
> On Thu, Jan 03, 2013 at 10:12:32PM +0000, Myklebust, Trond wrote:
> > > The analysis is likely completely wrong, so please don't go off doing
> > > something unnecessary.  Please take look at what's causing the
> > > deadlocks again.
> > 
> > The analysis is a no-brainer:
> > We see a deadlock due to one work item waiting for completion of another
> > work item that is queued on the same CPU. There is no other dependency
> > between the two work items.
> 
> What do you mean "waiting for completion of"?  Is one flushing the
> other?  Or is one waiting for the other to take certain action?  How
> are the two work items related?  Are they queued on the same
> workqueue?  Can you create a minimal repro case of the observed
> deadlock?

Ooh, BTW, there was a bug where workqueue code created a false
dependency between two work items.  Workqueue currently considers two
work items to be the same if they're on the same address and won't
execute them concurrently - ie. it makes a work item which is queued
again while being executed wait for the previous execution to
complete.

If a work function frees the work item, and then waits for an event
which should be performed by another work item and *that* work item
recycles the freed work item, it can create a false dependency loop.
There really is no reliable way to detect this short of verifying
every memory free.  A patch is queued to make such occurrences less
likely (work functions should also match for two work items considered
the same), but if you're seeing this, the best thing to do is freeing
the work item at the end of the work function.

Thanks.

-- 
tejun
