Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35161 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751371Ab2LUXpd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Dec 2012 18:45:33 -0500
Date: Fri, 21 Dec 2012 18:45:30 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Adamson, Dros" <Weston.Adamson@netapp.com>, Tejun Heo <tj@kernel.org>
Subject: Re: nfsd oops on Linus' current tree.
Message-ID: <20121221234530.GA30048@fieldses.org>
References: <20121221153348.GA32151@redhat.com>
 <20121221180824.GA27729@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA91197273D@SACEXCMBX04-PRD.hq.netapp.com>
 <20121221230849.GB29739@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA911972C73@SACEXCMBX04-PRD.hq.netapp.com>
 <20121221232609.GC29739@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA911972CA1@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA911972CA1@SACEXCMBX04-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 21, 2012 at 11:36:51PM +0000, Myklebust, Trond wrote:
> Please reread what I said. There was no obvious circular dependency,
> because nfsiod and rpciod are separate workqueues, both created with
> WQ_MEM_RECLAIM.

Oh, sorry, I read "rpciod" as "nfsiod"!

> Dros' experience shows, however that a call to
> rpc_shutdown_client in an nfsiod work item will deadlock with rpciod
> if the RPC task's work item has been assigned to the same CPU as the
> one running the rpc_shutdown_client work item.
> 
> I can't tell right now if that is intentional (in which case the
> WARN_ON in the rpc code is correct), or if it is a bug in the
> workqueue code. For now, we're assuming the former.

Well, Documentation/workqueue.txt says:

	"Each wq with WQ_MEM_RECLAIM set has an execution context
	reserved for it.  If there is dependency among multiple work
	items used during memory reclaim, they should be queued to
	separate wq each with WQ_MEM_RECLAIM."

And I can't see how it could have been safe to convert
create_single_singlethread_workqueue() callers otherwise.

--b.
