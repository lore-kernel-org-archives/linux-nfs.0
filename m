From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: A unresponsive file system can hang all I/O in the system on
	linux-2.6.23-rc6 (dirty_thresh problem?)
Date: Fri, 28 Sep 2007 20:48:59 +0200
Message-ID: <1191005339.18147.89.camel@lappy>
References: <92cbf19b0709272332s25684643odaade0e98cb3a1f4@mail.gmail.com>
	 <20070927235034.ae7bd73d.akpm@linux-foundation.org>
	 <1190998853.6702.17.camel@heimdal.trondhjem.org>
	 <20070928114930.2c201324.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Chakri n <chakriin5@gmail.com>,
	linux-pm <linux-pm@lists.linux-foundation.org>,
	lkml <linux-kernel@vger.kernel.org>, nfs@lists.sourceforge.net
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757383AbXI1SxT@vger.kernel.org>
In-Reply-To: <20070928114930.2c201324.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


On Fri, 2007-09-28 at 11:49 -0700, Andrew Morton wrote:

> Do you know where the stalls are occurring?  throttle_vm_writeout(), or via
> direct calls to congestion_wait() from page_alloc.c and vmscan.c?  (running
> sysrq-w five or ten times will probably be enough to determine this)

would it make sense to instrument congestion_wait() callsites with
vmstats?
