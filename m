From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: [PATCH] Fix xprt_bindresvport range
Date: Mon, 28 Feb 2005 08:41:56 -0800
Message-ID: <482A3FA0050D21419C269D13989C6113085397DA@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "Ian Kent" <raven@themaw.net>,
	"Charles Lever" <cel@citi.umich.edu>, <nfs@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D5nyE-00024W-IP
	for nfs@lists.sourceforge.net; Mon, 28 Feb 2005 08:42:10 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D5nyE-0004k3-6T
	for nfs@lists.sourceforge.net; Mon, 28 Feb 2005 08:42:10 -0800
To: "Olaf Kirch" <okir@suse.de>,
	"Trond Myklebust" <trond.myklebust@fys.uio.no>
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

hi olaf-

> I understand the theoretical reasons, but I wonder about the=20
> practical value. Any problem that causes retransmits over TCP=20
> is non-transient, otherwise TCP retransmit would simply fix=20
> it for us (question - there doesn't seem to be any code in=20
> sunrpc that breaks the connection after a timeout, major or=20
> minor: I think we want that)

this is actually required for NFSv4.

the new RPC client transport switch patches implement this feature.
after a major timeout, the FSM invokes a transport switch callout.  for
TCP sockets, this callout will invoke xprt_disconnect.  we may want to
go farther and actually close the socket at that point instead of just
marking it as a zombie, just to speed the reconnect process along.

Sun's RPC/TCP implementation allows two retransmits over a TCP transport
before closing it.  by setting retrans=3D2 and timeo=3D600, and =
including
this "disconnect on timeout" feature, we model the reference
implementation's behavior.

> To make matters worse, the Linux client is fairly=20
> conservative on TCP reconnects.  TCP connects will time out=20
> after 60 seconds, and if the first reconnect fails, we'll=20
> delay future reconnects by another 15 seconds.
> In general I believe this is A Good Thing, but this timing=20
> pattern will make sure there's not a shred of valid data left=20
> in your retransmit cache by the time the connection comes back...

the new RPC client transport switch patches also implement an
exponential backoff when retrying to connect a TCP transport socket,
replacing the current fixed 15 second timeout.  it starts (currently) at
3 seconds and caps at 60 seconds.

by adding in features such as SO_REUSEADDR and limiting the linger
timeout on TCP connections, it's more reasonable to expect that the DRC
will be effective during a TCP timeout.

> And this is not theoretical; I've seen this happen in our R&D network.
> The client/nfsd thread ratio was too high, so that nfsd=20
> started to drop connections frequently.  That caused=20
> interesting failures with silly renames that were real fun to debug :)

with NFSv4.1 sessions, the DRC size is capped.  by using a sequence
number, sessions allow the server to retire cache entries sanely after
an RPC is completed on the client, so this problem gets a lot easier.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
