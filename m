Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:33372 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759682Ab0D3WDI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Apr 2010 18:03:08 -0400
Date: Fri, 30 Apr 2010 18:03:05 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Marc Eshel <eshel@almaden.ibm.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
Subject: Re: [pnfs] Linux pNFS status meeting 04/29
Message-ID: <20100430220305.GF20732@fieldses.org>
References: <OF9FD7A126.8253DE0C-ON88257714.00106772-88257714.00108527@us.ibm.com> <20100429144600.GA1654@fieldses.org> <20100429173902.GE1654@fieldses.org> <20100429184311.GB4194@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100429184311.GB4194@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Apr 29, 2010 at 02:43:11PM -0400, J. Bruce Fields wrote:
> On Thu, Apr 29, 2010 at 01:39:03PM -0400, J. Bruce Fields wrote:
> > 1. upstream status/merge plans (trond, bfields)
> > 	- 2.6.34-rc5
> > 	- server: merged one 2.6.34 bugfix, some more bugfixes/cleanup for
> > 	  2.6.35, no new features merged.
> > 	- client: bunch of bugfixes:
> > 		- writeback code fixes:	
> > 			- race with commit
> > 			- nfs_setup_writeback BUG_ON()
> > 		- other than that, misc. NULL/ERR-mixups.
> > 		- Andy notes he's been seeing bigfile blocked for >= 30
> > 		  seconds; Trond says that's probably due to the commit
> > 		  race above.
> > 
> > 2. State of pNFS tree (bhalevy)
> > 	- forwarded-ported to -rc5, released a few minutes ago.  Passes
> > 	  cthon cleanly (thanks to commit race fix).
> > 	- merged some other patches.
> > 
> > 3. Mailing list change
> > 	- consolidated pnfs and nfsv4 lists to linux-nfs@vger.kernel.org
> > 	- kernel.org appears to be having trouble; bfields will
> > 	  investigate.
> 
> As far as I can tell, from my mail and from public archives, the
> kernel.org mailing lists just aren't working right now.

vger seems to be back, but mail to neither the pnfs nor the nfsv4 lists
is getting forwarded to this list.

All I did was add linux-nfs@vger.kernel.org as a member of each of the
two lists.

I can't find anything useful in linux-nfs logs, but maybe I don't know
what to look for....

--b.
