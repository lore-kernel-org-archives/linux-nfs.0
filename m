From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: [autofs] [PATCH/RFC 0/2] Userspace RPC proxying
Date: Tue, 8 Mar 2005 07:04:52 -0800
Message-ID: <482A3FA0050D21419C269D13989C611307CF4C10@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "linux-nfs" <nfs@lists.sourceforge.net>,
	"autofs mailing list" <autofs@linux.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8gGc-0002de-6J
	for nfs@lists.sourceforge.net; Tue, 08 Mar 2005 07:05:02 -0800
Received: from mx1.netapp.com ([216.240.18.38])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D8gGZ-0002kX-Ps
	for nfs@lists.sourceforge.net; Tue, 08 Mar 2005 07:05:02 -0800
To: <mike@waychison.com>
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

hi mike-

> Every once in a while, we see complaints that nfs mounts are=20
> failing due
> to there being no more reserved ports available for outbound rpc
> communication.  This often happens when using TCP transports,=20
> because all
> outbound connections that are closed go into a TIME_WAIT state.

i know that steved has also been looking at this problem.  he found that
user-land uses TCP connections with abandon and has put it on a diet.
and, the client side should take care to avoid using reserved ports
unless it is absolutely necessary.

> For various reasons, avoiding the TIME_WAIT state using connect(fd,
> {AF_UNSPEC}, ...) or doing SO_REUSEADDR may not be the safest way to
> handle things.

i have a patch for the kernel RPC client to use AF_UNSPEC to reuse the
port number on connections.  before i head into the wilderness, what's
unsafe about that?

> rpcproxyd will create outbound connections and multiplex the=20
> transports
> with any number of simultaneous clients.  There is no support for
> re-binding your transport once created.  It will also cache outbound
> server connections for 30 seconds after last use, which=20
> greatly helps keep the number of ports used down in a mount-storm
situation.

the typical RPC client-side connection timeout is 5 minutes.  any reason
not to use that value instead of 30 seconds?

you will also need a unique connection for each program/version number
combination to a given server; ie you can't share a single socket among
different program/version numbers (even though some implementations try
to do this, it is a bad practice, in my opinion).

to support IPv6 you will need support for rpcbind versions 3 and 4; but
that may be an issue outside of rpcproxyd.

> rpcproxyd is written as a single-threaded/no-signals/select-based
daemon.

will using select be a scalability issue?  you might be better off with
something like libevent or using epoll.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
