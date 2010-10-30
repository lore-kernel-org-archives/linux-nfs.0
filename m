Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:12050 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753904Ab0J3WXI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Oct 2010 18:23:08 -0400
Subject: Re: Error: state manager failed on NFSv4 server linux with error
 127
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "Brian J. Murrell" <brian@interlinx.bc.ca>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <1288475215.32627.406.camel@pc>
References: <1287334833.4871.6.camel@pc>
	 <1287340520.5266.70.camel@heimdal.trondhjem.org>
	 <1288460514.32627.105.camel@pc>
	 <1288461151.3238.9.camel@heimdal.trondhjem.org>
	 <1288461562.32627.151.camel@pc>
	 <1288462786.3238.16.camel@heimdal.trondhjem.org>
	 <1288474164.32627.383.camel@pc>
	 <1288474886.8621.3.camel@heimdal.trondhjem.org>
	 <1288475215.32627.406.camel@pc>
Content-Type: text/plain; charset="UTF-8"
Date: Sat, 30 Oct 2010 18:22:07 -0400
Message-ID: <1288477327.8621.5.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, 2010-10-30 at 17:46 -0400, Brian J. Murrell wrote:
> On Sat, 2010-10-30 at 17:41 -0400, Trond Myklebust wrote: 
> > 
> > There are 2 cases which can trigger recovery: server reboot, and network
> > partition (i.e. a networking fault that causes the client to be unable
> > to contact the server in time in order to renew its lease).
> 
> Yes, seems two cases which I would suspect also.
> 
> > If none of the above apply,
> 
> None should be applicable.  Of course I could never know if the network
> "blipped" (but highly doubt even that happened) but there should not
> have been an outtage long enough to prevent a lease renewal.
> 
> > then we need to look at whether it is the
> > client or the server that is screwed up.
> 
> Yes, fair enough.  I suppose having more than 1 client using the same
> server could be sufficient to determine fault at the client or server?
> Or is there a more direct route?

How about something like the following patch? It should allow you to log
only the errors that lead to a state recovery situation.

Cheers
  Trond

------------------------------------------------------------------------------
