Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from netnation.com ([204.174.223.2]:43587 "EHLO peace.netnation.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757808Ab0KKItR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Nov 2010 03:49:17 -0500
Date: Thu, 11 Nov 2010 00:49:15 -0800
From: Simon Kirby <sim@hostway.ca>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS client/sunrpc getting stuck on 2.6.36
Message-ID: <20101111084915.GA9782@hostway.ca>
References: <20101111023520.GH16939@hostway.ca> <1289452967.4062.10.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1289452967.4062.10.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Nov 11, 2010 at 01:22:47PM +0800, Trond Myklebust wrote:

> > 900ms matches the probably-silly nfs mount settings we're currently using:
> > 
> > rw,hard,intr,tcp,timeo=9,retrans=3,rsize=8192,wsize=8192
> > 
> > Full kernel log here: http://0x.ca/sim/ref/2.6.36_stuck_nfs/
> 
> timeo=9 is a completely insane retransmit value for a tcp connection.
> Please use the default timeo=600, and all will work correctly.

So this setting is expected to produce an usually-working setup that
occasionally fails? :)

A short history of our experiences:

We first tried to use TCP mounts but found that, in some cases,
reconnection time to NFS servers after an NFS server crash and fail-over
to the backup node would take upwards of 10 minutes, even with timeouts
configured much lower than that.  This was with 2.6.32-era NFS clients. 
Clients with little or no activity to the affected mounts would normally
reconnect immediately, but active clients would usually hit this hanging
issue.  Different client hosts would return to operation all at different
times (some took 5 minutes, some took 10 minutes, for example).  I was
not able to reproduce this outside of production or I would have reported
it with steps to reproduce.

So, UDP worked around this issue for us, where I think this timeo value
is reasonable.  In seeing these stuck NFS stuck issues, we replaced "udp"
with "tcp" without changing anything else to see if the problem stopped,
but we seem to be getting the same result.

We'll try with the default timeo and see if the problem recurs.  Perhaps
the TCP reconnection times have improved or maybe there are other options
we can set to improve that case.

Simon-
