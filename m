Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:38128 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755823Ab0JVRph convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Oct 2010 13:45:37 -0400
Subject: Re: [PATCH] xs_bind retry binding forever
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Ben Myers <bpm@sgi.com>, linux-nfs@vger.kernel.org
In-Reply-To: <48B51F5A-E060-4B0B-8AD6-1E4247C4289F@oracle.com>
References: <20101021183203.12776.28469.stgit@lady3jane.americas.sgi.com>
	 <20101021183337.12776.18768.stgit@lady3jane.americas.sgi.com>
	 <1287689917.9144.84.camel@heimdal.trondhjem.org>
	 <48B51F5A-E060-4B0B-8AD6-1E4247C4289F@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 22 Oct 2010 13:45:36 -0400
Message-ID: <1287769536.6311.9.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2010-10-22 at 11:56 -0400, Chuck Lever wrote:
> On Oct 21, 2010, at 3:38 PM, Trond Myklebust wrote:
> 
> > On Thu, 2010-10-21 at 13:33 -0500, Ben Myers wrote:
> >> Retry bind for reserved source ports forever.  Add an error message when we
> >> have a hard time binding one.
> > 
> > NACK. This approach leads to the process spinning forever in that loop,
> > which is exactly why we introduced the limit in the first place. See all
> > the old archived bug report emails about 'rpciod taking 100% cpu'.
> 
> The root problem seems to be the hard loop.  Thinking out loud, what if the client's FSM or some other higher up layer performed the retry, with a short delay inserted after each attempt?

The problem isn't only the hard loop. The reason why we return the
EADDRINUSE is in order to allow quick failure of mounts and/or
automounts when we can't bind the socket.

I suggest 2 changes:

     1. In case of error, pass the return value from xs_bind to the
        pending tasks
     2. Add a handler for EADDRINUSE in call_status(),
        xprt_connect_status() and call_connect_status(). Make sure that
        call_status() and call_connect_status() fail for SOFTCONN tasks,
        and that they print an error message, delay and retry in the
        case of ordinary hard tasks.

Cheers
  Trond
