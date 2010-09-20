Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53741 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756699Ab0ITS1R (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Sep 2010 14:27:17 -0400
Date: Mon, 20 Sep 2010 14:25:36 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Jeff Layton <jlayton@redhat.com>, Sachin Prabhu <sprabhu@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: Should we be aggressively invalidating cache when using
 -onolock?
Message-ID: <20100920182536.GA17543@fieldses.org>
References: <1103741.22.1284726314119.JavaMail.sprabhu@dhcp-1-233.fab.redhat.com>
 <29790688.25.1284726394683.JavaMail.sprabhu@dhcp-1-233.fab.redhat.com>
 <20100917174644.GD25515@fieldses.org>
 <20100918070932.1c1bb700@corrin.poochiereds.net>
 <20100919185318.GE32071@fieldses.org>
 <88791E8C-1109-480A-A3FA-E9DBA1DBF75D@oracle.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <88791E8C-1109-480A-A3FA-E9DBA1DBF75D@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Sep 20, 2010 at 10:41:59AM -0400, Chuck Lever wrote:
> At one point long ago, I had asked Trond if we could get rid of the
> cache-invalidation-on-lock behavior if "-onolock" was in effect.  He
> said at the time that this would eliminate the only recourse
> applications have for invalidating the data cache in case it was
> stale, and NACK'd the request.

Argh.  I guess I can see the argument, though.

> I suggested introducing a new mount option called "llock" that would
> be semantically the same as "llock" on other operating systems, to do
> this.  It never went anywhere.
> 
> We now seem to have a fresh opportunity to address this issue with the
> recent addition of "local_lock".  Can we augment this option or add
> another which allows better control of caching behavior during a file
> lock?

I wouldn't stand in the way, but it does start to sound like a rather
confusing array of choices.

--b.

> 
> It also seems to me that if RHEL 4 is _not_ invalidating on lock, then
> it is not working as designed.  AFAIK the Linux NFS client has always
> invalidated a file's data cache on lock.  Did I misread something?
