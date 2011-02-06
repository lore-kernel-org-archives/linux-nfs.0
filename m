Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from icebox.esperi.org.uk ([81.187.191.129]:47547 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753593Ab1BFSyz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 6 Feb 2011 13:54:55 -0500
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: George Spelvin <linux@horizon.com>, linux-nfs@vger.kernel.org
Subject: Re: persistent, quasi-random -ESTALE at mount time
References: <20110203034844.GA30641@fieldses.org>
	<20110203042814.6364.qmail@science.horizon.com>
	<20110203044010.GC30641@fieldses.org>
	<87zkqdo6yv.fsf@spindle.srvr.nix>
	<20110203134035.GA18325@fieldses.org>
From: Nix <nix@esperi.org.uk>
Date: Sun, 06 Feb 2011 18:54:46 +0000
In-Reply-To: <20110203134035.GA18325@fieldses.org> (J. Bruce Fields's message of "Thu, 3 Feb 2011 08:40:35 -0500")
Message-ID: <87sjw156yx.fsf@spindle.srvr.nix>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 3 Feb 2011, J. Bruce Fields uttered the following:

> On Thu, Feb 03, 2011 at 08:30:48AM +0000, Nix wrote:
>> I can give you a packet dump from my (completely reproducible) failure
>> with the same symptoms, if you like. (Again, it is fixed by running
>> exportfs repeatedly, each time fixing another few mounts: currently,
>> I have to run it six times.)
>
> That would be great, thanks.  And could you collect the contents of
> /proc/net/rpc/{nfsd.fh,nfsd.export}/content at the same time?  (I think
> you already sent some; but I'd be curious to match them up with the
> packet trace.)  Also, the output of "blkid" might help diagnose any
> problems with uuid's.

I jinxed it. I just recompiled and the problem went away. The only
differences between the old and new kernel are a so-far-entirely-
unconfigured IPv6 setup (so nothing but link-local private addresses, no
routing, nothing) and a new compiler (4.5.x rather than 4.4.x).

Which of these caused the change in behaviour I do not yet know, but
will try to figure out (by turning IPv6 off again and seeing if
the problem recurs).
