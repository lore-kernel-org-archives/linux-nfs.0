Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42065 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751256Ab1J2SsD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 29 Oct 2011 14:48:03 -0400
Date: Sat, 29 Oct 2011 14:47:59 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: David Flynn <davidf@rd.bbc.co.uk>, linux-nfs@vger.kernel.org,
        Chuck Lever <chuck.lever@oracle.com>
Subject: Re: NFS4ERR_STALE_CLIENTID loop
Message-ID: <20111029184759.GG12122@fieldses.org>
References: <1319455367.8505.3.camel@lade.trondhjem.org>
 <20111024131734.GE32587@rd.bbc.co.uk>
 <1319463165.2734.1.camel@lade.trondhjem.org>
 <20111024145027.GF32587@rd.bbc.co.uk>
 <1319470302.2734.4.camel@lade.trondhjem.org>
 <20111027221742.GI32587@rd.bbc.co.uk>
 <20111029002500.GA2011@rd.bbc.co.uk>
 <1319909376.2760.11.camel@lade.trondhjem.org>
 <20111029181509.GE12122@fieldses.org>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430BDE7474@SACMVEXC2-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430BDE7474@SACMVEXC2-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Oct 29, 2011 at 11:21:13AM -0700, Myklebust, Trond wrote:
> > From: J. Bruce Fields [mailto:bfields@fieldses.org]
> > On Sat, Oct 29, 2011 at 07:29:36PM +0200, Trond Myklebust wrote:
> > > OK. This is the first time I've seen this tcpdump.
> > >
> > > The problem seems like a split-brain issue on the server... On the
> one
> > > hand, it is happily telling us that our lease is OK when we RENEW.
> > > Then when we try to use said lease in an OPEN, it is replying with
> > > STALE_CLIENTID.
> > >
> > > IOW: This isn't a problem I can fix on the client whether or not I
> add
> > > exponential backoff. The problem needs to be addressed on the server
> > > by the Solaris folks....
> > 
> > Is there any simple thing we could do on the client to reduce the
> impact of
> > these sorts of loops?
> 
> WHY? Those loops aren't supposed to happen if the server works according
> to spec.

Yes, and it's not something I care that strongly about, really, my only
observation is that this sort of failure (an implementation bug on one
side or another resulting in a loop) seems to have been common (based on
no hard data, just my vague memories of list threads), and the results
fairly obnoxious (possibly even for unrelated hosts on the network).
So if there's some simple way to fail more gracefully it might be
helpful.

--b.
