Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f175.google.com ([209.85.223.175]:51337 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753808Ab3ACW0o (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jan 2013 17:26:44 -0500
Date: Thu, 3 Jan 2013 17:26:39 -0500
From: Tejun Heo <tj@kernel.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "Adamson, Dros" <Weston.Adamson@netapp.com>,
        Dave Jones <davej@redhat.com>,
        Linux Kernel <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: nfsd oops on Linus' current tree.
Message-ID: <20130103222639.GE2753@mtj.dyndns.org>
References: <4FA345DA4F4AE44899BD2B03EEEC2FA91197273D@SACEXCMBX04-PRD.hq.netapp.com>
 <20121221230849.GB29739@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA911972C73@SACEXCMBX04-PRD.hq.netapp.com>
 <20121221232609.GC29739@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA911972CA1@SACEXCMBX04-PRD.hq.netapp.com>
 <20121221234530.GA30048@fieldses.org>
 <0EC8763B847DB24D9ADF5EBD9CD7B4191259E4A2@SACEXCMBX02-PRD.hq.netapp.com>
 <20130103201120.GA2096@fieldses.org>
 <20130103220814.GB2753@mtj.dyndns.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9119886EE@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9119886EE@SACEXCMBX04-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello, Trond.

On Thu, Jan 03, 2013 at 10:12:32PM +0000, Myklebust, Trond wrote:
> > The analysis is likely completely wrong, so please don't go off doing
> > something unnecessary.  Please take look at what's causing the
> > deadlocks again.
> 
> The analysis is a no-brainer:
> We see a deadlock due to one work item waiting for completion of another
> work item that is queued on the same CPU. There is no other dependency
> between the two work items.

What do you mean "waiting for completion of"?  Is one flushing the
other?  Or is one waiting for the other to take certain action?  How
are the two work items related?  Are they queued on the same
workqueue?  Can you create a minimal repro case of the observed
deadlock?

Thanks.

-- 
tejun
