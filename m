From: Jeff Layton <jlayton@redhat.com>
Subject: Re: NFS performance degradation of local loopback FS.
Date: Tue, 1 Jul 2008 08:47:42 -0400
Message-ID: <20080701084742.45de9136@tupile.poochiereds.net>
References: <20080630153541.GD29011@fieldses.org>
	<OF75C86F21.1DE4E6F9-ON65257479.00382C87-65257479.0038BD28@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "J. Bruce Fields" <bfields@fieldses.org>, aglo@citi.umich.edu,
	Benny Halevy <bhalevy@panasas.com>,
	Chuck Lever <chuck.lever@oracle.com>,
	linux-nfs@vger.kernel.org, Dean Hildebrand <seattleplus@gmail.com>,
	Peter Staubach <staubach@redhat.com>
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:56009 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750985AbYGAMtT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Jul 2008 08:49:19 -0400
In-Reply-To: <OF75C86F21.1DE4E6F9-ON65257479.00382C87-65257479.0038BD28@in.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 1 Jul 2008 15:49:44 +0530
Krishna Kumar2 <krkumar2@in.ibm.com> wrote:

> "J. Bruce Fields" <bfields@fieldses.org> wrote on 06/30/2008 09:05:41 PM:
> 
> > On Mon, Jun 30, 2008 at 11:26:54AM -0400, Jeff Layton wrote:
> > > Recently I spent some time with others here at Red Hat looking
> > > at problems with nfs server performance. One thing we found was that
> > > there are some problems with multiple nfsd's. It seems like the I/O
> > > scheduling or something is fooled by the fact that sequential write
> > > calls are often handled by different nfsd's. This can negatively
> > > impact performance (I don't think we've tracked this down completely
> > > yet, however).
> >
> > Yes, we've been trying to see how close to full network speed we can get
> > over a 10 gig network and have run into situations where increasing the
> > number of threads (without changing anything else) seems to decrease
> > performance of a simple sequential write.
> >
> > And the hypothesis that the problem was randomized IO scheduling was the
> > first thing that came to mind.  But I'm not sure what the easiest way
> > would be to really prove that that was the problem.
> >
> > And then once we really are sure that's the problem, I'm not sure what
> > to do about it.  I suppose it may depend partly on exactly where the
> > reordering is happening.
> 
> For 1 process, this theory seems to work:
> 1 testing process: /local:            39.11 MB/s
>         64 nfsd's:                    29.63 MB/s
>         1 nfs'd:                      38.99 MB/s
> 
> 
> However for 6 processes reading 6 different files:
> 6 parallel testing processes: /local: 70 MB/s
>         1 nfs'd:                      36 MB/s (49% drop)
>         2 nfs'd:                      37.7 MB/s (46% drop)
>         4 nfs'd:                      38.6 MB/s (44.9% drop)
>         4 nfsd's on different cpu's:  37.5 MB/s (46% drop)
>         32 nfs'd:                     38.3 MB/s (45% drop)
>         64 nfs'd:                     38.3 MB/s (45% drop)
> 

That makes some sense, I think...

What's happening is that the processes on the client doing the I/O are
being "masqueraded" behind the nfsd's. This is throwing off readahead
(and maybe other predictive I/O optimizations?). These optimizations
help when a single thread is doing I/O, but when a single process is
feeding multiple nfsd's or multiple processes are spewing I/O to a
single nfsd, it falls back to random I/O behavior.

Also in the single nfsd case, you're also being bottlenecked by the
fact that all of the I/O is serialized. Not a problem with a single
client-side process, but it may be a significant slowdown when there
are multiple writers on the client.

We have a RHBZ open on this for RHEL5:

https://bugzilla.redhat.com/show_bug.cgi?id=448130

...there is a partial workaround described there as well.

-- 
Jeff Layton <jlayton@redhat.com>
