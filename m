Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e3.ny.us.ibm.com ([32.97.182.143]:37802 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756571Ab1K2Xtw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Nov 2011 18:49:52 -0500
Received: from /spool/local
	by e3.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <eshel@almaden.ibm.com>;
	Tue, 29 Nov 2011 18:49:51 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pATNnoi0254358
	for <linux-nfs@vger.kernel.org>; Tue, 29 Nov 2011 18:49:50 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pATNnm9h005783
	for <linux-nfs@vger.kernel.org>; Tue, 29 Nov 2011 18:49:49 -0500
In-Reply-To: <1322609431.11286.56.camel@lade.trondhjem.org>
References: <1322887965-2938-1-git-send-email-bergwolf@gmail.com>	   <4ED54FE4.9050008@panasas.com> <4ED55399.4060707@panasas.com>
	  <1322603848.11286.7.camel@lade.trondhjem.org> <4ED55F78.205@panasas.com>
	 <1322606842.11286.33.camel@lade.trondhjem.org>	 <4ED563AC.5040501@panasas.com> <1322609431.11286.56.camel@lade.trondhjem.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Peng Tao <bergwolf@gmail.com>, bhalevy@tonian.com,
        Boaz Harrosh <bharrosh@panasas.com>, Garth Gibson <garth@panasas.com>,
        Fred Isaman <iisaman@netapp.com>, linux-nfs@vger.kernel.org,
        Matt Benjamin <matt@linuxbox.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] nfs41: allow layoutget at pnfs_do_multiple_writes
Message-ID: <OFF7649CC5.E17B103B-ON88257957.0081DB7B-88257957.0082E12A@us.ibm.com>
From: Marc Eshel <eshel@almaden.ibm.com>
Date: Tue, 29 Nov 2011 15:49:45 -0800
Content-Type: text/plain; charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The only 1 cent that I can add to this argument is that I was led to 
believe by you and others that Linux kernel don't add functionality on the 
client side that is not supported on the server side. Last time I made 
this point I was told that it is ok if they are of by a version or two. 
You made it clear that this is no longer true and that the Linux client 
and server are now independent of each other. I spent time working on the 
server side believing that the client and server will progress more or 
less together, disappointed to find out that it is not the case any more.
Marc. 



From:
Trond Myklebust <Trond.Myklebust@netapp.com>
To:
Boaz Harrosh <bharrosh@panasas.com>
Cc:
Peng Tao <bergwolf@gmail.com>, linux-nfs@vger.kernel.org, 
bhalevy@tonian.com, Garth Gibson <garth@panasas.com>, Matt Benjamin 
<matt@linuxbox.com>, Marc Eshel <eshel@almaden.ibm.com>, Fred Isaman 
<iisaman@netapp.com>
Date:
11/29/2011 03:30 PM
Subject:
Re: [PATCH 0/4] nfs41: allow layoutget at pnfs_do_multiple_writes



On Tue, 2011-11-29 at 14:58 -0800, Boaz Harrosh wrote: 
> On 11/29/2011 02:47 PM, Trond Myklebust wrote:
> > On Tue, 2011-11-29 at 14:40 -0800, Boaz Harrosh wrote: 
> >> On 11/29/2011 01:57 PM, Trond Myklebust wrote:
> >>>> Also Files when they will support segments and servers that request 
segments,
> >>>> like the CEPH server, will very much enjoy the above, .i.e: Tell me 
the amount
> >>>> you know you want to write.
> >>>
> >>> Why would we want to add segment support to the pNFS files client???
> >>> Segments are a nuisance that multiply the amount of unnecessary 
chitchat
> >>> between the client and the MDS without providing any tangible
> >>> benefits...
> >>>
> >>
> >> Your kidding right?
> >>
> >> One: it is mandated by the Standard, This is not an option. So a 
perfectly
> >>      Standard complaint server is not Supported by Linux because we 
don't see
> >>      the point.
> > 
> > Bollocks.. Nothing is "mandated by the Standard". If the server 
doesn't
> > give us a full layout, then we fall back to write through MDS. Why 
dick
> > around with crap that SLOWS YOU DOWN.
> > 
> 
> NO! MAKE YOU FASTER.
> 
> The kind of typologies I'm talking about a single layout get ever 1GB is
> marginal to the gain I get in deploying 100 of DSs. I have thousands of
> DSs I want to spread the load evenly. I'm limited by the size of the 
layout
> (Device info in the case of files) So I'm limited by the number of DSs I 
can
> have in a layout. For large files these few devices become an hot spot 
all
> the while the rest of the cluster is idle.

I call "bullshit" on that whole argument...

You've done sod all so far to address the problem of a client managing
layout segments for a '1000 DS' case. Are you expecting that all pNFS
object servers out there are going to do that for you? How do I assume
that a generic pNFS files server is going to do the same? As far as I
know, the spec is completely moot on the whole subject.

IOW: I'm not even remotely interested in your "everyday problems" if
there are no "everyday solutions" that actually fit the generic can of
spec worms that the pNFS layout segments open.

> >> Two: There are already file-layout servers out there (multiple) which 
are
> >>      waiting for the Linux files-layout segment support, because the 
underline
> >>      FS requires Segments and now they do not work with the Linux 
client. These
> >>      are CEPH and GPFS and more.
> > 
> > Then they will have a _long_ wait....
> > 
> 
> OK, so now I understand. Because when I was talking to Fred before BAT 
and during
> It was very very peculiar to me why he is not already done with that 
simple stuff.
> Because usually Fred is such a brilliant fast programmer that I admire, 
and that simple
> crap?
> 
> But now that explains

Yes. It's all a big conspiracy, and we're deliberately holding Fred's
genius back in order to disappoint you...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com




