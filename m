From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] improve the performance of large sequential write NFS
 workloads
Date: Fri, 18 Dec 2009 20:41:29 +0100
Message-ID: <20091218194129.GB6153@elte.hu>
References: <1261015420.1947.54.camel@serenity>
 <1261037877.27920.36.camel@laptop>
 <1261164799.1947.123.camel@serenity>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <peterz@infradead.org>, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, Trond.Myklebust@netapp.com,
	Wu Fengguang <fengguang.wu@intel.com>,
	"jens.axboe" <jens.axboe@oracle.com>
To: Steve Rago <sar-a+KepyhlMvJWk0Htik3J/w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:51503 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750946AbZLRTlr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Dec 2009 14:41:47 -0500
In-Reply-To: <1261164799.1947.123.camel@serenity>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


* Steve Rago <sar-a+KepyhlMvJWk0Htik3J/w@public.gmane.org> wrote:

> > Also, I don't think this needs to have a sysctl, it should just work.
> 
> The sysctl is a *good thing* in that it allows the eager writeback behavior 
> to be tuned and shut off if need be.  I can only test the changes on a 
> finite set of systems, so better safe than sorry.

This issue has been settled many years ago and that's not what we do in the 
Linux kernel. We prefer patches to core code where we are reasonably sure they 
result in good behavior - and then we fix bugs in the new behavior, if any. 

(Otherwise odd sysctls would mushroom quickly and the system would become 
untestable in practice.)

	Ingo
