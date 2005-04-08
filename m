From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NAT & lockd
Date: Fri, 08 Apr 2005 09:39:14 -0400
Message-ID: <1112967554.15565.58.camel@lade.trondhjem.org>
References: <111aefd050408062546161db8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DJtiS-0000JM-PM
	for nfs@lists.sourceforge.net; Fri, 08 Apr 2005 06:40:08 -0700
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DJtiR-0002G6-0k
	for nfs@lists.sourceforge.net; Fri, 08 Apr 2005 06:40:08 -0700
To: penney@msu.edu
In-Reply-To: <111aefd050408062546161db8@mail.gmail.com>
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

fr den 08.04.2005 Klokka 09:25 (-0400) skreiv Chris Penney:

> nsm_mon_unmon: rpc failed, status=-13
> lockd: cannot monitor x.x.x.x
> 
> With our old NFS server I never got any messages.  The IP address
> x.x.x.x is that of the NAT box.  I'm curious if this means locking
> does not work behind nat or if it means something else.  Is there
> anything I can do here?  Would a 2.6.x based NAT box have a more up to
> date iptables that supports lockd?  This is non-critical, I'm just
> trying to understand.

Locking under NFSv2/v3 is not very NAT or firewall-friendly and was one
of the motivations for developing NFSv4.

The problem is that under NFSv2/v3, the protocol requires bi-directional
communication (by which I mean that the server needs to be able to
connect to the client, which is a problem for NAT as you can see above)
and requires a bunch of helper-protocols that use different ports (which
is a problem for firewalls).

Cheers,
  Trond
-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
