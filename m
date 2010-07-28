Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:32970 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754089Ab0G1Rnp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Jul 2010 13:43:45 -0400
Date: Wed, 28 Jul 2010 13:42:41 -0400
To: Jason Keltz <jas@cse.yorku.ca>
Cc: linux-nfs@vger.kernel.org
Subject: Re: hang on existing systems when exporting NFS share to new
 systems
Message-ID: <20100728174241.GB19362@fieldses.org>
References: <4C503450.1010609@cse.yorku.ca>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4C503450.1010609@cse.yorku.ca>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jul 28, 2010 at 09:44:48AM -0400, Jason Keltz wrote:
> Hi.
> 
> My list of NFS exports has been gradually growing over the years.
> Right now, for example, my home directories are exported to around
> 800 hosts. (although only a relatively small subset of those will
> mount at the same time...).  I used to just add hosts to
> /etc/exports on the file server, and run "exportfs -r", and
> everything would be fine.  New systems would be able to mount
> everything perfectly, and existing systems would not be affected at
> all.  As the list has grown, I've been noticing a problem. Now, when
> I run exportfs -r, there is an approximate 7-10 second hang on the
> systems that have already mounted the share, and then everything
> returns to normal.  This doesn't happen *while* exportfs -r is
> running, but just after it exits.  I figured that maybe exportfs was
> "unexporting"/re-exporting to hosts that already had the share in
> use which might have caused the problem, so I tried to manually
> add/remove hosts thinking that this would only affect those hosts,
> but it did not. Exporting to one new host still causes the hang on
> all existing hosts.
> 
> Since I have multiple exports to all of the hosts, adding one new
> host can hang things for a while.  I can see that reducing the list
> of exports, or hosts would reduce the delay.  What I am wondering is
> if there is a better way that I can add hosts without affecting
> connectivity to existing hosts?
> 
> The NFS server itself is pretty powerful -- dual quad core box, lots
> of memory, many NFS threads, exclusive NFS server, etc...  I am
> running an older RHEL4 release though, so it would have an older
> kernel/NFS system.  Maybe this issue has been solved in newer
> releases.

There have been fixes in this area, though I don't see any that I'm sure
would address your problem.  If you could test with the latest nfs-utils
(ideally, with the latest nfs-utils and kernel) and let us know the
result, that would be helpful.

The -t option to rpc.mountd (may need a newer nfs-utils?) may also help.

Also worth filing an RHEL bug.

--b.
