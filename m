Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:54376 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752584Ab0LXS1Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Dec 2010 13:27:16 -0500
Date: Fri, 24 Dec 2010 13:27:14 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Nix <nix@esperi.org.uk>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: persistent, quasi-random -ESTALE at mount time
Message-ID: <20101224182714.GA8899@fieldses.org>
References: <87mxra6duq.fsf@spindle.srvr.nix>
 <20100922155235.GE15560@fieldses.org>
 <8762xwqijb.fsf@spindle.srvr.nix>
 <20101001220018.GE1472@fieldses.org>
 <87zkux5ye1.fsf@spindle.srvr.nix>
 <20101001231144.GB12203@fieldses.org>
 <878vzo5dsh.fsf@spindle.srvr.nix>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <878vzo5dsh.fsf@spindle.srvr.nix>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Dec 17, 2010 at 08:45:34PM +0000, Nix wrote:
> On 2 Oct 2010, J. Bruce Fields stated:
> 
> > On Fri, Oct 01, 2010 at 11:41:42PM +0100, Nix wrote:
> >> I mean, yes, we can work around it by killing rpc.mountd and restarting
> >> it as soon as the server has booted, but, well, yuck, no thanks, too
> >> much of a kludge. I'll have a concentrated hunt for the bug soon (once I
> >> can reproduce it without rebooting the single largest machine I have
> >> root on!)
> >
> > OK, thanks for the persistence, and apologies that I can't think of
> > anything off the top of my head (and haven't had the time to try and
> > look more closely).  I'll look forward to anything more you can figure
> > out....
> 
> This is still happening. Just by chance (while checking to see if adding
> unique fsids to every line fixed it: no) I spotted something
> interesting, which I think points to the cause.
> 
> You don't need to repeatedly kill rpc.mountd and restart it at all to
> fix things. You just have to run exportfs many times!
> 
> Here are dumps of /proc/fs/nfs/exports on boot (after a single exportfs -ra),
> then after a subsequent one, then another:
...
> If exportfs is not correctly exporting everything to the kernel when
> run, that would pretty much explain the cause of spontaneous -ESTALEs on
> reboot, because rebooting clears the mount table: if a single exportfs
> is failing to properly refill it, mountd is going to say -ESTALE about
> everything it forgot to put back in.

Note that the contents of /proc/fs/nfs/exports represent the kernel's
cached view of the exports, *not* the entire export table; when a client
requests an export which the kernel does not know about, the kernel
makes an upcall to mountd to get the relevant export entry.  All
exportfs does is clear the kernel's cache so that subsequent upcalls
will get the new information.

So it's normal that the contents of /porc/fs/nfs/exports would be
incomplete immediately after running exportfs.

--b.

> 
> 
> I'll scatter debugging through exportfs and try to see what it's doing
> wrong.
