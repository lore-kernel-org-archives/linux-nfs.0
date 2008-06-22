From: Christoph Lameter <clameter@sgi.com>
Subject: Re: 2.6.26-rc: nfsd hangs for a few sec
Date: Sat, 21 Jun 2008 21:13:00 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0806212107510.18908@schroedinger.engr.sgi.com>
References: <a4423d670806210557k1e8fcee1le3526f62962799e@mail.gmail.com>
 <20080621224135.GD4692@csn.ul.ie> <Pine.LNX.4.64.0806211711470.18719@schroedinger.engr.sgi.com>
 <20080622013801.GE4692@csn.ul.ie>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alexander Beregalov <a.beregalov@gmail.com>,
	kernel-testers@vger.kernel.org,
	kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	Lee Schermerhorn <lee.schermerhorn@hp.com>,
	KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>,
	Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>,
	Nick Piggin <nickpiggin-/E1597aS9LT0CCvOHzKKcA@public.gmane.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	bfields@fieldses.org, neilb@suse.de, linux-nfs@vger.kernel.org
To: Mel Gorman <mel-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:58113 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750770AbYFVENF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 Jun 2008 00:13:05 -0400
In-Reply-To: <20080622013801.GE4692-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 22 Jun 2008, Mel Gorman wrote:

> > Before the change we walk all zones of the zonelist.
> > 
> 
> Yeah, but the zonelist is for GFP_KERNEL so it should not include the HIGHMEM
> zones, right? The key change is that after the patch there are fewer zonelists
> than get filtered.

But the HIGHMEM zones etc were included before. There was no check for 
HIGHMEM etc there. The gfpmask was ignored.
 
> I think the effect of that patch is that zones get shrunk that have
> nothing to do with the requestors requirements. Right?

Right. AFAICT That was the behavior before the change.
