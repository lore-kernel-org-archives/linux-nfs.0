Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46998 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753643Ab0ISSyj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 19 Sep 2010 14:54:39 -0400
Date: Sun, 19 Sep 2010 14:53:18 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Sachin Prabhu <sprabhu@redhat.com>, linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: Should we be aggressively invalidating cache when using
 -onolock?
Message-ID: <20100919185318.GE32071@fieldses.org>
References: <1103741.22.1284726314119.JavaMail.sprabhu@dhcp-1-233.fab.redhat.com>
 <29790688.25.1284726394683.JavaMail.sprabhu@dhcp-1-233.fab.redhat.com>
 <20100917174644.GD25515@fieldses.org>
 <20100918070932.1c1bb700@corrin.poochiereds.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100918070932.1c1bb700@corrin.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, Sep 18, 2010 at 07:09:32AM -0400, Jeff Layton wrote:
> On Fri, 17 Sep 2010 13:46:44 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Fri, Sep 17, 2010 at 08:26:39AM -0400, Sachin Prabhu wrote:
> > > We came across an issue where the performance of an application using flocks on RHEL 4(2.6.9 kernel) was far better when compared to the performance of the same application on RHEL 5(2.6.18 kernel). The nfs client behavior when performing flocks on RHEL 4 and RHEL 5 differ. To ensure we had a level playing field, we repeated the tests using the mount option -o nolock. 
> > > 
> > > The performance on RHEL 5 improved slightly but was still pretty bad when compared to performance on RHEL 4. On closer observation, it was seen that there are a large number of READ requests on RHEL 5 while on RHEL 4 there were hardly any. This difference in behavior was caused by the code which invalidates the cache in the do_setlk() function and results in the RHEL 5 client performing a large number of READ requests.
> > > 
> > > In this case, the files were only being accessed by one client. This is why the nolock mount option was used. When running such workloads, the aggressive invalidation of the cache is unnecessary. This patch improves the performance in such a scenario.
> > 
> > Makes sense to me.
> > 
> 
> Agreed. This is potentially a huge performance win for some workloads.
> 
> > (Is it possible that somebody might depend on lock/unlock to keep their
> > meaning of "invalidate cache/flush changes" even when they don't care
> > bout checking for inter-client lock conflicts?  That sounds like an odd
> > use case to me.)
> > 
> 
> Aye, there's the rub. It might cause anyone doing this to regress. My
> gut feeling is that those people are a minority if any exist at all.
> The consequences of such a change for them could be pretty ugly but I'm
> not sure we owe them any consistency guarantees in such a case.

Yeah, I haven't seen any documentation of the
revalidate-caches-but-don't-lock mode that has been accidentally
implemented here, and I don't think anyone could sensibly depend on it.

--b.
