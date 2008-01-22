From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfs2/3 ESTALE bug on mount point (v2.6.24-rc8)
Date: Tue, 22 Jan 2008 11:41:11 -0500
Message-ID: <20080122164111.GA24697@fieldses.org>
References: <20080121193116.GM17468@fieldses.org> <200801212028.m0LKSpwA002924@agora.fsl.cs.sunysb.edu> <20080121220828.GR17468@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
	nfs@lists.sourceforge.net
To: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:42324 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751587AbYAVQlT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Jan 2008 11:41:19 -0500
In-Reply-To: <20080121220828.GR17468@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 21, 2008 at 05:08:28PM -0500, bfields wrote:
> On Mon, Jan 21, 2008 at 03:28:51PM -0500, Erez Zadok wrote:
> > 
> > Here you go.  See the tcpdump in here:
> > 
> > 	http://agora.fsl.cs.sunysb.edu/tmp/nfs/
> > 
> > I captured it on an x86_64 machine using
> > 
> > 	tcpdump -s 0 -i lo -w tcpdump2
> > 
> > And it shows near the very end the ESTALE error.
> 
> Yep, thanks!  So frame 107855 has the MNT reply that returns the
> filehandle in question, which is used in an ACCESS call in frame 107855
> that gets an ESTALE.  Looks like an unhappy server!
> 
> > Do you think this could be related to nfs-utils?  I find that I can easily
> > trigger this problem on an FC7 machine with nfs-utils-1.1.0-4.fc7 (within
> > 10-30 runs of the above loop); but so far I cannot trigger the problem on an
> > FC6 machine with nfs-utils-1.0.10-14.fc6 (even after 300+ runs of the above
> > loop).
> 
> Yes, it's quite likely, though on a quick skim through the git logs I
> don't see an obviously related commit...

It might help to turn on rpc cache debugging:

	echo 2048 >/proc/sys/sunrpc/rpc_debug

and then capture the contents of the /proc/net/rpc/*/content files just
after the failure.

Possibly even better, though it'll produce a lot of stuff:

	strace -p `pidof rpc.mountd` -s4096 -otmp

and then pass along "tmp".

And then of course if the regression is in nfs-utils then there's always
a git-bisect as the debugging tool of last-resort: assuming you can
reproduce the same regression between nfs-utils-1-0-10 and
nfs-utils-1-1-0 from git://linux-nfs.org/nfs-utils, then all you'd need
to do is clone that repo and do

	git bisect start
	git bisect good nfs-utils-1-0-10
	git bisect bad nfs-utils-1-1-0

And it shouldn't take more than 8 tries.

Sorry for not having any more clever suggestions....

--b.
