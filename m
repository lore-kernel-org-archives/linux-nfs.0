Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40257 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751792Ab2BOPwu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Feb 2012 10:52:50 -0500
Date: Wed, 15 Feb 2012 10:52:47 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Vitaliy Gusev <gusev.vitaliy@nexenta.com>,
        "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs41: Initialize slot->seq_nr at
 nfs4_init_slot_table()
Message-ID: <20120215155247.GB12490@fieldses.org>
References: <1329256108-1535-1-git-send-email-gusev.vitaliy@nexenta.com>
 <1329259606.11759.15.camel@lade.trondhjem.org>
 <4F3AFD84.3020709@nexenta.com>
 <1329266587.28837.4.camel@lade.trondhjem.org>
 <20120215005315.GA9018@fieldses.org>
 <1329270628.28837.15.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1329270628.28837.15.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 15, 2012 at 01:50:28AM +0000, Myklebust, Trond wrote:
> On Tue, 2012-02-14 at 19:53 -0500, J. Bruce Fields wrote:
> > On Wed, Feb 15, 2012 at 12:43:08AM +0000, Myklebust, Trond wrote:
> > > Then we have a problem. The zero initialisation is already in use out
> > > there in both commercial and non-commercial versions of Linux. It is too
> > > late to change that now.
> > > 
> > > Furthermore, since none of the servers we've tested against in earlier
> > > Bakeathons and Connectathons have complained, I suggest that we rather
> > > change the spec with an errata.
> > 
> > Argh.
> > 
> > I just noticed that the server was crashing intermittently and traced it
> > to incorrect handling of the case where the client sends a one-op
> > SEQUENCE compound with seqid 0.  I'm not sure why it started popping up
> > just in 3.3--perhaps some change in the way the client uses slots made
> > that more likely.
> > 
> > The server code actually looks like it did assume initial seqid 1, but
> > accepted initial seqid 0 (except in this one case) basically by mistake.
> > 
> > In any case, I think it should be easy enough to teach it just to accept
> > any seqid on a previously unused slot, so I'll do that....
> 
> Hang on... Looking at 3.2, I think you're correct. We used to initialise
> to 1, and now we're initialising to 0.

OK.  I'll continue with my current fix, in that case, so using initial
sequenceid 0 will result in a MISORDERED error.

--b.
