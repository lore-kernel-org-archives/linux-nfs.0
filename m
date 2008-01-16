From: Bob Bell <b_linuxnfs-Y/+76LoPTq9wBoktGHYdvgC/G2K4zDHf@public.gmane.org>
Subject: Re: [PATCH 2/3] NFS: Add NFS_MOUNT_NONEGDE flag to avoid caching negative dentries
Date: Tue, 15 Jan 2008 20:22:10 -0500
Message-ID: <20080116012209.GB26010@newbie.thebellsplace.net>
References: <20080115163013.GC18911@newbie.thebellsplace.net> <1200415972.7702.7.camel@heimdal.trondhjem.org> <CB3B3B75-ECE5-4A46-BEA5-7DEDA8DB7DCA@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from srv03.macroped.com ([74.52.9.226]:54465 "EHLO
	srv03.macroped.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751263AbYAPBWT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jan 2008 20:22:19 -0500
In-Reply-To: <CB3B3B75-ECE5-4A46-BEA5-7DEDA8DB7DCA@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 15, 2008 at 12:04:50PM -0500, Chuck Lever wrote:
>On Jan 15, 2008, at 11:52 AM, Trond Myklebust wrote:
>>The patch itself looks OK. My only gripe is the two names 'negde' and
>>'nonegde'. Can we find something that rolls a bit more smoothly off  
>>the
>>tongue?
>
>Yeah, actually I thought it was spelled "non edge" until I looked  
>closer.

Heh -- I mentioned the same thing at the bottom of my (admittedly 
verbose) intro the patch.  In fact, I've mistyped it "nonedge" myself 
a few times, which I figured was a strong hint it needed renaming.

I was going for the terseness I saw in the rest of the options, and 
"nonegde" was the best my limited creativity could come up with.

>>How about something like 'cacheneglookup' 'nocacheneglookup'? Better
>>suggestions, anyone?

As long as no one objects to the length, I'll go with "nocacheneglookup" 
(and NFS_MOUNT_NOCACHENEGLOOKUP, I suppose) for round 2.

>You might consider tying this behavior to "noac" as well.  In other  
>words, make "noac" equivalent to "sync,actimeo=0,nonegde" .

I'll provide this as a separate patch in the patch set, as Trond 
indicated he would prefer.  This might make sense, as this is probably 
the set of options we'll used.

-- 
Bob Bell
