From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] improve the performance of large sequential write NFS
 workloads
Date: Fri, 18 Dec 2009 23:07:41 +0100
Message-ID: <20091218220741.GB21131@elte.hu>
References: <1261015420.1947.54.camel@serenity>
 <1261037877.27920.36.camel@laptop>
 <1261164799.1947.123.camel@serenity>
 <20091218194129.GB6153@elte.hu>
 <1261171211.1947.135.camel@serenity>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <peterz@infradead.org>, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, Trond.Myklebust@netapp.com,
	Wu Fengguang <fengguang.wu@intel.com>,
	"jens.axboe" <jens.axboe@oracle.com>
To: Steve Rago <sar-a+KepyhlMvJWk0Htik3J/w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:38686 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932653AbZLRWH6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Dec 2009 17:07:58 -0500
In-Reply-To: <1261171211.1947.135.camel@serenity>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


* Steve Rago <sar-a+KepyhlMvJWk0Htik3J/w@public.gmane.org> wrote:

> 
> On Fri, 2009-12-18 at 20:41 +0100, Ingo Molnar wrote:
> > * Steve Rago <sar-a+KepyhlMvJWk0Htik3J/w@public.gmane.org> wrote:
> > 
> > > > Also, I don't think this needs to have a sysctl, it should just work.
> > > 
> > > The sysctl is a *good thing* in that it allows the eager writeback behavior 
> > > to be tuned and shut off if need be.  I can only test the changes on a 
> > > finite set of systems, so better safe than sorry.
> > 
> > This issue has been settled many years ago and that's not what we do in the 
> > Linux kernel. We prefer patches to core code where we are reasonably sure they 
> > result in good behavior - and then we fix bugs in the new behavior, if any. 
> > 
> > (Otherwise odd sysctls would mushroom quickly and the system would become 
> > untestable in practice.)
> > 
> > 	Ingo
> 
> I don't disagree, but "that's not what we do" hardly provides insight into 
> making the judgment call. [...]

I gave you an example of the problems that arise, see the last sentence above.

> [...]  In this case, the variety of combinations of NFS server speed, NFS 
> client speed, transmission link speed, client memory size, and server memory 
> size argues for a tunable parameter, because one value probably won't work 
> well in all combinations.  Making it change dynamically based on these 
> parameters is more complicated than these circumstances call for, IMHO.

So having crappy tunables is the reason to introduce even more tunables? I 
think you just gave a good second example of why we dont want sysctls for 
features like this.

	Ingo
