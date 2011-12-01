Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43265 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751082Ab1LALPF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Dec 2011 06:15:05 -0500
Date: Thu, 1 Dec 2011 06:14:57 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Benny Halevy <bhalevy@tonian.com>
Cc: Marc Eshel <eshel@almaden.ibm.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Peng Tao <bergwolf@gmail.com>, Boaz Harrosh <bharrosh@panasas.com>,
        Garth Gibson <garth@panasas.com>, Fred Isaman <iisaman@netapp.com>,
        linux-nfs@vger.kernel.org, Matt Benjamin <matt@linuxbox.com>
Subject: Re: [PATCH 0/4] nfs41: allow layoutget at pnfs_do_multiple_writes
Message-ID: <20111201111457.GA4506@fieldses.org>
References: <1322606842.11286.33.camel@lade.trondhjem.org>
 <4ED563AC.5040501@panasas.com>
 <1322609431.11286.56.camel@lade.trondhjem.org>
 <OFF7649CC5.E17B103B-ON88257957.0081DB7B-88257957.0082E12A@us.ibm.com>
 <1322611689.11286.72.camel@lade.trondhjem.org>
 <OF5755ED9D.CC1FAA6E-ON88257958.00014359-88257958.0001D4D0@us.ibm.com>
 <1322613425.11286.86.camel@lade.trondhjem.org>
 <OFCC6E3358.498C4568-ON88257958.00043206-88257958.0004D550@us.ibm.com>
 <20111130194410.GB32028@fieldses.org>
 <4ED74D19.7060302@tonian.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4ED74D19.7060302@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 01, 2011 at 11:47:05AM +0200, Benny Halevy wrote:
> On 2011-11-30 21:44, J. Bruce Fields wrote:
> > On Tue, Nov 29, 2011 at 04:52:59PM -0800, Marc Eshel wrote:
> >> Trond Myklebust <Trond.Myklebust@netapp.com> wrote on 11/29/2011 04:37:05 
> >> PM:
> >>>
> >>> Peng Tao, bhalevy, Boaz Harrosh, Garth Gibson, Fred Isaman, linux-
> >>> nfs, Matt Benjamin
> >>>
> >>> On Tue, 2011-11-29 at 16:20 -0800, Marc Eshel wrote: 
> >>>> You ignored my main point, I was talking about the server side, my 
> >> point 
> >>>> was that there is nothing to build on on the serve side since the pNFS 
> >>
> >>>> Linux server is not happening.
> >>>> Marc.
> >>>
> >>> Sorry. I misunderstood your concern. As far as I know, the main problem
> >>> there is also one of investment: nobody has stepped up to help Bruce
> >>> write a pNFS server.
> >>>
> >>> I'm less worried about this now than I was earlier, because other open
> >>> source efforts are gaining traction (see Ganesha - which is being
> >>> sponsored by IBM, and projects such as Tigran's java based pNFS server).
> >>> The other point is that we've developed client test-rigs that don't
> >>> depend on the availability of a Linux server (newpynfs and the pynfs
> >>> based proxy).
> >>
> >> You got it backward, Ganesha is getting traction precisely because the 
> >> Linux kernel server is not happening :)
> > 
> > My understanding is the same as Trond's--the reason it's not happening
> > is because nobody is making an effort to merge it.  What am I missing?
> > 
> 
> Tonian is working on this and we've allocated resources also to help
> out on your nfs4.1 todo list.

Great, thanks; let me know how I can help.

--b.
