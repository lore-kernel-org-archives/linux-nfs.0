Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33338 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753198Ab1LALsS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Dec 2011 06:48:18 -0500
Date: Thu, 1 Dec 2011 06:48:12 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Benny Halevy <bhalevy@tonian.com>
Cc: Marc Eshel <eshel@almaden.ibm.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Peng Tao <bergwolf@gmail.com>, Boaz Harrosh <bharrosh@panasas.com>,
        Garth Gibson <garth@panasas.com>, Fred Isaman <iisaman@netapp.com>,
        linux-nfs@vger.kernel.org, Matt Benjamin <matt@linuxbox.com>
Subject: Re: [PATCH 0/4] nfs41: allow layoutget at pnfs_do_multiple_writes
Message-ID: <20111201114812.GB4506@fieldses.org>
References: <4ED563AC.5040501@panasas.com>
 <1322609431.11286.56.camel@lade.trondhjem.org>
 <OFF7649CC5.E17B103B-ON88257957.0081DB7B-88257957.0082E12A@us.ibm.com>
 <1322611689.11286.72.camel@lade.trondhjem.org>
 <OF5755ED9D.CC1FAA6E-ON88257958.00014359-88257958.0001D4D0@us.ibm.com>
 <1322613425.11286.86.camel@lade.trondhjem.org>
 <OFCC6E3358.498C4568-ON88257958.00043206-88257958.0004D550@us.ibm.com>
 <20111130194410.GB32028@fieldses.org>
 <4ED74D19.7060302@tonian.com>
 <20111201111457.GA4506@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111201111457.GA4506@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 01, 2011 at 06:14:57AM -0500, J. Bruce Fields wrote:
> On Thu, Dec 01, 2011 at 11:47:05AM +0200, Benny Halevy wrote:
> > On 2011-11-30 21:44, J. Bruce Fields wrote:
> > > My understanding is the same as Trond's--the reason it's not happening
> > > is because nobody is making an effort to merge it.  What am I missing?
> > > 
> > 
> > Tonian is working on this and we've allocated resources also to help
> > out on your nfs4.1 todo list.
> 
> Great, thanks; let me know how I can help.

(And, apologies, I shouldn't have said *nobody*: Mi Jinlong has been
doing some good work for a while now.  I also appreciate that you've
managed to squeeze in some time for testing and the occasional patch.
And thanks to Lior for the help triaging pynfs issues--I do hope to get
back to that soon.  But this code still isn't getting the love it
needs....)

--b.
