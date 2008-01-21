From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfs2/3 ESTALE bug on mount point (v2.6.24-rc8)
Date: Mon, 21 Jan 2008 17:08:28 -0500
Message-ID: <20080121220828.GR17468@fieldses.org>
References: <20080121193116.GM17468@fieldses.org> <200801212028.m0LKSpwA002924@agora.fsl.cs.sunysb.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
	nfs@lists.sourceforge.net
To: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:48632 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752410AbYAUWIf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Jan 2008 17:08:35 -0500
In-Reply-To: <200801212028.m0LKSpwA002924-zop+azHP2WsZjdeEBZXbMidm6ipF23ct@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 21, 2008 at 03:28:51PM -0500, Erez Zadok wrote:
> In message <20080121193116.GM17468@fieldses.org>, "J. Bruce Fields" writes:
> > On Mon, Jan 21, 2008 at 01:19:30PM -0500, Erez Zadok wrote:
> > > Since around 2.6.24-rc5 or so I've had an occasional problem: I get an
> > > ESTALE error on the mount point after setting up a localhost exported mount
> > > point, and trying to mkdir something there (this is part of my setup scripts
> > > prior to running unionfs regression tests).
> > > 
> > > I'm CC'ing both client and server maintainers/list, b/c I'm not certain
> > > where the problem is.  The problem doesn't exist in 2.6.23 or earlier stable
> > > kernels.  It doesn't appear in nfs4 either, only nfs2 and nfs3.
> > > 
> > > The problem is seen intermittently, and is probably some form of a race.  I
> > > was finally able to narrow it down a bit.  I was able to write a shell
> > > script that for me reproduces the problem within a few minutes (I tried it
> > > on v2.6.24-rc8-74-ga7da60f and several different machine configurations).
> > > 
> > > I've included the shell script below.  Hopefully you can use it to track the
> > > problem down.  The mkdir command in the middle of the script is that one
> > > that'll eventually cause an ESTALE error and cause the script to abort; you
> > > can run "df" afterward to see the stale mount points.
> > > 
> > > Notes: the one anecdotal factor that seems to make the bug appear sooner is
> > > if you increase the number of total mounts that the script below creates
> > > ($MAX in the script).
> > 
> > OK, so to summarize:
> > 
> > 	1. create $MAX ext2 filesystem images, loopback-mount them, and export
> > 	   the result.
> > 	2. nfs-mount each of those $MAX exports.
> > 	3. create a directory under each of those nfs-mounts.
> > 	4. unmount and unexport
> > 
> > Repeat that a thousand times, and eventually get you ESTALE at step 3?
> 
> Your description is correct.
> 
> > I guess one step would be to see if it's possible to get a network trace
> > showing what happened in the bad case....
> 
> Here you go.  See the tcpdump in here:
> 
> 	http://agora.fsl.cs.sunysb.edu/tmp/nfs/
> 
> I captured it on an x86_64 machine using
> 
> 	tcpdump -s 0 -i lo -w tcpdump2
> 
> And it shows near the very end the ESTALE error.

Yep, thanks!  So frame 107855 has the MNT reply that returns the
filehandle in question, which is used in an ACCESS call in frame 107855
that gets an ESTALE.  Looks like an unhappy server!

> Do you think this could be related to nfs-utils?  I find that I can easily
> trigger this problem on an FC7 machine with nfs-utils-1.1.0-4.fc7 (within
> 10-30 runs of the above loop); but so far I cannot trigger the problem on an
> FC6 machine with nfs-utils-1.0.10-14.fc6 (even after 300+ runs of the above
> loop).

Yes, it's quite likely, though on a quick skim through the git logs I
don't see an obviously related commit....

--b.
