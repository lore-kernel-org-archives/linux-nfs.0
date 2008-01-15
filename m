From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 2/3] NFS: Add NFS_MOUNT_NONEGDE flag to avoid caching
	negative dentries
Date: Tue, 15 Jan 2008 11:52:52 -0500
Message-ID: <1200415972.7702.7.camel@heimdal.trondhjem.org>
References: <20080115163013.GC18911@newbie.thebellsplace.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Bob Bell <b_linuxnfs-Y/+76LoPTq9wBoktGHYdvgC/G2K4zDHf@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:37484 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751059AbYAOQw4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jan 2008 11:52:56 -0500
In-Reply-To: <20080115163013.GC18911-y89O8yXFYpDSsb2jM9SCN5/hYUUxywnI@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Tue, 2008-01-15 at 11:30 -0500, Bob Bell wrote:
> From: Bob Bell <bell_robert@emc.com>
> 
> Add NFS_MOUNT_NONEGDE mount flag.  When this flag is set on a mounted
> NFS filesystem, negative dentries for that filesystem will not be 
> cached.  This can help address cache coherency when the NFS server does 
> not provide sufficiently fine-grained timestamps to consistently 
> distinguish when a directory has been modified, though performance when 
> repeatedly accessing filenames for files that do not exist may be 
> impacted.
> 
> Signed-off-by: Bob Bell <bell_robert@emc.com>
> ---

The patch itself looks OK. My only gripe is the two names 'negde' and
'nonegde'. Can we find something that rolls a bit more smoothly off the
tongue?

How about something like 'cacheneglookup' 'nocacheneglookup'? Better
suggestions, anyone?

Cheers
  Trond

