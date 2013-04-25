Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:9215 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756584Ab3DYMTi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Apr 2013 08:19:38 -0400
Subject: Re: [PATCH] NFSv4: Use exponential backoff delay for NFS4_ERRDELAY
From: David Wysochanski <dwysocha@redhat.com>
Reply-To: dwysocha@redhat.com
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Dave Chiluk <chiluk@canonical.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
In-Reply-To: <1366842905.22397.49.camel@leira.trondhjem.org>
References: <1366836949-18465-1-git-send-email-chiluk@canonical.com>
	 <1366838926.22397.25.camel@leira.trondhjem.org>
	 <5178549A.7010402@canonical.com>
	 <1366842905.22397.49.camel@leira.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 25 Apr 2013 08:19:34 -0400
Message-ID: <1366892374.26249.294.camel@localhost.localdomain>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2013-04-24 at 22:35 +0000, Myklebust, Trond wrote:
> On Wed, 2013-04-24 at 16:54 -0500, Dave Chiluk wrote:
> > On 04/24/2013 04:28 PM, Myklebust, Trond wrote:
> > > On Wed, 2013-04-24 at 15:55 -0500, Dave Chiluk wrote:
> > >> Changing the retry to start at NFS4_POLL_RETRY_MIN and exponentially grow
> > >> to NFS4_POLL_RETRY_MAX allow for faster handling of these error conditions.
> > >>
> > >> Additionally this alleviates an interoperability problem with the AIX NFSv4
> > >> Server.  The AIX server frequently (2 out of 3) returns NFS4ERR_DELAY, on a
> > >> close when it happens in close proximity to a RELEASE_LOCKOWNER.  This would
> > >> cause a linux client to hang for 15 seconds.
> > > 
> > > Hi Dave,
> > > 
> > > The AIX server is not being motivated by any requirements in the NFSv4
> > > spec here, so I fail to see the reason why the behaviour that you
> > > describe can justify changing the client. It is not at all obvious to me
> > > that we should be retrying aggressively when NFSv4 servers return
> > > NFS4ERR_DELAY. What makes 1/10sec more correct in these situations than
> > > the exising 15 seconds?
> > 
> > I agree with you that AIX is at fault, and that the preferable situation
> > for the linux client would be for AIX to not return NFS4ERR_DELAY in
> > this use case.  I have attached a simple program that causes exacerbates
> > the problem on the AIX server.  I have already had a conference call
> > with AIX NFS development about this issue, where I vehemently tried to
> > convince them to fix their server.  Unfortunately as I don't have much
> > reputation in the NFS community, I was unable to convince them to do the
> > right thing.  I would be more than happy to set up another call, if
> > someone higher up in the linux NFS hierarchy would be willing to
> > participate.
> 
> I'd think that if they have customers that want to use Linux clients,
> then those customers are likely to have more influence. This is entirely
> a consequence of _their_ design decisions, quite frankly, since
> returning NFS4ERR_DELAY in the above situation is downright silly. The
> server designers _know_ that the RELEASE_LOCKOWNER will finish whatever
> it is doing fairly quickly; it's not as if the CLOSE wouldn't have to do
> the exact same state manipulations anyway...
> 
> > That being said, I think implementing an exponential backoff is an
> > improvement in the client regardless of what AIX is doing.  If a server
> > needs only 2 seconds to process a request for which NFS4ERR_DELAY was
> > returned, this algorithm would get the client back and running after
> > only 2.1 seconds of elapsed time.  Whereas the current dumb algorithm
> > would simply wait 15 seconds.  This is the reason that I implemented
> > this change.
> 
> Right, but my point above is that _in_general_ if we don't know why the
> server is returning NFS4ERR_DELAY, then how can we attach any retry
> numbers at all? HSM systems, for instance, have very different latencies
> than the above and were the reason for inventing NFS3ERR_JUKEBOX in the
> first place.
> 

Agreed we can't know why the server is returning NFS4ERR_DELAY so it's
hard to pick a retry number.  Can you explain the rationale for the
current 15 seconds delay?  Was it just for simplicity or something else?



