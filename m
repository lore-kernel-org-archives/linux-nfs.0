From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: [PATCH] xprt sharing (was Re: xprt_bindresvport)
Date: Thu, 9 Dec 2004 06:03:12 -0800
Message-ID: <482A3FA0050D21419C269D13989C61130435EC79@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "Mike Waychison" <Michael.Waychison@sun.com>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CcOt8-0007i2-0P
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 06:03:22 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CcOt4-0000YE-Kt
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 06:03:21 -0800
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

> But two separate mounts with separate sockets do not=20
> serialize (at least they shouldn't).

there's so much spin locking and BKL activity in both the RPC client and
the NFS client that effectively, there is significant serialization
today.

> > Note also that we could also create pools of several=20
> transport sockets=20
> > per server: the current locking scheme allows for that too.=20
> That would=20
> > improve per-request scalability at the same time as it allows us to=20
> > limit the privileged port usage.
>=20
> Yes, that would help scalability a lot.

that's one direction we would like to take after the transport switch
API is integrated into 2.6.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
