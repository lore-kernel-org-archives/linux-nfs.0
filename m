Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37907 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754798Ab2DHVeW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 8 Apr 2012 17:34:22 -0400
Date: Sun, 8 Apr 2012 17:34:21 -0400
To: Mike Grant <mggr@pml.ac.uk>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS4 client loop (10025 / BAD_STATEID)
Message-ID: <20120408213421.GA854@fieldses.org>
References: <4F7DD5BF.7070003@pml.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F7DD5BF.7070003@pml.ac.uk>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 05, 2012 at 06:26:23PM +0100, Mike Grant wrote:
> Hi,
> 
> We've recently had some issues with NFS clients hammering servers to a
> crawl due to a loop condition with NFS4 BAD_STATEID.  After trawling the
> archives, I found something similar:
>  http://www.spinics.net/lists/linux-nfs/msg25012.html
>   ("RE: NFS4ERR_STALE_CLIENTID loop" Oct 2011)
> 
> I believe the outcome was that this was probably a Solaris server bug,
> but the archive search makes it tricky to be sure.
> 
> Our issue is similar albeit with BAD_STATEID.  A couple of tcpdumps can
> be found at http://rsg.pml.ac.uk/staff/mggr/linux-nfs/  The clients are
> a bit outdated (Fedora 14, running 2.6.35.14-106.fc14.x86_64).
> 
> This is also against a Solaris server and, while not reproducable on
> demand, happens about once every 2 days.  There are three machines in
> this loop as I write ;)  Anyway, I'm assuming that's Oracle's (and our)
> problem..
> 
> However, we have seen the same situation against a Linux server (RHEL 6,
> 2.6.32-71.el6.x86_64) about two weeks ago.  It occurred when the server
> was rebooted and 2 workstations (out of 40) that were active at the time
> of the reboot went into the same sort of loop when the server
> reappeared.  Unfortunately the workstations were quickly rebooted
> without gathering info and it's not yet reoccurred.
> 
> We're likely to do another reboot sometime after Easter, so I have my
> fingers crossed we'll get a repeat of the issue.  If so, what info and
> conditions would you ideally want us to try and get, bearing in mind
> this is a core operational fileserver?  (i.e. we'd rather not run
> development kernels on it)

Probably most helpful would be to capture the client/server wire
traffic.

Chances are it's very repetitive, so if we can get a long enough snippet
just to see what's going on, that should suffice.

So something like "tcpdump -s0 -wtmp.pcap" run for a second or so after
the problem happens.  (And send us tmp.pcap.  Note text output from
tcpdump is unlikely to be detailed enough.)

Or if you know when you expect the problem to happen, start the capture
before you do the reboot and keep it running until you're sure you've
hit the problem.

--b.
