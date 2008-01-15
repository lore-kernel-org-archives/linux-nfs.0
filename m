From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 2/3] NFS: Add NFS_MOUNT_NONEGDE flag to avoid caching
	negative dentries
Date: Tue, 15 Jan 2008 12:14:23 -0500
Message-ID: <1200417263.8937.8.camel@heimdal.trondhjem.org>
References: <20080115163013.GC18911@newbie.thebellsplace.net>
	 <1200415972.7702.7.camel@heimdal.trondhjem.org>
	 <CB3B3B75-ECE5-4A46-BEA5-7DEDA8DB7DCA@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Bob Bell <b_linuxnfs-Y/+76LoPTq9wBoktGHYdvgC/G2K4zDHf@public.gmane.org>,
	NFS list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:40747 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751140AbYAORO2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jan 2008 12:14:28 -0500
In-Reply-To: <CB3B3B75-ECE5-4A46-BEA5-7DEDA8DB7DCA@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Tue, 2008-01-15 at 12:04 -0500, Chuck Lever wrote:
> 
> I suspect system administrators have no idea what a "negative dentry"  
> is, and it would probably be beyond the scope of nfs(5) to explain  
> it.  So I vote for something that describes the behavior as observed  
> by a "lay person" rather than something that names the kernel  
> mechanisms involved.

The concept of a 'dentry' is in any case very Linux-specific. The more
generic term would be a 'negative lookup'.

That said, if someone can find a better name, I'd be all for it.

> You might consider tying this behavior to "noac" as well.  In other  
> words, make "noac" equivalent to "sync,actimeo=0,nonegde" .

I'd be open for that idea, however that should definitely be a separate
patch.

Cheers
  Trond

