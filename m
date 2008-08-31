From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFS regression? Odd delays and lockups accessing an NFS export.
Date: Sun, 31 Aug 2008 15:30:37 -0400
Message-ID: <20080831193037.GB14876@fieldses.org>
References: <1219442213.9097.25.camel@localhost> <1219603981.27921.145.camel@localhost.localdomain> <1219605422.14389.2.camel@localhost> <1219605596.14389.5.camel@localhost> <1219615789.27921.152.camel@localhost.localdomain> <1219616136.14389.12.camel@localhost> <48B2D7F8.5020206@opengridcomputing.com> <20080826192711.GJ4380@fieldses.org> <48B567F5.2090605@opengridcomputing.com> <1220111261.31172.14.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Tucker <tom@opengridcomputing.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	John Ronciak <john.ronciak@gmail.com>,
	Grant Coady <gcoady.lk@gmail.com>,
	linux-kernel@vger.kernel.org, neilb@suse.de,
	linux-nfs@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net
To: Ian Campbell <ijc-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:37369 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756120AbYHaTau (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 31 Aug 2008 15:30:50 -0400
In-Reply-To: <1220111261.31172.14.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Aug 30, 2008 at 04:47:41PM +0100, Ian Campbell wrote:
> On Wed, 2008-08-27 at 09:43 -0500, Tom Tucker wrote:
> > Sure. I've actually tried to reproduce it here unsuccessfully.
> > 
> > As a starter, I would suggest turning on transport debugging:
> > 
> > # echo 256 > /proc/sys/sunrpc/rpc_debug
> > [...]
> > If Ian is willing to create the log (or already has one), I'm
> > certainly willing to look at it.
> 
> It produced only the following (is that what was expected?):
> 
> [146866.448112] -pid- proc flgs status -client- -prog- --rqstp- -timeout -rpcwait -action- ---ops--
> [146866.448112] 30576 0001 00a0      0 f77a1600 100003 f7903340    15000 xprt_pending fa0ba88e fa0c9df4
> [146866.448112] 30577 0004 0080    -11 f77a1600 100003 f7903000        0 xprt_sending fa0ba88e fa0c9df4

It's normal to get something like that when you turn it on, yes (unless
someone else spots anything odd about that...) but what's really needed
is to turn this on and then reproduce the problem--it's the debugging
output that goes to the logs during the problem that'll be interesting.

--b.
