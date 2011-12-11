Return-Path: linux-nfs-owner@vger.kernel.org
Received: from frankvm.xs4all.nl ([83.163.148.79]:60892 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751492Ab1LKSKp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Dec 2011 13:10:45 -0500
Date: Sun, 11 Dec 2011 19:10:42 +0100
From: Frank van Maarseveen <frankvm@frankvm.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: 3.1.4: NFSv3 RPC scheduling issue?
Message-ID: <20111211181042.GA13425@janus>
References: <20111205165021.GA24165@janus>
 <1323128376.7237.7.camel@lade.trondhjem.org>
 <20111206081115.GA3570@janus>
 <1323201463.3199.18.camel@lade.trondhjem.org>
 <20111207134359.GA29828@janus>
 <1323486601.32695.2.camel@lade.trondhjem.org>
 <20111211124008.GA10460@janus>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111211124008.GA10460@janus>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Dec 11, 2011 at 01:40:08PM +0100, Frank van Maarseveen wrote:
> On Fri, Dec 09, 2011 at 10:10:01PM -0500, Trond Myklebust wrote:
> > [...]
> > I'm still mystified as to what is going on here...
> > 
> > Would it be possible to upgrade some of your clients to 3.1.5 (which
> > contains a fix for a sunrpc socket buffer problem) and then to add the
> > following patch?
> 
> Did so, the mount locked up and still is, ready for some more
> experimentation. I don't see any difference however. Did a
> echo 0 >/proc/sys/sunrpc/rpc_debug afterwards (see below).
> 
> A recipe which seems to trigger the issue (at least occasionally) is
> 
> 	cd /mount-point
> 	ssh server echo 3 \>/proc/sys/vm/drop_caches
> 	echo 3 >/proc/sys/vm/drop_caches
> 	for i in `seq 100`
> 	do
> 		du >/dev/null 2>&1 &
> 	done
> 
> I'll try it on a pristine kernel to rule out some kernel patches (unlikely to
> be the cause or trigger but just to be sure).

Tried, same result: my own NFS client patches seem not to make any
difference, as I expected. The ICMP port unreachable (see my other mail)
go away when I stop ypbind and they are triggered by "ypwhich" commands
too so I consider them no longer relevant.

Not much output this time after "echo 0 >/proc/sys/sunrpc/rpc_debug". I
tried twice:

-pid- flgs status -client- --rqstp- -timeout ---ops--
16020 0080    -11 f4778230 f325d0a0        0 c191b4ac nfsv3 GETATTR a:call_status q:xprt_sending
16038 0080    -11 f4778230   (null)        0 c191b4ac nfsv3 GETATTR a:call_reserveresult q:none
16041 0080    -11 f4778230   (null)        0 c191b4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
16045 0080    -11 f4778230   (null)        0 c191b4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
16048 0080    -11 f4778230   (null)        0 c191b4ac nfsv3 READDIRPLUS a:call_reserveresult q:xprt_sending
16060 0080    -11 f4778230   (null)        0 c191b4ac nfsv3 ACCESS a:call_reserveresult q:xprt_sending
16062 0080    -11 f4778230   (null)        0 c191b4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
16069 0080    -11 f4778230   (null)        0 c191b4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
-pid- flgs status -client- --rqstp- -timeout ---ops--
16020 0080    -11 f4778230 f325d0a0        0 c191b4ac nfsv3 GETATTR a:call_status q:xprt_sending
16038 0080    -11 f4778230   (null)        0 c191b4ac nfsv3 GETATTR a:call_reserveresult q:none
16041 0080    -11 f4778230   (null)        0 c191b4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
16045 0080    -11 f4778230   (null)        0 c191b4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
16048 0080    -11 f4778230   (null)        0 c191b4ac nfsv3 READDIRPLUS a:call_reserveresult q:xprt_sending
16060 0080    -11 f4778230   (null)        0 c191b4ac nfsv3 ACCESS a:call_reserveresult q:xprt_sending
16062 0080    -11 f4778230   (null)        0 c191b4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending
16069 0080    -11 f4778230   (null)        0 c191b4ac nfsv3 GETATTR a:call_reserveresult q:xprt_sending


The NFS client mounts from a machine holding many virtual NFS servers
using an separate IP address for every export. When access on the client
hangs then the same export is still mountable on this NFS client using
a different server IP address (one NIC at both sides btw.). The dead
virtual server IP address seems only dead for NFS RPC and only from the
client in question: there is no traffic going out. Ping, rpcinfo et al
just work. Mount on the client in trouble using the dead IP address but
specifying a different virtual server export produces some traffic and
then gets stuck too, I guess at the point when kernel needs to do NFS RPC.

So, kernel NFS RPC from client drops dead for a specific server IP address.

-- 
Frank
