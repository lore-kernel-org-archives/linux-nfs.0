From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH] xprt sharing (was Re: xprt_bindresvport)
Date: Thu, 9 Dec 2004 12:14:10 +0100
Message-ID: <20041209111410.GB15055@suse.de>
References: <Pine.LNX.4.44.0412090954400.23728-100000@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CcMFV-0003sl-LN
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 03:14:17 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CcMFU-0002P2-Gr
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 03:14:17 -0800
To: Peter =?iso-8859-1?Q?=C5strand?= <astrand@cendio.se>
In-Reply-To: <Pine.LNX.4.44.0412090954400.23728-100000@maggie.lkpg.cendio.se>
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

On Thu, Dec 09, 2004 at 09:54:58AM +0100, Peter =C5strand wrote:
> > The only thing to worry about now is any talking to the portmapper or
> > mountd from userspace using tcp, which will put the reserved ports in
> > TIME_WAIT state.  This can limit the 'speed' at which we mount many
> > mounts.
>=20
> How about using SO_REUSEADDR?

You cannot use it safely on active (i.e. client) sockets. Consider this

Application A:
	set SO_REUSEADDR
	bind to port 1234
	connect to server foo, port 2049

Application B:
	set SO_REUSEADDR
	bind to port 1234 (succeeds because of REUSEADDR)
	connect to server foo, port 2049: fails with EADDRNOTAVAIL,
		because there already is a connection from
		client:1234 -> foo:2049

Olaf
--=20
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
