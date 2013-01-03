Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f181.google.com ([209.85.216.181]:55112 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753934Ab3ACWWw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jan 2013 17:22:52 -0500
Received: by mail-qc0-f181.google.com with SMTP id x40so8225484qcp.26
        for <linux-nfs@vger.kernel.org>; Thu, 03 Jan 2013 14:22:51 -0800 (PST)
Date: Thu, 3 Jan 2013 17:15:03 -0500
From: Tejun Heo <tj@kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "Adamson, Dros" <Weston.Adamson@netapp.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Dave Jones <davej@redhat.com>,
        Linux Kernel <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: nfsd oops on Linus' current tree.
Message-ID: <20130103221503.GC2753@mtj.dyndns.org>
References: <4FA345DA4F4AE44899BD2B03EEEC2FA91197273D@SACEXCMBX04-PRD.hq.netapp.com>
 <20121221230849.GB29739@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA911972C73@SACEXCMBX04-PRD.hq.netapp.com>
 <20121221232609.GC29739@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA911972CA1@SACEXCMBX04-PRD.hq.netapp.com>
 <20121221234530.GA30048@fieldses.org>
 <0EC8763B847DB24D9ADF5EBD9CD7B4191259E4A2@SACEXCMBX02-PRD.hq.netapp.com>
 <20130103201120.GA2096@fieldses.org>
 <0EC8763B847DB24D9ADF5EBD9CD7B4191259F54D@SACEXCMBX02-PRD.hq.netapp.com>
 <20130103205221.GB2533@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130103205221.GB2533@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's getting a bit repetitive but I really wanna steer people away
from implementing separate kthreads for wrong reasons.  kthread is
surprisingly difficult to get right especially around freezing /
exiting / hotplugs and people get it subtly wrong very often.

On Thu, Jan 03, 2013 at 03:52:21PM -0500, J. Bruce Fields wrote:
> No, I meant I was happy having my workqueue handled by a single
> dedicated thread, which I don't see a trivial way to do any more.

Because you don't need that.  The old workqueue didn't give you
anything better than the current one.  It was usually more difficult
to get right in terms of execution dependency because it introduced a
lot of unintended execution dependencies through
one-(per-cpu)-worker-per-workqueue rule.

If anyone can show me workqueue is deadlocking when it shouldn't I'll
be happy to look into it and fix it, but, up until now, most if not
all reported cases were through incorrect usage, and things definitely
don't work like described in this thread.

Thanks.

-- 
tejun
