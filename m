From: mike <mike503@gmail.com>
Subject: Re: [NFS] Help! NFS broken
Date: Mon, 8 Dec 2008 16:12:12 -0800
Message-ID: <bd9320b30812081612t6f6ec465rb5879051a8509b1f@mail.gmail.com>
References: <bd9320b30812070648x652c8430uf567b9c80cda07a6@mail.gmail.com>
	<20081208233811.GD24083@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:35927 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753522AbYLIANJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Dec 2008 19:13:09 -0500
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1L9qDq-0008FX-DC
	for linux-nfs@vger.kernel.org; Tue, 09 Dec 2008 11:13:06 +1100
In-Reply-To: <20081208233811.GD24083@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 8, 2008 at 3:38 PM, J. Bruce Fields <bfields@fieldses.org> wrote:

> So the "server" in the first paragraph is an NFS client, and its NFS
> server is the FreeBSD machine?

Yes

> And what are the first symptoms?  Any threads accessing the NFS
> filesystem just hang?  A sysrq-T trace on the client showing where
> they're hanging might be helpful.

Honestly, these are production, and I looked in every place I could
think for any hints, and I get nothing. I can't really be using this
to test either. What is odd is identically configured machines (down
to the same files in /etc, same packages from dpkg -l etc) have no
issue.

For a last result, I tried different kernel versions (from Ubuntu):

linux-image-2.6.27-10-server - broken
linux-image-2.6.27-7-server - broken
linux-image-2.6.28-2-server - i think i used this too quick and it was
broken (I might be wrong and wound up deciding to go back instead of
forward)
linux-image-2.6.24-16-server - working for 2 days now, so sticking with it

Note that all the other nodes (5 of the 6 identical nodes are fine,
this was the one bad one) are running the default kernel in Intrepid
at the moment: linux-image-2.6.27-10-server and don't seem to be
suffering from any issues.

So it seems to be a combination of those kernels + that machine.
Problem is, that machine's configuration is identical - same
nfs-utils, portmap, etc, etc. and from my rsync scan, even the
majority of files (and anything that should be relevant) in /etc are
identical too.

This might be an Ubuntu bug or something flaky with 2.6.27 (maybe
2.6.28 too) and NFS in general but I don't know how I can produce any
worthwhile debugging, especially considering this is in production.
When I wrote this I saw no fix in place; the kernel downgrade appears
to be the workaround for now.

Sorry I can't be more help. At the point of this email I had the
luxury of a broken setup to debug, but now that I've stabilized it I
have to keep it this way :)

------------------------------------------------------------------------------
SF.Net email is Sponsored by MIX09, March 18-20, 2009 in Las Vegas, Nevada.
The future of the web can't happen without you.  Join us at MIX09 to help
pave the way to the Next Web now. Learn more and register at
http://ad.doubleclick.net/clk;208669438;13503038;i?http://2009.visitmix.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

