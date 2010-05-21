Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53373 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756223Ab0EURjL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 May 2010 13:39:11 -0400
Date: Fri, 21 May 2010 13:39:08 -0400
To: Martin Vogt <martin.vogt@itwm.fraunhofer.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: permission denied with >= ~2.6.25
Message-ID: <20100521173908.GD9639@fieldses.org>
References: <4BE7ED5D.90801@itwm.fraunhofer.de> <4BE93940.5070804@itwm.fraunhofer.de> <4BED1E44.4020708@itwm.fraunhofer.de> <20100516175213.GA9225@lts032.itwm.fhg.de> <4BF25109.40300@itwm.fraunhofer.de> <4BF3C7A4.8030906@itwm.fraunhofer.de> <20100519171347.GB8137@fieldses.org> <4BF500C9.2010904@itwm.fraunhofer.de>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4BF500C9.2010904@itwm.fraunhofer.de>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, May 20, 2010 at 11:28:41AM +0200, Martin Vogt wrote:
> J. Bruce Fields wrote:
> > On Wed, May 19, 2010 at 01:12:36PM +0200, Martin Vogt wrote:
> >> Martin Vogt wrote:
> >>> Hello,
> >>>
> >>>
> >>> today I tried 2.6.34 on server/client with standard
> >>> hardware. After around the 69th checkout I had an
> >>> "Invalid cross-device link" Error.
> >>> (Before that it was EIO/EPERM)
> >>>
> >>> Test ran for around 9 hours before it failed.
> >>>
> >>>> svn: In directory 'Kernel-pxe3-69.EZvgHTmbzv/include/asm-sparc'
> >>>> svn: Can't move
> >>> 'Kernel-pxe3-69.EZvgHTmbzv/include/asm-sparc/resource.h.tmp'
> >>>> to 'Kernel-pxe3-69.EZvgHTmbzv/include/asm-sparc/resource.h': Invalid
> >>>> cross-device link
> >>>> Mon May 17 23:46:32 CEST 2010,1
> >>>> runcounter: 69
> >> Ok.
> >> RTFM: no_subtree_check :-(
> >>
> >> This option made the checkouts reliable.
> > 
> > Erp.  Should have thought of that.  It's no longer the default in recent
> > nfs-utils, for this sort of reason.
> > 
> > (But, note: for anyone exporting directories that aren't mountpoints,
> > that may expose more of their filesystem than intended.)
> > 
> 
> Hello,
> 
> the report for the latest kernel was done with "no_subtree_check"

OK, sorry, I don't know.

You've been varying both client and server, but from your initial
reports it sounded like this was something that first started happening
on a client upgrade?

Have you been able to keep the server fixed while doing a binary search
through the client version for the first non-working client?

--b.

> 
> -9 hours client/server both 2.6.34 before "Invalid cross-device link"
> 
> 2.6.34 still shows some svn problem with "no_subtree_check" on.
> But only after 9 hours (vs 10 minutes, with subtree_check)
> 
> It was done with:
> 
> >log:Assuming default behaviour ('no_subtree_check').
> exports:
> >/var/tmp/nfs_export
> >192.168.9.0/255.255.255.0(rw,async,wdelay,acl,no_root_squash,fsid=6666)
> 
> Using "no_subtree_check" made it only "much more" stable
> than before, but not "stable".
> 
> Server was 4 core (2 sockets) Xeon 5148@2.33GHz,
> 8GB mem.
> Exported fs was ext3 from a Standard Sata drive,
> and the client was a dual core E8400.
> 
> Mount client:
> mount -o rw,nosuid,nodev,rsize=8192,wsize=8192,vers=3 -t nfs
> pxe2:/var/tmp/nfs_export  /home/local
> 
> 
> I'm attaching my test script. The script needs to be run two times
> in parallel on the machine. (In screen for example).
> If someone wants to reproduce this.A single checkout on
> the machine would even takes longer to reproduce the problem.
> 
> I imported a normal kernel tree into a svn repository
> on a dedicated server only for this and started svnserve -d
> as normal user.
> 
> 
> regards,
> 
> Martin
> 


