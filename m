From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/6] Cache deferral improvements - try N+2
Date: Thu, 12 Aug 2010 08:03:42 -0400
Message-ID: <20100812120342.GA23475@fieldses.org>
References: <20100812065722.11459.18978.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: NeilBrown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43753 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753851Ab0HLMF2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Aug 2010 08:05:28 -0400
In-Reply-To: <20100812065722.11459.18978.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 12, 2010 at 05:04:05PM +1000, NeilBrown wrote:
> Note that there is a conflict between this patch set and the other
> one.  The other changes someing in nfs4idmap.c, and this one removes
> all the code that was changed.  Very easy to resolve.

Thanks, Neil!

I'll go through both of these series next week after I've gotten back
from Linuxcon.

--b.
