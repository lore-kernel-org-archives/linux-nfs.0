Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41402 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935180Ab3BTUVW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Feb 2013 15:21:22 -0500
Date: Wed, 20 Feb 2013 15:21:14 -0500
To: Mark Lehrer <mark@tpsit.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Time to declare war on "stale nfs file handle"
Message-ID: <20130220202114.GA4995@fieldses.org>
References: <alpine.DEB.1.00.1302191507240.5816@shell>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <alpine.DEB.1.00.1302191507240.5816@shell>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 19, 2013 at 03:36:25PM -0700, Mark Lehrer wrote:
> 
> I set up a pair of servers with DRBD, Pacemaker, and a virtual IP address.  I am mounting with NFSv3 & TCP.  The /etc/exports entry looks like this:
> 
> /nfs/volume01   *(rw,no_root_squash,fsid=778,insecure,async)
> 
> 
> Failing between nodes seems to work well whenever I am testing it.
> However, it seems that whenever I get into a situation where it has
> been running for awhile and then I fail over, clients get the dreaded
> Stale NFS file handle error on any open files.  In this case they are

That's weird.  The contents of /proc/net/rpc/nfsd.fh/content and
/proc/net/rpc/nfsd.export/content on both nodes after a failed failover
might be interesting.

What filesystem are you exporting?

> VM images, which means lots of rebooting.
> 
> What should I do to prevent this error from happening?  I didn't have any
> luck with exportfs -f.  Unfortunately this is a tough one to duplicate so
> I am just trying to prepare a few tests for the next time it happens.
> 
> Also, I understand that NFSv4 is not quite as stateless as the older versions.
> Will this kind of arrangement have potential data loss issues on NFSv4?

It should still work if you copy over all the right stuff in
/var/lib/nfs.

--b.
