Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46410 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754173Ab0FXQHj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Jun 2010 12:07:39 -0400
Date: Thu, 24 Jun 2010 12:07:38 -0400
To: Rob Henderson <robh@indiana.edu>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Runaway kernel slab memory usage when user over quota
Message-ID: <20100624160738.GC17827@fieldses.org>
References: <4C1F7B58.4090802@indiana.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4C1F7B58.4090802@indiana.edu>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

(Changed cc to new list.)

On Mon, Jun 21, 2010 at 10:46:48AM -0400, Rob Henderson wrote:
> We've been fighting a problem with runaway kernel slab memory usage on our file servers ever since moving from nfsv3 to nfsv4 and think I've finally identified the trigger.  We are using disk quotas and the problem seems to arise when a user (whose home directory is on the nfsv4 server) goes over quota.  I've suspected this was the cause for quite some time but just recently caught things in the act and collected evidence to support this theory.  Here was the scenario for one such incident.

Thanks for the report.

What distributions and kernels (client and server side) are involved?

> 1) We have alerts to warn us when the slab usage goes over 650K and I got one such warning.
> 2) I started monitoring the nfs network traffic and noticed one system hitting the server quite hard.
> 3) I checked this system and found a user logged in who was over quota.
> 4) At this point, the slab usage was still rising and was getting dangerously close to 800MB which is when the server dies.

Could you capture the network traffic while the user over quota is
attempting file operations?

> 5) I increased the user in question's disk quota and the Slab usage immediately came down to around 600-650MB and stabilized.
> 6) After a couple days, I noticed that the usage was still hanging in the 600-650MB range which is higher than I like to see.

How are you measuring slab usage?  Also, does /proc/slabinfo tell you
which slab specifically is responsible?

> 7) I rebooted the workstation that the over quota user was still logged into and the usage *immediately* dropped to the 450MB range.
> 
> 
> Since this time, there have been two other times when the slab usage started to rise quickly and in both cases I was able to head off any problems by getting the offending user under quota.
> 
> Here are some other random notes:
> 
>  - During these incidents, if nothing is done the server will typically go from a slab usage of 600MB to 800MB (and crash) in a timeframe of about an hour.
>  - We are running RHEL5 with all updates on all servers and clients.
>  - The servers in question are running 32bit kernels.  We are looking at upgrading to 64bit as a stop-gap measure.
>  - We never saw this behavior in the many years we were using nfsv3.  We've been using nfsv4 for about a year now and started experiencing this behavior shortly after the migration.

I'm working just 3 days between vacations and may not get to this
promptly.

Might also be worth attempting to find a small test case that will
reproduce the same behavior.

Off-hand one explanation might be a memory leak on an error path
somewhere--presumably an error path that's only hit in frequently in the
case when some operation fails due to a quota being exceeded.  I don't
know what operation that would be, though.

--b.
