Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:60737 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932211Ab0KSXR3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Nov 2010 18:17:29 -0500
Subject: Re: NFS client/sunrpc getting stuck on 2.6.36
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Simon Kirby <sim@hostway.ca>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20101119225803.GC3270@hostway.ca>
References: <20101111023520.GH16939@hostway.ca>
	 <1289452967.4062.10.camel@heimdal.trondhjem.org>
	 <20101119202004.GA3270@hostway.ca>
	 <1290201888.3135.61.camel@heimdal.trondhjem.org>
	 <20101119220356.GB3270@hostway.ca>
	 <1290205039.3135.74.camel@heimdal.trondhjem.org>
	 <20101119225803.GC3270@hostway.ca>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 19 Nov 2010 18:17:25 -0500
Message-ID: <1290208645.3135.88.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2010-11-19 at 14:58 -0800, Simon Kirby wrote:
> On Fri, Nov 19, 2010 at 05:17:19PM -0500, Trond Myklebust wrote:
> > So what were all the 
> > 
> > 'lockd: server 10.10.52.xxx not responding, still trying'
> > 
> > messages all about? There were quite a few of them for a number of
> > different servers in the moments leading up to the hang. Could it be a
> > problem with the switch these clients are attached to?
> 
> If it were a switch problem, would we see port 2049 socket backlogs with
> netstat -tan or ss -tan?  I haven't seen this at all when the problem
> occurs.  All of the sockets are idle (and usually it seems to close them
> all except the one server that all of the slots are stuck on).  tcpdump
> shows no problems, just very slow requests rates that match the rpc/nfs
> debugging.

No retransmits that might indicate dropped packets at the switch? How
fast are the tcp ACKs from the server being returned?

> If the rpc slots are stuck full, would that cause lockd to print those
> timeouts?

Yes. That would be the only kind of event that would trigger these
messages.

> Actually, another one just got stuck right now:
> 
> [root@lsh1003:/root]# dmesg|tail
> lockd: server 10.10.52.227 not responding, still trying
> lockd: server 10.10.52.155 not responding, still trying
> lockd: server 10.10.52.163 not responding, still trying
> lockd: server 10.10.52.155 not responding, still trying
> lockd: server 10.10.52.150 not responding, still trying
> lockd: server 10.10.52.151 not responding, still trying
> lockd: server 10.10.52.162 not responding, still trying
> lockd: server 10.10.52.155 not responding, still trying
> lockd: server 10.10.52.163 not responding, still trying
> lockd: server 10.10.52.155 not responding, still trying
> [root@lsh1003:/root]# netstat -tano | grep 2049

lockd requests don't get sent to port 2049. They go to whatever port the
server is advertising using the RPC portmapper.

rpcinfo -p <servername> | grep nlockmgr

should tell you on which tcp and udp ports lockd is listening. Then you
can try probing for service using

rpcinfo -t <servername> nlockmgr
rpcinfo -u <servername> nlockmgr

Trond

