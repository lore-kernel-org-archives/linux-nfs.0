Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:9943 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932323Ab1J2SVP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 29 Oct 2011 14:21:15 -0400
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: NFS4ERR_STALE_CLIENTID loop
Date: Sat, 29 Oct 2011 11:21:13 -0700
Message-ID: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430BDE7474@SACMVEXC2-PRD.hq.netapp.com>
In-Reply-To: <20111029181509.GE12122@fieldses.org>
References: <20111024104042.GD32587@rd.bbc.co.uk> <1319455367.8505.3.camel@lade.trondhjem.org> <20111024131734.GE32587@rd.bbc.co.uk> <1319463165.2734.1.camel@lade.trondhjem.org> <20111024145027.GF32587@rd.bbc.co.uk> <1319470302.2734.4.camel@lade.trondhjem.org> <20111027221742.GI32587@rd.bbc.co.uk> <20111029002500.GA2011@rd.bbc.co.uk> <1319909376.2760.11.camel@lade.trondhjem.org> <20111029181509.GE12122@fieldses.org>
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "David Flynn" <davidf@rd.bbc.co.uk>, <linux-nfs@vger.kernel.org>,
        "Chuck Lever" <chuck.lever@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: J. Bruce Fields [mailto:bfields@fieldses.org]
> Sent: Saturday, October 29, 2011 8:15 PM
> To: Myklebust, Trond
> Cc: David Flynn; linux-nfs@vger.kernel.org; Chuck Lever
> Subject: Re: NFS4ERR_STALE_CLIENTID loop
> 
> On Sat, Oct 29, 2011 at 07:29:36PM +0200, Trond Myklebust wrote:
> > OK. This is the first time I've seen this tcpdump.
> >
> > The problem seems like a split-brain issue on the server... On the
one
> > hand, it is happily telling us that our lease is OK when we RENEW.
> > Then when we try to use said lease in an OPEN, it is replying with
> > STALE_CLIENTID.
> >
> > IOW: This isn't a problem I can fix on the client whether or not I
add
> > exponential backoff. The problem needs to be addressed on the server
> > by the Solaris folks....
> 
> Is there any simple thing we could do on the client to reduce the
impact of
> these sorts of loops?

WHY? Those loops aren't supposed to happen if the server works according
to spec.

> Given that we know there are bad servers out there it might be nice to
do if
> it's not complicated.

Again WHY? We can't fix a broken server by backing off correctly formed
requests. If a server wants us to back off, it will send us
NFS4ERR_DELAY.

> (Though as a server implementer my purely selfish impulse is to leave
things
> as they are since it ensures I'll get bug reports if I screw
> up....)

You would have gotten the same bugreport. That said, I refuse to change
the client to accommodate buggy servers. The solution to the problem of
buggy servers is to fix those servers.

Trond

