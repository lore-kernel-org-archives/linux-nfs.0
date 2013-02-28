Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51358 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759595Ab3B1R3R (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Feb 2013 12:29:17 -0500
Date: Thu, 28 Feb 2013 12:29:16 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Iordan Iordanov <iordan@cdf.toronto.edu>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS v3 hangs with kernel version v3.2.0, 32-bit
Message-ID: <20130228172916.GA29852@fieldses.org>
References: <511BFB74.3060803@cdf.toronto.edu>
 <51253F36.40501@cdf.toronto.edu>
 <20130222150158.GB20588@fieldses.org>
 <512F84AC.1020705@cdf.toronto.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <512F84AC.1020705@cdf.toronto.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 28, 2013 at 11:24:12AM -0500, Iordan Iordanov wrote:
> Hi Bruce,
> 
> On 02/22/13 10:01, J. Bruce Fields wrote:
> >Some of that debugging is extremely verbose, yes.
> >
> >Since this list is for upstream (not ubuntu) development, most useful
> >would probably be if you could work out whether the problem is
> >reproduceable on the latest upstream kernel.
> 
> Understandable.
> 
> We've been unable to pin down what triggers this bug, so we are
> unable to reproduce it synthetically. It only appears to happen on
> shared servers with lots of NFS traffic, and in all cases it
> happened with more than a month of uptime. Also, we are unable to
> put an upstream kernel on a production machine.
> 
> These two conditions will make it exceedingly unlikely that we would
> be able to work this out with an upstream kernel.
> 
> Even if we were able to reproduce this with an upstream kernel, if
> it takes such a long time to reproduce could that have aged the
> kernel we're testing enough to invalidate our testing results?

Yes, it's certainly harder to know what to do with a fix that can't be
confirmed for months.

But there's certainly no harm in continuing to report any further
symptoms; eventually somebody may recognize the problem.

--b.
