From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Random UDP port assignment for rpc.statd
Date: Sun, 20 Feb 2005 09:03:40 -0500
Message-ID: <1108908221.27120.26.camel@lade.trondhjem.org>
References: <20050220111312.GA3974@s>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D2rgm-000595-95
	for nfs@lists.sourceforge.net; Sun, 20 Feb 2005 06:04:00 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D2rgj-0003QX-MO
	for nfs@lists.sourceforge.net; Sun, 20 Feb 2005 06:04:00 -0800
Received: from mail-mx2.uio.no ([129.240.10.30] ident=[U2FsdGVkX18bnGGIQ5C1BNDh2NA7JkdAgtOko5W41Z0=])
	by pat.uio.no with esmtp (Exim 4.43)
	id 1D2rgd-00066z-OQ
	for nfs@lists.sourceforge.net; Sun, 20 Feb 2005 15:03:51 +0100
To: Haakon Riiser <haakon.riiser@fys.uio.no>
In-Reply-To: <20050220111312.GA3974@s>
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

su den 20.02.2005 Klokka 12:13 (+0100) skreiv Haakon Riiser:
> Why isn't it possible to specify all of statd's listening ports
> using the -p flag?  It works for the TCP port and one of the
> UDP ports, but there is always one more listening UDP port that
> is randomly assigned.  I googled around for information on this
> problem, and came up with this Debian bug report:
> 
>   http://www.mail-archive.com/debian-bugs-dist@lists.debian.org/msg11985.html
> 
> The thread ends with "I think we may have a real bug", but this
> was reported in 1.0.6, and the problem still persists in 1.0.7,
> so I was wondering if this isn't a bug after all.

rpc.statd needs some ports for communication with the portmapper and the
lockd manager on the loopback net, and this is probably what you are
seeing. There should be nothing that needs to be allowed firewall
access, though.

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
