From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: [PATCH] Fix xprt_bindresvport range
Date: Wed, 23 Feb 2005 09:05:29 -0800
Message-ID: <482A3FA0050D21419C269D13989C6113085397AB@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D3zxC-0000O5-Kj
	for nfs@lists.sourceforge.net; Wed, 23 Feb 2005 09:05:38 -0800
Received: from mx1.netapp.com ([216.240.18.38])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D3zxB-0002bz-9c
	for nfs@lists.sourceforge.net; Wed, 23 Feb 2005 09:05:38 -0800
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>,
	"Olaf Kirch" <okir@suse.de>
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

> on den 23.02.2005 Klokka 17:28 (+0100) skreiv Olaf Kirch:
> > xprt_bindresvport would grab ports in the range 1-800, which can
> > conflict with all sorts of network services. What we really want
> > to do is select from a range N - 1023.
> >=20
> > The patch below changes xprt_bindresvport to select ports from
> > 650-1023 by default (631 is cups, which we better avoid).

note some mainboard's with built-in ethernet and IPMI implementations
quietly use port 623; incoming UDP traffic on 623 appears to be blocked
to the O/S.  so 650 is a good choice.

> > It also adds sysctls to allow the admin to select a different
> > port range.
>=20
> The patch looks good, and this is definitely a feature we should have.
>=20
> Chuck, how will this fit in with your transport switch work?

it fits fine.  i can add it to my transport switch patchset, or you can
take it now and i will work the transport switch around it.

one problem with sysctls and the transport switch is i'm not sure how to
add new sysctls dynamically when a transport module is loaded.  so far
i've just hacked around it (for the slot table size sysctl).  i'm sure
olaf's is the first of many patches that will add another sysctl
parameter to the RPC client.  any ideas?


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
