From: Trond Myklebust <trondmy@trondhjem.org>
Subject: Re: address for lockd recovery
Date: Tue, 25 Jan 2005 22:44:37 -0800
Message-ID: <1106721877.10014.18.camel@lade.trondhjem.org>
References: <20050125091649.70886.qmail@web51605.mail.yahoo.com>
	 <1106720796.10014.10.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ctgvl-00032s-QT
	for nfs@lists.sourceforge.net; Tue, 25 Jan 2005 22:45:33 -0800
Received: from adsl-207-214-87-84.dsl.snfc21.pacbell.net ([207.214.87.84] helo=lade.trondhjem.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1Ctgvl-0004sw-FJ
	for nfs@lists.sourceforge.net; Tue, 25 Jan 2005 22:45:33 -0800
To: mehta kiran <kiranmehta1981@yahoo.com>
In-Reply-To: <1106720796.10014.10.camel@lade.trondhjem.org>
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

ty den 25.01.2005 Klokka 22:26 (-0800) skreiv Trond Myklebust:
> >      Is there any issue in using notifcation
> >      messages's source address as destination
> >      address to reclaim lock. ?
> 
> If you have a multi-homed server, it does not follow that the source
> address used by rpc.statd hosts the same NFS server as the mon_name
> address.

The other common issue is that the two addresses may have different
firewalling rules.

Cheers,
  Trond

-- 
Trond Myklebust <trondmy@trondhjem.org>


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
