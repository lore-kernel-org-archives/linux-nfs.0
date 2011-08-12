Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45041 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751167Ab1HLBOO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Aug 2011 21:14:14 -0400
Date: Thu, 11 Aug 2011 21:14:10 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: NFS list <linux-nfs@vger.kernel.org>, Malcolm Locke <malc@wholemeal.co.nz>
Subject: Re: Grace period NEVER ends
Message-ID: <20110812011410.GC9761@pad.fieldses.org>
References: <4E44790A.8000106@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E44790A.8000106@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Aug 11, 2011 at 05:51:22PM -0700, Boaz Harrosh wrote:
> I have this weird problem with latest code. It is Benny's latest based
> on 3.1-rc1 + linus/master of today + trond/linux-next.
> 
> For my testing I use a pNFS client mounted on localhost over a pNFS-nfsd on
> the same machine. If I wait the 90 seconds or so and then mount all is well
> but if I mount right away, or stop the server, then start and mount.
>   The Grace period NEVER ends. On prints I see the server returning 100013
>   continuously forever.
> 
> This is my usual test setup. In the passed it would wait the annoying grace
> and continue. Now it never returns.
> 
> Before I start to bisect back to a good point I though I might ask for pointers
> on what might have changed in this respect.

Hm, I don't know.  We turned on the reply cache for nfsv4, so it could
be mistakenly treating the calls as replays, but that seems unlikely.

There was one other report of such behavior here:

	http://marc.info/?l=linux-nfs&m=131280896721834&w=2

--b.
