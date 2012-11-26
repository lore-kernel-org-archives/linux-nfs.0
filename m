Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59564 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753450Ab2KZQIx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 11:08:53 -0500
Date: Mon, 26 Nov 2012 11:08:53 -0500
To: "dE ." <de.techno@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Slow NFS loop performance.
Message-ID: <20121126160853.GB11860@fieldses.org>
References: <50AF57A3.3090000@gmail.com>
 <20121123172333.GB8776@fieldses.org>
 <50B3918E.4020303@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <50B3918E.4020303@gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 26, 2012 at 09:28:06PM +0530, dE . wrote:
> On 11/23/12 22:53, J. Bruce Fields wrote:
> >On Fri, Nov 23, 2012 at 04:31:55PM +0530, dE . wrote:
> >>Humm... The last thing I expected was no response even in the mailing list.
> >>
> >>So I'm filing a bug on this.
> >>
> >>On Oct 23, 2012 2:19 PM, "dE ."<de.techno@gmail.com>  wrote:
> >>>Hi!
> >>>
> >>>Great job with NFS server, it surely is fast, but not on loop devices.
> >>>
> >>>If I loop mount a file and share the mount point over NFS3 or NFS4, the
> >>>write performance of the client on the loop mounted share is pretty bad.
> >>>
> >>>On a 100 Mbps (or 12.5MBps) full duplex Ethernet link, I get ~8MBps
> >>>speeds, whereas on the loop mounted device, I get at best 6MBps.
> >What exactly is your test?
> >
> >--b.
> 
> Sorry for the late response. I'd 200+ unread mails.
> 
> I'm writing a large file to the mounted loop device.

How large, and do you have the exact command you're using for that?

Also, what are the client and server versions?

I don't have any good idea off the top of my head.  I doubt anyone's
worked on optimizing exports of loop devices.  I guess the first step
would be to collect some statistics in the two cases (loop device and
non-loop device), compare them, and see if you can see any patterns.
/proc/self/mountstats on the client, and /proc/fs/nfsd/pool_stats, on
the server, would be starting points.  Maybe perf on the server could
also show up something.  Just running "top" on the server might be
interesting.  (E.g.  is the CPU obviously busier in the slow case?)

--b.
