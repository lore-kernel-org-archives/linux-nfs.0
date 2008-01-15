From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] fd cache inconsistency!
Date: Tue, 15 Jan 2008 12:22:43 -0500
Message-ID: <20080115172243.GH17937@fieldses.org>
References: <215ff4410801150718o28118bc8me7d344b303e00306@mail.gmail.com>
	<20080115164440.GC17937@fieldses.org>
	<215ff4410801150915g6142b65ch2fc55f2cd332a333@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chris Fanning <christopher.fanning@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:59141 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750895AbYAORXH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jan 2008 12:23:07 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JEpVA-0003QB-7r
	for linux-nfs@vger.kernel.org; Wed, 16 Jan 2008 04:23:04 +1100
In-Reply-To: <215ff4410801150915g6142b65ch2fc55f2cd332a333-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 15, 2008 at 06:15:26PM +0100, Chris Fanning wrote:
> On Jan 15, 2008 5:44 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> >
> > On Tue, Jan 15, 2008 at 04:18:10PM +0100, Chris Fanning wrote:
> > > Hi all,
> > >
> > > In my syslog I'm getting lots of these.
> > >
> > > nfsd[1926]: fd cache inconsistency!
> > > last message repeated 31 times
> > >
> > > Does anyone know what it means?
> >
> > No.  In fact, I can't find that message in the current kernel or
> > nfs-utils.  What versions of those are you using?
> 
> /usr/sbin/rpc.nfsd -v
> Universal NFS Server 2.2beta47

Oh.  My understanding is that that's not maintained very much.

So I'd recommend reporting the problem to your distributor's bug
database and considering using the kernel's nfs server instead.

--b.

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

