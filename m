Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59046 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756424Ab0HCXRr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Aug 2010 19:17:47 -0400
Date: Tue, 3 Aug 2010 19:16:25 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Michael Guntsche <mike@it-loops.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Kerberos auth Problem with nfs3/4
Message-ID: <20100803231625.GD9752@fieldses.org>
References: <20100803154556.GA6262@gibson.comsick.at>
 <20100803194342.GE31579@fieldses.org>
 <20100803211906.GA24236@gibson.comsick.at>
 <20100803213650.GJ31579@fieldses.org>
 <20100803215523.GA25413@gibson.comsick.at>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100803215523.GA25413@gibson.comsick.at>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Aug 03, 2010 at 11:55:24PM +0200, Michael Guntsche wrote:
> On 03 Aug 10 17:36, J. Bruce Fields wrote:
> > > Aug  3 23:12:23 gibson kernel: RPC: AUTH_GSS upcall timed out.
> > > Aug  3 23:12:23 gibson kernel: Please check user daemon is running.
> > > 
> > > Of course all the daemons on the server are running and the system seems
> > > to work fine otherwise.
> > 
> > That's actually a client-side complaint--if you're seeing it on the
> > server then it's probably the server trying to do a callback to an NFSv4
> > client.  Are you running rpc.gssd as well as rpc.svcgssd on the server?
> > Might want to if you want delegations to work (but it's not a critical
> > problem).
> Yes, rpc.gssd as well as rpc.svcgssd is running on the server. To make
> matters worse I noticed something else with sec=krb5. This messages
> appears on first access to a file either read or write. Not always, it
> seems that it reappears after some timeout but it is sparmming my logs
> nevertheless. But what's worse is that I now got a Stale NFS file handle
> on the lost+found directory of the export. A lot of question marks and
> then just the name. I am now running with sec=sys and cannot up to now
> was not able to reproduce this problem. Is it possible that does two
> problems are related or are they completely separate from each other?

I doubt they're related.

Is there something special about the lost+found directory that would
lead to stale filehandles?  I can't think why there would be.

--b.

> FYI the patched nfs-utils version is only running on the server for now
> but I do not think that this is the problem.
