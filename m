From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] xprt sharing (was Re: xprt_bindresvport)
Date: Thu, 09 Dec 2004 08:33:32 -0500
Message-ID: <1102599212.24133.30.camel@lade.trondhjem.org>
References: <482A3FA0050D21419C269D13989C61130435EC70@lavender-fe.eng.netapp.com>
	 <20041209112233.GC15055@suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Charles Lever <Charles.Lever@netapp.com>, Mike Waychison <Michael.Waychison@sun.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CcOQx-0005Ra-Jb
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 05:34:15 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CcOQt-0005q3-Pd
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 05:34:13 -0800
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20041209112233.GC15055@suse.de>
Sender: nfs-admin@lists.sourceforge.net
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

to den 09.12.2004 Klokka 12:22 (+0100) skreiv Olaf Kirch:

> I think you will hit all sorts of limits on the way if you do this,
> not just the sunrpc locks.  Using a single TCP connection means you
> will have to serialize all sendmsg() calls across all clients, because
> otherwise you'll mess up the RPC record framing.
> You may also run into the max send/recv buffer sizes of a socket.
> 
> I cannot see how this can scale very well.

As long as it scales better than 1 privileged port per mountpoint. ;-)

Seriously, though: we *already* have this serialization problem with the
single client per transport case, and so there is nothing that needs to
added to the locking in order to deal with multiple clients per
transport. IOW contention today is at the per-request level and it would
have to remain so for the shared transport case.

Note also that we could also create pools of several transport sockets
per server: the current locking scheme allows for that too. That would
improve per-request scalability at the same time as it allows us to
limit the privileged port usage. There be a couple of small dragons
there (unless you are running on NFSv4.1 w/ sessions, you cannot replay
a request on a different port for instance) but such a scheme does not
have to be too sophisticated to be useful.

Cheers,
  Trond

-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
