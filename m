From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: [PATCH] xprt sharing (was Re: xprt_bindresvport)
Date: Wed, 8 Dec 2004 11:08:18 -0800
Message-ID: <482A3FA0050D21419C269D13989C61130435EC70@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "Olaf Kirch" <okir@suse.de>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cc7At-0005tu-3g
	for nfs@lists.sourceforge.net; Wed, 08 Dec 2004 11:08:31 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Cc7Ao-0000df-Gr
	for nfs@lists.sourceforge.net; Wed, 08 Dec 2004 11:08:27 -0800
To: "Mike Waychison" <Michael.Waychison@Sun.COM>
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

> > but also notice this cuts the usable port range in half=20
> (from ~800 to
> > ~420).  we need some form of mitigation to ensure we aren't=20
> limiting the
> > number of NFS mounts a client can have.
>=20
> This has been bugging me for a while.  The fact that we are limitting
> ourselves to a single nfs mount per port.  From what I can=20
> tell, Solaris
> shares the transports between nfs mounts from the same server=20
> and saves
> themselves a lot of trouble with running out of port numbers=20
> in doing so.
>=20
> The attached patch does the same for Linux against 2.6.9.  We share
> xprts from existing connections, effectively removing any limit on the
> number of nfs mounts we have in the system.
>=20
> The only thing to worry about now is any talking to the portmapper or
> mountd from userspace using tcp, which will put the reserved ports in
> TIME_WAIT state.  This can limit the 'speed' at which we=20
> mount many mounts.

we're looking at a similar solution.  we want to make sure we don't
limit the scalability of everyone's mount point by making them all
funnel through a single slot table.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
