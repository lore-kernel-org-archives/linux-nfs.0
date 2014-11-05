Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48223 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751229AbaKEVFu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Nov 2014 16:05:50 -0500
Date: Wed, 5 Nov 2014 16:05:46 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: bstroesser@ts.fujitsu.com
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
Subject: Re: [nfs-utils] [PATCH 0/3] rpc.mountd: fix some vulnerabilities
Message-ID: <20141105210546.GH6513@fieldses.org>
References: <61eb00$5dituo@dgate20u.abg.fsc.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <61eb00$5dituo@dgate20u.abg.fsc.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 05, 2014 at 09:21:37PM +0100, bstroesser@ts.fujitsu.com wrote:
> Hello,
> 
> I'm sending a small set of 3 patches for a problem, that I have
> reported a few weeks ago.
> rpc.mountd can be blocked by a bad client, that sends lots of
> RPC requests, but never reads the replies from the socket either
> intentionally or e.g. caused by a wrong configured MTU.
> 
> While looking for a possible solution, I found another weakness
> in rpc.mountd if it is used "multithreaded" (-t nn).
> 
> The first two patches fix that weakness in the case of !HAVE_LIBTIRPC
> and HAVE_LIBTIRPC.

They look fine to me.

> The third patch more a kind of suggestion how the main problem could
> be fixed.

Sounds reasonable to me.

> I don't know whether we can set MAXREC without causing
> new troubles. When this patch is used, a  further patch for libtirpc
> also should be used. You can find it here:
>     http://sourceforge.net/p/libtirpc/mailman/libtirpc-devel/?viewmonth=201409

So applying this last patch and then building against an unpatched
libtirpc would expose us to a serious bug?  Do we need to do something
to make that less likely to happen?

--b.

> 
> Best regards,
> Bodo
