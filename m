Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:41871 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753643Ab3ACWMe convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jan 2013 17:12:34 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Tejun Heo <tj@kernel.org>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        "Adamson, Dros" <Weston.Adamson@netapp.com>,
        Dave Jones <davej@redhat.com>,
        Linux Kernel <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: nfsd oops on Linus' current tree.
Date: Thu, 3 Jan 2013 22:12:32 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9119886EE@SACEXCMBX04-PRD.hq.netapp.com>
References: <20121221153348.GA32151@redhat.com>
	 <20121221180824.GA27729@fieldses.org>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA91197273D@SACEXCMBX04-PRD.hq.netapp.com>
	 <20121221230849.GB29739@fieldses.org>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA911972C73@SACEXCMBX04-PRD.hq.netapp.com>
	 <20121221232609.GC29739@fieldses.org>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA911972CA1@SACEXCMBX04-PRD.hq.netapp.com>
	 <20121221234530.GA30048@fieldses.org>
	 <0EC8763B847DB24D9ADF5EBD9CD7B4191259E4A2@SACEXCMBX02-PRD.hq.netapp.com>
	 <20130103201120.GA2096@fieldses.org> <20130103220814.GB2753@mtj.dyndns.org>
In-Reply-To: <20130103220814.GB2753@mtj.dyndns.org>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-01-03 at 17:08 -0500, Tejun Heo wrote:
+AD4- Hello,
+AD4- 
+AD4- On Thu, Jan 03, 2013 at 03:11:20PM -0500, J. Bruce Fields wrote:
+AD4- +AD4- Both rpciod and nfsiod already set WQ+AF8-MEM+AF8-RECLAIM.
+AD4- +AD4- 
+AD4- +AD4- But, right, looking at kernel/workqueue.c, it seems that the dedicated
+AD4- +AD4- +ACI-rescuer+ACI- threads are invoked only in the case when work is stalled
+AD4- +AD4- because a new worker thread isn't allocated quickly enough.
+AD4- 
+AD4- Because that's the +ACo-only+ACo- case where progress can't be guaranteed
+AD4- otherwise.
+AD4- 
+AD4- +AD4- So, what to do that's simplest enough that it would work for
+AD4- +AD4- post-rc2/stable?  I was happy having just a simple dedicated
+AD4- +AD4- thread--these are only started when nfsd is, so there's no real thread
+AD4- +AD4- proliferation problem.
+AD4- 
+AD4- The analysis is likely completely wrong, so please don't go off doing
+AD4- something unnecessary.  Please take look at what's causing the
+AD4- deadlocks again.

The analysis is a no-brainer:
We see a deadlock due to one work item waiting for completion of another
work item that is queued on the same CPU. There is no other dependency
between the two work items.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
