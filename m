Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f176.google.com ([209.85.223.176]:54428 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754385Ab3ACWIU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jan 2013 17:08:20 -0500
Date: Thu, 3 Jan 2013 17:08:14 -0500
From: Tejun Heo <tj@kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "Adamson, Dros" <Weston.Adamson@netapp.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Dave Jones <davej@redhat.com>,
        Linux Kernel <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: nfsd oops on Linus' current tree.
Message-ID: <20130103220814.GB2753@mtj.dyndns.org>
References: <20121221153348.GA32151@redhat.com>
 <20121221180824.GA27729@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA91197273D@SACEXCMBX04-PRD.hq.netapp.com>
 <20121221230849.GB29739@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA911972C73@SACEXCMBX04-PRD.hq.netapp.com>
 <20121221232609.GC29739@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA911972CA1@SACEXCMBX04-PRD.hq.netapp.com>
 <20121221234530.GA30048@fieldses.org>
 <0EC8763B847DB24D9ADF5EBD9CD7B4191259E4A2@SACEXCMBX02-PRD.hq.netapp.com>
 <20130103201120.GA2096@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130103201120.GA2096@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On Thu, Jan 03, 2013 at 03:11:20PM -0500, J. Bruce Fields wrote:
> Both rpciod and nfsiod already set WQ_MEM_RECLAIM.
> 
> But, right, looking at kernel/workqueue.c, it seems that the dedicated
> "rescuer" threads are invoked only in the case when work is stalled
> because a new worker thread isn't allocated quickly enough.

Because that's the *only* case where progress can't be guaranteed
otherwise.

> So, what to do that's simplest enough that it would work for
> post-rc2/stable?  I was happy having just a simple dedicated
> thread--these are only started when nfsd is, so there's no real thread
> proliferation problem.

The analysis is likely completely wrong, so please don't go off doing
something unnecessary.  Please take look at what's causing the
deadlocks again.

Thanks.

-- 
tejun
