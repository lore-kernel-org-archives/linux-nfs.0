Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60012 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754979Ab2HOPCw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Aug 2012 11:02:52 -0400
Date: Wed, 15 Aug 2012 11:02:51 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: v3.5 nfsd4 regression; utime sometimes takes 40+ seconds to
 return
Message-ID: <20120815150251.GB16057@fieldses.org>
References: <20120815061115.GC32347@cucamonga.audible.transient.net>
 <20120815135854.GI32347@cucamonga.audible.transient.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120815135854.GI32347@cucamonga.audible.transient.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 15, 2012 at 01:58:54PM +0000, Jamie Heilman wrote:
> Jamie Heilman wrote:
> > I'll try to get full rcpdebug traces on client and server as the delay
> > is occuring in the hopes that helps pin things down, and post them
> > separately.
> 
> OK, here are the logs from client and server, where a run of my test program
> under strace -T resulted in:
> 
> utime("utime-test.c", [2012/08/15-13:35:20, 2012/08/15-13:22:04]) = 0 <0.150815>
> open("utime-test.c", O_RDONLY)          = 3 <0.242635>
> close(3)                                = 0 <0.147768>
> stat("utime-test.c", {st_mode=S_IFREG|0644, st_size=696, ...}) = 0 <0.002772>
> utime("utime-test.c", [2012/08/15-13:35:20, 2012/08/15-13:22:04]) = 0 <71.878058>
> 
> The client is a 64-bit v3.4.8 kernel, the server is 32-bit, v3.5.1 +
> the two sunprc patches that will be in v3.5.2.
> 
> (The client's system clock is a touch faster than the server's, but
> these logs start at the same instant.)

Thanks for all the details.

What's probably happening is that the client is returning a delegation
with the open.  The setattr then breaks that delegation; you can see it
getting 10008 (NFS4ERR_DELAY) replies while the server waits for the
delegation to be returned.  But for some reason the callback to break
the delegation isn't working.  ("NFSD: warning: no callback path to
client 192.168.2.42/192.168.2.4 tcp UNIX 0: error -110" (110 is
ETIMEDOUT).)  So instead you wait for the delegation to time out and get
forcibly revoked.

The reproducer might be more reliable if you did two opens.

It'd be worth looking at the traffic in wireshark.  You should see
setattr, open, close, setattr, a DELAY reply to the setattr, a
CB_RECALL, and then a DELEGRETURN that gets a succesful reply.  But for
some reason the DELEGRETURN isn't getting through in your case, I'm not
sure why.  I can't reproduce that.  You'll need to start wireshark
before you mount to make sure it knows how to parse the callbacks.

I don't see anything in that range of git commits that looks suspicious,
but I may well have overlooked something.

--b.
