From: "Chris Fanning" <christopher.fanning@gmail.com>
Subject: Re: [NFS] fd cache inconsistency!
Date: Wed, 16 Jan 2008 18:12:04 +0100
Message-ID: <215ff4410801160912h7c995672xd856c86fbfaf431d@mail.gmail.com>
References: <215ff4410801150718o28118bc8me7d344b303e00306@mail.gmail.com>
	<20080115164440.GC17937@fieldses.org>
	<215ff4410801150915g6142b65ch2fc55f2cd332a333@mail.gmail.com>
	<20080115172243.GH17937@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:44856 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757421AbYAPRMZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Jan 2008 12:12:25 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JFBoM-0007pi-V8
	for linux-nfs@vger.kernel.org; Thu, 17 Jan 2008 04:12:23 +1100
In-Reply-To: <20080115172243.GH17937@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 15, 2008 6:22 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Tue, Jan 15, 2008 at 06:15:26PM +0100, Chris Fanning wrote:
> > On Jan 15, 2008 5:44 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > >
> > > On Tue, Jan 15, 2008 at 04:18:10PM +0100, Chris Fanning wrote:
> > > > Hi all,
> > > >
> > > > In my syslog I'm getting lots of these.
> > > >
> > > > nfsd[1926]: fd cache inconsistency!
> > > > last message repeated 31 times
> > > >
> > > > Does anyone know what it means?
> > >
> > > No.  In fact, I can't find that message in the current kernel or
> > > nfs-utils.  What versions of those are you using?
> >
> > /usr/sbin/rpc.nfsd -v
> > Universal NFS Server 2.2beta47
>
> Oh.  My understanding is that that's not maintained very much.
>
> So I'd recommend reporting the problem to your distributor's bug
> database and considering using the kernel's nfs server instead.
>

ok. I'll do that. thanks.

Chris.

> --b.
>

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

