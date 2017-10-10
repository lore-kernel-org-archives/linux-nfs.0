Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:33230 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932089AbdJJODn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Oct 2017 10:03:43 -0400
Date: Tue, 10 Oct 2017 07:03:36 -0700
From: "tj@kernel.org" <tj@kernel.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "lorenzo.pieralisi@arm.com" <lorenzo.pieralisi@arm.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "jiangshanlai@gmail.com" <jiangshanlai@gmail.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "jlayton@poochiereds.net" <jlayton@poochiereds.net>
Subject: Re: net/sunrpc: v4.14-rc4 lockdep warning
Message-ID: <20171010140336.GI3301751@devbig577.frc2.facebook.com>
References: <20171009181738.GA30680@red-moon>
 <1507573931.3516.3.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1507573931.3516.3.camel@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello, Trond.

On Mon, Oct 09, 2017 at 06:32:13PM +0000, Trond Myklebust wrote:
> On Mon, 2017-10-09 at 19:17 +0100, Lorenzo Pieralisi wrote:
> > I have run into the lockdep warning below while running v4.14-rc3/rc4
> > on an ARM64 defconfig Juno dev board - reporting it to check whether
> > it is a known/genuine issue.
> > 
> > Please let me know if you need further debug data or need some
> > specific tests.
> > 
> > [    6.209384] ======================================================
> > [    6.215569] WARNING: possible circular locking dependency detected
> > [    6.221755] 4.14.0-rc4 #54 Not tainted
> > [    6.225503] ------------------------------------------------------
> > [    6.231689] kworker/4:0H/32 is trying to acquire lock:
> > [    6.236830]  ((&task->u.tk_work)){+.+.}, at: [<ffff0000080e64cc>]
> > process_one_work+0x1cc/0x3f0
> > [    6.245472] 
> >                but task is already holding lock:
> > [    6.251309]  ("xprtiod"){+.+.}, at: [<ffff0000080e64cc>]
> > process_one_work+0x1cc/0x3f0
> > [    6.259158] 
> >                which lock already depends on the new lock.
> > 
> > [    6.267345] 
> >                the existing dependency chain (in reverse order) is:
..
> Adding Tejun and Lai, since this looks like a workqueue locking issue.

It looks a bit cryptic but it's warning against the following case.

1. Memory pressure is high and rescuer kicks in for the xprtiod
   workqueue.  There are no other kworkers serving the workqueue.

2. The rescuer runs the xptr_destroy path and ends up calling
   cancel_work_sync() on a work item which is queued on xprtiod.

3. The work item is pending on the same workqueue and assuming that
   memory pressure doesn't let off (let's say reclaim is trying to
   kick off nfs pages), the only way it can get executed is by the
   rescuer which is waiting for the work item - an A-B-A deadlock.

Thanks.

-- 
tejun
