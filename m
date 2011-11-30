Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e1.ny.us.ibm.com ([32.97.182.141]:58422 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753269Ab1K3AxF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Nov 2011 19:53:05 -0500
Received: from /spool/local
	by e1.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <eshel@almaden.ibm.com>;
	Tue, 29 Nov 2011 19:53:04 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAU0r1Qk267856
	for <linux-nfs@vger.kernel.org>; Tue, 29 Nov 2011 19:53:02 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAU0r18P023161
	for <linux-nfs@vger.kernel.org>; Tue, 29 Nov 2011 19:53:01 -0500
In-Reply-To: <1322613425.11286.86.camel@lade.trondhjem.org>
References: <1322887965-2938-1-git-send-email-bergwolf@gmail.com>			   <4ED54FE4.9050008@panasas.com> <4ED55399.4060707@panasas.com>
	 <1322603848.11286.7.camel@lade.trondhjem.org> <4ED55F78.205@panasas.com>
	 <1322606842.11286.33.camel@lade.trondhjem.org>			 <4ED563AC.5040501@panasas.com>
	 <1322609431.11286.56.camel@lade.trondhjem.org>		 <OFF7649CC5.E17B103B-ON88257957.0081DB7B-88257957.0082E12A@us.ibm.com>
	 <1322611689.11286.72.camel@lade.trondhjem.org>	 <OF5755ED9D.CC1FAA6E-ON88257958.00014359-88257958.0001D4D0@us.ibm.com> <1322613425.11286.86.camel@lade.trondhjem.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Peng Tao <bergwolf@gmail.com>, bhalevy@tonian.com,
        Boaz Harrosh <bharrosh@panasas.com>, Garth Gibson <garth@panasas.com>,
        Fred Isaman <iisaman@netapp.com>, linux-nfs@vger.kernel.org,
        Matt Benjamin <matt@linuxbox.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] nfs41: allow layoutget at pnfs_do_multiple_writes
Message-ID: <OFCC6E3358.498C4568-ON88257958.00043206-88257958.0004D550@us.ibm.com>
From: Marc Eshel <eshel@almaden.ibm.com>
Date: Tue, 29 Nov 2011 16:52:59 -0800
Content-Type: text/plain; charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust <Trond.Myklebust@netapp.com> wrote on 11/29/2011 04:37:05 
PM:
> 
> Peng Tao, bhalevy, Boaz Harrosh, Garth Gibson, Fred Isaman, linux-
> nfs, Matt Benjamin
> 
> On Tue, 2011-11-29 at 16:20 -0800, Marc Eshel wrote: 
> > You ignored my main point, I was talking about the server side, my 
point 
> > was that there is nothing to build on on the serve side since the pNFS 

> > Linux server is not happening.
> > Marc.
> 
> Sorry. I misunderstood your concern. As far as I know, the main problem
> there is also one of investment: nobody has stepped up to help Bruce
> write a pNFS server.
> 
> I'm less worried about this now than I was earlier, because other open
> source efforts are gaining traction (see Ganesha - which is being
> sponsored by IBM, and projects such as Tigran's java based pNFS server).
> The other point is that we've developed client test-rigs that don't
> depend on the availability of a Linux server (newpynfs and the pynfs
> based proxy).

You got it backward, Ganesha is getting traction precisely because the 
Linux kernel server is not happening :)
Sorry, I did not mean to change the topic of this thread, go back to 
addressing Boaz's concern.
Marc. 

> 
> Cheers
>   Trond 
> 
> > From:
> > Trond Myklebust <Trond.Myklebust@netapp.com>
> > To:
> > Marc Eshel <eshel@almaden.ibm.com>
> > Cc:
> > Peng Tao <bergwolf@gmail.com>, bhalevy@tonian.com, Boaz Harrosh 
> > <bharrosh@panasas.com>, Garth Gibson <garth@panasas.com>, Fred Isaman 
> > <iisaman@netapp.com>, linux-nfs@vger.kernel.org, Matt Benjamin 
> > <matt@linuxbox.com>
> > Date:
> > 11/29/2011 04:08 PM
> > Subject:
> > Re: [PATCH 0/4] nfs41: allow layoutget at pnfs_do_multiple_writes
> > 
> > 
> > 
> > On Tue, 2011-11-29 at 15:49 -0800, Marc Eshel wrote: 
> > > The only 1 cent that I can add to this argument is that I was led to 

> > > believe by you and others that Linux kernel don't add functionality 
on 
> > the 
> > > client side that is not supported on the server side. Last time I 
made 
> > > this point I was told that it is ok if they are of by a version or 
two. 
> > > You made it clear that this is no longer true and that the Linux 
client 
> > > and server are now independent of each other. I spent time working 
on 
> > the 
> > > server side believing that the client and server will progress more 
or 
> > > less together, disappointed to find out that it is not the case any 
> > more.
> > > Marc. 
> > 
> > I don't know how to manage layout segments in a way that meets the 
pNFS
> > goals of scalability and performance, and neither you nor the pNFS 
spec
> > have told me how to do this.
> > 
> > If IBM wants a client that implements layout segments, then it is 
_your_
> > responsibility to: 
> >      A. Convince me that it is an implementable part of the spec. 
> >      B. Provide me with an implementation that deals all with the
> >         concerns that I have.
> > 
> > IOW: nobody has ever promised IBM that the community would do all your
> > client work for you. EMC, NetApp and Panasas have implemented (most 
of)
> > the bits that they cared about; any bits that they haven't implemented
> > and that you care about are up to you.
> > 
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 

