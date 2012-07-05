Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga11.intel.com ([192.55.52.93]:26396 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751497Ab2GEQ1V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Jul 2012 12:27:21 -0400
Date: Thu, 5 Jul 2012 09:27:20 -0700
From: Andi Kleen <ak@linux.intel.com>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Linux-NFS <linux-nfs@vger.kernel.org>, Trond.Myklebust@netapp.com
Subject: Re: rpcauth_lookup_credcache() lock contentions
Message-ID: <20120705162720.GE32640@tassilo.jf.intel.com>
References: <20120623122604.GA10887@localhost>
 <20120624213417.GI4152@tassilo.jf.intel.com>
 <20120625024211.GA11057@localhost>
 <20120627180353.GO4152@tassilo.jf.intel.com>
 <20120705131105.GA13775@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120705131105.GA13775@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 05, 2012 at 09:11:05PM +0800, Fengguang Wu wrote:
> On Wed, Jun 27, 2012 at 11:03:53AM -0700, Andi Kleen wrote:
> > > > Can you try this patch?
> > > 
> > > Thank you! This patch brings %sys down to 24%, a pretty large improvement!
> > 
> > I redid the patch now and fixed the race Trond pointed out.
> > 
> > Fengguang, can you retest please? Trond, does it look good now?
> 
> Andi, this patch performs equally well! And it runs stable for over a week.

Thanks for testing. But it still has the race Trond pointed out.
Probably need to rely on write ordering with the uncached flag.

-Andi

