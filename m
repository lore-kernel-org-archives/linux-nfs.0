From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: xprt_bindresvport
Date: Wed, 8 Dec 2004 06:33:15 -0800
Message-ID: <482A3FA0050D21419C269D13989C61130435EC6F@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cc2sf-00034m-74
	for nfs@lists.sourceforge.net; Wed, 08 Dec 2004 06:33:25 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Cc2se-0000rU-2W
	for nfs@lists.sourceforge.net; Wed, 08 Dec 2004 06:33:24 -0800
To: "Olaf Kirch" <okir@suse.de>
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

> the current xprt_bindresvport implementation will search for=20
> a privileged
> port by counting down from 800 to 0. I think this is a bug, because it
> will potentially interfere with services trying to bind to=20
> low ports as
> well.

is this idle speculation, or do you actually have a test case that
fails?  :^)

> The bindresvport implementation in glibc picks from the 600-1023
> range.

we should review what other RPC implementations do (namely the reference
implementation, Solaris).

but also notice this cuts the usable port range in half (from ~800 to
~420).  we need some form of mitigation to ensure we aren't limiting the
number of NFS mounts a client can have.

> I also think it would be good to start at a "random" port. Otherwise,
> when you reboot, the server may still have a TCB for the old=20
> connection
> and send you an ACK probe when you try to connect (if all=20
> goes well), and
> the client's TCP stack will RST and fail the connect. If things go
> not-so-well you have a packet filter somewhere inbetween that eats the
> ACK probe because its connection tracking engine thinks the connection
> is in half-open and shouldn't see any SYN-less ACKs yet.

i don't agree.  you're just making the bad behavior more rare by
choosing ports at random; you are not actually addressing the root
problem you describe.  is it possible to fix the RPC client to retry the
connection in this case?  and/or fix the server to recognize and remove
the context for the old connection?

introducing randomness here will make reproducing problems in this area
very difficult.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
