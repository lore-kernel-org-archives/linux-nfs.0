From: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>
Subject: Re: [NFS] nfs2/3 ESTALE bug on mount point (v2.6.24-rc8)
Date: Mon, 21 Jan 2008 15:28:51 -0500
Message-ID: <200801212028.m0LKSpwA002924@agora.fsl.cs.sunysb.edu>
References: <20080121193116.GM17468@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-nfs@vger.kernel.org,
	Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>, Trond.Myklebust@netapp.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:52324 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756005AbYAUU3X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Jan 2008 15:29:23 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JH3Gj-0007Ln-2H
	for linux-nfs@vger.kernel.org; Tue, 22 Jan 2008 07:29:21 +1100
In-reply-to: Your message of "Mon, 21 Jan 2008 14:31:16 EST."
	<20080121193116.GM17468@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In message <20080121193116.GM17468@fieldses.org>, "J. Bruce Fields" writes:
> On Mon, Jan 21, 2008 at 01:19:30PM -0500, Erez Zadok wrote:
> > Since around 2.6.24-rc5 or so I've had an occasional problem: I get an
> > ESTALE error on the mount point after setting up a localhost exported mount
> > point, and trying to mkdir something there (this is part of my setup scripts
> > prior to running unionfs regression tests).
> > 
> > I'm CC'ing both client and server maintainers/list, b/c I'm not certain
> > where the problem is.  The problem doesn't exist in 2.6.23 or earlier stable
> > kernels.  It doesn't appear in nfs4 either, only nfs2 and nfs3.
> > 
> > The problem is seen intermittently, and is probably some form of a race.  I
> > was finally able to narrow it down a bit.  I was able to write a shell
> > script that for me reproduces the problem within a few minutes (I tried it
> > on v2.6.24-rc8-74-ga7da60f and several different machine configurations).
> > 
> > I've included the shell script below.  Hopefully you can use it to track the
> > problem down.  The mkdir command in the middle of the script is that one
> > that'll eventually cause an ESTALE error and cause the script to abort; you
> > can run "df" afterward to see the stale mount points.
> > 
> > Notes: the one anecdotal factor that seems to make the bug appear sooner is
> > if you increase the number of total mounts that the script below creates
> > ($MAX in the script).
> 
> OK, so to summarize:
> 
> 	1. create $MAX ext2 filesystem images, loopback-mount them, and export
> 	   the result.
> 	2. nfs-mount each of those $MAX exports.
> 	3. create a directory under each of those nfs-mounts.
> 	4. unmount and unexport
> 
> Repeat that a thousand times, and eventually get you ESTALE at step 3?

Your description is correct.

> I guess one step would be to see if it's possible to get a network trace
> showing what happened in the bad case....

Here you go.  See the tcpdump in here:

	http://agora.fsl.cs.sunysb.edu/tmp/nfs/

I captured it on an x86_64 machine using

	tcpdump -s 0 -i lo -w tcpdump2

And it shows near the very end the ESTALE error.
 
> --b.

Do you think this could be related to nfs-utils?  I find that I can easily
trigger this problem on an FC7 machine with nfs-utils-1.1.0-4.fc7 (within
10-30 runs of the above loop); but so far I cannot trigger the problem on an
FC6 machine with nfs-utils-1.0.10-14.fc6 (even after 300+ runs of the above
loop).

Let me know if I can help more.

Erez.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

