From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 2/3] NFS: Add NFS_MOUNT_NONEGDE flag to avoid caching
 negative dentries
Date: Wed, 16 Jan 2008 07:49:30 -0500
Message-ID: <478DFD5A.1040501@RedHat.com>
References: <20080115163013.GC18911@newbie.thebellsplace.net>	 <1200415972.7702.7.camel@heimdal.trondhjem.org>	 <CB3B3B75-ECE5-4A46-BEA5-7DEDA8DB7DCA@oracle.com>	 <20080116012209.GB26010@newbie.thebellsplace.net> <1200451350.28088.43.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Bob Bell <b_linuxnfs-Y/+76LoPTq9wBoktGHYdvgC/G2K4zDHf@public.gmane.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:34214 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752142AbYAPMuZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Jan 2008 07:50:25 -0500
In-Reply-To: <1200451350.28088.43.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Tue, 2008-01-15 at 20:22 -0500, Bob Bell wrote:
>>>> How about something like 'cacheneglookup' 'nocacheneglookup'? Better
>>>> suggestions, anyone?
>> As long as no one objects to the length, I'll go with "nocacheneglookup" 
>> (and NFS_MOUNT_NOCACHENEGLOOKUP, I suppose) for round 2.
> 
> I'm still not happy with that name. What do people think about
> introducing a generic 'cache' option that can be used for fine control
> of caching options?
> 
> I'm thinking somewhat along the lines of
> 
> 	-ocache=lookup_all		/* Cache all dentries */
> 	-ocache=lookup_positive		/* Cache positive dentries */
> 	-ocache=lookup_none		/* Force all lookups */
Maybe we should define the type of cache were are controlling, in case
we want to add controls for other caches. So how about:

        -olpcache=all        /* Cache all directory entries */
        -olpcache=found      /* Cache only directory entires that are found */
        -olpcache=off        /* Turn off the caching of directory entries */ 


steved.
