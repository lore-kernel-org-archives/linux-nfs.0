From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH] Fix xprt_bindresvport range
Date: Mon, 28 Feb 2005 17:57:53 +0100
Message-ID: <20050228165753.GB27975@suse.de>
References: <482A3FA0050D21419C269D13989C6113085397DA@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Ian Kent <raven@themaw.net>, Charles Lever <cel@citi.umich.edu>,
	nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D5oDV-0002gk-PN
	for nfs@lists.sourceforge.net; Mon, 28 Feb 2005 08:57:57 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1D5oDV-0003yi-2s
	for nfs@lists.sourceforge.net; Mon, 28 Feb 2005 08:57:57 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C6113085397DA@lavender-fe.eng.netapp.com>
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

Hi Chuck,

> the new RPC client transport switch patches implement this feature.
> after a major timeout, the FSM invokes a transport switch callout.  for
> TCP sockets, this callout will invoke xprt_disconnect.  we may want to
> go farther and actually close the socket at that point instead of just
> marking it as a zombie, just to speed the reconnect process along.

Good to hear!

> by adding in features such as SO_REUSEADDR and limiting the linger
> timeout on TCP connections, it's more reasonable to expect that the DRC
> will be effective during a TCP timeout.

I'm not a friend of SO_REUSEADDR, at least on the client side. Using
reuseaddr on the client doesn't make any sense. If you use it, your bind()
will succeed, but then your connect() call may fail because there already
is a connection to the same destination with the same source port.
reuseaddr really is just a server side thing, IMO.

> with NFSv4.1 sessions, the DRC size is capped.  by using a sequence
> number, sessions allow the server to retire cache entries sanely after
> an RPC is completed on the client, so this problem gets a lot easier.

We could probably do something similar for NFSv3 if we limit the number of
entries per client to some fixed value (say 4 or 8). Enforcing that limit in a
sane way would require that we no longer hash by XID but by a combination
of client IP and client port. This would put all cache entries of a single
client on the same hash chain, which would allow us to count them as we
search the chain.

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
