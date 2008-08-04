From: Bernd Schubert <bs-PKu+Ek1N2UGzQB+pC5nmwQ@public.gmane.org>
Subject: Re: high latency NFS
Date: Mon, 4 Aug 2008 11:18:18 +0200
Message-ID: <200808041118.19743.bs@q-leap.de>
References: <200807241311.31457.shuey@purdue.edu> <20080804003206.GB6119@disturbed> <20080804011158.GA8066@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: Neil Brown <neilb@suse.de>, Michael Shuey <shuey-olO2ZdjDehc3uPMLIKxrzw@public.gmane.org>,
	Shehjar Tikoo <shehjart-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	rees@citi.umich.edu, aglo@citi.umich.edu
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns1.q-leap.de ([153.94.51.193]:52354 "EHLO mail.q-leap.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752124AbYHDJSV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Aug 2008 05:18:21 -0400
In-Reply-To: <20080804011158.GA8066@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Monday 04 August 2008 03:11:58 J. Bruce Fields wrote:
> On Mon, Aug 04, 2008 at 10:32:06AM +1000, Dave Chinner wrote:
> > On Fri, Aug 01, 2008 at 03:15:59PM -0400, J. Bruce Fields wrote:
> > > On Fri, Aug 01, 2008 at 05:23:20PM +1000, Dave Chinner wrote:
> > > > On Thu, Jul 31, 2008 at 05:03:05PM +1000, Neil Brown wrote:
> > > > > You might want to track the max length of the request queue too and
> > > > > start more threads if the queue is long, to allow a quick ramp-up.
> > > >
> > > > Right, but even request queue depth is not a good indicator. You
> > > > need to leep track of how many NFSDs are actually doing useful
> > > > work. That is, if you've got an NFSD on the CPU that is hitting
> > > > the cache and not blocking, you don't need more NFSDs to handle
> > > > that load because they can't do any more work than the NFSD
> > > > that is currently running is.
> > > >
> > > > i.e. take the solution that Greg banks used for the CPU scheduler
> > > > overload issue (limiting the number of nfsds woken but not yet on
> > > > the CPU),
> > >
> > > I don't remember that, or wasn't watching when it happened.... Do you
> > > have a pointer?
> >
> > Ah, I thought that had been sent to mainline because it was
> > mentioned in his LCA talk at the start of the year. Slides
> > 65-67 here:
> >
> > http://mirror.linux.org.au/pub/linux.conf.au/2007/video/talks/41.pdf
>
> OK, so to summarize: when the rate of incoming rpc's is very high (and,
> I guess, when we're serving everything out of cache and don't have IO
> wait), all the nfsd threads will stay runable all the time.  That keeps
> userspace processes from running (possibly for "minutes").  And that's a
> problem even on a server dedicated only to nfs, since it affects portmap
> and rpc.mountd.

Even worse, it affects user space HA software such as heartbeat and everyone 
with reasonable timeouts will see spurious 'failures'. 


-- 
Bernd Schubert
Q-Leap Networks GmbH
