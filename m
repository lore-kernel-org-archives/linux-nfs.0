From: bpm@sgi.com
Subject: Re: Problem with nfs server reboot causing exports to jumble
Date: Fri, 26 Feb 2010 10:38:42 -0600
Message-ID: <20100226163842.GI20620@sgi.com>
References: <20100225192911.09CC318839E@wsnyder.org> <20100225200657.GD20620@sgi.com> <20100225203336.9F69118839E@wsnyder.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Wilson Snyder <wsnyder-12vJDDTx9R9AfugRpC6u6w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.179.30]:42249 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965310Ab0BZQhu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Feb 2010 11:37:50 -0500
In-Reply-To: <20100225203336.9F69118839E-12vJDDTx9R9AfugRpC6u6w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Wilson,

On Thu, Feb 25, 2010 at 03:33:36PM -0500, Wilson Snyder wrote:
> >Use the mp and fsid export options documented in the exports manpage.
> 
> Reading between the lines, are you suggesting the mounts
> weren't ready when the exports started

I'm suggesting that it's a good idea to use the mp export option so that
you don't export your root filesystem in the off chance that the
filesystems you want to export aren't mounted yet.

> I presume then that it's enough to just use mp - assuming
> each mountpoint has a unique UUID?  

Look into how the fsid that identifies each filesystem to the nfs client
is chosen by the nfs server.  Is it possible that it changed across the
reboot?  I don't know offhand.  If it did change across a reboot, using
the fsid export option to explicitly set the fsid for each export might 
prevent this happening again.

> Wouldn't adding fsid now (with the server and clients all up) require
> me to remount every client?

Yep, I think so.  Maybe you want to schedule some downtime.

> Finally, is there a way to examine the present
> (automatically assigned) fsid's so I can confirm this was
> the problem?

Maybe you can try ethereal or something like that.

-Ben
