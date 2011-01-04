From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] svcrpc: modifying positive sunrpc cache entries is racy
Date: Tue, 4 Jan 2011 16:15:32 -0500
Message-ID: <20110104211532.GE7908@fieldses.org>
References: <20101229204752.GC12218@fieldses.org>
 <20101229205942.GD12218@fieldses.org>
 <20101230121940.3f48223a@notabene.brown>
 <20101230015719.GA27614@fieldses.org>
 <20110103205514.GB18056@fieldses.org>
 <20110104160152.602a3c44@notabene.brown>
 <20110104152231.GA27889@fieldses.org>
 <20110104192350.GE2308@fieldses.org>
 <20110105081031.220bfbc9@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: NeilBrown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52852 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751005Ab1ADVPd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jan 2011 16:15:33 -0500
In-Reply-To: <20110105081031.220bfbc9-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 05, 2011 at 08:10:31AM +1100, NeilBrown wrote:
> On Tue, 4 Jan 2011 14:23:51 -0500 "J. Bruce Fields" <bfields@fieldses.org>
> wrote:
> 
> > So, that being the real problem, perhaps it's clearer to use explicit
> > memory barriers instead of more locking, and add some comments.  Also
> > split this into a separate patch, as in the following.
> 
> Me likie.
> 
> Two separate patches is good, and nice comments next to the memory barriers
> is good.
> Reviewed-by: NeilBrown <neilb@suse.de>

Good, thanks--queueing up for 2.6.38.--b.
