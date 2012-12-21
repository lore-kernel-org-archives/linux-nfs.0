Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55546 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750733Ab2LUX0K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Dec 2012 18:26:10 -0500
Date: Fri, 21 Dec 2012 18:26:09 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Adamson, Dros" <Weston.Adamson@netapp.com>
Subject: Re: nfsd oops on Linus' current tree.
Message-ID: <20121221232609.GC29739@fieldses.org>
References: <20121221153348.GA32151@redhat.com>
 <20121221180824.GA27729@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA91197273D@SACEXCMBX04-PRD.hq.netapp.com>
 <20121221230849.GB29739@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA911972C73@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA911972C73@SACEXCMBX04-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 21, 2012 at 11:15:40PM +0000, Myklebust, Trond wrote:
> Apologies for top-posting. The SSD on my laptop died, and so I'm stuck using webmail for this account...

Fun!  If that happens to me on this trip, I've got a week trying to hack
the kernel from my cell phone....

> Our experience with nfsiod is that the WQ_MEM_RECLAIM option still deadlocks despite the "rescuer thread". The CPU that is running the workqueue will deadlock with any rpciod task that is assigned to the same CPU. Interestingly enough, the WQ_UNBOUND option also appears able to deadlock in the same situation.
> 
> Sorry, I have no explanation why...

As I said:

> there shouldn't be any deadlock as long as there's no circular
> dependency among the three.

There was a circular dependency (of rpciod on itself), so having a
dedicated rpciod rescuer thread wouldn't help--once the rescuer thread
is waiting for work queued to do the same queue you're asking for
trouble.

The last argument in

	alloc_workqueue("rpciod", WQ_MEM_RECLAIM, 1);

ensures that it will never allow more than 1 piece of work to run per
CPU, so the deadlock should be pretty easy to hit.

And with UNBOUND that's only one piece of work globally, so yeah all you
need is an rpc at shutdown time and it should deadlock every time.

--b.
