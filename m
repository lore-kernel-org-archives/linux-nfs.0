From: Haakon Riiser <haakon.riiser@fys.uio.no>
Subject: Re: Random UDP port assignment for rpc.statd
Date: Sun, 20 Feb 2005 15:10:37 +0100
Message-ID: <20050220141037.GA7686@s>
References: <20050220111312.GA3974@s> <1108908221.27120.26.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D2rnO-00029P-Qr
	for nfs@lists.sourceforge.net; Sun, 20 Feb 2005 06:10:50 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D2rnO-00045h-4L
	for nfs@lists.sourceforge.net; Sun, 20 Feb 2005 06:10:50 -0800
Received: from mail-mx6.uio.no ([129.240.10.47] ident=[U2FsdGVkX18P81iyHdSSw7gcAx0foGcfXoJr0gsW5Nw=])
	by pat.uio.no with esmtp (Exim 4.43)
	id 1D2rnI-0007Sw-Tg
	for nfs@lists.sourceforge.net; Sun, 20 Feb 2005 15:10:45 +0100
Received: from 160.80-203-48.nextgentel.com ([80.203.48.160] helo=s.hn.org)
	by mail-mx6.uio.no with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.43)
	id 1D2rnG-000514-Ty
	for nfs@lists.sourceforge.net; Sun, 20 Feb 2005 15:10:43 +0100
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1108908221.27120.26.camel@lade.trondhjem.org>
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

[Trond Myklebust]

> su den 20.02.2005 Klokka 12:13 (+0100) skreiv Haakon Riiser:

>> Why isn't it possible to specify all of statd's listening
>> ports using the -p flag?  It works for the TCP port and one
>> of the UDP ports, but there is always one more listening UDP
>> port that is randomly assigned.  [...]

> rpc.statd needs some ports for communication with the portmapper
> and the lockd manager on the loopback net, and this is probably
> what you are seeing. There should be nothing that needs to be
> allowed firewall access, though.

Actually, I wanted to /block/ this port in the firewall, not open
for external access.  My firewall allows everything by default, and
has rules to block ports that shouldn't be visible to the world.
Should I be concerned about this port being unblocked?

-- 
 Haakon


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
