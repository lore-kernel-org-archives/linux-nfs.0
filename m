From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.6.5-rc3 xprt_connect changes?
Date: Thu, 01 Apr 2004 15:57:07 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1080853027.2682.22.camel@lade.trondhjem.org>
References: <20040401144740.GH20772@suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B99FV-0004In-In
	for nfs@lists.sourceforge.net; Thu, 01 Apr 2004 12:57:17 -0800
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1B99FT-000142-Tx
	for nfs@lists.sourceforge.net; Thu, 01 Apr 2004 12:57:16 -0800
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040401144740.GH20772@suse.de>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Thu, 2004-04-01 at 09:47, Olaf Kirch wrote:
> Hi,
> 
> I have a problem with the xprt_connect changes introduced
> in 2.6.5-rc1. They break pmap_register, it always returns
> with EIO now.
> 
> It seems the problem is this:
> 
>  -	xprt_connect puts the task on the pending queue
>  -	xprt_socket_connect calls xprt_close, which in turn
>  	calls xprt_disconnect, which wakes up all tasks on
> 	the pending list with ENOTCONN
> 
> For transports with "soft" semantics (this includes the portmap client),
> this will always cause it to fail with EIO.
> 
> For "hard" transports, it seems that after some delay (set in
> xprt_connect_status) we come back to call_connect_status, which
> notices the ENOTCONN status. It sets the function pointer to
> call_connect. If xprt_connected() evaluates to true when we get
> there (which is always the case for UDP, and which is true for
> TCP igf the SYNACK has arrived in the meanwhile), the call to
> xprt_connect() succeeds, and we can continue.
> 
> The attached, untested patch should hopefully fix this. I still need
> to test this.

How about if we simply move the call for xprt_disconnect() out of
xprt_close()?

I fully agree that xprt_connect() doesn't actually need to tell the
world that the socket has disconnected: we should already have an RPC
task that is taking responsibility for monitoring the reconnection of
the socket. 

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
