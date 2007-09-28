From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: A unresponsive file system can hang all I/O in the system
 on linux-2.6.23-rc6 (dirty_thresh problem?)
Date: Fri, 28 Sep 2007 11:49:30 -0700
Message-ID: <20070928114930.2c201324.akpm@linux-foundation.org>
References: <92cbf19b0709272332s25684643odaade0e98cb3a1f4@mail.gmail.com>
	<20070927235034.ae7bd73d.akpm@linux-foundation.org>
	<1190998853.6702.17.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	linux-pm <linux-pm@lists.linux-foundation.org>,
	lkml <linux-kernel@vger.kernel.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IbKuV-0003hQ-31
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 11:49:59 -0700
Received: from smtp2.linux-foundation.org ([207.189.120.14])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IbKua-0000W6-0v
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 11:50:04 -0700
In-Reply-To: <1190998853.6702.17.camel@heimdal.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Fri, 28 Sep 2007 13:00:53 -0400 Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> On Thu, 2007-09-27 at 23:50 -0700, Andrew Morton wrote:
> 
> > Actually we perhaps could address this at the VFS level in another way. 
> > Processes which are writing to the dead NFS server will eventually block in
> > balance_dirty_pages() once they've exceeded the memory limits and will
> > remain blocked until the server wakes up - that's the behaviour we want.
> > 
> > What we _don't_ want to happen is for other processes which are writing to
> > other, non-dead devices to get collaterally blocked.  We have patches which
> > might fix that queued for 2.6.24.  Peter?
> 
> Do these patches also cause the memory reclaimers to steer clear of
> devices that are congested (and stop waiting on a congested device if
> they see that it remains congested for a long period of time)? Most of
> the collateral blocking I see tends to happen in memory allocation...
> 

No, they don't attempt to do that, but I suspect they put in place
infrastructure which could be used to improve direct-reclaimer latency.  In
the throttle_vm_writeout() path, at least.

Do you know where the stalls are occurring?  throttle_vm_writeout(), or via
direct calls to congestion_wait() from page_alloc.c and vmscan.c?  (running
sysrq-w five or ten times will probably be enough to determine this)


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
