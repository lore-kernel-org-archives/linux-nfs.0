From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 2/3] NFS: Add NFS_MOUNT_NONEGDE flag to avoid caching
	negative dentries
Date: Tue, 15 Jan 2008 21:42:30 -0500
Message-ID: <1200451350.28088.43.camel@heimdal.trondhjem.org>
References: <20080115163013.GC18911@newbie.thebellsplace.net>
	 <1200415972.7702.7.camel@heimdal.trondhjem.org>
	 <CB3B3B75-ECE5-4A46-BEA5-7DEDA8DB7DCA@oracle.com>
	 <20080116012209.GB26010@newbie.thebellsplace.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chuck Lever <chuck.lever@oracle.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: Bob Bell <b_linuxnfs-Y/+76LoPTq9wBoktGHYdvgC/G2K4zDHf@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:41397 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758719AbYAPCmg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jan 2008 21:42:36 -0500
In-Reply-To: <20080116012209.GB26010-y89O8yXFYpDSsb2jM9SCN5/hYUUxywnI@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Tue, 2008-01-15 at 20:22 -0500, Bob Bell wrote:
> >>How about something like 'cacheneglookup' 'nocacheneglookup'? Better
> >>suggestions, anyone?
> 
> As long as no one objects to the length, I'll go with "nocacheneglookup" 
> (and NFS_MOUNT_NOCACHENEGLOOKUP, I suppose) for round 2.

I'm still not happy with that name. What do people think about
introducing a generic 'cache' option that can be used for fine control
of caching options?

I'm thinking somewhat along the lines of

	-ocache=lookup_all		/* Cache all dentries */
	-ocache=lookup_positive		/* Cache positive dentries */
	-ocache=lookup_none		/* Force all lookups */

...and then possibly adding other 'cache=' options later if we find out
that we need them?

Cheers
  Trond

