From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH] xprt sharing (was Re: xprt_bindresvport)
Date: Thu, 9 Dec 2004 12:22:33 +0100
Message-ID: <20041209112233.GC15055@suse.de>
References: <482A3FA0050D21419C269D13989C61130435EC70@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mike Waychison <Michael.Waychison@Sun.COM>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CcMNZ-0004aL-BH
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 03:22:37 -0800
Received: from mail-ex.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CcMNY-0007oK-C5
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 03:22:37 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C61130435EC70@lavender-fe.eng.netapp.com>
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

On Wed, Dec 08, 2004 at 11:08:18AM -0800, Lever, Charles wrote:
> we're looking at a similar solution.  we want to make sure we don't
> limit the scalability of everyone's mount point by making them all
> funnel through a single slot table.

I think you will hit all sorts of limits on the way if you do this,
not just the sunrpc locks.  Using a single TCP connection means you
will have to serialize all sendmsg() calls across all clients, because
otherwise you'll mess up the RPC record framing.
You may also run into the max send/recv buffer sizes of a socket.

I cannot see how this can scale very well.

Olaf
-- 
Olaf Kirch     | Things that make Monday morning interesting, #2:
okir@suse.de   |        "We have 8,000 NFS mount points, why do we keep
---------------+ 	 running out of privileged ports?"


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
